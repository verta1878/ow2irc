/* x64win64.h — see x64win64.c for full spec */
#ifndef X64_WIN64_H
#define X64_WIN64_H
#include <stdint.h>
#include <stdbool.h>
#define WIN64_SHADOW_SPACE 32
#define WIN64_NUM_ARGS 4
typedef struct { int next_arg; int stack_offset; int num_stack_args; } win64_call_state_t;
typedef struct { bool in_register; bool is_float; int arg_index; int stack_offset; bool by_reference; } win64_parm_info_t;
void win64_call_init(win64_call_state_t *state);
int win64_caller_arg_area(int total_args);
#endif
