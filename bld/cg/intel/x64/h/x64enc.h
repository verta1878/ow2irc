/*
 * openwatcomirc — x86_64 REX prefix and encoding extensions
 *
 * This module extends the x86 instruction encoder (x86enc.c) with
 * x86_64 support: REX prefixes, 64-bit operand size, extended registers,
 * and RIP-relative addressing.
 *
 * REX byte format: 0100WRXB
 *   W = 1: 64-bit operand size
 *   R = 1: extends ModRM.reg to 3+1=4 bits (R8-R15)
 *   X = 1: extends SIB.index
 *   B = 1: extends ModRM.rm or SIB.base (R8-R15)
 *
 * Key x86_64 encoding differences from 386:
 *   1. Default operand size is 32-bit (NOT 64-bit) — need REX.W for 64-bit
 *   2. Default address size is 64-bit
 *   3. RIP-relative addressing: ModRM mod=00 rm=5 → [RIP+disp32]
 *   4. No far jumps/calls in 64-bit mode
 *   5. Some 1-byte opcodes repurposed (INC/DEC reg → REX prefixes)
 */

#ifndef X64ENC_H
#define X64ENC_H

#include <stdint.h>

/* REX prefix byte values */
#define REX_NONE    0x00    /* no REX needed */
#define REX_BASE    0x40    /* REX with no bits set (needed for SPL/BPL/SIL/DIL) */
#define REX_B       0x41    /* extend rm/base field */
#define REX_X       0x42    /* extend SIB index */
#define REX_XB      0x43
#define REX_R       0x44    /* extend reg field */
#define REX_RB      0x45
#define REX_RX      0x46
#define REX_RXB     0x47
#define REX_W       0x48    /* 64-bit operand size */
#define REX_WB      0x49
#define REX_WX      0x4A
#define REX_WXB     0x4B
#define REX_WR      0x4C
#define REX_WRB     0x4D
#define REX_WRX     0x4E
#define REX_WRXB    0x4F

/*
 * Compute the REX prefix byte for a given instruction.
 *
 * Parameters:
 *   need_w     - true if 64-bit operand size needed
 *   reg_ext    - true if the reg field register is R8-R15
 *   index_ext  - true if the SIB index register is R8-R15
 *   rm_ext     - true if the rm/base register is R8-R15
 *
 * Returns: REX byte (0x40-0x4F) or 0 if no REX needed
 */
static inline uint8_t x64_rex(int need_w, int reg_ext, int index_ext, int rm_ext)
{
    uint8_t rex = 0;
    if (need_w)    rex |= 0x08;
    if (reg_ext)   rex |= 0x04;
    if (index_ext) rex |= 0x02;
    if (rm_ext)    rex |= 0x01;
    if (rex)       rex |= REX_BASE;
    return rex;
}

/*
 * Check if a hw_reg_set register needs REX.B (is R8-R15)
 * Uses the bit pattern from cgx64reg.h
 */
#define X64_REG_IS_EXTENDED(hw_reg) \
    ((hw_reg).u.word[1] & 0x000003FCU)  /* bits 2-9 = R8-R15 */

/*
 * Get the 3-bit encoding for an extended register (R8-R15)
 * R8=0, R9=1, ..., R15=7
 */
static inline int x64_ext_reg_idx(uint32_t word1_bits)
{
    /* bits 2-9 → shift right 2, then find position */
    uint32_t shifted = (word1_bits >> 2) & 0xFF;
    int idx = 0;
    while (shifted > 1) { shifted >>= 1; idx++; }
    return idx;
}

/*
 * RIP-relative addressing encoding
 * In x86_64, ModRM with mod=00 rm=101 (5) means [RIP + disp32]
 * This replaces the 386 meaning of [disp32] (absolute address).
 */
#define MODRM_RIP_REL(reg)  (((reg) << 3) | 5)  /* mod=00, rm=5 */
#define MODRM(mod,reg,rm)   (((mod) << 6) | ((reg) << 3) | (rm))

/*
 * Encoding table: x86_64 differences from 386
 *
 * Changed opcodes:
 *   0x40-0x4F: INC/DEC r32 → REX prefixes (use FF /0 and FF /1 instead)
 *   0x06,0x07: PUSH/POP ES → invalid
 *   0x0E:      PUSH CS → invalid
 *   0x16,0x17: PUSH/POP SS → invalid
 *   0x1E,0x1F: PUSH/POP DS → invalid
 *   0x27:      DAA → invalid
 *   0x2F:      DAS → invalid
 *   0x37:      AAA → invalid
 *   0x3F:      AAS → invalid
 *   0x60,0x61: PUSHA/POPA → invalid
 *   0x62:      BOUND → invalid (repurposed for EVEX prefix)
 *   0x9A:      CALLF → invalid
 *   0xEA:      JMPF → invalid
 *
 * Default operand sizes in 64-bit mode:
 *   Most instructions: 32-bit (need REX.W for 64-bit)
 *   PUSH/POP: 64-bit (no REX needed)
 *   CALL/JMP near: 64-bit
 *   MOV to/from CRn/DRn: 64-bit
 */

/* Function declarations for x64enc.c — used by x64obj.c */
extern void     X64Init( bool is_x64 );
extern void     X64ResetRex( void );
extern void     X64SetRexW( void );
extern void     X64SetRexR( void );
extern void     X64SetRexB( void );
extern void     X64SetRexX( void );
extern uint8_t  X64GetRex( void );
extern bool     X64IsExtReg( hw_reg_set reg );
extern int      X64ExtRegIdx( hw_reg_set reg );
extern bool     X64NeedsRexW( type_class_def type_class );
extern int      X64InsertRex( uint8_t *inst, int ilen, int opcode_pos, uint8_t rex );
extern void     X64FixupIncDec( uint8_t *inst, int *ilen );

#endif /* X64ENC_H */
