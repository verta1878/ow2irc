; crt0_x64.asm — Minimal Linux x86_64 C runtime startup
; Assembled with NASM: nasm -f elf64 crt0_x64.asm -o crt0_x64.o
;
; Entry point: _start
; Calls: main(argc, argv)
; On return: sys_exit(eax)

bits 64
section .text

global _start
extern main

_start:
    ; Linux passes argc at [rsp], argv at [rsp+8]
    mov rdi, [rsp]          ; argc → first arg (rdi)
    lea rsi, [rsp+8]        ; argv → second arg (rsi)
    
    ; Align stack to 16 bytes (required by SysV ABI)
    and rsp, -16
    
    ; Call main(argc, argv)
    call main
    
    ; sys_exit(return_value)
    mov edi, eax            ; exit code from main's return value
    mov eax, 60             ; __NR_exit
    syscall

; ====================================================================
; Linux syscall stubs — direct syscalls, no libc
; ====================================================================

global _sys_write
global _sys_read
global _sys_open
global _sys_close
global _sys_exit

; ssize_t _sys_write(int fd, const void *buf, size_t count)
_sys_write:
    mov rax, 1              ; __NR_write
    syscall
    ret

; ssize_t _sys_read(int fd, void *buf, size_t count)
_sys_read:
    mov rax, 0              ; __NR_read
    syscall
    ret

; int _sys_open(const char *pathname, int flags, int mode)
_sys_open:
    mov rax, 2              ; __NR_open
    syscall
    ret

; int _sys_close(int fd)
_sys_close:
    mov rax, 3              ; __NR_close
    syscall
    ret

; void _sys_exit(int status)
_sys_exit:
    mov eax, 60             ; __NR_exit
    syscall
    ; no return
