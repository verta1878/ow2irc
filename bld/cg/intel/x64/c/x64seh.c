/*
 * x64seh.c — Win64 Structured Exception Handling (.pdata/.xdata)
 *
 * Emits RUNTIME_FUNCTION entries (.pdata) and UNWIND_INFO structures
 * (.xdata) for Win64 PE objects. Required for exception handling and
 * debugger stack traces on Windows x64.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "x64seh.h"

/* ====================================================================
 * .xdata Buffer — collects UNWIND_INFO + UNWIND_CODE entries
 * ==================================================================== */

#define XDATA_MAX   32768
#define PDATA_MAX   4096    /* Max 341 functions (12 bytes each) */
#define MAX_UNWIND_CODES 32

static uint8_t  xdata_buf[XDATA_MAX];
static int      xdata_pos = 0;

static uint8_t  pdata_buf[PDATA_MAX];
static int      pdata_pos = 0;

/* Current function's unwind codes (built in reverse prologue order) */
static UNWIND_CODE  current_codes[MAX_UNWIND_CODES];
static int          current_code_count = 0;
static uint32_t     current_begin_rva = 0;
static uint8_t      current_prolog_size = 0;
static int          current_frame_reg = 0;
static int          current_frame_offset = 0;

void seh_init(void)
{
    xdata_pos = 0;
    pdata_pos = 0;
}

void seh_begin_function(const char *name, uint32_t begin_rva)
{
    (void)name;
    current_begin_rva = begin_rva;
    current_code_count = 0;
    current_prolog_size = 0;
    current_frame_reg = 0;
    current_frame_offset = 0;
}

/* ====================================================================
 * Record Prologue Operations
 *
 * Called as each prologue instruction is emitted.
 * Codes are stored and later written in REVERSE order.
 * ==================================================================== */

static void add_code(uint8_t offset, uint8_t op, uint8_t info)
{
    if (current_code_count < MAX_UNWIND_CODES) {
        current_codes[current_code_count].CodeOffset = offset;
        current_codes[current_code_count].UnwindOp = op;
        current_codes[current_code_count].OpInfo = info;
        current_code_count++;
        if (offset > current_prolog_size) {
            current_prolog_size = offset;
        }
    }
}

void seh_push_reg(int win64_reg, uint8_t code_offset)
{
    /* UWOP_PUSH_NONVOL: OpInfo = register number */
    add_code(code_offset, UWOP_PUSH_NONVOL, (uint8_t)win64_reg);
}

void seh_alloc_stack(uint32_t size, uint8_t code_offset)
{
    if (size <= 128 && (size % 8) == 0) {
        /* UWOP_ALLOC_SMALL: OpInfo = (size - 8) / 8 */
        add_code(code_offset, UWOP_ALLOC_SMALL, (uint8_t)((size - 8) / 8));
    } else if (size <= 512 * 1024 - 8) {
        /* UWOP_ALLOC_LARGE with 1 extra slot: size / 8 */
        add_code(code_offset, UWOP_ALLOC_LARGE, 0);
        /* Extra slot follows — handled in emit */
    } else {
        /* UWOP_ALLOC_LARGE with 2 extra slots: full 32-bit size */
        add_code(code_offset, UWOP_ALLOC_LARGE, 1);
    }
}

void seh_set_frame_reg(int win64_reg, uint8_t offset, uint8_t code_offset)
{
    /* UWOP_SET_FPREG: OpInfo = 0 (offset encoded in UNWIND_INFO header) */
    add_code(code_offset, UWOP_SET_FPREG, 0);
    current_frame_reg = win64_reg;
    current_frame_offset = offset / 16;  /* Scaled by 16 */
}

void seh_save_reg(int win64_reg, uint32_t stack_offset, uint8_t code_offset)
{
    if (stack_offset <= 8 * 65535) {
        add_code(code_offset, UWOP_SAVE_NONVOL, (uint8_t)win64_reg);
    } else {
        add_code(code_offset, UWOP_SAVE_NONVOL_FAR, (uint8_t)win64_reg);
    }
}

void seh_save_xmm(int xmm_reg, uint32_t stack_offset, uint8_t code_offset)
{
    if (stack_offset <= 16 * 65535) {
        add_code(code_offset, UWOP_SAVE_XMM128, (uint8_t)xmm_reg);
    } else {
        add_code(code_offset, UWOP_SAVE_XMM128_FAR, (uint8_t)xmm_reg);
    }
}

/* ====================================================================
 * End Function — emit UNWIND_INFO to .xdata and RUNTIME_FUNCTION to .pdata
 * ==================================================================== */

void seh_end_function(uint32_t end_rva)
{
    /* Emit UNWIND_INFO to .xdata */
    int unwind_rva = xdata_pos;

    /* UNWIND_INFO header */
    UNWIND_INFO info;
    info.Version = 1;
    info.Flags = UNW_FLAG_NHANDLER;
    info.SizeOfProlog = current_prolog_size;
    info.CountOfCodes = (uint8_t)current_code_count;
    info.FrameRegister = (uint8_t)current_frame_reg;
    info.FrameOffset = (uint8_t)current_frame_offset;

    /* Emit header (4 bytes) */
    uint8_t hdr[4];
    hdr[0] = (info.Version & 0x7) | ((info.Flags & 0x1F) << 3);
    hdr[1] = info.SizeOfProlog;
    hdr[2] = info.CountOfCodes;
    hdr[3] = (info.FrameRegister & 0xF) | ((info.FrameOffset & 0xF) << 4);

    if (xdata_pos + 4 + current_code_count * 2 <= XDATA_MAX) {
        memcpy(xdata_buf + xdata_pos, hdr, 4);
        xdata_pos += 4;

        /* Emit UNWIND_CODEs in REVERSE prologue order */
        for (int i = current_code_count - 1; i >= 0; i--) {
            uint8_t code[2];
            code[0] = current_codes[i].CodeOffset;
            code[1] = (current_codes[i].UnwindOp & 0xF) |
                      ((current_codes[i].OpInfo & 0xF) << 4);
            memcpy(xdata_buf + xdata_pos, code, 2);
            xdata_pos += 2;
        }

        /* Pad to 4-byte alignment */
        if (xdata_pos % 4 != 0) {
            xdata_buf[xdata_pos++] = 0;
            xdata_buf[xdata_pos++] = 0;
        }
    }

    /* Emit RUNTIME_FUNCTION to .pdata */
    if (pdata_pos + 12 <= PDATA_MAX) {
        RUNTIME_FUNCTION rf;
        rf.BeginAddress = current_begin_rva;
        rf.EndAddress = end_rva;
        rf.UnwindInfoAddress = (uint32_t)unwind_rva;
        memcpy(pdata_buf + pdata_pos, &rf, 12);
        pdata_pos += 12;
    }
}

void seh_finalize(void)
{
    /* Emit .pdata and .xdata sections via OWL:
     *
     *   owl_section_handle pdata_sec = OWLSectionInit(file, ".pdata",
     *       OWL_SECTION_DATA, 4);
     *   OWLEmitData(pdata_sec, (const char*)pdata_buf, pdata_pos);
     *   OWLSectionFini(pdata_sec);
     *
     *   owl_section_handle xdata_sec = OWLSectionInit(file, ".xdata",
     *       OWL_SECTION_DATA, 4);
     *   OWLEmitData(xdata_sec, (const char*)xdata_buf, xdata_pos);
     *   OWLSectionFini(xdata_sec);
     *
     * Plus relocations from .pdata to .text and .xdata.
     */
}
