/*
 * openwatcomirc — x86_64 instruction encoding extensions
 *
 * Extends the shared x86 encoder (x86enc.c) with:
 *   - REX prefix generation
 *   - 64-bit operand handling
 *   - RIP-relative addressing
 *   - Extended register (R8-R15) support
 *
 * This file is compiled alongside x86enc.c for the x64 target.
 * It provides x64-specific overrides and helpers.
 */

#include "_cgstd.h"
#include "coderep.h"
#include "x64enc.h"
#include "pcencode.h"

/* REX prefix accumulator — collected during instruction encoding,
 * flushed before the opcode byte is emitted. */
static uint8_t  rex_pending = 0;
static bool     rex_needed = false;   /* true if any REX bit was set */
static bool     x64_mode = false;     /* true when targeting x86_64 */

void X64Init( bool is_x64 )
{
    x64_mode = is_x64;
}

void X64ResetRex( void )
{
    rex_pending = 0;
    rex_needed = false;
}

/*
 * Set REX.W — 64-bit operand size.
 * Called by the instruction emitter when the operation needs 64-bit.
 */
void X64SetRexW( void )
{
    if( !x64_mode ) return;
    rex_pending |= 0x08;
    rex_needed = true;
}

/*
 * Set REX.R — the ModRM.reg field references R8-R15.
 * Called by LayReg() when it detects an extended register.
 */
void X64SetRexR( void )
{
    if( !x64_mode ) return;
    rex_pending |= 0x04;
    rex_needed = true;
}

/*
 * Set REX.X — the SIB.index references R8-R15.
 * Called by LayModRM() when encoding SIB with extended index.
 */
void X64SetRexX( void )
{
    if( !x64_mode ) return;
    rex_pending |= 0x02;
    rex_needed = true;
}

/*
 * Set REX.B — the ModRM.rm or SIB.base references R8-R15.
 * Called by LayRegRM() and LayModRM() for extended registers.
 */
void X64SetRexB( void )
{
    if( !x64_mode ) return;
    rex_pending |= 0x01;
    rex_needed = true;
}

/*
 * Get the REX byte to emit. Returns 0 if no REX needed.
 * Called by TransferIns() or the opcode emitter.
 */
uint8_t X64GetRex( void )
{
    uint8_t rex = 0;
    if( rex_needed ) {
        rex = 0x40 | rex_pending;
    }
    X64ResetRex();
    return rex;
}

/*
 * Check if a hw_reg_set is an extended x64 register (R8-R15).
 * Returns true if the register needs REX.B or REX.R.
 */
bool X64IsExtReg( hw_reg_set reg )
{
    if( !x64_mode ) return false;
    return( (reg._1 & 0x000003FCU) != 0 );  /* bits 2-9 = R8-R15 */
}

/*
 * Get the 3-bit encoding index for an extended register.
 * R8=0, R9=1, ..., R15=7.
 */
int X64ExtRegIdx( hw_reg_set reg )
{
    uint32_t bits = (reg._1 >> 2) & 0xFF;
    int idx = 0;
    while( bits > 1 ) { bits >>= 1; idx++; }
    return idx;
}

/*
 * For x86_64 RIP-relative addressing:
 * In 64-bit mode, ModRM with mod=00 rm=101 means [RIP + disp32].
 * The 386 meaning of [disp32] (absolute) is not available in 64-bit mode.
 *
 * This affects all memory references to globals and static data.
 * The encoder must:
 *   1. Use mod=00 rm=5 instead of the 386's disp32 addressing
 *   2. Emit a R_X86_64_PC32 relocation instead of R_386_32
 *   3. Set the addend to account for the displacement offset
 */
bool X64UseRipRelative( void );

bool X64UseRipRelative( void )
{
    return x64_mode;
}

/*
 * Insert REX byte into the instruction buffer before the opcode.
 * Called during TransferIns() or instruction finalization.
 *
 * The Inst[] buffer layout is:
 *   Inst[KEY] = opcode byte
 *   Inst[RMR] = ModRM byte
 *   ...
 *
 * For x86_64, we need to insert REX between any legacy prefixes
 * (operand size 66h, REP F2h/F3h) and the opcode.
 *
 * This function shifts the instruction buffer right by 1 byte
 * at position `opcode_pos` and inserts the REX byte.
 */
int X64InsertRex( uint8_t *inst, int ilen, int opcode_pos, uint8_t rex )
{
    (void)ilen;
    if( rex == 0 ) return ilen;

    /* Shift everything from opcode_pos onward right by 1 */
    for( int i = ilen; i > opcode_pos; i-- ) {
        inst[i] = inst[i-1];
    }
    inst[opcode_pos] = rex;
    return ilen + 1;
}

/*
 * Determine if an instruction needs REX.W based on operand type class.
 * In x86_64:
 *   - 32-bit operations: no REX.W needed (default operand size)
 *   - 64-bit operations: REX.W required
 *   - PUSH/POP/CALL/JMP: always 64-bit, no REX.W needed
 */
bool X64NeedsRexW( type_class_def type_class )
{
    if( !x64_mode ) return false;
    /* 8-byte (64-bit) types need REX.W */
    switch( type_class ) {
    case XX:    /* pointer types in 64-bit mode */
    case PT:    /* pointer */
    case CP:    /* code pointer */
        return true;
    default:
        return false;
    }
}

/*
 * x86_64 instruction table fixups.
 *
 * The 386 instruction table uses INC r32 (0x40+r) and DEC r32 (0x48+r).
 * In x86_64, these bytes are REX prefixes. Must use:
 *   INC r/m64: FF /0 with REX.W
 *   DEC r/m64: FF /1 with REX.W
 *
 * This function remaps the single-byte INC/DEC to the FF /0 and FF /1 forms.
 */
void X64FixupIncDec( uint8_t *inst, int *ilen )
{
    (void)ilen;  /* length unchanged by INC/DEC fixup */
    if( !x64_mode ) return;

    /* Check for single-byte INC (0x40-0x47) */
    if( inst[KEY] >= 0x40 && inst[KEY] <= 0x47 ) {
        uint8_t reg = inst[KEY] - 0x40;
        inst[KEY] = 0xFF;
        inst[RMR] = MODRM(3, 0, reg);  /* /0 = INC */
        /* REX.W should already be set for 64-bit */
    }
    /* Check for single-byte DEC (0x48-0x4F) */
    else if( inst[KEY] >= 0x48 && inst[KEY] <= 0x4F ) {
        uint8_t reg = inst[KEY] - 0x48;
        inst[KEY] = 0xFF;
        inst[RMR] = MODRM(3, 1, reg);  /* /1 = DEC */
    }
}

/* ====================================================================
 * Object output through OWL (replaces x86obj.c for ELF64 targets)
 * ==================================================================== */

/*
 * The x86 backend outputs OMF objects via x86obj.c (3,393 lines).
 * For ELF64, we redirect through OWL instead.
 *
 * The OWL integration is already proven in Phase 16:
 *   - OWLSectionInit(".text", OWL_SECTION_CODE, 16)
 *   - OWLEmitData(text, code_bytes, len)
 *   - OWLEmitReloc(text, offset, sym, OWL_RELOC_HALF_LO or BRANCH_REL)
 *   - OWLFileFini() writes the ELF64 object
 *
 * The cg's existing object output interface (objout.h):
 *   ObjInit() — called once at start
 *   ObjFini() — called once at end
 *   GenObject() — called to emit current instruction
 *
 * For x64, x64obj.c would implement these three functions using OWL
 * instead of the OMF writer. The instruction bytes come from GenObjCode()
 * which fills Inst[]/ILen, then GenObject() writes them to the OWL section.
 *
 * This module is a stub that documents the integration point.
 * Full implementation requires wiring into the cg build system.
 */

/* Placeholder — the actual OWL integration is proven in Phase 16.
 * Implementation connects:
 *   GenObject() → OWLEmitData(text_section, Inst, ILen)
 *   Label emission → OWLEmitLabel()
 *   Relocations → OWLEmitReloc() with R_X86_64_PC32 / R_X86_64_PLT32
 */

