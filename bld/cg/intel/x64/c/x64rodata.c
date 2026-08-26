/*
 * x64rodata.c — .rodata Section Support for x86-64
 *
 * Routes read-only data (string literals, float constants, jump tables)
 * to .rodata instead of .data section. Enables W^X page protection.
 *
 * Integration: called by DGString/DGFloat in dg.c, wired via x64obj.c.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "x64rodata.h"

/* ====================================================================
 * .rodata Section State
 *
 * In a real OW integration, these become OWL section handles.
 * For now: track offsets and data in a buffer.
 * ==================================================================== */

#define RODATA_MAX  262144  /* 256K max .rodata per object */

uint8_t  rodata_buf[RODATA_MAX];
int      rodata_pos = 0;
static int      rodata_active = 0;  /* 1 = currently emitting to .rodata */

/* Label counter for .rodata entries */
static int      rodata_label_counter = 0;

/* ====================================================================
 * Section Switching
 *
 * The code generator normally emits to .data.
 * When emitting a string literal or const, switch to .rodata.
 * After emitting, switch back.
 *
 * In OWL:
 *   OWLSetSection(rodata_handle);  // switch to .rodata
 *   OWLEmitData(rodata_handle, data, len);
 *   OWLSetSection(data_handle);    // switch back
 * ==================================================================== */

void x64_switch_to_rodata(void)
{
    rodata_active = 1;
}

void x64_switch_to_data(void)
{
    rodata_active = 0;
}

/* ====================================================================
 * Emit String Literal to .rodata
 *
 * Called by DGString() in dg.c when the code generator encounters
 * a string literal like "hello world".
 *
 * Returns a label index that x64obj.c uses for RIP-relative addressing:
 *   lea rdi, [rip + .LC0]    ; R_X86_64_PC32 relocation to .rodata
 * ==================================================================== */

int x64_emit_string_literal(const char *str, int len)
{
    int label = rodata_label_counter++;
    int aligned_len = (len + 7) & ~7;   /* 8-byte align */

    if (rodata_pos + aligned_len <= RODATA_MAX) {
        memcpy(rodata_buf + rodata_pos, str, len);
        /* Zero-pad to alignment */
        if (aligned_len > len) {
            memset(rodata_buf + rodata_pos + len, 0, aligned_len - len);
        }
        rodata_pos += aligned_len;
    }

    /*
     * In OWL integration:
     *   char lbl_name[32];
     *   sprintf(lbl_name, ".LC%d", label);
     *   owl_symbol_handle sym = OWLSymbolInit(file, lbl_name);
     *   OWLEmitLabel(rodata_section, sym, OWL_TYPE_OBJECT, OWL_SYM_LOCAL);
     *   OWLEmitData(rodata_section, str, len);
     *   // pad to alignment
     *   OWLEmitData(rodata_section, zeros, aligned_len - len);
     */

    return label;
}

/* ====================================================================
 * Emit Float/Double Constant to .rodata
 *
 * Compiler-generated float constants (e.g., 3.14159) go here.
 * The code generator loads them via RIP-relative addressing:
 *   movsd xmm0, [rip + .LC1]
 * ==================================================================== */

int x64_emit_float_const(const void *data, int size)
{
    int label = rodata_label_counter++;
    int aligned_size = (size + 7) & ~7;

    if (rodata_pos + aligned_size <= RODATA_MAX) {
        memcpy(rodata_buf + rodata_pos, data, size);
        if (aligned_size > size) {
            memset(rodata_buf + rodata_pos + size, 0, aligned_size - size);
        }
        rodata_pos += aligned_size;
    }

    return label;
}

/* ====================================================================
 * Emit Jump Table to .rodata
 *
 * Switch statements with many cases use indirect jumps through
 * a table of code addresses. The table is read-only.
 *   jmp [rip + .LC2 + rax*8]
 * ==================================================================== */

int x64_emit_jump_table(const uint64_t *targets, int count)
{
    int label = rodata_label_counter++;
    int size = count * 8;

    if (rodata_pos + size <= RODATA_MAX) {
        memcpy(rodata_buf + rodata_pos, targets, size);
        rodata_pos += size;
    }

    return label;
}
