/* x64ehframe.h — see x64ehframe.c for full spec (250+ lines of docs) */
#ifndef X64_EHFRAME_H
#define X64_EHFRAME_H
#include <stdint.h>
#include <stdbool.h>
#define DW_CFA_advance_loc     0x40
#define DW_CFA_offset          0x80
#define DW_CFA_restore         0xC0
#define DW_CFA_nop             0x00
#define DW_CFA_advance_loc1    0x02
#define DW_CFA_advance_loc2    0x03
#define DW_CFA_advance_loc4    0x04
#define DW_CFA_offset_extended 0x05
#define DW_CFA_def_cfa         0x0C
#define DW_CFA_def_cfa_register 0x0D
#define DW_CFA_def_cfa_offset  0x0E
#define DWARF_RAX 0
#define DWARF_RDX 1
#define DWARF_RCX 2
#define DWARF_RBX 3
#define DWARF_RSI 4
#define DWARF_RDI 5
#define DWARF_RBP 6
#define DWARF_RSP 7
#define DWARF_R8  8
#define DWARF_R9  9
#define DWARF_R12 12
#define DWARF_R13 13
#define DWARF_R14 14
#define DWARF_R15 15
#define DWARF_RA  16
void eh_frame_init(void);
void eh_frame_begin_function(const char *name, uint64_t addr, uint64_t size);
void eh_frame_push_reg(int dwarf_reg, int code_offset);
void eh_frame_set_cfa_register(int dwarf_reg, int offset, int code_offset);
void eh_frame_set_cfa_offset(int offset, int code_offset);
void eh_frame_save_reg(int dwarf_reg, int cfa_offset, int code_offset);
void eh_frame_end_function(void);
void eh_frame_finalize(void);
void eh_frame_emit_file_symbol(const char *filename);
void eh_frame_emit_gnu_property(void);
#endif
