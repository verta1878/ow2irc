/*
 * openwatcomirc — x86_64 register extensions
 * 
 * Adds R8-R15 general purpose registers using the unused bits in
 * word 1 of hw_reg_set (bits 2-9). Word 1 currently only uses
 * bits 0-1 for FS and GS.
 *
 * Include AFTER cgx86reg.h
 */

#ifndef CG_X64_REG_H
#define CG_X64_REG_H

/* R8-R15 use bits 2-9 of word 1 */
HW_DEFINE_SIMPLE( HW_R8,     0x00000000U, 0x00000004U );
HW_DEFINE_SIMPLE( HW_R9,     0x00000000U, 0x00000008U );
HW_DEFINE_SIMPLE( HW_R10,    0x00000000U, 0x00000010U );
HW_DEFINE_SIMPLE( HW_R11,    0x00000000U, 0x00000020U );
HW_DEFINE_SIMPLE( HW_R12,    0x00000000U, 0x00000040U );
HW_DEFINE_SIMPLE( HW_R13,    0x00000000U, 0x00000080U );
HW_DEFINE_SIMPLE( HW_R14,    0x00000000U, 0x00000100U );
HW_DEFINE_SIMPLE( HW_R15,    0x00000000U, 0x00000200U );

/* XMM0-XMM15 use bits 10-25 of word 1 */
HW_DEFINE_SIMPLE( HW_XMM0,   0x00000000U, 0x00000400U );
HW_DEFINE_SIMPLE( HW_XMM1,   0x00000000U, 0x00000800U );
HW_DEFINE_SIMPLE( HW_XMM2,   0x00000000U, 0x00001000U );
HW_DEFINE_SIMPLE( HW_XMM3,   0x00000000U, 0x00002000U );
HW_DEFINE_SIMPLE( HW_XMM4,   0x00000000U, 0x00004000U );
HW_DEFINE_SIMPLE( HW_XMM5,   0x00000000U, 0x00008000U );
HW_DEFINE_SIMPLE( HW_XMM6,   0x00000000U, 0x00010000U );
HW_DEFINE_SIMPLE( HW_XMM7,   0x00000000U, 0x00020000U );
HW_DEFINE_SIMPLE( HW_XMM8,   0x00000000U, 0x00040000U );
HW_DEFINE_SIMPLE( HW_XMM9,   0x00000000U, 0x00080000U );
HW_DEFINE_SIMPLE( HW_XMM10,  0x00000000U, 0x00100000U );
HW_DEFINE_SIMPLE( HW_XMM11,  0x00000000U, 0x00200000U );
HW_DEFINE_SIMPLE( HW_XMM12,  0x00000000U, 0x00400000U );
HW_DEFINE_SIMPLE( HW_XMM13,  0x00000000U, 0x00800000U );
HW_DEFINE_SIMPLE( HW_XMM14,  0x00000000U, 0x01000000U );
HW_DEFINE_SIMPLE( HW_XMM15,  0x00000000U, 0x02000000U );

/* Composite register sets for x86_64 */
#define HW_DEFINE_X64_COMPOUND( x ) \
enum {                                                              \
    /* 64-bit GPRs — RAX through RDI are just EAX through EDI in 64-bit mode */ \
    HW_RAX_##x = HW_EAX_##x,                                       \
    HW_RBX_##x = HW_EBX_##x,                                       \
    HW_RCX_##x = HW_ECX_##x,                                       \
    HW_RDX_##x = HW_EDX_##x,                                       \
    HW_RSI_##x = HW_ESI_##x,                                       \
    HW_RDI_##x = HW_EDI_##x,                                       \
    HW_RBP_##x = HW_EBP_##x,                                       \
    HW_RSP_##x = HW_ESP_##x,                                       \
    /* Extended GPRs */                                              \
    HW_R8_15_##x = (HW_R8_##x+HW_R9_##x+HW_R10_##x+HW_R11_##x    \
                   +HW_R12_##x+HW_R13_##x+HW_R14_##x+HW_R15_##x), \
    /* All 16 GPRs */                                                \
    HW_ALLGPR64_##x = (HW_ABCD_##x+HW_ESI_##x+HW_EDI_##x          \
                       +HW_EBP_##x+HW_ESP_##x+HW_R8_15_##x),      \
    /* SysV ABI callee-saved: RBX, RBP, R12-R15 */                  \
    HW_CALLEE_SAVED_##x = (HW_EBX_##x+HW_EBP_##x                   \
                          +HW_R12_##x+HW_R13_##x+HW_R14_##x+HW_R15_##x), \
    /* SysV ABI caller-saved (volatile): RAX,RCX,RDX,RSI,RDI,R8-R11 */ \
    HW_CALLER_SAVED_##x = (HW_EAX_##x+HW_ECX_##x+HW_EDX_##x       \
                          +HW_ESI_##x+HW_EDI_##x                    \
                          +HW_R8_##x+HW_R9_##x+HW_R10_##x+HW_R11_##x), \
    /* SysV ABI integer arg registers: RDI,RSI,RDX,RCX,R8,R9 */     \
    HW_ARG_REGS_##x = (HW_EDI_##x+HW_ESI_##x+HW_EDX_##x           \
                       +HW_ECX_##x+HW_R8_##x+HW_R9_##x),           \
    HW_X64_END_##x = 0                                               \
};

/* REX prefix helpers — does a hw_reg_set need REX.B? */
/* R8-R15 all live in word 1 bits 2-9 */
#define HW_X64_NEEDS_REX_B(reg)  ((reg).u.word[1] & 0x000003FCU)

/* Map R8-R15 to encoding index 0-7 */
/* R8=bit2→0, R9=bit3→1, ... R15=bit9→7 */

/* Encoding: for R8-R15, the 3-bit register field is (bit_position - 2) */
/* RegTrans returns 0-7 for the standard GPRs. For R8-R15, we return 0-7 */
/* and the caller must emit REX.B=1 */

#endif /* CG_X64_REG_H */
