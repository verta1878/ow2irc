.text
/* _malloc: allocate via mmap with MAP_32BIT (keeps pointers < 2GB)
 * Watcom cdecl: size at 8(%rsp) */
.globl _malloc
_malloc:
    mov 8(%rsp),%rsi        /* size */
    add $4095,%rsi
    and $-4096,%rsi         /* round up to page */
    xor %rdi,%rdi           /* addr = NULL */
    mov $3,%rdx             /* PROT_READ|PROT_WRITE */
    mov $0x62,%r10          /* MAP_PRIVATE(0x02)|MAP_ANONYMOUS(0x20)|MAP_32BIT(0x40) */
    mov $-1,%r8d            /* fd = -1 */
    xor %r9,%r9             /* offset = 0 */
    mov $9,%eax             /* sys_mmap */
    syscall
    cmp $-4096,%rax
    jbe 1f
    xor %eax,%eax           /* return NULL on error */
1:  ret

/* _free: munmap (needs size but we don't track it — just unmap a page) */
.globl _free
_free:
    mov 8(%rsp),%rdi        /* addr */
    mov $4096,%esi          /* size (minimum) */
    mov $11,%eax            /* sys_munmap */
    syscall
    ret

.section .note.GNU-stack,"",@progbits
