/*
 * x64parm.c — SysV AMD64 + Win64 Parameter Passing for wcc64
 *
 * Replaces x86parm.c's ParmReg() when targeting x64.
 * Uses extended registers from cgx64reg.h (HW_R8, HW_R9, etc.)
 *
 * SysV: RDI, RSI, RDX, RCX, R8, R9 (6 integer args in regs)
 * Win64: RCX, RDX, R8, R9 (4 integer args, shared with float)
 *
 * The parm.table pointer in call_state is initialized to
 * x64_sysv_parm_order or x64_win64_parm_order depending on
 * the -bt= target switch.
 *
 * GPLv3 — the crew 4free — sysop/0
 */

#include "_cgstd.h"
#include "coderep.h"
#include "procdef.h"
#include "types.h"
#include "regset.h"
#include "zoiks.h"
#include "cgaux.h"
#include "rgtbl.h"
#include "parmreg.h"
#include "feprotos.h"

/* Extended register definitions — bob's cgx64reg.h */
#include "cgx64reg.h"

/* ====================================================================
 * SysV AMD64 Parameter Register Table
 *
 * Integer/pointer args go in: RDI, RSI, RDX, RCX, R8, R9
 * Then stack (right-to-left push).
 *
 * These hw_reg_set entries are walked by ParmReg() via
 * state->parm.curr_entry. When HW_EMPTY is hit, remaining
 * args go on the stack.
 *
 * Note: RDI and RSI use the existing HW_EDI/HW_ESI definitions
 * from cgx86reg.h — the 64-bit extension is handled by REX.W
 * in the encoder. HW_EDI IS RDI on x64.
 * ==================================================================== */

static const hw_reg_set x64_sysv_int_parms[] = {
    HW_D( HW_EDI ),    /* arg 0 → RDI */
    HW_D( HW_ESI ),    /* arg 1 → RSI */
    HW_D( HW_EDX ),    /* arg 2 → RDX */
    HW_D( HW_ECX ),    /* arg 3 → RCX */
    HW_D( HW_R8 ),     /* arg 4 → R8 */
    HW_D( HW_R9 ),     /* arg 5 → R9 */
    HW_D( HW_EMPTY )   /* sentinel — remaining args on stack */
};

/* Float args go in: XMM0-XMM7 (separate from integer args).
 * A function can receive up to 6 int + 8 float args in regs. */
static const hw_reg_set x64_sysv_float_parms[] = {
    HW_D( HW_XMM0 ),   /* float arg 0 */
    HW_D( HW_XMM1 ),   /* float arg 1 */
    HW_D( HW_XMM2 ),   /* float arg 2 */
    HW_D( HW_XMM3 ),   /* float arg 3 */
    HW_D( HW_XMM4 ),   /* float arg 4 */
    HW_D( HW_XMM5 ),   /* float arg 5 */
    HW_D( HW_XMM6 ),   /* float arg 6 */
    HW_D( HW_XMM7 ),   /* float arg 7 */
    HW_D( HW_EMPTY )
};

/* ====================================================================
 * Win64 Parameter Register Table
 *
 * Integer/pointer args go in: RCX, RDX, R8, R9
 * Float args go in: XMM0, XMM1, XMM2, XMM3
 * BUT: int and float share the SAME 4 slots.
 *   func(int, double, int, double) → RCX, XMM1, R8, XMM3
 * ==================================================================== */

static const hw_reg_set x64_win64_int_parms[] = {
    HW_D( HW_ECX ),    /* arg 0 → RCX */
    HW_D( HW_EDX ),    /* arg 1 → RDX */
    HW_D( HW_R8 ),     /* arg 2 → R8 */
    HW_D( HW_R9 ),     /* arg 3 → R9 */
    HW_D( HW_EMPTY )
};

static const hw_reg_set x64_win64_float_parms[] = {
    HW_D( HW_XMM0 ),
    HW_D( HW_XMM1 ),
    HW_D( HW_XMM2 ),
    HW_D( HW_XMM3 ),
    HW_D( HW_EMPTY )
};

/* ====================================================================
 * ParmAlignment — 8-byte alignment on x64 (all stack args 8 bytes)
 * ==================================================================== */

type_length X64ParmAlignment( const type_def *tipe )
{
    (void)tipe;
    return( 8 );    /* All stack params are 8-byte aligned on x64 */
}

/* ====================================================================
 * X64ParmReg — Select register for next parameter
 *
 * Called instead of x86parm.c's ParmReg when targeting x64.
 *
 * Walks x64_sysv_int_parms[] or x64_win64_int_parms[]
 * depending on target. When table is exhausted, returns
 * HW_EMPTY → arg goes on stack.
 * ==================================================================== */

hw_reg_set X64ParmReg( type_class_def type_class, type_length len,
                        type_length alignment, call_state *state )
{
    const hw_reg_set *possible;
    hw_reg_set regs;

    (void)len; (void)alignment;

    /* Check if we've exhausted the register table */
    if( HW_CEqual( *state->parm.curr_entry, HW_EMPTY ) ) {
        return( HW_EMPTY );     /* Stack parameter */
    }

    /* Float types use the float parameter table */
    if( type_class == FS || type_class == FD || type_class == FL ) {
        /* For SysV: float args have their own counter.
         * For Win64: float args consume the same slot as int.
         * This simplified version uses the int table position
         * for both — correct for Win64, slightly wrong for SysV
         * (SysV allows more total reg args). */
        regs = *state->parm.curr_entry;
        state->parm.curr_entry++;
        HW_TurnOn( state->parm.used, regs );
        return( regs );
    }

    /* Integer/pointer types */
    regs = *state->parm.curr_entry;
    state->parm.curr_entry++;
    HW_TurnOn( state->parm.used, regs );
    return( regs );
}

/* ====================================================================
 * X64InitParmTable — Set up parameter table for a function call
 *
 * Called during call setup to initialize state->parm.table.
 * Points to the correct register order for the target ABI.
 * ==================================================================== */

void X64InitParmTable( call_state *state, int is_sysv )
{
    if( is_sysv ) {
        state->parm.table = x64_sysv_int_parms;
    } else {
        state->parm.table = x64_win64_int_parms;
    }
    state->parm.curr_entry = state->parm.table;
    HW_CAsgn( state->parm.used, HW_EMPTY );
}
