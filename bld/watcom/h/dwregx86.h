/****************************************************************************
*
*                            Open Watcom Project
*
* Copyright (c) 2002-2023 The Open Watcom Contributors. All Rights Reserved.
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
* Description:  DWARF x86 register definitions and related data.
*
****************************************************************************/

/*    id      name    ci   start len */
pick( EAX,    eax,    CI_EAX, 0, 32 )
pick( ECX,    ecx,    CI_ECX, 0, 32 )
pick( EDX,    edx,    CI_EDX, 0, 32 )
pick( EBX,    ebx,    CI_EBX, 0, 32 )
pick( ESP,    esp,    CI_ESP, 0, 32 )
pick( EBP,    ebp,    CI_EBP, 0, 32 )
pick( ESI,    esi,    CI_ESI, 0, 32 )
pick( EDI,    edi,    CI_EDI, 0, 32 )
pick( EIP,    eip,    CI_EIP, 0, 32 )
pick( EFLAGS, eflags, CI_EFL, 0, 32 )
pick( TRAPNO, trapno, 0,      0, 0  )
pick( ST0,    st0,    CI_ST0, 0, 80 )
pick( ST1,    st1,    CI_ST1, 0, 80 )
pick( ST2,    st2,    CI_ST2, 0, 80 )
pick( ST3,    st3,    CI_ST3, 0, 80 )
pick( ST4,    st4,    CI_ST4, 0, 80 )
pick( ST5,    st5,    CI_ST5, 0, 80 )
pick( ST6,    st6,    CI_ST6, 0, 80 )
pick( ST7,    st7,    CI_ST7, 0, 80 )
pick( AL,     al,     CI_EAX, 0, 8  )
pick( AH,     ah,     CI_EAX, 8, 8  )
pick( BL,     bl,     CI_EBX, 0, 8  )
pick( BH,     bh,     CI_EBX, 8, 8  )
pick( CL,     cl,     CI_ECX, 0, 8  )
pick( CH,     ch,     CI_ECX, 8, 8  )
pick( DL,     dl,     CI_EDX, 0, 8  )
pick( DH,     dh,     CI_EDX, 8, 8  )
pick( AX,     ax,     CI_EAX, 0, 16 )
pick( BX,     bx,     CI_EBX, 0, 16 )
pick( CX,     cx,     CI_ECX, 0, 16 )
pick( DX,     dx,     CI_EDX, 0, 16 )
pick( SI,     si,     CI_ESI, 0, 16 )
pick( DI,     di,     CI_EDI, 0, 16 )
pick( BP,     bp,     CI_EBP, 0, 16 )
pick( SP,     sp,     CI_ESP, 0, 16 )
pick( CS,     cs,     CI_CS,  0, 16 )
pick( SS,     ss,     CI_SS,  0, 16 )
pick( DS,     ds,     CI_DS,  0, 16 )
pick( ES,     es,     CI_ES,  0, 16 )
pick( FS,     fs,     CI_FS,  0, 16 )
pick( GS,     gs,     CI_GS,  0, 16 )
/* x86-64 extended registers (OW2IRC) — DWARF x86-64 ABI numbering */
pick( R8,     r8,     CI_R8,   0, 64 )
pick( R9,     r9,     CI_R9,   0, 64 )
pick( R10,    r10,    CI_R10,  0, 64 )
pick( R11,    r11,    CI_R11,  0, 64 )
pick( R12,    r12,    CI_R12,  0, 64 )
pick( R13,    r13,    CI_R13,  0, 64 )
pick( R14,    r14,    CI_R14,  0, 64 )
pick( R15,    r15,    CI_R15,  0, 64 )
pick( XMM0,   xmm0,   CI_XMM0,  0, 128 )
pick( XMM1,   xmm1,   CI_XMM1,  0, 128 )
pick( XMM2,   xmm2,   CI_XMM2,  0, 128 )
pick( XMM3,   xmm3,   CI_XMM3,  0, 128 )
pick( XMM4,   xmm4,   CI_XMM4,  0, 128 )
pick( XMM5,   xmm5,   CI_XMM5,  0, 128 )
pick( XMM6,   xmm6,   CI_XMM6,  0, 128 )
pick( XMM7,   xmm7,   CI_XMM7,  0, 128 )
pick( XMM8,   xmm8,   CI_XMM8,  0, 128 )
pick( XMM9,   xmm9,   CI_XMM9,  0, 128 )
pick( XMM10,  xmm10,  CI_XMM10, 0, 128 )
pick( XMM11,  xmm11,  CI_XMM11, 0, 128 )
pick( XMM12,  xmm12,  CI_XMM12, 0, 128 )
pick( XMM13,  xmm13,  CI_XMM13, 0, 128 )
pick( XMM14,  xmm14,  CI_XMM14, 0, 128 )
pick( XMM15,  xmm15,  CI_XMM15, 0, 128 )
