/* SysV ABI wrappers for Watcom __cdecl convention.
 * Watcom cdecl: args pushed right-to-left on stack, caller cleans up.
 * SysV x64: args in RDI, RSI, RDX, RCX, R8, R9; float in XMM0-7.
 * Each wrapper reads args from stack and calls the real function.
 *
 * Stack on entry to wrapper:
 *   [RSP]     = return address
 *   [RSP+8]   = arg1
 *   [RSP+16]  = arg2
 *   [RSP+24]  = arg3
 *   ...
 */

.text

/* 1-arg wrappers: arg1 → RDI */
.globl _malloc
_malloc:
    mov 8(%rsp),%rdi
    jmp malloc@PLT

.globl _free
_free:
    mov 8(%rsp),%rdi
    jmp free@PLT

.globl _strlen
_strlen:
    mov 8(%rsp),%rdi
    jmp strlen@PLT

/* 2-arg wrappers: arg1 → RDI, arg2 → RSI */
.globl _memset
_memset:
    mov 8(%rsp),%rdi
    mov 16(%rsp),%rsi
    mov 24(%rsp),%rdx
    jmp memset@PLT

.globl _memcpy
_memcpy:
    mov 8(%rsp),%rdi
    mov 16(%rsp),%rsi
    mov 24(%rsp),%rdx
    jmp memcpy@PLT

.globl _strcmp
_strcmp:
    mov 8(%rsp),%rdi
    mov 16(%rsp),%rsi
    jmp strcmp@PLT

.globl _strcpy
_strcpy:
    mov 8(%rsp),%rdi
    mov 16(%rsp),%rsi
    jmp strcpy@PLT

.globl _strncpy
_strncpy:
    mov 8(%rsp),%rdi
    mov 16(%rsp),%rsi
    mov 24(%rsp),%rdx
    jmp strncpy@PLT

/* printf: variadic — up to 6 args (format + 5 args) */
.globl printf
printf:
    mov 8(%rsp),%rdi    /* format string */
    mov 16(%rsp),%rsi   /* arg1 */
    mov 24(%rsp),%rdx   /* arg2 */
    mov 32(%rsp),%rcx   /* arg3 */
    mov 40(%rsp),%r8    /* arg4 */
    mov 48(%rsp),%r9    /* arg5 */
    xor %eax,%eax       /* no float args in XMM */
    push %rbp
    mov %rsp,%rbp
    and $-16,%rsp        /* 16-byte align stack for SysV */
    call printf@PLT
    mov %rbp,%rsp
    pop %rbp
    ret

/* sprintf: variadic */
.globl _sprintf
_sprintf:
    mov 8(%rsp),%rdi    /* buffer */
    mov 16(%rsp),%rsi   /* format */
    mov 24(%rsp),%rdx   /* arg1 */
    mov 32(%rsp),%rcx   /* arg2 */
    mov 40(%rsp),%r8    /* arg3 */
    mov 48(%rsp),%r9    /* arg4 */
    xor %eax,%eax
    push %rbp
    mov %rsp,%rbp
    and $-16,%rsp
    call sprintf@PLT
    mov %rbp,%rsp
    pop %rbp
    ret

/* write/read: already SysV in our crt0, but add underscore versions */
.globl _write
_write:
    mov 8(%rsp),%rdi
    mov 16(%rsp),%rsi
    mov 24(%rsp),%rdx
    mov $1,%rax         /* sys_write */
    syscall
    ret

.globl _read
_read:
    mov 8(%rsp),%rdi
    mov 16(%rsp),%rsi
    mov 24(%rsp),%rdx
    mov $0,%rax         /* sys_read */
    syscall
    ret
