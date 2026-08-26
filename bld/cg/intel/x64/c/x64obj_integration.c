/*
 * x64obj_integration.c — Phase 6-11 Integration Points for x64obj.c
 *
 * This file documents and implements the changes needed in x64obj.c
 * to wire in phases 6-11. Each section shows the exact location
 * in X64ObjFini() where code must be inserted.
 *
 * x64obj.c emits ELF64 directly (no OWL). It reads the OMF
 * output from the 386 code generator, patches instructions for
 * x64 (REX prefixes, RIP-relative, 64-bit operands), and writes
 * a complete ELF64 .o file.
 *
 * Integration is done by adding new sections to the ELF output
 * and modifying the section header table.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "x64ehframe.h"
#include "x64rodata.h"
#include "x64seh.h"

/* ====================================================================
 * INTEGRATION POINT 1: Section String Table
 *
 * Location: X64ObjFini(), around line 861
 * Currently defines: .text .strtab .symtab .data .rela.text .rela.data
 *
 * ADD these section names to strtab:
 * ==================================================================== */

static void add_section_strings(char *strtab, int *st_len)
{
    /* Phase 6: .eh_frame */
    int str_ehframe = *st_len;
    memcpy(strtab + *st_len, ".eh_frame", 10);
    *st_len += 10;

    /* Phase 7: .rodata */
    int str_rodata = *st_len;
    memcpy(strtab + *st_len, ".rodata", 8);
    *st_len += 8;

    /* Phase 9: .pdata + .xdata (Win64 only) */
#ifdef TARGET_WIN64
    int str_pdata = *st_len;
    memcpy(strtab + *st_len, ".pdata", 7);
    *st_len += 7;

    int str_xdata = *st_len;
    memcpy(strtab + *st_len, ".xdata", 7);
    *st_len += 7;
#endif

    /* Phase 11: .note.gnu.property (Linux optional) */
    int str_note = *st_len;
    memcpy(strtab + *st_len, ".note.gnu.property", 19);
    *st_len += 19;

    (void)str_ehframe; (void)str_rodata; (void)str_note;
}

/* ====================================================================
 * INTEGRATION POINT 2: Section Headers
 *
 * Location: X64ObjFini(), around line 931-939
 * Currently creates: null, .text, .data, .bss, .symtab,
 *                    [.rela.text], [.rela.data], .strtab
 *
 * ADD section headers for new sections.
 * ==================================================================== */

/* ELF section header for .eh_frame */
static void emit_ehframe_shdr(FILE *fp, int name_offset, size_t file_offset,
                               size_t size, int text_section_idx)
{
    /* Elf64_Shdr for .eh_frame */
    uint8_t shdr[64];
    memset(shdr, 0, 64);

    /* sh_name */
    uint32_t val32 = name_offset;
    memcpy(shdr + 0, &val32, 4);

    /* sh_type = SHT_PROGBITS (1) */
    val32 = 1;
    memcpy(shdr + 4, &val32, 4);

    /* sh_flags = SHF_ALLOC (2) */
    uint64_t val64 = 2;
    memcpy(shdr + 8, &val64, 8);

    /* sh_addr = 0 */
    /* sh_offset */
    memcpy(shdr + 24, &file_offset, 8);

    /* sh_size */
    memcpy(shdr + 32, &size, 8);

    /* sh_link = text section (for relocations) */
    val32 = text_section_idx;
    memcpy(shdr + 40, &val32, 4);

    /* sh_addralign = 8 */
    val64 = 8;
    memcpy(shdr + 48, &val64, 8);

    fwrite(shdr, 1, 64, fp);
}

/* ELF section header for .rodata */
static void emit_rodata_shdr(FILE *fp, int name_offset, size_t file_offset,
                              size_t size)
{
    uint8_t shdr[64];
    memset(shdr, 0, 64);

    uint32_t val32 = name_offset;
    memcpy(shdr + 0, &val32, 4);

    /* SHT_PROGBITS */
    val32 = 1;
    memcpy(shdr + 4, &val32, 4);

    /* SHF_ALLOC only — NO SHF_WRITE */
    uint64_t val64 = 2;
    memcpy(shdr + 8, &val64, 8);

    memcpy(shdr + 24, &file_offset, 8);
    memcpy(shdr + 32, &size, 8);

    /* sh_addralign = 8 */
    val64 = 8;
    memcpy(shdr + 48, &val64, 8);

    fwrite(shdr, 1, 64, fp);
}

/* ====================================================================
 * INTEGRATION POINT 3: STT_FILE Symbol
 *
 * Location: X64ObjFini(), symbol table emission (~line 974)
 * Currently emits: [0] null, [1] .text, [2] .data, [3] .bss,
 *                  then publics, then externs
 *
 * ADD: STT_FILE symbol BEFORE section symbols (index 1)
 * ==================================================================== */

static void emit_file_symbol(FILE *fp, const char *filename, int strtab_offset)
{
    /* Elf64_Sym for STT_FILE */
    uint8_t sym[24];
    memset(sym, 0, 24);

    /* st_name */
    uint32_t val32 = strtab_offset;
    memcpy(sym + 0, &val32, 4);

    /* st_info = ELF64_ST_INFO(STB_LOCAL, STT_FILE) = (0 << 4) | 4 = 4 */
    sym[4] = 4;

    /* st_other = 0 (default visibility) */

    /* st_shndx = SHN_ABS (0xFFF1) */
    uint16_t val16 = 0xFFF1;
    memcpy(sym + 6, &val16, 2);

    fwrite(sym, 1, 24, fp);
}

/* ====================================================================
 * INTEGRATION POINT 4: ELF File Layout
 *
 * Current layout in X64ObjFini():
 *   Elf64_Ehdr
 *   .text (code)
 *   .data (initialized data)
 *   .symtab
 *   .rela.text (code relocations)
 *   .rela.data (data relocations)
 *   .strtab (string table)
 *   Section headers
 *
 * NEW layout with phases 6-11:
 *   Elf64_Ehdr
 *   .text (code)
 *   .rodata (Phase 7 — read-only data)
 *   .data (initialized data)
 *   .bss (uninitialized data)
 *   .eh_frame (Phase 6 — unwinding)
 *   .symtab (with STT_FILE — Phase 6)
 *   .rela.text (code relocations)
 *   .rela.data (data relocations)
 *   .strtab (extended string table)
 *   Section headers (more entries)
 *
 * For Win64 PE (Phase 8+9):
 *   PE32+ header
 *   .text
 *   .rdata (.rodata equivalent)
 *   .data
 *   .bss
 *   .pdata (Phase 9 — RUNTIME_FUNCTION array)
 *   .xdata (Phase 9 — UNWIND_INFO structures)
 *
 * The key change: num_shdrs increases from 8 to 10-11.
 * All offsets after .text must be recalculated.
 * ==================================================================== */

/* ====================================================================
 * INTEGRATION POINT 5: Prologue/Epilogue Hooks
 *
 * Location: wherever x64obj.c patches prologue instructions
 *
 * Currently x64obj.c patches:
 *   push rbp → (keep, add REX if needed)
 *   mov rbp, rsp → (keep)
 *   sub rsp, N → (patch immediate for alignment)
 *   push callee-saved → (add REX for R12-R15)
 *
 * ADD: call eh_frame_*() / seh_*() for each prologue instruction:
 *
 *   // After emitting "push rbp":
 *   eh_frame_push_reg(DWARF_RBP, code_offset);
 *   eh_frame_set_cfa_offset(16, code_offset);
 *   seh_push_reg(UNW_REG_RBP, code_offset);
 *
 *   // After emitting "mov rbp, rsp":
 *   eh_frame_set_cfa_register(DWARF_RBP, 16, code_offset);
 *   seh_set_frame_reg(UNW_REG_RBP, 0, code_offset);
 *
 *   // After emitting "sub rsp, N":
 *   seh_alloc_stack(N, code_offset);
 *   // (eh_frame doesn't need this if using RBP frame)
 *
 *   // After emitting "push rbx":
 *   eh_frame_push_reg(DWARF_RBX, code_offset);
 *   seh_push_reg(UNW_REG_RBX, code_offset);
 *
 * The code_offset is the byte position within the function's
 * .text output, measured from the function's start label.
 * ==================================================================== */

/* ====================================================================
 * INTEGRATION POINT 6: Target Selection
 *
 * Location: X64ObjInit() or compiler driver
 *
 * Phase 8 (Win64) adds a new target:
 *   -bt=linux64  → SysV ABI, .eh_frame, LP64, ELF64 output
 *   -bt=nt64     → Win64 ABI, .pdata/.xdata, LLP64, PE32+ output
 *
 * The switch affects:
 *   - Calling convention (x64sysv.h vs x64win64.h)
 *   - Unwinding format (x64ehframe.h vs x64seh.h)
 *   - Type model (long = 8 vs long = 4)
 *   - Object format (ELF64 vs PE32+/COFF)
 *   - Callee-saved registers (RDI/RSI differ!)
 *
 * Implementation: check cgtargsw.h CGSW_X64_SYSV_ABI flag
 *   if (target_switches & CGSW_X64_SYSV_ABI) {
 *       // Linux: SysV + .eh_frame + LP64
 *   } else {
 *       // Windows: Win64 + .pdata/.xdata + LLP64
 *   }
 * ==================================================================== */

/* ====================================================================
 * INTEGRATION POINT 7: C Library Startup
 *
 * Location: linker (wlink) or standalone startup object
 *
 * Phase 11 provides:
 *   x64_emit_linux_start()  → generates _start machine code
 *   x64_emit_win64_start()  → generates mainCRTStartup machine code
 *   x64_emit_setjmp_sysv()  → generates setjmp machine code
 *   x64_emit_longjmp_sysv() → generates longjmp machine code
 *
 * These are compiled into crt0_x64.o (Linux) or crt0_nt64.o (Windows)
 * and linked automatically by wlink when targeting x64.
 *
 * Build process:
 *   1. Compile x64clib.c with the host compiler (gcc or wcc386)
 *   2. Run: output startup machine code to crt0_x64.o
 *   3. wlink includes crt0_x64.o when linking x64 ELF executables
 *   4. wlink includes crt0_nt64.o when linking x64 PE executables
 * ==================================================================== */
