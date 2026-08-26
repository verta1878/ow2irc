/* x64clib.h — see x64clib.c for full spec */
#ifndef X64_CLIB_H
#define X64_CLIB_H
#include <stdint.h>
typedef struct { uint64_t rbx,rbp,r12,r13,r14,r15,rsp,rip; } x64_jmp_buf[1];
typedef struct { unsigned int gp_offset; unsigned int fp_offset; void *overflow_arg_area; void *reg_save_area; } x64_va_list[1];
int x64_emit_linux_start(uint8_t *buf);
int x64_emit_win64_start(uint8_t *buf);
int x64_emit_setjmp_sysv(uint8_t *buf);
int x64_emit_longjmp_sysv(uint8_t *buf);
#endif
