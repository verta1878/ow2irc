/*
 * x64ehframe.c — .eh_frame Implementation for x86-64 ELF Objects
 *
 * Emits DWARF .eh_frame section into ELF64 objects produced by x64obj.c.
 * Enables GDB backtraces and exception handling for wcc64 binaries.
 *
 * Integration: x64obj.c calls eh_frame_*() during prologue/epilogue.
 * Output: .eh_frame section appended to ELF object via OWL.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "x64ehframe.h"

/* ====================================================================
 * ULEB128 / SLEB128 Encoding
 *
 * DWARF uses variable-length integer encoding.
 * ULEB128: unsigned, 7 bits per byte, MSB = continue flag
 * SLEB128: signed, 7 bits per byte, sign-extended
 * ==================================================================== */

/* Encode unsigned value as ULEB128, return bytes written */
static int encode_uleb128(uint8_t *buf, uint64_t value)
{
    int n = 0;
    do {
        uint8_t byte = value & 0x7F;
        value >>= 7;
        if (value != 0) byte |= 0x80;  /* more bytes follow */
        buf[n++] = byte;
    } while (value != 0);
    return n;
}

/* Encode signed value as SLEB128, return bytes written */
static int encode_sleb128(uint8_t *buf, int64_t value)
{
    int n = 0;
    int more = 1;
    while (more) {
        uint8_t byte = value & 0x7F;
        value >>= 7;
        /* Sign bit of byte is bit 6 */
        if ((value == 0 && !(byte & 0x40)) ||
            (value == -1 && (byte & 0x40))) {
            more = 0;
        } else {
            byte |= 0x80;
        }
        buf[n++] = byte;
    }
    return n;
}

/* ====================================================================
 * .eh_frame Buffer — collects CIE + FDEs during compilation
 * ==================================================================== */

#define EH_FRAME_MAX    65536   /* 64K max .eh_frame per object file */

uint8_t  eh_buf[EH_FRAME_MAX];
int      eh_pos = 0;
static int      eh_cie_offset = -1;     /* Offset of CIE in buffer */
static int      eh_current_fde = -1;    /* Start of current FDE */
static int      eh_last_code_offset = 0;/* Last DW_CFA_advance_loc position */

/* Append bytes to .eh_frame buffer */
static void eh_emit(const uint8_t *data, int len)
{
    if (eh_pos + len <= EH_FRAME_MAX) {
        memcpy(eh_buf + eh_pos, data, len);
        eh_pos += len;
    }
}

static void eh_emit_byte(uint8_t b) { eh_emit(&b, 1); }

static void eh_emit_u16(uint16_t v) { eh_emit((uint8_t*)&v, 2); }

static void eh_emit_u32(uint32_t v) { eh_emit((uint8_t*)&v, 4); }

static void eh_emit_u64(uint64_t v) { eh_emit((uint8_t*)&v, 8); }

static void eh_emit_uleb128(uint64_t v) {
    uint8_t tmp[16];
    int n = encode_uleb128(tmp, v);
    eh_emit(tmp, n);
}

static void eh_emit_sleb128(int64_t v) {
    uint8_t tmp[16];
    int n = encode_sleb128(tmp, v);
    eh_emit(tmp, n);
}

/* ====================================================================
 * CIE — Common Information Entry
 *
 * Standard CIE for x86-64 SysV ABI:
 *   code_alignment_factor = 1
 *   data_alignment_factor = -8
 *   return_address_register = 16 (RA)
 *   Initial rules: CFA = RSP + 8, RA at CFA - 8
 * ==================================================================== */

void eh_frame_init(void)
{
    eh_pos = 0;
    eh_cie_offset = -1;
    eh_current_fde = -1;
    eh_last_code_offset = 0;

    /* Emit CIE */
    eh_cie_offset = eh_pos;
    int cie_start = eh_pos;

    eh_emit_u32(0);         /* length placeholder */
    eh_emit_u32(0);         /* CIE ID = 0 */
    eh_emit_byte(1);        /* version */

    /* Augmentation string "zR\0" — sized + PC-relative FDE encoding */
    eh_emit_byte('z');
    eh_emit_byte('R');
    eh_emit_byte(0);

    eh_emit_uleb128(1);     /* code_alignment_factor */
    eh_emit_sleb128(-8);    /* data_alignment_factor */
    eh_emit_uleb128(16);    /* return_address_register (RA) */

    /* Augmentation data */
    eh_emit_uleb128(1);     /* augmentation data length */
    eh_emit_byte(0x1B);     /* DW_EH_PE_pcrel | DW_EH_PE_sdata4 */

    /* Initial instructions */
    /* DW_CFA_def_cfa RSP(7), 8 */
    eh_emit_byte(DW_CFA_def_cfa);
    eh_emit_uleb128(DWARF_RSP);
    eh_emit_uleb128(8);

    /* DW_CFA_offset RA(16), 1 → saved at CFA - 8 */
    eh_emit_byte(DW_CFA_offset | DWARF_RA);
    eh_emit_uleb128(1);     /* 1 * |data_alignment| = 8 bytes from CFA */

    /* Pad to 8-byte alignment */
    while ((eh_pos - cie_start) % 8 != 0) {
        eh_emit_byte(DW_CFA_nop);
    }

    /* Patch CIE length */
    uint32_t cie_len = eh_pos - cie_start - 4;
    memcpy(eh_buf + cie_start, &cie_len, 4);
}

/* ====================================================================
 * FDE — Frame Description Entry (one per function)
 * ==================================================================== */

void eh_frame_begin_function(const char *name, uint64_t addr, uint64_t size)
{
    (void)name;  /* Used for debug, not emitted in .eh_frame */

    eh_current_fde = eh_pos;
    eh_last_code_offset = 0;

    int fde_start = eh_pos;

    eh_emit_u32(0);         /* length placeholder */

    /* CIE offset: distance from this field to start of CIE */
    uint32_t cie_delta = eh_pos - eh_cie_offset;
    eh_emit_u32(cie_delta);

    /* PC begin (will be relocated) */
    eh_emit_u32((uint32_t)addr);    /* sdata4, PC-relative */

    /* PC range */
    eh_emit_u32((uint32_t)size);

    /* Augmentation data length (0 for basic FDE) */
    eh_emit_uleb128(0);
}

/* ====================================================================
 * Prologue Event Recording
 *
 * Called by x64obj.c as each prologue instruction is emitted.
 * Each call produces one or more DW_CFA_* instructions in the FDE.
 * ==================================================================== */

/* Emit DW_CFA_advance_loc to advance the code position */
static void eh_advance_loc(int code_offset)
{
    int delta = code_offset - eh_last_code_offset;
    if (delta <= 0) return;
    eh_last_code_offset = code_offset;

    if (delta <= 63) {
        /* DW_CFA_advance_loc: delta in low 6 bits */
        eh_emit_byte(DW_CFA_advance_loc | (uint8_t)delta);
    } else if (delta <= 255) {
        eh_emit_byte(DW_CFA_advance_loc1);
        eh_emit_byte((uint8_t)delta);
    } else if (delta <= 65535) {
        eh_emit_byte(DW_CFA_advance_loc2);
        eh_emit_u16((uint16_t)delta);
    } else {
        eh_emit_byte(DW_CFA_advance_loc4);
        eh_emit_u32((uint32_t)delta);
    }
}

void eh_frame_push_reg(int dwarf_reg, int code_offset)
{
    /* push rbp → CFA offset increases by 8, register saved */
    eh_advance_loc(code_offset);

    /* DW_CFA_offset: register saved at CFA - N */
    if (dwarf_reg <= 63) {
        eh_emit_byte(DW_CFA_offset | (uint8_t)dwarf_reg);
    } else {
        eh_emit_byte(DW_CFA_offset_extended);
        eh_emit_uleb128(dwarf_reg);
    }
    /* Offset from CFA in data_alignment units */
    /* Each push adds 8 bytes; data_alignment = -8 */
    /* So offset = (number of pushes) */
    eh_emit_uleb128(1);     /* Caller updates CFA separately */
}

void eh_frame_set_cfa_register(int dwarf_reg, int offset, int code_offset)
{
    /* mov rbp, rsp → CFA is now RBP + offset */
    eh_advance_loc(code_offset);
    eh_emit_byte(DW_CFA_def_cfa);
    eh_emit_uleb128(dwarf_reg);
    eh_emit_uleb128(offset);
}

void eh_frame_set_cfa_offset(int offset, int code_offset)
{
    /* sub rsp, N or push → CFA offset changes */
    eh_advance_loc(code_offset);
    eh_emit_byte(DW_CFA_def_cfa_offset);
    eh_emit_uleb128(offset);
}

void eh_frame_save_reg(int dwarf_reg, int cfa_offset, int code_offset)
{
    /* Register saved at specific CFA offset (e.g., mov [rbp-8], rbx) */
    eh_advance_loc(code_offset);
    eh_emit_byte(DW_CFA_offset_extended);
    eh_emit_uleb128(dwarf_reg);
    /* Convert byte offset to data_alignment units */
    eh_emit_uleb128(cfa_offset / 8);
}

void eh_frame_end_function(void)
{
    if (eh_current_fde < 0) return;

    /* Pad FDE to 8-byte alignment */
    while ((eh_pos - eh_current_fde) % 8 != 0) {
        eh_emit_byte(DW_CFA_nop);
    }

    /* Patch FDE length */
    uint32_t fde_len = eh_pos - eh_current_fde - 4;
    memcpy(eh_buf + eh_current_fde, &fde_len, 4);

    eh_current_fde = -1;
}

/* ====================================================================
 * Finalize — emit .eh_frame via OWL
 * ==================================================================== */

void eh_frame_finalize(void)
{
    /* Emit terminator (zero-length CIE) */
    eh_emit_u32(0);

    /* At this point, eh_buf[0..eh_pos-1] contains the complete
     * .eh_frame section. Call OWL to emit it:
     *
     *   owl_section_handle eh_section;
     *   eh_section = OWLSectionInit(file, ".eh_frame",
     *       OWL_SECTION_INFO, 8);  // 8-byte alignment
     *   OWLEmitData(eh_section, (const char*)eh_buf, eh_pos);
     *   OWLSectionFini(eh_section);
     *
     * The integration point is in x64obj.c's finalization routine.
     */
}

/* ====================================================================
 * STT_FILE Symbol
 * ==================================================================== */

void eh_frame_emit_file_symbol(const char *filename)
{
    /* Emit via OWL:
     *   owl_symbol_handle file_sym = OWLSymbolInit(file, filename);
     *   OWLEmitLabel(text_section, file_sym,
     *       OWL_TYPE_FILE, OWL_SYM_LOCAL);
     *
     * This creates a STT_FILE entry in .symtab that GDB uses
     * to map addresses to source files.
     */
    (void)filename;
}

void eh_frame_emit_gnu_property(void)
{
    /* .note.gnu.property — minimal, marks no special ISA features.
     * Can be omitted for now; modern linkers add it automatically.
     */
}
