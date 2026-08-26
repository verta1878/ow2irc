.text

/* mini_printf: format in 8(%rsp), args at 16(%rsp), 24(%rsp), ...
 * Handles: %d (int), %s (string), %c (char), %x (hex), %% (literal %)
 * Returns number of chars written in EAX */
.globl printf
printf:
    push %rbx; push %rcx; push %rdx; push %rsi; push %rdi
    push %r8; push %r9; push %r10; push %r11; push %rbp
    mov %rsp,%rbp

    /* args start at rbp + 10*8(saved regs) + 8(ret addr) + 8 = rbp+96 */
    mov 88(%rbp),%rsi       /* format string */
    lea 96(%rbp),%r10      /* pointer to first vararg */
    xor %r8d,%r8d           /* total chars written */
    sub $32,%rsp            /* scratch buffer */
    and $-16,%rsp           /* align */

.Lnext_char:
    movzbl (%rsi),%eax
    test %al,%al
    jz .Ldone
    cmp $'%',%al
    je .Lformat
    /* regular character — write it */
    mov %al,(%rsp)
    mov $1,%edx; mov %rsp,%r9
    jmp .Lwrite_buf

.Lformat:
    inc %rsi
    movzbl (%rsi),%eax
    cmp $'d',%al; je .Lfmt_d
    cmp $'s',%al; je .Lfmt_s
    cmp $'c',%al; je .Lfmt_c
    cmp $'x',%al; je .Lfmt_x
    cmp $'%',%al; je .Lfmt_pct
    /* unknown format — skip */
    inc %rsi; jmp .Lnext_char

.Lfmt_pct:
    movb $'%',(%rsp)
    mov $1,%edx; mov %rsp,%r9
    jmp .Lwrite_buf

.Lfmt_c:
    mov (%r10),%eax; add $8,%r10
    mov %al,(%rsp)
    mov $1,%edx; mov %rsp,%r9
    jmp .Lwrite_buf

.Lfmt_s:
    mov (%r10),%rdi; add $8,%r10
    /* strlen of rdi */
    xor %edx,%edx
1:  cmpb $0,(%rdi,%rdx,1); je 2f; inc %edx; jmp 1b
2:  mov %rdi,%r9
    jmp .Lwrite_buf

.Lfmt_x:
    mov (%r10),%eax; add $8,%r10
    lea 16(%rsp),%r9
    mov $0,%ecx
3:  mov %eax,%edx; and $0xf,%edx
    cmp $10,%edx; jb 4f; add $('a'-10),%dl; jmp 5f
4:  add $'0',%dl
5:  dec %r9; mov %dl,(%r9); inc %ecx
    shr $4,%eax; jnz 3b
    mov %ecx,%edx
    jmp .Lwrite_buf

.Lfmt_d:
    mov (%r10),%eax; add $8,%r10
    lea 16(%rsp),%r9
    xor %ecx,%ecx
    test %eax,%eax; jns .Ld_pos
    neg %eax; mov $1,%ecx   /* remember sign */
.Ld_pos:
    push %rcx               /* save sign flag */
    xor %ecx,%ecx
.Ld_loop:
    xor %edx,%edx; mov $10,%ebx; div %ebx
    add $'0',%dl; dec %r9; mov %dl,(%r9); inc %ecx
    test %eax,%eax; jnz .Ld_loop
    pop %rax                /* sign flag */
    test %eax,%eax; jz .Ld_nosign
    dec %r9; movb $'-',(%r9); inc %ecx
.Ld_nosign:
    mov %ecx,%edx
    jmp .Lwrite_buf

.Lwrite_buf:
    /* write(1, r9, edx) */
    push %rsi; push %rdx
    mov %r9,%rsi; mov $1,%edi; mov %edx,%edx
    mov $1,%eax; syscall
    pop %rdx; pop %rsi
    add %edx,%r8d
    inc %rsi
    jmp .Lnext_char

.Ldone:
    mov %r8d,%eax
    mov %rbp,%rsp
    pop %rbp; pop %r11; pop %r10; pop %r9; pop %r8
    pop %rdi; pop %rsi; pop %rdx; pop %rcx; pop %rbx
    ret
