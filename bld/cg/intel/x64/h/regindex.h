/*
 * openwatcomirc — x86_64 register index table
 * 
 * Extends the x86 register table with 64-bit GPRs (RAX-R15)
 * and XMM registers. Used by the x86_64 code generator.
 *
 * Format: pick(id, encoding_index, register_class)
 *   id    — register name (matches HW_xxx)
 *   idx   — 3-bit encoding value (0-7)
 *   cls   — GPR, FPR, XMR (new: XMM register class)
 *
 * For R8-R15: encoding is 0-7 with REX.B=1
 * The encoder checks HW_X64_NEEDS_REX_B() to decide.
 */

#ifdef MAPREGCLASS
#define pick0(id,idx,cls)
#define pick1(id,idx,cls,s1,s2)     pick_start(s1) = pick_item(id), pick_start(s2) = pick_item(id),
#define pick2(id,idx,cls,e1,s1)     pick_end(e1) = pick_item(id), pick_start(s1) = pick_item(id),
#define pick3(id,idx,cls,e1,e2,s1)  pick_end(e1) = pick_item(id), pick_end(e2) = pick_item(id), pick_start(s1) = pick_item(id),
#define pick4(id,e1)                pick_end(e1) = pick_item(id),
#else
#define pick0(id,idx,cls)           pick(id,idx,cls)
#define pick1(id,idx,cls,s1,s2)     pick(id,idx,cls)
#define pick2(id,idx,cls,e1,s1)     pick(id,idx,cls)
#define pick3(id,idx,cls,e1,e2,s1)  pick(id,idx,cls)
#define pick4(id,e1)
#endif

/* 8-bit registers — same as 386 */
/*    id  idx  cls */
pick1( AL,  0,  GPR, GPR, BYTE )
pick0( CL,  1,  GPR )
pick0( DL,  2,  GPR )
pick0( BL,  3,  GPR )
pick0( AH,  4,  GPR )
pick0( CH,  5,  GPR )
pick0( DH,  6,  GPR )
pick0( BH,  7,  GPR )

/* 16-bit registers */
pick2( AX,  0,  GPR, BYTE, WORD )
pick0( CX,  1,  GPR )
pick0( DX,  2,  GPR )
pick0( BX,  3,  GPR )
pick0( SP,  4,  GPR )
pick0( BP,  5,  GPR )
pick0( SI,  6,  GPR )
pick0( DI,  7,  GPR )

/* 32-bit registers (also represent 64-bit RAX-RDI in 64-bit mode) */
pick2( EAX, 0,  GPR, WORD, DWORD )
pick0( ECX, 1,  GPR )
pick0( EDX, 2,  GPR )
pick0( EBX, 3,  GPR )
pick0( ESP, 4,  GPR )
pick0( EBP, 5,  GPR )
pick0( ESI, 6,  GPR )
pick0( EDI, 7,  GPR )

/* x86_64 extended GPRs — encoding 0-7 with REX.B=1 */
pick2( R8,  0,  GPR, DWORD, QWORD )
pick0( R9,  1,  GPR )
pick0( R10, 2,  GPR )
pick0( R11, 3,  GPR )
pick0( R12, 4,  GPR )
pick0( R13, 5,  GPR )
pick0( R14, 6,  GPR )
pick0( R15, 7,  GPR )

/* x87 FPU */
pick3( ST0, 0,  FPR, QWORD, GPR, FPR )
pick0( ST1, 1,  FPR )
pick0( ST2, 2,  FPR )
pick0( ST3, 3,  FPR )
pick0( ST4, 4,  FPR )
pick0( ST5, 5,  FPR )
pick0( ST6, 6,  FPR )
pick0( ST7, 7,  FPR )

/* Segment registers (mostly irrelevant in 64-bit flat model) */
pick2( ES,  0,  SEG, FPR, SEG )
pick0( CS,  1,  SEG )
pick0( SS,  2,  SEG )
pick0( DS,  3,  SEG )
pick0( FS,  4,  SEG )
pick0( GS,  5,  SEG )
pick4( END, SEG )

#undef pick0
#undef pick1
#undef pick2
#undef pick3
#undef pick4
