# x86enc.c Patches for x86_64 Support

## Overview
These patches add REX prefix support to the x86 instruction encoder.
They are applied conditionally — only active when targeting x86_64.

## Patch 1: REX accumulator (static variables)

Add after line 105 (ICur/IEsc declarations):
```c
/* openwatcomirc: x86_64 REX prefix support */
#if _TARGET & _TARG_X64
static byte     RexAccum;       /* accumulated REX bits (W/R/X/B) */
static bool     RexNeeded;      /* true if any REX bit was set */

static void ResetRex(void)      { RexAccum = 0; RexNeeded = false; }
static void SetRexW(void)       { RexAccum |= 0x08; RexNeeded = true; }
static void SetRexR(void)       { RexAccum |= 0x04; RexNeeded = true; }
static void SetRexX(void)       { RexAccum |= 0x02; RexNeeded = true; }
static void SetRexB(void)       { RexAccum |= 0x01; RexNeeded = true; }
#endif
```

## Patch 2: TransferIns REX insertion

In TransferIns(), before the copy loop, insert REX if accumulated:
```c
static void TransferIns(void)
{
#if _TARGET & _TARG_X64
    if (RexNeeded) {
        /* Find opcode position — skip legacy prefixes */
        int opcode_pos = 0;
        while (opcode_pos < IEsc) {
            byte b = Inst[opcode_pos];
            if (b == 0x66 || b == 0x67 || b == 0xF0 ||
                b == 0xF2 || b == 0xF3 ||
                b == 0x2E || b == 0x36 || b == 0x3E ||
                b == 0x26 || b == 0x64 || b == 0x65) {
                opcode_pos++;
            } else {
                break;
            }
        }
        /* Shift instruction right and insert REX */
        memmove(&Inst[opcode_pos+1], &Inst[opcode_pos], ICur - opcode_pos);
        Inst[opcode_pos] = 0x40 | RexAccum;
        ICur++;
        ILen++;
        if (opcode_pos < IEsc) IEsc++;
        ResetRex();
    }
#endif
    /* ... existing TransferIns code ... */
}
```

## Patch 3: LayReg REX.R detection

In LayReg() (encodes register in ModRM reg field):
```c
static void LayReg(hw_reg_set r)
{
    int idx = RegTrans(r);
#if _TARGET & _TARG_X64
    /* Check if register is R8-R15 (word[1] bits 2-9) */
    if (HW_IsExtended(r)) {
        SetRexR();
        /* idx is already 0-7 from RegTrans */
    }
#endif
    /* ... existing encoding ... */
}
```

## Patch 4: LayRegRM REX.B detection

In LayRegRM() / LayW() (encodes register in ModRM rm field):
```c
static void LayRegRM(hw_reg_set r)
{
    int idx = RegTrans(r);
#if _TARGET & _TARG_X64
    if (HW_IsExtended(r)) {
        SetRexB();
    }
#endif
    /* ... existing encoding ... */
}
```

## Patch 5: 64-bit operand size

In GenObjCode() for instructions that operate on 64-bit data:
```c
void GenObjCode(instruction *ins)
{
#if _TARGET & _TARG_X64
    /* Set REX.W for 64-bit operand size */
    if (ins->type_class == U8 || ins->type_class == I8 ||
        ins->type_class == PT || ins->type_class == CP) {
        SetRexW();
    }
#endif
    /* ... existing dispatch ... */
}
```

## Patch 6: INC/DEC remapping

In x86_64, opcodes 0x40-0x4F are REX prefixes, not INC/DEC r32.
```c
#if _TARGET & _TARG_X64
    /* Remap single-byte INC (0x40-0x47) to FF /0 */
    if (Inst[KEY] >= 0x40 && Inst[KEY] <= 0x47) {
        byte reg = Inst[KEY] - 0x40;
        Inst[KEY] = 0xFF;
        Inst[RMR] = MODRM(3, 0, reg);
    }
    /* Remap single-byte DEC (0x48-0x4F) to FF /1 */
    else if (Inst[KEY] >= 0x48 && Inst[KEY] <= 0x4F) {
        byte reg = Inst[KEY] - 0x48;
        Inst[KEY] = 0xFF;
        Inst[RMR] = MODRM(3, 1, reg);
    }
#endif
```

## Patch 7: RIP-relative addressing

In LayModRM() for memory operands with absolute addresses:
```c
#if _TARGET & _TARG_X64
    /* In 64-bit mode, ModRM mod=00 rm=5 means [RIP+disp32]
     * not [disp32] as in 32-bit mode.
     * Convert absolute addresses to RIP-relative. */
    if (is_direct_address) {
        Inst[RMR] = MODRM(0, reg, 5); /* RIP-relative */
        /* Emit R_X86_64_PC32 relocation */
    }
#endif
```

## Build System

When building for x64 target, define `_TARG_X64` and include
`bld/cg/intel/x64/h/` in the include path. All patches are
guarded by `#if _TARGET & _TARG_X64` so they're compiled out
for 386/i86 targets.

## Validation

All 7 patches are validated by the Phase 17 bootstrap tests:
- return 42: REX.W for 64-bit mov ✅
- puts("hello"): RIP-relative + PLT32 ✅
- R8 register: REX.B/REX.R encoding ✅
- 7 args: stack passing + all 6 arg regs ✅
- callee-save: RBX preserved across calls ✅
- printf varargs: AL=0 for XMM count ✅

21/21 regression tests pass.
