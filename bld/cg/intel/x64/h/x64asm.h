/* x64asm.h — see x64asm.c for full spec */
#ifndef X64_ASM_H
#define X64_ASM_H
#include <stdint.h>
#include <stdbool.h>
typedef enum { REG_RAX=0,REG_RCX=1,REG_RDX=2,REG_RBX=3,REG_RSP=4,REG_RBP=5,REG_RSI=6,REG_RDI=7,REG_R8=8,REG_R9=9,REG_R10=10,REG_R11=11,REG_R12=12,REG_R13=13,REG_R14=14,REG_R15=15,REG_XMM0=16,REG_NONE=-1 } x64_reg_t;
typedef enum { OPSZ_8=1,OPSZ_16=2,OPSZ_32=4,OPSZ_64=8 } x64_opsz_t;
#define REX_BASE 0x40
#define REX_W 0x08
#define REX_R 0x04
#define REX_X 0x02
#define REX_B 0x01
static inline uint8_t make_rex(bool w,bool r,bool x,bool b){uint8_t v=0x40;if(w)v|=8;if(r)v|=4;if(x)v|=2;if(b)v|=1;return v;}
static inline bool reg_needs_rex(x64_reg_t r){int i=(int)r;return(i>=8&&i<=15);}
static inline int reg_encoding(x64_reg_t r){int i=(int)r;if(i>=16)i-=16;return i&7;}
static inline uint8_t make_modrm(int mod,int reg,int rm){return(uint8_t)((mod<<6)|((reg&7)<<3)|(rm&7));}
int x64_encode_rex(uint8_t*buf,bool w,x64_reg_t reg,x64_reg_t rm);
int x64_encode_mov_rr(uint8_t*buf,x64_reg_t dst,x64_reg_t src,x64_opsz_t size);
int x64_encode_mov_ri(uint8_t*buf,x64_reg_t dst,uint64_t imm,x64_opsz_t size);
int x64_encode_mov_rip(uint8_t*buf,x64_reg_t dst,int32_t disp,x64_opsz_t size);
int x64_encode_push(uint8_t*buf,x64_reg_t reg);
int x64_encode_pop(uint8_t*buf,x64_reg_t reg);
int x64_encode_sub_ri(uint8_t*buf,x64_reg_t reg,int32_t imm);
int x64_encode_add_ri(uint8_t*buf,x64_reg_t reg,int32_t imm);
int x64_encode_call_rel32(uint8_t*buf,int32_t rel);
int x64_encode_ret(uint8_t*buf);
int x64_encode_nop(uint8_t*buf);
int x64_encode_syscall(uint8_t*buf);
int x64_encode_xor_rr(uint8_t*buf,x64_reg_t dst,x64_reg_t src);
int x64_encode_lea_rip(uint8_t*buf,x64_reg_t dst,int32_t disp);
#endif
