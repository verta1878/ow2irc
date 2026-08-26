/****************************************************************************
*
*                            Open Watcom Project
*
* Copyright (c) 2002-2022 The Open Watcom Contributors. All Rights Reserved.
*    Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
*
*  ========================================================================
*
*    This file contains Original Code and/or Modifications of Original
*    Code as defined in and that are subject to the Sybase Open Watcom
*    Public License version 1.0 (the 'License'). You may not use this file
*    except in compliance with the License. BY USING THIS FILE YOU AGREE TO
*    ALL TERMS AND CONDITIONS OF THE LICENSE. A copy of the License is
*    provided with the Original Code and Modifications, and is also
*    available at www.sybase.com/developer/opensource.
*
*    The Original Code and all software distributed under the License are
*    distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
*    EXPRESS OR IMPLIED, AND SYBASE AND ALL CONTRIBUTORS HEREBY DISCLAIM
*    ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF
*    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR
*    NON-INFRINGEMENT. Please see the License for the specific language
*    governing rights and limitations under the License.
*
*  ========================================================================
*
* Description:  WHEN YOU FIGURE OUT WHAT THIS FILE DOES, PLEASE
*               DESCRIBE IT HERE!
*
****************************************************************************/


#include "_cgstd.h"
#include "coderep.h"
#include "opctable.h"
#include "zoiks.h"
#include "optab.h"
#include "feprotos.h"


const opcode_entry  *CodeTable( instruction *ins )
/************************************************/
{
    int         idx;
    table_def   opcode_idx;

    idx = ins->head.opcode;
    idx *= ( XX + 1 );
#if _TARGET & _TARG_X64
    /* On x86-64, 8-byte integer and pointer operations use the same
     * single-register instruction patterns as 4-byte operations.
     * REX.W (added by LayOpndSize) promotes them to 64-bit operand size.
     * Without this remap, the CG uses the 386 EDX:EAX pair tables
     * for U8/I8 and the far-pointer segment:offset tables for CP/PT,
     * neither of which applies to flat-model x86-64.
     *
     * Both the table index AND the instruction's type_class must be
     * remapped. The table index selects the right instruction patterns
     * (single-register, not pair or segment:offset). The type_class
     * remap ensures the register allocator uses 4-byte register sets
     * (which are the 8-byte registers in disguise — EAX is RAX).
     * The original type_class is preserved in base_type_class so
     * LayOpndSize can still emit REX.W for 64-bit operands. */
    {
        type_class_def tc = ins->type_class;
        /* Exempt OP_CONVERT with U8/I8 type_class from remap.
         * These are widening conversions (U4→U8, I4→I8) created by
         * rDIVREGISTER for CDQ sign-extension before IDIV. They need
         * the Cnv8 table (which has RG_CDQ: EAX→EDX:EAX) not Cnv4. */
        if( ins->head.opcode == OP_CONVERT
          && ( tc == U8 || tc == I8 ) ) {
            /* keep tc as U8/I8 for Cnv8 table lookup */
        } else if( tc == U8 || tc == CP || tc == PT ) {
            ins->base_type_class = tc;
            ins->type_class = U4;
            tc = U4;
        } else if( tc == I8 ) {
            ins->base_type_class = tc;
            ins->type_class = I4;
            tc = I4;
        }
        idx += tc;
    }
#else
    idx += ins->type_class;
#endif
    opcode_idx = OpTable[idx];
    if( opcode_idx == BAD ) {
        _Zoiks( ZOIKS_052 );
    }
#if _TARGET_RISC
    if( opcode_idx == NYI ) {
        _Zoiks( ZOIKS_091 );
    }
#endif
    return( OpcodeTable( opcode_idx ) );
}


void    DoNothing( instruction *ins )
/***********************************/
{
    ins->table = OpcodeTable( DONOTHING );
    ins->u.gen_table = ins->table;
}


bool    DoesSomething( instruction *ins )
/***************************************/
{
    if( ins->u.gen_table == NULL )
        return( true );
    if( G( ins ) != G_NO )
        return( true );
    return( false );
}
