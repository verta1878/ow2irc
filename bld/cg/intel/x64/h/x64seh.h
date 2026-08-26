/* x64seh.h — see x64seh.c for full spec */
#ifndef X64_SEH_H
#define X64_SEH_H
#include <stdint.h>
#include <stdbool.h>
#define UWOP_PUSH_NONVOL     0
#define UWOP_ALLOC_LARGE     1
#define UWOP_ALLOC_SMALL     2
#define UWOP_SET_FPREG       3
#define UWOP_SAVE_NONVOL     4
#define UWOP_SAVE_NONVOL_FAR 5
#define UWOP_SAVE_XMM128     8
#define UWOP_SAVE_XMM128_FAR 9
#define UNW_FLAG_NHANDLER    0
#define UNW_FLAG_EHANDLER    1
#define UNW_FLAG_UHANDLER    2
#define UNW_REG_RBP 5
#define UNW_REG_RBX 3
#define UNW_REG_RDI 7
#define UNW_REG_RSI 6
typedef struct { uint32_t BeginAddress; uint32_t EndAddress; uint32_t UnwindInfoAddress; } RUNTIME_FUNCTION;
typedef struct { uint8_t CodeOffset; uint8_t UnwindOp:4; uint8_t OpInfo:4; } UNWIND_CODE;
typedef struct { uint8_t Version:3; uint8_t Flags:5; uint8_t SizeOfProlog; uint8_t CountOfCodes; uint8_t FrameRegister:4; uint8_t FrameOffset:4; } UNWIND_INFO;
void seh_init(void);
void seh_begin_function(const char *name, uint32_t begin_rva);
void seh_push_reg(int win64_reg, uint8_t code_offset);
void seh_alloc_stack(uint32_t size, uint8_t code_offset);
void seh_set_frame_reg(int win64_reg, uint8_t offset, uint8_t code_offset);
void seh_save_reg(int win64_reg, uint32_t stack_offset, uint8_t code_offset);
void seh_save_xmm(int xmm_reg, uint32_t stack_offset, uint8_t code_offset);
void seh_end_function(uint32_t end_rva);
void seh_finalize(void);
#endif
