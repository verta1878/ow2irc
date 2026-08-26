/*
 * x64win64.c — Win64 (Microsoft x64) Calling Convention Implementation
 *
 * Parameter allocation, frame layout, and prologue/epilogue generation
 * for Windows x64 targets (-bt=nt64).
 *
 * Key differences from SysV (x64sysv.h):
 *   - 4 registers max (RCX,RDX,R8,R9) not 6+8
 *   - Integer and float args share the SAME 4 slots
 *   - 32-byte shadow space ALWAYS reserved by caller
 *   - No red zone
 *   - RDI/RSI are callee-saved (caller-saved on SysV!)
 *   - LLP64: sizeof(long) = 4 (not 8)
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "x64win64.h"

/* ====================================================================
 * Win64 Prologue Generation
 *
 * Standard Win64 prologue:
 *   push rbp
 *   mov rbp, rsp
 *   push rbx                  ; if used
 *   push rdi                  ; callee-saved on Win64!
 *   push rsi                  ; callee-saved on Win64!
 *   push r12-r15              ; if used
 *   sub rsp, frame_size       ; locals + alignment
 *   ; Optionally spill register args to shadow space:
 *   mov [rbp+16], rcx         ; shadow[0]
 *   mov [rbp+24], rdx         ; shadow[1]
 *   mov [rbp+32], r8          ; shadow[2]
 *   mov [rbp+40], r9          ; shadow[3]
 * ==================================================================== */

typedef struct {
    int     locals_size;
    int     callee_save_size;
    int     frame_size;         /* SUB RSP amount */
    int     num_callee_saved;
    bool    saves_rdi;          /* Win64 callee-saved, SysV caller-saved */
    bool    saves_rsi;          /* Win64 callee-saved, SysV caller-saved */
    bool    spill_args;         /* Spill register args to shadow space */
} win64_frame_t;

/*
 * Compute Win64 frame layout.
 *
 * At entry: RSP ≡ 8 (mod 16) — return address pushed by CALL.
 * After push rbp: RSP ≡ 0 (mod 16).
 * After N callee-saves: RSP ≡ (N * 8) mod 16.
 * frame_size must restore 16-byte alignment before any CALL.
 */
void win64_compute_frame(
    win64_frame_t *frame,
    int locals_size,
    int num_callee_saved_used,
    bool uses_rdi,
    bool uses_rsi,
    bool has_args)
{
    frame->saves_rdi = uses_rdi;
    frame->saves_rsi = uses_rsi;
    frame->spill_args = has_args;

    /* Count callee-saved pushes: rbp + explicit saves + rdi/rsi */
    int pushes = 1 + num_callee_saved_used;  /* rbp always pushed */
    if (uses_rdi) pushes++;
    if (uses_rsi) pushes++;

    frame->num_callee_saved = pushes - 1;  /* exclude rbp */
    frame->callee_save_size = (pushes - 1) * 8;

    /* Raw frame = locals (must be non-negative) */
    int raw = locals_size;
    if (raw < 0) raw = 0;

    /* Align: after pushes, RSP ≡ (1 + pushes) * 8 mod 16 from entry.
     * Entry RSP ≡ 8 mod 16. After push rbp + N saves:
     * If total pushes (including rbp) is even → aligned
     * If odd → 8 off */
    if ((pushes % 2) == 0) {
        frame->frame_size = (raw + 15) & ~15;
    } else {
        frame->frame_size = ((raw + 8 + 15) & ~15) - 8;
        if (frame->frame_size < raw) frame->frame_size += 16;
    }

    frame->locals_size = locals_size;
}

/*
 * Compute caller's outgoing arg area size.
 * Win64: ALWAYS at least 32 bytes (shadow space).
 * Plus 8 bytes per stack arg beyond the 4 register args.
 */
int win64_caller_arg_area(int total_args)
{
    int stack_args = total_args > 4 ? total_args - 4 : 0;
    int size = WIN64_SHADOW_SPACE + (stack_args * 8);
    /* Align to 16 bytes */
    return (size + 15) & ~15;
}

/* Non-inline version for external linkage */
void win64_call_init(win64_call_state_t *state)
{
    state->next_arg = 0;
    state->stack_offset = WIN64_SHADOW_SPACE;
    state->num_stack_args = 0;
}
