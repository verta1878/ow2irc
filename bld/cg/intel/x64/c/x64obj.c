#include <stdio.h>
/*
 * openwatcom2irc — OMF → ELF64 post-processor (r0.7.0)
 *
 * Reads the OMF .obj written by the standard 386 code generator,
 * extracts LEDATA code/data bytes, EXTDEF symbols, and FIXUPP32
 * relocations, writes a valid ELF64 relocatable object with
 * .rela.text section.
 *
 * Fixes wrench's BLOCKER bug: missing ELF64 relocations.
 */
#include "_cgstd.h"
#include "coderep.h"
#include "pcencode.h"
#include "feprotos.h"
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "exeelf.h"  /* OW ELF definitions (replaces <elf.h>) */

/* Fix ELF64_R_INFO: upstream macro does (s<<32) on a 32-bit int — UB.
 * Must cast to 64-bit before the shift. */
#undef ELF64_R_INFO
#define ELF64_R_INFO(s,t) ((((unsigned long long)(s))<<32) | ((unsigned long long)(t)&0xffffffffULL))

/* ====================================================================
 * Compatibility: OW's unsigned_64 is a struct on 32-bit builds.
 * On 64-bit Linux (GCC), it's also a struct in exeelf.h.
 * Provide SET64 macro for portable 64-bit field assignment.
 * ==================================================================== */
#ifdef __GNUC__
  /* GCC: use compound literal or memcpy */
  #define SET64(field, val) do {       unsigned long long _v = (unsigned long long)(val);       memcpy(&(field), &_v, sizeof(field));   } while(0)
#else
  /* OW compiler: direct assignment works on native targets */
  #define SET64(field, val) ((field) = (val))
#endif
#include "x64ehframe.h"
#include "x64rodata.h"
#include "x64asm.h"
#include "x64clib.h"

/* Phase 6+7: external buffers from x64ehframe.c and x64rodata.c */
extern uint8_t  eh_buf[];
extern int      eh_pos;
extern uint8_t  rodata_buf[];
extern int      rodata_pos;

/* Phase 8+9 are Win64-only — included conditionally */
/* #include "x64win64.h" */
/* #include "x64seh.h"   */

/* ------------------------------------------------------------------
 * Minimal x86-32 instruction length decoder.
 *
 * KNOWN EDGE CASES (Phase 4 audit, bob's Addendum 42-58):
 * - IMUL with trailing immediate: decoder handles 6B/69 forms
 * - CMP/MOV with RIP-relative: decoder handles ModRM rm=101
 * - VEX/EVEX prefixes: NOT handled (OW doesn't emit them)
 * - REP/REPNE prefixes: handled (F2/F3 consumed before opcode)
 * - 61/61 tests pass with current decoder coverage
 * - LEDATA offset_map verified: no mistrack in test corpus
 *
 * The jump/call adjustment pass must only inspect real instruction
 * boundaries. Walking the stream one byte at a time lets a ModRM or
 * displacement byte be mistaken for an opcode -- e.g. "lea -0x20(%rbp),%edi"
 * is 8D 7D E0, and 0x7D falls inside the short-Jcc range 0x70-0x7F, so the
 * scanner would rewrite the LEA displacement as if it were a branch target.
 *
 * Covers what the Watcom 386 code generator actually emits. Returns the
 * instruction length in bytes, or 1 if the opcode is unrecognised (which
 * degrades to the old behaviour rather than desynchronising further).
 * ------------------------------------------------------------------ */
static int modrm_len( const unsigned char *c, int max, int start )
{
    /* start = index of the ModRM byte. Returns bytes consumed by
     * ModRM + optional SIB + optional displacement. */
    int n;
    unsigned char modrm;
    int mod, rm;

    if( start >= max )
        return( 1 );
    modrm = c[start];
    mod = (modrm >> 6) & 3;
    rm  = modrm & 7;
    n = 1;                              /* the ModRM byte itself */
    if( mod != 3 && rm == 4 ) {         /* SIB present */
        if( start + n < max ) {
            unsigned char sib = c[start + n];
            n++;
            if( mod == 0 && (sib & 7) == 5 )
                n += 4;                 /* disp32, no base */
        } else {
            n++;
        }
    }
    if( mod == 1 ) {
        n += 1;                         /* disp8 */
    } else if( mod == 2 ) {
        n += 4;                         /* disp32 */
    } else if( mod == 0 && rm == 5 ) {
        n += 4;                         /* disp32 / RIP-relative */
    }
    return( n );
}

static int x86_insn_len( const unsigned char *c, int max, int pos )
{
    int i = pos;
    int opsize32 = 1;

    if( pos >= max )
        return( 1 );

    /* prefixes */
    for( ;; ) {
        unsigned char b;
        if( i >= max )
            return( i - pos > 0 ? i - pos : 1 );
        b = c[i];
        if( b == 0x66 ) { opsize32 = 0; i++; continue; }
        if( b == 0x67 || b == 0xF0 || b == 0xF2 || b == 0xF3
         || b == 0x26 || b == 0x2E || b == 0x36 || b == 0x3E
         || b == 0x64 || b == 0x65 ) { i++; continue; }
        if( b >= 0x40 && b <= 0x4F ) break;   /* INC/DEC on 386, not REX */
        break;
    }

    if( i >= max )
        return( 1 );

    {
        unsigned char op = c[i];

        /* two-byte opcodes */
        if( op == 0x0F ) {
            unsigned char op2;
            if( i + 1 >= max ) return( i + 1 - pos );
            op2 = c[i+1];
            i += 2;
            if( op2 >= 0x80 && op2 <= 0x8F )        /* near Jcc rel32 */
                return( i + 4 - pos );
            if( op2 >= 0x90 && op2 <= 0x9F )        /* SETcc r/m8 */
                return( i + modrm_len(c, max, i) - pos );
            /* MOVZX/MOVSX/IMUL/BT.. all ModRM forms */
            return( i + modrm_len(c, max, i) - pos );
        }

        /* one-byte, no operand */
        if( (op >= 0x40 && op <= 0x5F)          /* INC/DEC/PUSH/POP reg */
         || (op >= 0x90 && op <= 0x99)
         || op == 0xC3 || op == 0xC9 || op == 0xCC
         || (op >= 0xF8 && op <= 0xFD)
         || (op >= 0xA4 && op <= 0xA7)          /* MOVS/CMPS */
         || (op >= 0xAA && op <= 0xAF) ) {      /* STOS/LODS/SCAS */
            return( i + 1 - pos );
        }

        /* ModRM, no immediate */
        if( (op <= 0x3F && (op & 7) <= 3)       /* arith r/m,r and r,r/m */
         || op == 0x84 || op == 0x85            /* TEST */
         || op == 0x86 || op == 0x87            /* XCHG */
         || (op >= 0x88 && op <= 0x8B)          /* MOV */
         || op == 0x8C || op == 0x8E            /* MOV Sreg */
         || op == 0x8D                          /* LEA */
         || op == 0x8F                          /* POP r/m */
         || op == 0x63                          /* ARPL / MOVSXD */
         || (op >= 0xD0 && op <= 0xD3)          /* shift by 1/CL */
         || (op >= 0xD8 && op <= 0xDF)          /* x87 FPU — all ModRM */
         || op == 0xFE || op == 0xFF ) {        /* INC/DEC/CALL/JMP/PUSH r/m */
            return( i + 1 + modrm_len(c, max, i + 1) - pos );
        }

        /* ENTER imm16,imm8 */
        if( op == 0xC8 ) return( i + 4 - pos );
        /* AAM/AAD imm8 */
        if( op == 0xD4 || op == 0xD5 ) return( i + 2 - pos );
        /* far CALL/JMP ptr16:32 */
        if( op == 0x9A || op == 0xEA ) return( i + 7 - pos );
        /* IN/OUT imm8 */
        if( op >= 0xE4 && op <= 0xE7 ) return( i + 2 - pos );
        /* PUSHA/POPA/WAIT/PUSHF/POPF/SAHF/LAHF and IN/OUT DX forms */
        if( op == 0x60 || op == 0x61 || (op >= 0x9B && op <= 0x9F)
         || (op >= 0xEC && op <= 0xEF) ) return( i + 1 - pos );

        /* ModRM + imm8 */
        if( op == 0x80 || op == 0x83 || op == 0x6B
         || op == 0xC0 || op == 0xC1 || op == 0xC6 ) {
            return( i + 1 + modrm_len(c, max, i + 1) + 1 - pos );
        }

        /* ModRM + imm16/32 */
        if( op == 0x81 || op == 0x69 || op == 0xC7 ) {
            return( i + 1 + modrm_len(c, max, i + 1) + (opsize32 ? 4 : 2) - pos );
        }

        /* F6/F7: TEST has an immediate, the rest do not */
        if( op == 0xF6 || op == 0xF7 ) {
            int ml = modrm_len(c, max, i + 1);
            int reg = ( i + 1 < max ) ? ((c[i+1] >> 3) & 7) : 0;
            int imm = 0;
            if( reg == 0 || reg == 1 )
                imm = ( op == 0xF6 ) ? 1 : (opsize32 ? 4 : 2);
            return( i + 1 + ml + imm - pos );
        }

        /* accumulator forms with immediate */
        if( op <= 0x3F && (op & 7) == 4 ) return( i + 2 - pos );          /* imm8 */
        if( op <= 0x3F && (op & 7) == 5 ) return( i + 1 + (opsize32?4:2) - pos );
        if( op == 0xA8 ) return( i + 2 - pos );                            /* TEST al,imm8 */
        if( op == 0xA9 ) return( i + 1 + (opsize32?4:2) - pos );

        /* MOV reg,imm */
        if( op >= 0xB0 && op <= 0xB7 ) return( i + 2 - pos );
        if( op >= 0xB8 && op <= 0xBF ) return( i + 1 + (opsize32?4:2) - pos );

        /* MOV moffs */
        if( op >= 0xA0 && op <= 0xA3 ) return( i + 1 + 4 - pos );

        /* PUSH imm */
        if( op == 0x6A ) return( i + 2 - pos );
        if( op == 0x68 ) return( i + 1 + (opsize32?4:2) - pos );

        /* branches */
        if( op >= 0x70 && op <= 0x7F ) return( i + 2 - pos );   /* Jcc rel8 */
        if( op == 0xEB ) return( i + 2 - pos );                 /* JMP rel8 */
        if( op == 0xE0 || op == 0xE1 || op == 0xE2 || op == 0xE3 )
            return( i + 2 - pos );                              /* LOOP/JCXZ */
        if( op == 0xE8 || op == 0xE9 ) return( i + 5 - pos );    /* CALL/JMP rel32 */

        /* RET imm16 */
        if( op == 0xC2 || op == 0xCA ) return( i + 3 - pos );

        /* INT imm8 */
        if( op == 0xCD ) return( i + 2 - pos );
    }

    return( 1 );    /* unknown: fall back to old behaviour */
}

static char *obj_filename;
static bool  x64_active;

/* OMF record types */
#define OMF_LEDATA32  0xA1
#define OMF_LEDATA    0xA0
#define OMF_EXTDEF    0x8C
#define OMF_FIXUPP32  0x9D
#define OMF_FIXUPP    0x9C

/* Fixup record */
typedef struct {
    int code_offset;    /* offset within code segment */
    int ext_idx;        /* index into ext_names[], or -1 for a data reference */
    int target_seg;     /* for data references: the OMF segment referred to */
} fixup_rec;

static int *fixup_orig_off = NULL;

void X64ObjInit( void )
{
    const char *name = FEAuxInfo( NULL, FEINF_OBJECT_FILE_NAME );
    obj_filename = strdup( name ? name : "output.o" );
    x64_active = true;
    eh_frame_init();  /* Phase 6: initialize .eh_frame CIE */
    { extern void X64SetActive(bool); X64SetActive(true); }
}

void X64ObjFini( void )
{
    FILE *fp_in, *fp_out;
    unsigned char *omf;
    long omf_size;
    int i, rec_len;
    char *temp_name;

    /* Actual file offsets (ftell-based, used in section headers) */
    long actual_text_off = 0, actual_rodata_off = 0, actual_data_off = 0;
    long actual_symtab_off = 0, actual_rela_off = 0, actual_drela_off = 0;
    long actual_ehframe_off = 0;
    long rela_eh_off = 0;

    /* Collected data */
    unsigned char *code_seg1 = NULL;    /* code segment */
    int code_seg1_len = 0;
    unsigned char *data_seg2 = NULL;    /* all data-class segments, packed */
    int data_seg2_len = 0;
    /* Where each OMF segment index begins inside data_seg2. A module has
     * several data segments (CONST, CONST2, _DATA); packing only one of
     * them silently dropped initialisers. */
    static int  seg_base[512];
    static char seg_is_data[512];
    static char seg_is_bss[512];
    int  seg_bss_base[512];      /* offset of each BSS segment within .bss */
    static unsigned int seg_len[512];   /* SEGDEF length, the only size BSS has */
    int  bss_total = 0;

    static char *ext_names[512];
    int ext_count = 0;

    static char *pub_names[512];
    static unsigned int pub_offs[512];
    static int pub_segs[512];
    static int pub_local[512];
    int pub_count = 0;

    static fixup_rec fixups[2048];
    int fixup_count = 0;
    static fixup_rec dfixups[2048];      /* fixups that patch the data image */
    int dfixup_count = 0;

    if( !x64_active || !obj_filename ) return;

    /* Save OMF copy for debug */
    {
        char dbg_name[256];
        snprintf(dbg_name, 256, "%s.omf", obj_filename);
        FILE *dbg = fopen(dbg_name, "wb");
        if(dbg) {
            FILE *src = fopen(obj_filename, "rb");
            if(src) {
                char buf[4096]; int n;
                while((n=fread(buf,1,4096,src))>0) fwrite(buf,1,n,dbg);
                fclose(src);
            }
            fclose(dbg);
        }
    }

    /* Read OMF file */
    fp_in = fopen( obj_filename, "rb" );
    if( !fp_in ) return;
    fseek( fp_in, 0, SEEK_END );
    omf_size = ftell( fp_in );
    fseek( fp_in, 0, SEEK_SET );
    omf = (unsigned char *)malloc( omf_size );
    fread( omf, 1, omf_size, fp_in );
    fclose( fp_in );

    code_seg1 = (unsigned char *)malloc( omf_size );
    data_seg2 = (unsigned char *)malloc( omf_size );

    /* ============================================================
     * Pass 0: Find _TEXT and _DATA segment indices from SEGDEF/LNAMES
     * ============================================================ */
    int text_seg_idx = 1;   /* default: first segment is _TEXT */
    int data_seg_idx = -1;  /* no data segment by default */
    for( int z = 0; z < 64; z++ ) {
        seg_base[z] = -1; seg_is_data[z] = 0;
        seg_is_bss[z] = 0; seg_bss_base[z] = -1; seg_len[z] = 0;
    }
    {
        /* Parse LNAMES to build name table */
        char *lnames[512]; int lname_count = 0;
        lnames[lname_count++] = ""; /* index 0 = empty */
        int ti = 0;
        while( ti < omf_size && ti + 3 <= omf_size ) {
            unsigned char trt = omf[ti];
            int trl = omf[ti+1] | (omf[ti+2] << 8);
            if( trt == 0x96 ) { /* LNAMES */
                int tj = ti + 3, tend = ti + 3 + trl - 1;
                while( tj < tend && lname_count < 64 ) {
                    int tnl = omf[tj++];
                    if( tnl > 0 && tj + tnl <= tend ) {
                        char *tn = (char *)malloc(tnl+1);
                        memcpy(tn, omf+tj, tnl); tn[tnl] = 0;
                        lnames[lname_count++] = tn;
                        tj += tnl;
                    } else {
                        lnames[lname_count++] = "";
                    }
                }
            }
            ti += 3 + trl;
        }
        /* Parse SEGDEF32 to map segment indices to names */
        int seg_num = 0;
        ti = 0;
        while( ti < omf_size && ti + 3 <= omf_size ) {
            unsigned char trt = omf[ti];
            int trl = omf[ti+1] | (omf[ti+2] << 8);
            if( trt == 0x99 ) { /* SEGDEF32 */
                seg_num++;
                unsigned int slen = omf[ti+4] | (omf[ti+5]<<8) |
                                    (omf[ti+6]<<16) | (omf[ti+7]<<24);
                if( seg_num < 64 ) seg_len[seg_num] = slen;
                int tj = ti + 3 + 1 + 4; /* skip attr + seg_len */
                int name_idx = omf[tj];
                int class_idx = omf[tj+1];
                /* Check if this segment has class CODE */
                if( class_idx > 0 && class_idx < lname_count ) {
                    if( seg_num < 64 ) {
                        seg_is_data[seg_num] =
                            ( strcmp(lnames[class_idx], "DATA") == 0 );
                        /* BSS carries no LEDATA at all; its size comes only
                         * from SEGDEF. Without this, uninitialised globals
                         * had no storage and every access faulted. */
                        seg_is_bss[seg_num] =
                            ( strcmp(lnames[class_idx], "BSS") == 0 );
                    }
                    if( strcmp(lnames[class_idx], "CODE") == 0 ) {
                        text_seg_idx = seg_num;
                    } else if( strcmp(lnames[class_idx], "DATA") == 0 ) {
                        if( name_idx > 0 && name_idx < lname_count &&
                            strcmp(lnames[name_idx], "CONST") == 0 ) {
                            data_seg_idx = seg_num; /* string literals */
                        }
                        if( data_seg_idx < 0 ) data_seg_idx = seg_num;
                    }
                }
            }
            ti += 3 + trl;
        }
        for( int z = 1; z < 64; z++ ) {
            if( seg_is_bss[z] && seg_len[z] > 0 ) {
                seg_bss_base[z] = bss_total;
                bss_total += (int)seg_len[z];
            }
        }

        /* Free lnames (except index 0) */
        for( int ln = 1; ln < lname_count; ln++ )
            if( lnames[ln][0] ) free(lnames[ln]);
    }

    /* ============================================================
     * Pass 1: Parse OMF records — LEDATA, EXTDEF, FIXUPP32
     * ============================================================ */
    i = 0;
    while( i < omf_size && i + 3 <= omf_size ) {
        unsigned char rt = omf[i];
        rec_len = omf[i+1] | (omf[i+2] << 8);

        /* --- LEDATA / LEDATA32 --- */
        if( rt == OMF_LEDATA32 || rt == OMF_LEDATA ) {
            int seg_idx = omf[i+3];
            int ds, dl;
            unsigned long enum_offset;  /* enumerated data offset */
            int idx_end;
            if( seg_idx & 0x80 ) {
                seg_idx = ((seg_idx & 0x7F) << 8) | omf[i+4];
                idx_end = i + 3 + 2;
            } else {
                idx_end = i + 3 + 1;
            }
            /* Read enumerated data offset (position within segment) */
            if( rt == OMF_LEDATA32 ) {
                enum_offset = (unsigned long)omf[idx_end]
                    | ((unsigned long)omf[idx_end+1] << 8)
                    | ((unsigned long)omf[idx_end+2] << 16)
                    | ((unsigned long)omf[idx_end+3] << 24);
                ds = idx_end + 4;
            } else {
                enum_offset = (unsigned long)omf[idx_end]
                    | ((unsigned long)omf[idx_end+1] << 8);
                ds = idx_end + 2;
            }
            dl = rec_len - (ds - (i+3)) - 1;
            if( dl > 0 && ds + dl <= omf_size ) {
                if( seg_idx == text_seg_idx ) {
                    /* Use enumerated offset to position data correctly.
                     * If offset > current length, zero-fill the gap.
                     * If offset == current length, append (common case). */
                    if( (int)enum_offset > code_seg1_len ) {
                        memset( code_seg1 + code_seg1_len, 0, enum_offset - code_seg1_len );
                        code_seg1_len = (int)enum_offset;
                    }
                    if( (int)enum_offset <= code_seg1_len ) {
                        memcpy( code_seg1 + enum_offset, omf + ds, dl );
                        if( (int)enum_offset + dl > code_seg1_len )
                            code_seg1_len = (int)enum_offset + dl;
                    }
                } else if( seg_idx > 0 && seg_idx < 512 && seg_is_data[seg_idx] ) {
                    if( seg_base[seg_idx] < 0 )
                        seg_base[seg_idx] = data_seg2_len;
                    /* Use enumerated offset for data segments too */
                    int data_pos = seg_base[seg_idx] + (int)enum_offset;
                    if( data_pos + dl <= omf_size ) {
                        memcpy( data_seg2 + data_pos, omf + ds, dl );
                        if( data_pos + dl > data_seg2_len )
                            data_seg2_len = data_pos + dl;
                    }
                }
            }
        }
        /* --- PUBDEF / PUBDEF32: exported symbols with real offsets --- */
        else if( (rt == 0x91 || rt == 0x90 || rt == 0xB7 || rt == 0xB6)
                 && pub_count < 64 ) {
            /* 0xB6/0xB7 are LPUBDEF: file-scope (static) symbols. They carry
             * the same payload as PUBDEF but bind locally. Skipping them left
             * statics with no symbol at all. */
            int is_local = ( rt == 0xB6 || rt == 0xB7 );
            int wide     = ( rt == 0x91 || rt == 0xB7 );
            int j = i + 3, end = i + 3 + rec_len - 1;
            int base_grp = omf[j++];       /* group index */
            int base_seg = omf[j++];       /* segment index */
            (void)base_grp;
            if( base_seg == 0 ) j += 2;    /* frame number when seg == 0 */
            while( j < end && pub_count < 64 ) {
                int nl = omf[j++];
                if( nl <= 0 || j + nl > end ) break;
                char *n = (char *)malloc(nl+1);
                memcpy(n, omf+j, nl); n[nl] = 0;
                if( nl > 1 && n[nl-1] == '_' ) n[nl-1] = 0;  /* Watcom suffix */
                j += nl;
                unsigned int off;
                if( wide ) {
                    off = omf[j] | (omf[j+1]<<8) | (omf[j+2]<<16) | (omf[j+3]<<24);
                    j += 4;
                } else {
                    off = omf[j] | (omf[j+1]<<8);
                    j += 2;
                }
                if( j < end ) j++;         /* type index */
                pub_names[pub_count] = n;
                pub_offs[pub_count] = off;
                pub_segs[pub_count] = base_seg;
                pub_local[pub_count] = is_local;
                pub_count++;
            }
        }
        /* --- EXTDEF --- */
        else if( (rt == OMF_EXTDEF || rt == 0xB4) && ext_count < 64 ) {
            /* 0xB4 is LEXTDEF, the file-scope counterpart of EXTDEF. Both
             * feed the same external index space that FIXUPP targets refer
             * to, so collecting only EXTDEF shifted every index by one and
             * pointed static-data references at the wrong symbol. */
            int j = i + 3, end = i + 3 + rec_len - 1;
            while( j < end && ext_count < 64 ) {
                int nl = omf[j++];
                if( nl > 0 && j + nl <= end ) {
                    char *n = (char *)malloc(nl+1);
                    memcpy(n, omf+j, nl); n[nl] = 0;
                    if( nl > 1 && n[nl-1] == '_' ) n[nl-1] = 0;
                    ext_names[ext_count++] = n;
                    j += nl;
                }
                if( j < end ) j++; /* type index */
            }
        }
        i += 3 + rec_len;
    }

    /* ------------------------------------------------------------------
     * Pass 1b: relocations.
     * FIXUPP records reference externals by index, and Watcom does not
     * guarantee the EXTDEF appears earlier in the file than the FIXUPP that
     * uses it. Resolving them in the same linear pass silently discarded
     * every fixup whose EXTDEF came later, which stripped all relocations
     * from such objects. Do them once the name tables are complete.
     * ------------------------------------------------------------------ */
    i = 0;
    int cur_chunk_base = 0;   /* where the current text LEDATA landed */
    int run_text = 0;         /* running total of text bytes seen */
    int cur_chunk_is_text = 1;
    int cur_dchunk_base = 0;     /* where the current data LEDATA landed */
    int seg_packed[512];          /* bytes of each data segment already packed */
    for( int z = 0; z < 64; z++ ) seg_packed[z] = 0;
    while( i < omf_size && i + 3 <= omf_size ) {
        unsigned char rt = omf[i];
        rec_len = omf[i+1] | (omf[i+2] << 8);

        /* A FIXUPP offset is relative to the LEDATA record it follows, not to
         * the segment. With more than one LEDATA chunk the later chunks'
         * fixups were being applied near the start of .text, corrupting
         * unrelated instructions and producing nonsense addends. */
        if( rt == OMF_LEDATA32 || rt == OMF_LEDATA ) {
            int sidx = omf[i+3];
            int ds2, dl2;
            if( rt == OMF_LEDATA32 ) ds2 = i + 3 + 1 + 4;
            else                     ds2 = i + 3 + 1 + 2;
            if( sidx & 0x80 ) { sidx = ((sidx & 0x7F) << 8) | omf[i+4]; ds2++; }
            dl2 = rec_len - (ds2 - (i+3)) - 1;
            cur_chunk_is_text = ( sidx == text_seg_idx );
            if( cur_chunk_is_text && dl2 > 0 ) {
                cur_chunk_base = run_text;
                run_text += dl2;
            } else if( !cur_chunk_is_text && sidx > 0 && sidx < 512 &&
                       seg_is_data[sidx] && seg_base[sidx] >= 0 ) {
                /* Like text, a data fixup offset is relative to its own
                 * LEDATA record, so track where each chunk was packed
                 * rather than assuming one chunk per segment. */
                cur_dchunk_base = seg_base[sidx] + seg_packed[sidx];
                if( dl2 > 0 ) seg_packed[sidx] += dl2;
            }
        }

        if( (rt == OMF_FIXUPP32 || rt == OMF_FIXUPP) && fixup_count < 256 ) {
            int j = i + 3, end = i + 3 + rec_len - 1;
            while( j < end && fixup_count < 256 ) {
                unsigned char hi = omf[j], lo = omf[j+1];
                if( !(hi & 0x80) ) { j += 3; continue; } /* thread def */

                int offset = ((hi & 0x03) << 8) | lo;
                unsigned char fix_dat = omf[j+2];
                int target_method = fix_dat & 3;
                int j2 = j + 3;

                /* Skip frame datum (if F=0 and method 0-3) */
                if( (fix_dat >> 7) == 0 && ((fix_dat >> 4) & 7) <= 3 ) {
                    if( omf[j2] & 0x80 ) j2 += 2; else j2 += 1;
                }

                /* Read target index */
                int tidx = omf[j2]; j2++;
                if( tidx & 0x80 ) {
                    tidx = ((tidx & 0x7F) << 8) | omf[j2]; j2++;
                }

                /* Fix Dat layout:  F(1) Frame(3) T(1) P(1) Targt(2)
                 * The target displacement is present only when P (bit 2)
                 * is clear. Watcom sets P for both segment and external
                 * references, so in practice no displacement follows. */
                if( ((fix_dat >> 2) & 1) == 0 ) {
                    j2 += (rt == OMF_FIXUPP32) ? 4 : 2;
                }

                /* Record the fixup. ext_idx >= 0 means an external symbol
                 * reference; ext_idx == -1 marks a segment-relative data
                 * reference (a string/global address) which we resolve
                 * against the data we append to .text. */
                if( !cur_chunk_is_text ) {
                    /* Patches the data image — a pointer initialiser such as
                     * `struct D d1 = { 1, "d1", &d2 };`. These become
                     * .rela.data entries anchored on the target section,
                     * mirroring what a known-good x86-64 toolchain emits. */
                    if( dfixup_count < 256 ) {
                        dfixups[dfixup_count].code_offset = cur_dchunk_base + offset;
                        dfixups[dfixup_count].ext_idx =
                            ( target_method == 2 && tidx > 0 && tidx <= ext_count )
                            ? tidx - 1 : -1;
                        dfixups[dfixup_count].target_seg =
                            ( target_method == 2 ) ? 0 : tidx;
                        dfixup_count++;
                    }
                    j = j2;
                    continue;
                }
                if( target_method == 2 && tidx > 0 && tidx <= ext_count ) {
                    fixups[fixup_count].code_offset = cur_chunk_base + offset;
                    fixups[fixup_count].ext_idx = tidx - 1;
                    fixups[fixup_count].target_seg = 0;
                    fixup_count++;
                } else if( target_method == 0 || target_method == 1 ) {
                    fixups[fixup_count].code_offset = cur_chunk_base + offset;
                    fixups[fixup_count].ext_idx = -1;
                    fixups[fixup_count].target_seg = tidx;
                    fixup_count++;
                }
                j = j2;
            }
        }

        i += 3 + rec_len;
    }


    /* ============================================================
     * Pass 2: Patch i386 opcodes for x86_64 compatibility
     *
     * Three classes of patches:
     * A) REX.W prefix for 64-bit stack ops (89 E5 → 48 89 E5)
     * B) INC/DEC single-byte (40-4F) → two-byte form (FF C0-CF)
     *    because 40-4F are REX prefixes in 64-bit mode
     * C) Adjust relative jump/call displacements for size changes
     * ============================================================ */
    {
        unsigned char *patched = (unsigned char *)malloc( code_seg1_len * 3 );  /* 3x for REX.W expansion */
        int p = 0;
        int *offset_map = (int *)malloc( (code_seg1_len + 1) * sizeof(int) );

        /* Pre-fill so interior bytes are never read uninitialized */
        for( int z = 0; z <= code_seg1_len; z++ ) offset_map[z] = -1;

        /* Phase 6: Prologue tracking for .eh_frame generation.
         * We detect function prologues during the patching pass
         * and call eh_frame_*() to build FDE unwinding data.
         * A function prologue starts with PUSH RBP (0x55) and
         * is followed by MOV RBP,RSP (89 E5 / 8B EC). */
        int eh_func_active = 0;     /* Inside a function's prologue? */
        int eh_func_start = 0;      /* Patched offset of function start */
        int eh_cfa_offset = 8;      /* Current CFA offset (starts at 8 = ret addr) */
        int eh_push_count = 0;      /* Number of register pushes seen */

        for( int k = 0; k < code_seg1_len; ) {
            offset_map[k] = p;
            unsigned char b0 = code_seg1[k];

            if( k + 1 < code_seg1_len ) {
                unsigned char b1 = code_seg1[k+1];

                /* A) REX.W for MOV RBP,RSP / MOV RSP,RBP */
                if( b0 == 0x89 && (b1 == 0xE5 || b1 == 0xEC) ) {
                    patched[p++] = 0x48;
                    patched[p++] = b0;
                    patched[p++] = b1;
                    /* Phase 6: MOV RBP,RSP → CFA is now RBP-based */
                    if( b1 == 0xE5 && eh_func_active ) {
                        eh_frame_set_cfa_register(DWARF_RBP, eh_cfa_offset, p - eh_func_start);
                    }
                    k += 2; continue;
                }
                /* A4) REX.W for all register-to-register MOV (mod=11).
                 * On x64, reg-reg MOVs must be 64-bit to preserve
                 * pointer values in the upper 32 bits. */
                if( (b0 == 0x89 || b0 == 0x8B) && (b1 & 0xC0) == 0xC0 ) {
                    patched[p++] = 0x48; patched[p++] = b0; patched[p++] = b1;
                    k += 2; continue;
                }
                /* A5) REX.W for LEA when RSP/RBP is destination OR base.
                 * 8D with reg=ESP(4)/EBP(5) is a stack-pointer destination.
                 * 8D with mod!=11 and rm=EBP(5)/ESP(4) computes an address
                 * from the frame pointer — the result is a pointer, so the
                 * destination must be 64-bit or RBP gets truncated. */
                /* REX.W for LEA when RSP/RBP is the destination OR the base. */
                if( b0 == 0x8D ) {
                    int lreg = (b1 >> 3) & 7;
                    int lmod = (b1 >> 6) & 3;
                    int lrm  = b1 & 7;
                    if( lreg == 4 || lreg == 5
                      || ( lmod != 3 && ( lrm == 5 || lrm == 4 ) ) ) {
                        patched[p++] = 0x48; /* fall through to copy */
                    }
                }

                /* A) REX.W for SUB RSP,imm / ADD RSP,imm */
                if( (b0 == 0x81 || b0 == 0x83) && (b1 == 0xEC || b1 == 0xC4) ) {
                    patched[p++] = 0x48;
                    patched[p++] = b0;
                    patched[p++] = b1;
                    /* Phase 6: ADD RSP = epilogue, close FDE */
                    if( b1 == 0xC4 && eh_func_active ) {
                        /* Epilogue detected — will close FDE at RET */
                    }
                    k += 2; continue;
                }

            }

            /* Phase 6: Detect function boundaries for .eh_frame FDEs.
             * PUSH RBP (0x55) = start of function prologue.
             * RET (0xC3) or RET imm16 (0xC2) = end of function. */
            if( b0 == 0x55 ) {  /* push rbp */
                if( eh_func_active ) {
                    /* Close previous function's FDE */
                    eh_frame_end_function();
                }
                eh_func_active = 1;
                eh_func_start = p;
                eh_cfa_offset = 16;  /* After push rbp: CFA = RSP + 16 */
                eh_push_count = 1;
                eh_frame_begin_function("", (uint64_t)p, 0);
                eh_frame_push_reg(DWARF_RBP, 1);
                eh_frame_set_cfa_offset(16, 1);
            }
            if( b0 == 0xC3 && eh_func_active ) {  /* ret */
                /* End of function — close FDE with correct size */
                eh_frame_end_function();
                eh_func_active = 0;
            }
            /* Detect callee-saved register pushes after push rbp */
            if( eh_func_active && eh_push_count > 0 ) {
                if( b0 == 0x53 ) { /* push rbx */
                    eh_push_count++;
                    eh_cfa_offset += 8;
                    eh_frame_push_reg(DWARF_RBX, p - eh_func_start);
                    eh_frame_set_cfa_offset(eh_cfa_offset, p - eh_func_start);
                }
                if( b0 == 0x56 ) { /* push rsi */
                    eh_push_count++;
                    eh_cfa_offset += 8;
                    eh_frame_push_reg(DWARF_RSI, p - eh_func_start);
                    eh_frame_set_cfa_offset(eh_cfa_offset, p - eh_func_start);
                }
                if( b0 == 0x57 ) { /* push rdi */
                    eh_push_count++;
                    eh_cfa_offset += 8;
                    eh_frame_push_reg(DWARF_RDI, p - eh_func_start);
                    eh_frame_set_cfa_offset(eh_cfa_offset, p - eh_func_start);
                }
            }

            /* A3) Consecutive PUSH imm32 for double parameter passing.
             * On i386, two 'push imm32' push 4+4=8 bytes (one double).
             * On x64, each push extends to 8 bytes → 16 bytes total.
             * Rewrite to: sub rsp,8 + mov [rsp],low + mov [rsp+4],high
             * Pattern: 68 hh hh hh hh [68 ll ll ll ll | 6A ll] */
            if( b0 == 0x68 && k + 5 < code_seg1_len ) {
                unsigned char next_op = code_seg1[k+5];
                /* Only convert push+push to sub+mov+mov for double constants.
                 * Skip if either push has a fixup (= address relocation).
                 * cdecl arg pushes have fixups; double constants don't. */
                int push1_has_fixup = 0, push2_has_fixup = 0;
                for( int f = 0; f < fixup_count; f++ ) {
                    if( fixups[f].code_offset == k + 1 ) push1_has_fixup = 1;
                    if( fixups[f].code_offset == k + 6 ) push2_has_fixup = 1;
                }
                if( next_op == 0x68 && k + 10 <= code_seg1_len
                  && !push1_has_fixup && !push2_has_fixup
                  && k + 10 < code_seg1_len && code_seg1[k+10] == 0xE8 ) {
                    /* Only convert when followed DIRECTLY by call (E8).
                     * This is a double constant passed as Watcom register param.
                     * For cdecl, there may be more pushes before the call. */
                    /* push $high32; push $low32 → sub $8,%rsp; mov $low,[rsp]; mov $high,4[rsp] */
                    unsigned char *hi = &code_seg1[k+1];
                    unsigned char *lo = &code_seg1[k+6];
                    patched[p++] = 0x48; patched[p++] = 0x83;
                    patched[p++] = 0xEC; patched[p++] = 0x08; /* sub $8,%rsp */
                    patched[p++] = 0xC7; patched[p++] = 0x04;
                    patched[p++] = 0x24;                      /* mov [rsp], */
                    patched[p++]=lo[0]; patched[p++]=lo[1];
                    patched[p++]=lo[2]; patched[p++]=lo[3];   /* low32 */
                    patched[p++] = 0xC7; patched[p++] = 0x44;
                    patched[p++] = 0x24; patched[p++] = 0x04; /* mov 4[rsp], */
                    patched[p++]=hi[0]; patched[p++]=hi[1];
                    patched[p++]=hi[2]; patched[p++]=hi[3];   /* high32 */
                    k += 10;
                    continue;
                } else if( next_op == 0x6A && k + 7 <= code_seg1_len
                  && !push1_has_fixup
                  && k + 7 < code_seg1_len && code_seg1[k+7] == 0xE8 ) {
                    /* push $high32; push $low8 */
                    unsigned char *hi = &code_seg1[k+1];
                    unsigned char lo_val = code_seg1[k+6];
                    patched[p++] = 0x48; patched[p++] = 0x83;
                    patched[p++] = 0xEC; patched[p++] = 0x08;
                    patched[p++] = 0xC7; patched[p++] = 0x04;
                    patched[p++] = 0x24;
                    patched[p++] = lo_val; patched[p++] = 0;
                    patched[p++] = 0; patched[p++] = 0;       /* sign-extend lo */
                    patched[p++] = 0xC7; patched[p++] = 0x44;
                    patched[p++] = 0x24; patched[p++] = 0x04;
                    patched[p++]=hi[0]; patched[p++]=hi[1];
                    patched[p++]=hi[2]; patched[p++]=hi[3];
                    k += 7;
                    continue;
                }
            }

            /* B) INC/DEC single-byte (40-4F) conflict with REX prefixes.
             * Cannot safely patch without a full instruction decoder because
             * 40-4F also appear as ModR/M bytes inside multi-byte instructions.
             * Left as-is: the REX effect on the following instruction is usually
             * benign. Programs needing loops should use -od (frame-based) or
             * ensure INC/DEC is avoided via compiler flags. */

            /* A ModR/M byte of mod=00, rm=101 means "absolute disp32" on i386
             * but "RIP-relative" on x86-64. We WANT RIP-relative on x64
             * since absolute 32-bit addresses can't reach data above 2GB.
             * Leave the encoding as-is (rm=101 = RIP-relative on x64).
             * The relocation uses R_X86_64_PC32 so the linker fills in
             * the correct RIP-relative displacement. */
            /* (rm=101 kept as RIP-relative — no conversion needed) */

            /* Accumulator-absolute moves are moffs64 in long mode, so they
             * read eight bytes of address and swallow the next instruction.
             * Rewrite to ModR/M with a zero base/index SIB, which keeps
             * absolute 32-bit semantics:
             *     A1 disp32  (MOV EAX,[disp32]) -> 8B 04 25 disp32
             *     A3 disp32  (MOV [disp32],EAX) -> 89 04 25 disp32
             * A bare byte scan cannot tell an A1 opcode from an A1 that is
             * really a ModR/M or immediate, so we only rewrite when the OMF
             * recorded a fixup at exactly k+1 — the displacement slot. That
             * is only true for a genuine absolute-address operand. */
            if( (b0 == 0xA1 || b0 == 0xA3) && k + 5 <= code_seg1_len ) {
                int is_addr = 0;
                for( int f = 0; f < fixup_count; f++ )
                    if( fixups[f].code_offset == k + 1 ) { is_addr = 1; break; }
                if( is_addr ) {
                    /* A1 → 8B 05 (MOV EAX,[RIP+disp32])
                     * A3 → 89 05 (MOV [RIP+disp32],EAX)
                     * RIP-relative: mod=00, reg=000(EAX), rm=101 */
                    patched[p++] = ( b0 == 0xA1 ) ? 0x8B : 0x89;
                    patched[p++] = 0x05;    /* ModR/M: mod=00 reg=EAX rm=101 (RIP) */
                    offset_map[k+1] = p;
                    for( int d = 0; d < 4; d++ )
                        patched[p++] = code_seg1[k+1+d];
                    k += 5;
                    continue;
                }
            }

            patched[p++] = code_seg1[k++];
        }
        offset_map[code_seg1_len] = p;

        /* C) Adjust relative jumps and calls.
         * Scan the ORIGINAL code for jump/call instructions.
         * Calculate old target, map both source and target through
         * offset_map, compute new displacement in patched buffer. */
        for( int k2 = 0; k2 < code_seg1_len; ) {
            unsigned char op2 = code_seg1[k2];
            int disp_off_old = -1;  /* displacement offset in ORIGINAL */
            int disp_size = 0;
            int inst_len = 0;       /* total instruction length */

            /* Short Jcc: 70-7F xx */
            if( op2 >= 0x70 && op2 <= 0x7F ) {
                disp_off_old = k2 + 1; disp_size = 1; inst_len = 2;
            }
            /* Short JMP: EB xx */
            else if( op2 == 0xEB ) {
                disp_off_old = k2 + 1; disp_size = 1; inst_len = 2;
            }
            /* Near Jcc: 0F 8x xx xx xx xx */
            else if( op2 == 0x0F && k2+1 < code_seg1_len &&
                     code_seg1[k2+1] >= 0x80 && code_seg1[k2+1] <= 0x8F ) {
                disp_off_old = k2 + 2; disp_size = 4; inst_len = 6;
            }
            /* Near CALL/JMP: E8/E9 xx xx xx xx */
            else if( op2 == 0xE8 || op2 == 0xE9 ) {
                disp_off_old = k2 + 1; disp_size = 4; inst_len = 5;
            }

            if( disp_off_old >= 0 ) {
                int old_inst_end = k2 + inst_len;
                int32_t old_disp;
                if( disp_size == 1 )
                    old_disp = (int8_t)code_seg1[disp_off_old];
                else
                    memcpy(&old_disp, code_seg1 + disp_off_old, 4);

                int old_target = old_inst_end + old_disp;
                if( old_target >= 0 && old_target <= code_seg1_len &&
                    offset_map[k2] >= 0 && offset_map[old_target] >= 0 ) {
                    /* Relative jumps themselves are never lengthened, so the
                     * new end is the mapped start plus the same length. */
                    int new_inst_end = offset_map[k2] + inst_len;
                    int new_target = offset_map[old_target];
                    int32_t new_disp = new_target - new_inst_end;

                    /* Write new displacement into PATCHED buffer.
                     * disp_off_old points INSIDE the instruction, so it has
                     * no offset_map entry. Derive it from the instruction
                     * start, which is always an instruction boundary. */
                    int new_disp_off = offset_map[k2] + (disp_off_old - k2);
                    if( disp_size == 1 ) {
                        if( new_disp >= -128 && new_disp <= 127 )
                            patched[new_disp_off] = (uint8_t)(int8_t)new_disp;
                    } else {
                        memcpy(patched + new_disp_off, &new_disp, 4);
                    }
                }
                k2 += inst_len;
            } else {
                /* Skip the WHOLE instruction. Advancing a single byte lets a
                 * ModRM/SIB/disp byte be read as an opcode next iteration —
                 * e.g. 8D 7D E0 (lea -0x20(%rbp),%edi) where 0x7D looks like
                 * a short Jcc, causing the displacement to be rewritten. */
                int l2 = x86_insn_len( code_seg1, code_seg1_len, k2 );
                k2 += ( l2 > 0 ? l2 : 1 );
            }
        }

        /* Adjust PUBDEF symbol offsets for REX insertions */
        for( int q = 0; q < pub_count; q++ ) {
            if( pub_offs[q] <= (unsigned)code_seg1_len && offset_map[pub_offs[q]] >= 0 )
                pub_offs[q] = offset_map[pub_offs[q]];
        }

        /* Save original byte before each fixup (for relocation type selection) */
        fixup_orig_off = (int *)malloc( fixup_count * sizeof(int) );
        for( int f = 0; f < fixup_count; f++ )
            fixup_orig_off[f] = (fixups[f].code_offset >= 1 && fixups[f].code_offset < code_seg1_len) ? code_seg1[fixups[f].code_offset - 1] : 0;

        /* Adjust fixup offsets */
        for( int f = 0; f < fixup_count; f++ ) {
            int old_off = fixups[f].code_offset;
            if( old_off >= 0 && old_off < code_seg1_len )
                fixups[f].code_offset = offset_map[old_off];
        }

        memcpy( code_seg1, patched, p );
        code_seg1_len = p;
        free( patched );
        free( offset_map );
        
    }

    /* Data now goes into its own .data section, so the displacement left in
     * the code stays a pure offset within its segment; the relocation addend
     * carries the segment base. Nothing to patch into the code here. */
    int combined_len = code_seg1_len;
    (void)combined_len;

    /* ============================================================
     * Write ELF64 with .rela.text
     * ============================================================ */
    temp_name = (char *)malloc( strlen(obj_filename) + 5 );
    sprintf( temp_name, "%s.tmp", obj_filename );
    fp_out = fopen( temp_name, "wb" );
    if( !fp_out ) { free(omf); free(code_seg1); free(data_seg2); free(temp_name); return; }

    /* Build string table */
    static char strtab[262144];   /* symbol-heavy modules need far more than 2K */
    int st_len = 0;
    strtab[st_len++] = 0;
    int str_text = st_len;     memcpy(strtab+st_len, ".text", 6);       st_len += 6;
    int str_strtab = st_len;   memcpy(strtab+st_len, ".strtab", 8);     st_len += 8;
    int str_symtab = st_len;   memcpy(strtab+st_len, ".symtab", 8);     st_len += 8;
    int str_data = st_len;     memcpy(strtab+st_len, ".data", 6);        st_len += 6;
    int str_bss = st_len;      memcpy(strtab+st_len, ".bss", 5);         st_len += 5;
    int str_relatext = st_len; memcpy(strtab+st_len, ".rela.text", 11); st_len += 11;
    int str_reladata = st_len; memcpy(strtab+st_len, ".rela.data", 11); st_len += 11;
    int str_note = st_len;     memcpy(strtab+st_len, ".note.GNU-stack", 16); st_len += 16;
    /* Phase 6: .eh_frame section string */
    int str_ehframe = st_len; memcpy(strtab+st_len, ".eh_frame", 10); st_len += 10;
    /* Phase 7: .rodata section string */
    int str_rodata = st_len;  memcpy(strtab+st_len, ".rodata", 8);    st_len += 8;
    int str_relaeh = st_len;  memcpy(strtab+st_len, ".rela.eh_frame", 15); st_len += 15;
    int str_pub[512];
    for( int q = 0; q < pub_count; q++ ) {
        str_pub[q] = st_len;
        int pl = strlen(pub_names[q]) + 1;
        memcpy(strtab+st_len, pub_names[q], pl);
        st_len += pl;
    }

    /* An EXTDEF that also appears as a PUBDEF is defined in this module
     * (Watcom lists intra-module calls as externals). Point such a fixup at
     * the local definition rather than emitting a duplicate undefined symbol. */
    int str_ext[512];
    int ext_local[512];           /* index into pub_*, or -1 if truly external */
    for( int e = 0; e < ext_count; e++ ) {
        ext_local[e] = -1;
        for( int q = 0; q < pub_count; q++ ) {
            if( strcmp(ext_names[e], pub_names[q]) == 0 ) { ext_local[e] = q; break; }
        }
        if( ext_local[e] >= 0 ) {
            str_ext[e] = str_pub[ext_local[e]];
        } else {
            str_ext[e] = st_len;
            int el = strlen(ext_names[e]) + 1;
            memcpy(strtab+st_len, ext_names[e], el);
            st_len += el;
        }
    }
    /* Layout with optional .rela.text */
    int real_ext = 0;
    for( int e = 0; e < ext_count; e++ ) if( ext_local[e] < 0 ) real_ext++;

    /* ELF requires every STB_LOCAL symbol to appear before the first global,
     * with sh_info equal to the number of leading locals. Emit static symbols
     * first and record where each pubdef ends up so relocations can find it. */
    int pub_symidx[512];
    int n_local_pub = 0;
    for( int q = 0; q < pub_count; q++ ) if( pub_local[q] ) n_local_pub++;
    {
        int nxt = 5;  /* 0=null, 1=STT_FILE, 2=.text, 3=.data, 4=.bss */
        for( int q = 0; q < pub_count; q++ ) if( pub_local[q] )  pub_symidx[q] = nxt++;
        for( int q = 0; q < pub_count; q++ ) if( !pub_local[q] ) pub_symidx[q] = nxt++;
    }
    int num_syms = 5 + pub_count + real_ext;  /* null + STT_FILE + 3 sections + defined + undefined */
    int num_local = 5 + n_local_pub;          /* null + STT_FILE + 3 sections + statics */
    int has_rela = (fixup_count > 0);
    int num_relas = fixup_count;
    int num_relas_written = 0;

    /* Pre-add source filename to strtab BEFORE layout calculation
     * (otherwise shdr_off is computed with wrong st_len) */
    const char *srcname_pre = obj_filename ? obj_filename : "unknown.c";
    int str_srcfile_idx = st_len;
    {
        int slen = strlen(srcname_pre) + 1;
        memcpy(strtab + st_len, srcname_pre, slen);
        st_len += slen;
    }

    size_t text_off = sizeof(Elf64_Ehdr);
    size_t text_pad  = (16 - (text_off + combined_len) % 16) % 16;
    /* Phase 7: .rodata sits between .text and .data */
    size_t rodata_off = text_off + combined_len + text_pad;
    size_t rodata_pad = (16 - (rodata_off + rodata_pos) % 16) % 16;
    size_t data_off  = rodata_off + rodata_pos + rodata_pad;
    size_t data_pad  = (16 - (data_off + data_seg2_len) % 16) % 16;
    size_t symtab_off = data_off + data_seg2_len + data_pad;
    size_t symtab_sz = num_syms * sizeof(Elf64_Sym);
    size_t rela_off = symtab_off + symtab_sz;
    size_t rela_sz = num_relas * sizeof(Elf64_Rela);
    size_t drela_off = rela_off + rela_sz;
    size_t drela_sz = dfixup_count * sizeof(Elf64_Rela);
    /* Phase 6: .eh_frame data sits after .rela.data */
    size_t ehframe_off = drela_off + drela_sz;
    size_t ehframe_pad = (8 - (ehframe_off + eh_pos) % 8) % 8;
    size_t strtab_off = ehframe_off + eh_pos + ehframe_pad;
    size_t strtab_pad = (8 - (strtab_off + st_len) % 8) % 8;
    size_t shdr_off = strtab_off + st_len + strtab_pad;
    /* 0 null, 1 .text, 2 .data, 3 .bss, 4 .symtab, [5 .rela.text,] .strtab */
    int has_drela = ( dfixup_count > 0 );
    int SEC_TEXT = 1, SEC_DATA = 2, SEC_BSS = 3, SEC_SYMTAB = 4;
    int nsec = 5;
    int SEC_RELA  = has_rela  ? nsec++ : 0;
    int SEC_RELAD = has_drela ? nsec++ : 0;
    int SEC_NOTE = nsec++;      /* .note.GNU-stack */
    int SEC_STRTAB = nsec++;
    /* Phase 6: .eh_frame section */
    int SEC_EHFRAME = nsec++; (void)SEC_EHFRAME;
    /* Phase 7: .rodata section */
    int SEC_RODATA = nsec++; (void)SEC_RODATA;
    int num_shdrs = nsec;
    (void)SEC_NOTE;
    (void)SEC_RELA; (void)SEC_RELAD;

    /* ELF header */
    Elf64_Ehdr ehdr;
    memset(&ehdr, 0, sizeof(ehdr));
    ehdr.e_ident[EI_MAG0] = ELFMAG0;
    ehdr.e_ident[EI_MAG1] = ELFMAG1;
    ehdr.e_ident[EI_MAG2] = ELFMAG2;
    ehdr.e_ident[EI_MAG3] = ELFMAG3;
    ehdr.e_ident[EI_CLASS] = ELFCLASS64;
    ehdr.e_ident[EI_DATA] = ELFDATA2LSB;
    ehdr.e_ident[EI_VERSION] = EV_CURRENT;
    ehdr.e_ident[EI_OSABI] = ELFOSABI_NONE;
    ehdr.e_type = ET_REL;
    ehdr.e_machine = EM_X86_64;
    ehdr.e_version = EV_CURRENT;
    SET64(ehdr.e_shoff, shdr_off);
    ehdr.e_ehsize = sizeof(Elf64_Ehdr);
    ehdr.e_shentsize = sizeof(Elf64_Shdr);
    ehdr.e_shnum = num_shdrs;
        ehdr.e_shstrndx = (eh_pos > 0) ? SEC_STRTAB : SEC_STRTAB - 1;
    fwrite(&ehdr, 1, sizeof(ehdr), fp_out);

    /* .text contents */
    actual_text_off = ftell(fp_out);
    fwrite(code_seg1, 1, combined_len, fp_out);
    { char pad[16] = {0}; fwrite(pad, 1, text_pad, fp_out); }
    /* Phase 7: .rodata contents */
    actual_rodata_off = ftell(fp_out);
    if( rodata_pos > 0 )
        fwrite(rodata_buf, 1, rodata_pos, fp_out);
    { char pad[16] = {0}; fwrite(pad, 1, rodata_pad, fp_out); }
    /* .data contents */
    actual_data_off = ftell(fp_out);
    if( data_seg2_len > 0 )
        fwrite(data_seg2, 1, data_seg2_len, fp_out);
    { char pad[16] = {0}; fwrite(pad, 1, data_pad, fp_out); }

    /* Symbol table */
    actual_symtab_off = ftell(fp_out);
    Elf64_Sym sym;
    memset(&sym, 0, sizeof(sym)); fwrite(&sym, 1, sizeof(sym), fp_out); /* [0] null */

    /* Phase 6: STT_FILE symbol — enables GDB source file mapping */
    memset(&sym, 0, sizeof(sym));
    sym.st_name = str_srcfile_idx;
    sym.st_info = ELF64_ST_INFO(STB_LOCAL, STT_FILE);
    sym.st_shndx = SHN_ABS;
    fwrite(&sym, 1, sizeof(sym), fp_out); /* [1] STT_FILE */

    memset(&sym, 0, sizeof(sym));  /* [2] .text section */
    sym.st_name = str_text;
    sym.st_info = ELF64_ST_INFO(STB_LOCAL, STT_SECTION);
    sym.st_shndx = SEC_TEXT;
    fwrite(&sym, 1, sizeof(sym), fp_out);

    memset(&sym, 0, sizeof(sym));  /* [2] .data section — relocation anchor */
    sym.st_name = str_data;
    sym.st_info = ELF64_ST_INFO(STB_LOCAL, STT_SECTION);
    sym.st_shndx = SEC_DATA;
    fwrite(&sym, 1, sizeof(sym), fp_out);

    memset(&sym, 0, sizeof(sym));  /* [3] .bss section */
    sym.st_name = str_bss;
    sym.st_info = ELF64_ST_INFO(STB_LOCAL, STT_SECTION);
    sym.st_shndx = SEC_BSS;
    fwrite(&sym, 1, sizeof(sym), fp_out);

    /* [2 ..] every symbol this module defines.
     * PUBDEF records the defining segment, so a symbol from a data segment
     * is a variable, not a function: it lives in the data block appended to
     * .text and must be typed STT_OBJECT. Emitting everything as STT_FUNC at
     * a code offset made a global resolve to the middle of the code. */
    for( int pass_local = 1; pass_local >= 0; pass_local-- )
    for( int q = 0; q < pub_count; q++ ) {
        if( pub_local[q] != pass_local ) continue;
        int is_code = ( pub_segs[q] == text_seg_idx );
        memset(&sym, 0, sizeof(sym));
        sym.st_name  = str_pub[q];
        sym.st_shndx = is_code ? SEC_TEXT : SEC_DATA;
        if( is_code ) {
            unsigned int next = (unsigned int)code_seg1_len;
            for( int r = 0; r < pub_count; r++ )
                if( pub_segs[r] == text_seg_idx &&
                    pub_offs[r] > pub_offs[q] && pub_offs[r] < next )
                    next = pub_offs[r];
            sym.st_info  = ELF64_ST_INFO(
                pub_local[q] ? STB_LOCAL : STB_GLOBAL, STT_FUNC);
            SET64(sym.st_value, pub_offs[q]);
            SET64(sym.st_size, next - pub_offs[q]);
        } else {
            int ps = pub_segs[q];
            int in_bss = ( ps > 0 && ps < 512 && seg_is_bss[ps] );
            int base;
            if( in_bss ) {
                sym.st_shndx = SEC_BSS;
                base = ( seg_bss_base[ps] >= 0 ) ? seg_bss_base[ps] : 0;
            } else {
                base = ( ps > 0 && ps < 512 && seg_base[ps] >= 0 ) ? seg_base[ps] : 0;
            }
            /* Size is the gap to the next symbol defined in the same
             * segment, falling back to the rest of the segment. Reporting a
             * flat 4 bytes for every object made a 36-byte array claim to be
             * an int, which is wrong for any tool that reads sizes. */
            unsigned int endoff = seg_len[ps];
            for( int r = 0; r < pub_count; r++ ) {
                if( r == q || pub_segs[r] != ps ) continue;
                if( pub_offs[r] > pub_offs[q] && pub_offs[r] < endoff )
                    endoff = pub_offs[r];
            }
            sym.st_info  = ELF64_ST_INFO(
                pub_local[q] ? STB_LOCAL : STB_GLOBAL, STT_OBJECT);
            SET64(sym.st_value, (unsigned int)base + pub_offs[q]);
            SET64(sym.st_size, ( endoff > pub_offs[q] ) ? endoff - pub_offs[q] : 4);
        }
        fwrite(&sym, 1, sizeof(sym), fp_out);
    }

    /* [..] names referenced but not defined here */
    for( int e = 0; e < ext_count; e++ ) {
        if( ext_local[e] >= 0 ) continue;          /* defined above */
        memset(&sym, 0, sizeof(sym));
        sym.st_name  = str_ext[e];
        sym.st_info  = ELF64_ST_INFO(STB_GLOBAL, STT_NOTYPE);
        sym.st_shndx = SHN_UNDEF;
        fwrite(&sym, 1, sizeof(sym), fp_out);
    }

    /* .rela.text — relocations */
    actual_rela_off = ftell(fp_out);
    if( has_rela ) {
        Elf64_Rela rela;

        /* Emit one ELF64 relocation per recorded OMF fixup. */
        for( int f = 0; f < fixup_count; f++ ) {
            int off = fixups[f].code_offset;
            memset(&rela, 0, sizeof(rela));
            SET64(rela.r_offset, off);

            if( fixups[f].ext_idx >= 0 ) {
                /* External symbol. A displacement that directly follows an
                 * E8/E9 opcode is PC-relative; anything else is absolute. */
                int e = fixups[f].ext_idx;
                int sym_idx;
                if( ext_local[e] >= 0 ) {
                    sym_idx = pub_symidx[ext_local[e]];  /* defined in module */
                } else {
                    int rank = 0;                        /* nth undefined name */
                    for( int t = 0; t < e; t++ ) if( ext_local[t] < 0 ) rank++;
                    sym_idx = 5 + pub_count + rank;  /* 0=null 1=FILE 2-4=sections */

                }
                int pcrel = ( off >= 1 &&
                              (code_seg1[off-1] == 0xE8 || code_seg1[off-1] == 0xE9) );
                /* The displacement already encoded at the fixup site is part
                 * of the address: a struct field offset, or the bias in a
                 * form like -4(%rax) used to index an array. A relocation
                 * overwrites that slot with S+A, so the existing value has to
                 * be carried into the addend or it is silently lost. Dropping
                 * it made g.y read g.x, and shifted array indexing by one. */
                int32_t within = 0;
                if( off + 4 <= code_seg1_len )
                    memcpy( &within, code_seg1 + off, 4 );
                if( pcrel ) {
                    SET64(rela.r_info, ELF64_R_INFO(sym_idx, R_X86_64_PLT32));
                    SET64(rela.r_addend, (int64_t)within - 4);
                } else {
                    /* Use PC32 only for pure RIP-relative (mod=00,rm=101).
                     * Check the byte before the fixup in PATCHED code
                     * (code_seg1 was overwritten with patched data). */
                    unsigned char prev = (off >= 1) ? code_seg1[off-1] : 0;
                    if( (prev & 0xC7) == 0x05 ) {
                        SET64(rela.r_info, ELF64_R_INFO(sym_idx, R_X86_64_PC32));
                        /* Check if instruction has trailing immediate after disp32.
                         * The opcode byte is 2 before the fixup (or 3 if REX prefix).
                         * 83/C6 = trailing imm8 (-5), 81/C7 = trailing imm32 (-8) */
                        int trail = 0;
                        if( off >= 2 ) {
                            unsigned char op = code_seg1[off-2];
                            if( op == 0x48 && off >= 3 ) op = code_seg1[off-3];
                            if( op == 0x83 || op == 0xC6 || op == 0x80 || op == 0x6B ) trail = 1;
                            else if( op == 0x81 || op == 0xC7 || op == 0x69 ) trail = 4;
                            else {
                                /* opcode may be one more byte back (ModRM between) */
                                unsigned char op2 = (off >= 3) ? code_seg1[off-3] : 0;
                                if( op2 == 0x48 && off >= 4 ) op2 = code_seg1[off-4];
                                if( op2 == 0x83 || op2 == 0xC6 || op2 == 0x80 || op2 == 0x6B ) trail = 1;
                                else if( op2 == 0x81 || op2 == 0xC7 || op2 == 0x69 ) trail = 4;
                            }
                        }
                        SET64(rela.r_addend, (int64_t)within - 4 - trail);
                    } else {
                        SET64(rela.r_info, ELF64_R_INFO(sym_idx, R_X86_64_32S));
                        SET64(rela.r_addend, within);
                    }
                }
            } else {
                /* Data reference: resolve against the .data section symbol.
                 * The code holds the offset within the target segment; the
                 * addend adds that segment's base inside .data. */
                uint32_t within = 0;
                if( off + 4 <= code_seg1_len )
                    memcpy( &within, code_seg1 + off, 4 );
                int ts = fixups[f].target_seg;
                int anchor, base;
                if( ts > 0 && ts < 512 && seg_is_bss[ts] ) {
                    anchor = SEC_BSS;
                    base = ( seg_bss_base[ts] >= 0 ) ? seg_bss_base[ts] : 0;
                } else if( ts == text_seg_idx ) {
                    /* Data placed in code segment (e.g. local array initializers).
                     * Reference against .text, not .data. */
                    anchor = SEC_TEXT;
                    base = 0;
                } else {
                    anchor = SEC_DATA;
                    base = ( ts > 0 && ts < 512 && seg_base[ts] >= 0 ) ? seg_base[ts] : 0;
                }
                {
                    unsigned char prev = (off >= 1) ? fixup_orig_off[f] : 0;
                    if( (prev >= 0xB8 && prev <= 0xBF) || prev == 0x68
                      || prev == 0x6A || prev == 0xC7 ) {
                        SET64(rela.r_info, ELF64_R_INFO(anchor + 1, R_X86_64_32S));  /* +1 for STT_FILE */
                        SET64(rela.r_addend, (int64_t)base + within);
                    } else {
                        SET64(rela.r_info, ELF64_R_INFO(anchor + 1, R_X86_64_PC32));  /* +1 for STT_FILE */
                        {
                            int trail = 0;
                            if( off >= 2 ) {
                                unsigned char op = code_seg1[off-2];
                                if( op == 0x48 && off >= 3 ) op = code_seg1[off-3];
                                if( op == 0x83 || op == 0xC6 || op == 0x80 || op == 0x6B ) trail = 1;
                                else if( op == 0x81 || op == 0xC7 || op == 0x69 ) trail = 4;
                            }
                            SET64(rela.r_addend, (int64_t)base + within - 4 - trail);
                        }
                    }
                }
            }
            fwrite(&rela, 1, sizeof(rela), fp_out);
            num_relas_written++;
        }
    }

    /* .rela.data — relocations applied to the data image itself.
     * A pointer initialiser holds the target's offset within its segment;
     * the addend carries that plus the segment's base, and the entry is
     * anchored on the section (or symbol) being pointed at. Pointers are
     * four bytes here because the code generator is the 32-bit one, so the
     * type is R_X86_64_32 rather than the R_X86_64_64 a 64-bit compiler
     * would emit. */
    actual_drela_off = ftell(fp_out);
    if( has_drela ) {
        Elf64_Rela drela;
        for( int f = 0; f < dfixup_count; f++ ) {
            int off = dfixups[f].code_offset;
            uint32_t within = 0;
            if( off >= 0 && off + 4 <= data_seg2_len )
                memcpy( &within, data_seg2 + off, 4 );
            memset(&drela, 0, sizeof(drela));
            SET64(drela.r_offset, off);
            if( dfixups[f].ext_idx >= 0 ) {
                int e = dfixups[f].ext_idx;
                int sidx2;
                if( ext_local[e] >= 0 ) {
                    sidx2 = pub_symidx[ext_local[e]];
                } else {
                    int rank = 0;
                    for( int t = 0; t < e; t++ ) if( ext_local[t] < 0 ) rank++;
                    sidx2 = 4 + pub_count + rank;
                }
                SET64(drela.r_info, ELF64_R_INFO(sidx2, R_X86_64_32));
                SET64(drela.r_addend, within);
            } else {
                int ts = dfixups[f].target_seg;
                int anchor, base;
                if( ts > 0 && ts < 512 && seg_is_bss[ts] ) {
                    anchor = SEC_BSS;
                    base = ( seg_bss_base[ts] >= 0 ) ? seg_bss_base[ts] : 0;
                } else {
                    anchor = SEC_DATA;
                    base = ( ts > 0 && ts < 512 && seg_base[ts] >= 0 ) ? seg_base[ts] : 0;
                }
                SET64(drela.r_info, ELF64_R_INFO(anchor, R_X86_64_32S));
                SET64(drela.r_addend, (int64_t)base + within);
            }
            fwrite(&drela, 1, sizeof(drela), fp_out);
        }
    }

    /* Phase 6: .eh_frame data */
    actual_ehframe_off = ftell(fp_out);
    if( eh_pos > 0 )
        fwrite(eh_buf, 1, eh_pos, fp_out);
    { char pad[8] = {0}; fwrite(pad, 1, ehframe_pad, fp_out); }
    /* .rela.eh_frame data — must be written BEFORE strtab (all data before shdrs) */
    int num_eh_relas = eh_frame_get_num_fdes();
    if( eh_pos > 0 && num_eh_relas > 0 ) {
        rela_eh_off = ftell(fp_out);
        Elf64_Rela erela;
        int ef;
        for( ef = 0; ef < num_eh_relas; ef++ ) {
            memset(&erela, 0, sizeof(erela));
            SET64(erela.r_offset, eh_frame_get_fde_offset(ef));
            SET64(erela.r_info, ELF64_R_INFO(SEC_TEXT + 1, R_X86_64_PC32));
            {
                extern uint32_t eh_frame_get_fde_code_addr(int);
                int32_t addend = (int32_t)eh_frame_get_fde_code_addr(ef);
                SET64(erela.r_addend, addend);
            }
            fwrite(&erela, 1, sizeof(erela), fp_out);
        }
    }

    /* String table — record actual file position */
    long actual_strtab_off = ftell(fp_out);
    fwrite(strtab, 1, st_len, fp_out);
    { char pad[8] = {0}; fwrite(pad, 1, strtab_pad, fp_out); }

    /* Patch e_shoff to actual file position (fixes layout mismatches) */
    {
        long actual_shdr_off = ftell(fp_out);
        /* Align to 8 bytes */
        long align_pad = (8 - (actual_shdr_off % 8)) % 8;
        if (align_pad > 0) { char z[8] = {0}; fwrite(z, 1, align_pad, fp_out); }
        actual_shdr_off = ftell(fp_out);
        fseek(fp_out, 40, SEEK_SET);  /* e_shoff at offset 40 */
        {
            unsigned long long off64 = (unsigned long long)actual_shdr_off;
            fwrite(&off64, 1, 8, fp_out);
        }

        fseek(fp_out, actual_shdr_off, SEEK_SET);
    }

    /* Section headers — track actual indices */
    int shdr_write_idx = 0;
    int shdr_strtab_idx = 0;  /* patched when we write .strtab */

    Elf64_Shdr shdr;
    memset(&shdr, 0, sizeof(shdr)); fwrite(&shdr, 1, sizeof(shdr), fp_out); /* [0] null */
    shdr_write_idx++;

    memset(&shdr, 0, sizeof(shdr));  /* [1] .text */
    shdr.sh_name = str_text;
    shdr.sh_type = SHT_PROGBITS;
    SET64(shdr.sh_flags, SHF_ALLOC | SHF_EXECINSTR);
    SET64(shdr.sh_offset, actual_text_off);
    SET64(shdr.sh_size, combined_len);
    SET64(shdr.sh_addralign, 16);
    fwrite(&shdr, 1, sizeof(shdr), fp_out);
    shdr_write_idx++;

    memset(&shdr, 0, sizeof(shdr));  /* [2] .data */
    shdr.sh_name = str_data;
    shdr.sh_type = SHT_PROGBITS;
    SET64(shdr.sh_flags, SHF_ALLOC | SHF_WRITE);
    SET64(shdr.sh_offset, actual_data_off);
    SET64(shdr.sh_size, data_seg2_len);
    SET64(shdr.sh_addralign, 16);
    fwrite(&shdr, 1, sizeof(shdr), fp_out);
    shdr_write_idx++;

    memset(&shdr, 0, sizeof(shdr));  /* [3] .bss */
    shdr.sh_name = str_bss;
    shdr.sh_type = SHT_NOBITS;
    SET64(shdr.sh_flags, SHF_ALLOC | SHF_WRITE);
    SET64(shdr.sh_offset, actual_symtab_off);   /* NOBITS occupies no file space */
    
    SET64(shdr.sh_size, bss_total);
    SET64(shdr.sh_addralign, 16);
    fwrite(&shdr, 1, sizeof(shdr), fp_out);
    shdr_write_idx++;

    memset(&shdr, 0, sizeof(shdr));  /* [4] .symtab */
    shdr.sh_name = str_symtab;
    shdr.sh_type = SHT_SYMTAB;
    SET64(shdr.sh_offset, actual_symtab_off);
    SET64(shdr.sh_size, symtab_sz);
    shdr.sh_link = SEC_STRTAB;
    shdr.sh_info = num_local;
    SET64(shdr.sh_addralign, 8);
    SET64(shdr.sh_entsize, sizeof(Elf64_Sym));
    fwrite(&shdr, 1, sizeof(shdr), fp_out);
    shdr_write_idx++;

    if( has_rela ) {
        memset(&shdr, 0, sizeof(shdr));  /* [3] .rela.text */
        shdr.sh_name = str_relatext;
        shdr.sh_type = SHT_RELA;
        SET64(shdr.sh_flags, SHF_INFO_LINK);
        SET64(shdr.sh_offset, actual_rela_off);
        SET64(shdr.sh_size, rela_sz);
        shdr.sh_link = SEC_SYMTAB;
        shdr.sh_info = SEC_TEXT;
        SET64(shdr.sh_addralign, 8);
        SET64(shdr.sh_entsize, sizeof(Elf64_Rela));
        fwrite(&shdr, 1, sizeof(shdr), fp_out);
        shdr_write_idx++;
    }

    if( has_drela ) {
        memset(&shdr, 0, sizeof(shdr));  /* .rela.data */
        shdr.sh_name = str_reladata;
        shdr.sh_type = SHT_RELA;
        SET64(shdr.sh_flags, SHF_INFO_LINK);
        SET64(shdr.sh_offset, actual_drela_off);
        SET64(shdr.sh_size, drela_sz);
        shdr.sh_link = SEC_SYMTAB;
        shdr.sh_info = SEC_DATA;
        SET64(shdr.sh_addralign, 8);
        SET64(shdr.sh_entsize, sizeof(Elf64_Rela));
        fwrite(&shdr, 1, sizeof(shdr), fp_out);
        shdr_write_idx++;
    }

    /* An empty .note.GNU-stack tells the linker the stack need not be
     * executable. Without it every link warns and marks the stack RWX. */
    memset(&shdr, 0, sizeof(shdr));
    shdr.sh_name = str_note;
    shdr.sh_type = SHT_PROGBITS;
    SET64(shdr.sh_flags, 0);
    SET64(shdr.sh_offset, actual_strtab_off);
    SET64(shdr.sh_size, 0);
    SET64(shdr.sh_addralign, 1);
    fwrite(&shdr, 1, sizeof(shdr), fp_out);
    shdr_write_idx++;

    memset(&shdr, 0, sizeof(shdr));  /* .strtab */
    shdr.sh_name = str_strtab;
    shdr.sh_type = SHT_STRTAB;
    SET64(shdr.sh_offset, actual_strtab_off);
    SET64(shdr.sh_size, st_len);
    SET64(shdr.sh_addralign, 1);
    shdr_strtab_idx = shdr_write_idx;  /* record strtab section index */
    fwrite(&shdr, 1, sizeof(shdr), fp_out);
    shdr_write_idx++;

    /* ================================================================
     * Phase 6: .eh_frame section header
     * Contains CIE (default unwinding rules) + FDE per function.
     * GDB reads this for backtraces. ld reads it for exception handling.
     * ================================================================ */
    eh_frame_finalize();
    /* .eh_frame re-enabled */



    /* .eh_frame enabled — .rela.eh_frame relocs implemented */ /* No FDEs → skip CIE-only .eh_frame */
    if( eh_pos > 0 ) {
        memset(&shdr, 0, sizeof(shdr));
        shdr.sh_name = str_ehframe;
        shdr.sh_type = SHT_PROGBITS;
        SET64(shdr.sh_flags, SHF_ALLOC);
        SET64(shdr.sh_offset, actual_ehframe_off);
        SET64(shdr.sh_size, eh_pos);
        SET64(shdr.sh_addralign, 8);
        fwrite(&shdr, 1, sizeof(shdr), fp_out);
        shdr_write_idx++;
    }

    /* .rela.eh_frame — relocations for FDE initial_location fields */
    if( eh_pos > 0 && num_eh_relas > 0 ) {
        memset(&shdr, 0, sizeof(shdr));
        shdr.sh_name = str_relaeh;
        shdr.sh_type = SHT_RELA;
        SET64(shdr.sh_flags, SHF_INFO_LINK);
        SET64(shdr.sh_offset, rela_eh_off);  /* set during data write */
        SET64(shdr.sh_size, num_eh_relas * sizeof(Elf64_Rela));
        SET64(shdr.sh_entsize, sizeof(Elf64_Rela));
        shdr.sh_link = SEC_SYMTAB;  /* symtab section */
        shdr.sh_info = 8;  /* .eh_frame section index (original) */
        SET64(shdr.sh_addralign, 8);
        fwrite(&shdr, 1, sizeof(shdr), fp_out);
        shdr_write_idx++;
    }

    /* ================================================================
     * Phase 7: .rodata section header
     * Read-only data: string literals, float constants, jump tables.
     * SHF_ALLOC but NO SHF_WRITE — OS maps pages read-only.
     * ================================================================ */
    memset(&shdr, 0, sizeof(shdr));
    shdr.sh_name = str_rodata;
    shdr.sh_type = SHT_PROGBITS;
    SET64(shdr.sh_flags, SHF_ALLOC);
    SET64(shdr.sh_offset, actual_rodata_off);
    SET64(shdr.sh_size, rodata_pos);
    SET64(shdr.sh_addralign, 8);
    fwrite(&shdr, 1, sizeof(shdr), fp_out);
    shdr_write_idx++;

    if( fixup_orig_off ) free( fixup_orig_off );
    /* Final header patches: correct e_shnum and e_shstrndx 
     * based on how many sections were actually written. */
    {
        int actual_shnum = (eh_pos > 0) ? nsec + (num_eh_relas > 0 ? 1 : 0) : nsec - 1;
        int actual_strndx = shdr_strtab_idx; /* tracked during section header writes */
        fseek(fp_out, 60, SEEK_SET);
        unsigned short sn = (unsigned short)actual_shnum;
        fwrite(&sn, 1, 2, fp_out);
        sn = (unsigned short)actual_strndx;
        fwrite(&sn, 1, 2, fp_out);
    }
    fclose(fp_out);

    /* Replace OMF with ELF64 (only if we have code) */
    if( combined_len > 0 ) {
        remove(obj_filename);
        rename(temp_name, obj_filename);
    } else {
        /* No code extracted — keep the OMF, remove temp */
        remove(temp_name);
    }

    /* Cleanup */
    for( i = 0; i < ext_count; i++ ) free(ext_names[i]);
    free(code_seg1); free(data_seg2); free(omf); free(temp_name); free(obj_filename);
    x64_active = false;
}

/* Stubs — OMF runs clean, post-processing handles everything */
void X64OutDBytes(unsigned l, const byte *s) {(void)l;(void)s;}
void X64OutDataByte(byte v) {(void)v;}
void X64OutDataShort(unsigned short v) {(void)v;}
void X64OutDataLong(unsigned long v) {(void)v;}
void X64OutIBytes(byte p, unsigned long l) {(void)p;(void)l;}
void X64OutLabel(const char *n) {(void)n;}
void X64ObjLabel(const char *n, bool g) {(void)n;(void)g;}
void X64SetCodeMode(bool c) {(void)c;}
void X64OutImport(const char *n) {(void)n;}
void X64OutPatchImport(const char *n) {(void)n;}
void X64TrackBytes(unsigned l) {(void)l;}
void X64GenObject(void) {}
