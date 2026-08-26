/*
 * x64clib.c — x86-64 C Library Support
 *
 * Platform-specific startup code and runtime functions for x64.
 * Generates _start (Linux) or mainCRTStartup (Win64) entry points.
 * Implements setjmp/longjmp and va_list helpers.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "x64clib.h"
#include "x64asm.h"

/* ====================================================================
 * Linux ELF _start Entry Point
 *
 * Generates the startup code that bridges kernel → main().
 * The kernel places argc, argv, envp on the stack before jumping
 * to _start. We extract them and call main().
 * ==================================================================== */

/*
 * Emit Linux _start function (machine code):
 *
 *   xor rbp, rbp          ; ABI: clear frame pointer at deepest frame
 *   pop rdi               ; argc (first arg to main)
 *   mov rsi, rsp          ; argv = current stack pointer
 *   lea rdx, [rsi+rdi*8+8]; envp = argv + argc*8 + 8 (skip NULL)
 *   and rsp, -16          ; align stack to 16 bytes
 *   call main             ; main(argc, argv, envp)
 *   mov edi, eax          ; exit code = main's return value
 *   mov eax, 60           ; __NR_exit
 *   syscall               ; exit(return_value)
 */
int x64_emit_linux_start(uint8_t *buf)
{
    int n = 0;

    /* xor ebp, ebp — clear frame pointer */
    n += x64_encode_xor_rr(buf + n, REG_RBP, REG_RBP);

    /* pop rdi — argc */
    n += x64_encode_pop(buf + n, REG_RDI);

    /* mov rsi, rsp — argv */
    n += x64_encode_mov_rr(buf + n, REG_RSI, REG_RSP, OPSZ_64);

    /* lea rdx, [rsi + rdi*8 + 8] — envp
     * This needs SIB encoding: base=RSI, index=RDI, scale=8, disp=8
     * REX.W 8D 54 FE 08 */
    buf[n++] = 0x48;  /* REX.W */
    buf[n++] = 0x8D;  /* LEA */
    buf[n++] = 0x54;  /* ModRM: mod=01, reg=RDX(2), rm=100(SIB) */
    buf[n++] = 0xFE;  /* SIB: scale=8(11), index=RDI(111), base=RSI(110) */
    buf[n++] = 0x08;  /* disp8 = 8 */

    /* and rsp, -16 — align stack */
    buf[n++] = 0x48;  /* REX.W */
    buf[n++] = 0x83;  /* AND r/m64, imm8 */
    buf[n++] = 0xE4;  /* ModRM: mod=11, reg=/4(AND), rm=RSP(100) */
    buf[n++] = 0xF0;  /* -16 */

    /* call main — rel32 placeholder (linker fills in) */
    n += x64_encode_call_rel32(buf + n, 0);  /* R_X86_64_PLT32 reloc */

    /* mov edi, eax — exit code */
    n += x64_encode_mov_rr(buf + n, REG_RDI, REG_RAX, OPSZ_32);

    /* mov eax, 60 — __NR_exit */
    n += x64_encode_mov_ri(buf + n, REG_RAX, 60, OPSZ_32);

    /* syscall */
    n += x64_encode_syscall(buf + n);

    return n;
}

/* ====================================================================
 * Win64 mainCRTStartup Entry Point
 *
 * Minimal startup for console applications linking against msvcrt.dll.
 * Calls __getmainargs to get argc/argv, then calls main().
 * ==================================================================== */

/*
 * Emit Win64 mainCRTStartup:
 *
 *   sub rsp, 56           ; shadow space (32) + locals (24), aligned
 *   lea rcx, [rsp+32]     ; &argc
 *   lea rdx, [rsp+36]     ; &argv (pointer)
 *   lea r8,  [rsp+40]     ; &envp (pointer)
 *   xor r9d, r9d          ; _dowildcard = 0
 *   call __getmainargs
 *   mov ecx, [rsp+32]     ; argc
 *   mov rdx, [rsp+36]     ; argv
 *   mov r8,  [rsp+40]     ; envp
 *   call main
 *   mov ecx, eax          ; exit code
 *   call exit
 *   int 3                 ; should never reach here
 */
int x64_emit_win64_start(uint8_t *buf)
{
    int n = 0;

    /* sub rsp, 56 — shadow(32) + 3 locals(24), 16-byte aligned */
    n += x64_encode_sub_ri(buf + n, REG_RSP, 56);

    /* Placeholder: the actual __getmainargs and main calls
     * need relocations that the linker resolves.
     * We emit the instruction skeleton here. */

    /* For now: minimal direct-to-main path */
    /* xor ecx, ecx — argc = 0 */
    n += x64_encode_xor_rr(buf + n, REG_RCX, REG_RCX);

    /* xor edx, edx — argv = NULL */
    n += x64_encode_xor_rr(buf + n, REG_RDX, REG_RDX);

    /* call main */
    n += x64_encode_call_rel32(buf + n, 0);

    /* mov ecx, eax — exit code */
    n += x64_encode_mov_rr(buf + n, REG_RCX, REG_RAX, OPSZ_32);

    /* call exit */
    n += x64_encode_call_rel32(buf + n, 0);

    /* int 3 — breakpoint trap (unreachable) */
    buf[n++] = 0xCC;

    return n;
}

/* ====================================================================
 * setjmp — Save Callee-Saved Registers
 *
 * SysV: save RBX, RBP, R12-R15, RSP, RIP to jmp_buf
 * Win64: save RBX, RBP, RDI, RSI, R12-R15, RSP, RIP, XMM6-XMM15
 *
 * Returns bytes of machine code written.
 * ==================================================================== */

int x64_emit_setjmp_sysv(uint8_t *buf)
{
    int n = 0;

    /* jmp_buf is in RDI (first arg, SysV) */

    /* mov [rdi+0], rbx */
    buf[n++] = 0x48; buf[n++] = 0x89; buf[n++] = 0x1F; /* mov [rdi], rbx */

    /* mov [rdi+8], rbp */
    buf[n++] = 0x48; buf[n++] = 0x89; buf[n++] = 0x6F; buf[n++] = 0x08;

    /* mov [rdi+16], r12 */
    buf[n++] = 0x4C; buf[n++] = 0x89; buf[n++] = 0x67; buf[n++] = 0x10;

    /* mov [rdi+24], r13 */
    buf[n++] = 0x4C; buf[n++] = 0x89; buf[n++] = 0x6F; buf[n++] = 0x18;

    /* mov [rdi+32], r14 */
    buf[n++] = 0x4C; buf[n++] = 0x89; buf[n++] = 0x77; buf[n++] = 0x20;

    /* mov [rdi+40], r15 */
    buf[n++] = 0x4C; buf[n++] = 0x89; buf[n++] = 0x7F; buf[n++] = 0x28;

    /* lea rax, [rsp+8] — RSP value at call site (skip return address) */
    buf[n++] = 0x48; buf[n++] = 0x8D; buf[n++] = 0x44; buf[n++] = 0x24;
    buf[n++] = 0x08;

    /* mov [rdi+48], rax — save RSP */
    buf[n++] = 0x48; buf[n++] = 0x89; buf[n++] = 0x47; buf[n++] = 0x30;

    /* mov rax, [rsp] — return address */
    buf[n++] = 0x48; buf[n++] = 0x8B; buf[n++] = 0x04; buf[n++] = 0x24;

    /* mov [rdi+56], rax — save RIP */
    buf[n++] = 0x48; buf[n++] = 0x89; buf[n++] = 0x47; buf[n++] = 0x38;

    /* xor eax, eax — return 0 */
    n += x64_encode_xor_rr(buf + n, REG_RAX, REG_RAX);

    /* ret */
    n += x64_encode_ret(buf + n);

    return n;
}

/* ====================================================================
 * longjmp — Restore Callee-Saved Registers and Jump
 * ==================================================================== */

int x64_emit_longjmp_sysv(uint8_t *buf)
{
    int n = 0;

    /* jmp_buf in RDI, val in ESI (SysV) */

    /* mov rbx, [rdi+0] */
    buf[n++] = 0x48; buf[n++] = 0x8B; buf[n++] = 0x1F;

    /* mov rbp, [rdi+8] */
    buf[n++] = 0x48; buf[n++] = 0x8B; buf[n++] = 0x6F; buf[n++] = 0x08;

    /* mov r12, [rdi+16] */
    buf[n++] = 0x4C; buf[n++] = 0x8B; buf[n++] = 0x67; buf[n++] = 0x10;

    /* mov r13, [rdi+24] */
    buf[n++] = 0x4C; buf[n++] = 0x8B; buf[n++] = 0x6F; buf[n++] = 0x18;

    /* mov r14, [rdi+32] */
    buf[n++] = 0x4C; buf[n++] = 0x8B; buf[n++] = 0x77; buf[n++] = 0x20;

    /* mov r15, [rdi+40] */
    buf[n++] = 0x4C; buf[n++] = 0x8B; buf[n++] = 0x7F; buf[n++] = 0x28;

    /* mov rsp, [rdi+48] — restore stack */
    buf[n++] = 0x48; buf[n++] = 0x8B; buf[n++] = 0x67; buf[n++] = 0x30;

    /* mov rax, rsi — return value */
    buf[n++] = 0x48; buf[n++] = 0x89; buf[n++] = 0xF0;

    /* test eax, eax — check if val == 0 */
    buf[n++] = 0x85; buf[n++] = 0xC0;

    /* jnz +2 — skip inc if non-zero */
    buf[n++] = 0x75; buf[n++] = 0x02;

    /* inc eax — if val == 0, return 1 (C standard) */
    buf[n++] = 0xFF; buf[n++] = 0xC0;

    /* jmp [rdi+56] — jump to saved RIP */
    buf[n++] = 0xFF; buf[n++] = 0x67; buf[n++] = 0x38;

    return n;
}
