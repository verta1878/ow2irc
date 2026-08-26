/* crt0_x64.S — Minimal Linux x86_64 C runtime startup
 * Assembled with: gcc -c crt0_x64.S -o crt0_x64.o
 *
 * Entry point: _start
 * Calls: main(argc, argv) 
 * On return: sys_exit(eax)
 * No libc dependency.
 */

.text
.global _start
.type _start, @function

_start:
    /* Linux puts argc at (%rsp), argv at 8(%rsp) */
    movq (%rsp), %rdi       /* argc → first arg */
    leaq 8(%rsp), %rsi      /* argv → second arg */
    
    /* Align stack to 16 bytes (SysV ABI requirement) */
    andq $-16, %rsp
    
    /* Call main(argc, argv) */
    call main
    
    /* sys_exit(return_value) */
    movl %eax, %edi         /* exit code */
    movl $60, %eax          /* __NR_exit */
    syscall

/* ================================================================
 * Minimal C library — direct Linux syscalls
 * ================================================================ */

.global puts
.type puts, @function
puts:
    /* puts(const char *s) — Watcom register convention: arg1 in EAX.
     * Under this convention EAX is the only scratch register: the compiler
     * keeps locals in EDX/EBX/ECX across calls, so a callee must preserve
     * everything but EAX. These stubs make raw syscalls, which clobber RSI/RDI/RCX/R11,
     * so the preserved set must be saved explicitly. Without this a caller
     * holding a pointer in one of those registers across a call — walking a
     * linked list, for instance — resumed with a corrupted value. */
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rsi
    pushq %rdi
    pushq %r11
    movq %rax, %rsi         /* buf = string pointer from EAX */
    /* Find string length */
    xorq %rdx, %rdx         /* count = 0 */
.puts_len:
    cmpb $0, (%rsi,%rdx)
    je .puts_write
    incq %rdx
    jmp .puts_len
.puts_write:
    movq $1, %rdi           /* fd = stdout */
    movq $1, %rax           /* __NR_write */
    syscall
    /* Write newline */
    pushq $10               /* '\n' on stack */
    movq %rsp, %rsi
    movq $1, %rdx           /* count = 1 */
    movq $1, %rdi           /* fd = stdout */
    movq $1, %rax           /* __NR_write */
    syscall
    addq $8, %rsp
    popq %r11
    popq %rdi
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx
    xorl %eax, %eax         /* return 0 */
    ret

.global write
.type write, @function
write:
    /* ssize_t write(int fd, const void *buf, size_t count) */
    /* Args already in rdi, rsi, rdx per SysV ABI */
    movq $1, %rax           /* __NR_write */
    syscall
    ret

.global read
.type read, @function
read:
    movq $0, %rax           /* __NR_read */
    syscall
    ret

.global _exit
.type _exit, @function
_exit:
    movl %edi, %edi         /* status */
    movl $60, %eax          /* __NR_exit */
    syscall

/* Watcom runtime stubs — needed for -od compiled code */
.global __CHK
.type __CHK, @function
__CHK:
    /* Stack check — Watcom pushes stack size before calling.
     * Pop the argument and return. Linux kernel handles stack growth. */
    ret $8

/* Stack-grow runtime (RT_GROW). Like __CHK, the compiler pushes the frame
 * size before the call (GenUnkPush + DoRTCall(RT_GROW, true) in x86proc.c),
 * so this MUST pop that 8-byte argument on return. A bare `ret` here leaves
 * the stack 8 bytes off and the caller returns to garbage -> segfault on the
 * default-optimization path. */
.global __GRO
.type __GRO, @function
__GRO:
    ret $8

/* Stack-touch/probe (RT_STK thunk). Called without a pushed argument. */
.global __STK
.type __STK, @function
__STK:
    ret

/* Stack-check-with-pointer helper (__CHP). No pushed argument. */
.global __CHP
.type __CHP, @function
__CHP:
    ret

/* x87 emulator init. Freestanding target has a real FPU; nothing to do. */
.global __init_387_emulator
.type __init_387_emulator, @function
__init_387_emulator:
    ret

.global _cstart
.type _cstart, @function  
_cstart:
    /* Watcom startup — redirect to _start */
    jmp _start

/* Watcom 64-bit integer helpers. The compiler emits calls to these for
 * long long operations; clib normally supplies them and this freestanding
 * runtime does not have it.
 *
 * The ABI was read off the generated code rather than assumed: the value
 * arrives in EDX:EAX (EDX high) and the shift count in ECX:EBX (a 64-bit
 * count, low half in EBX), with the result returned in EDX:EAX. An earlier
 * version of these stubs took the count in CL and silently returned wrong
 * answers, which is worse than not providing them at all. */
.global __I8RS
.type __I8RS, @function
__I8RS:                     /* signed  EDX:EAX >>= EBX */
    movl  %ebx, %ecx
    cmpb  $32, %cl
    jae   .I8RS_big
    shrdl %cl, %edx, %eax
    sarl  %cl, %edx
    ret
.I8RS_big:
    movl  %edx, %eax
    sarl  $31, %edx
    subb  $32, %cl
    sarl  %cl, %eax
    ret

.global __U8RS
.type __U8RS, @function
__U8RS:                     /* unsigned EDX:EAX >>= EBX */
    movl  %ebx, %ecx
    cmpb  $32, %cl
    jae   .U8RS_big
    shrdl %cl, %edx, %eax
    shrl  %cl, %edx
    ret
.U8RS_big:
    movl  %edx, %eax
    xorl  %edx, %edx
    subb  $32, %cl
    shrl  %cl, %eax
    ret

.global __I8LS
.type __I8LS, @function
__I8LS:                     /* EDX:EAX <<= EBX */
    movl  %ebx, %ecx
    cmpb  $32, %cl
    jae   .I8LS_big
    shldl %cl, %eax, %edx
    shll  %cl, %eax
    ret
.I8LS_big:
    movl  %eax, %edx
    xorl  %eax, %eax
    subb  $32, %cl
    shll  %cl, %edx
    ret

.section .note.GNU-stack,"",@progbits
