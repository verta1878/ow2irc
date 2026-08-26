/* x64rodata.h — see x64rodata.c for full spec */
#ifndef X64_RODATA_H
#define X64_RODATA_H
#include <stdint.h>
void x64_switch_to_rodata(void);
void x64_switch_to_data(void);
int x64_emit_string_literal(const char *str, int len);
int x64_emit_float_const(const void *data, int size);
int x64_emit_jump_table(const uint64_t *targets, int count);
#endif
