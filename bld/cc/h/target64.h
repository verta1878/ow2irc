/****************************************************************************
*   OpenWatcom 2 IRC — x86-64 target configuration
*   TARGET_POINTER = 8 (64-bit pointers)
*   GPLv3 — the crew 4free — sysop/0
****************************************************************************/

#define TARGET_SHORT        2
#define TARGET_INT          4
#define TARGET_LONG         4       /* LP64: long = 8, but OW uses LLP64-style */
#define TARGET_LONG64       8
#define TARGET_POINTER      8       /* 64-bit pointers */
#define TARGET_NEAR_POINTER 8
#define TARGET_FAR_POINTER  10      /* seg:off64 */
#define TARGET_DOUBLE       8
#define TARGET_LONG_DOUBLE  10      /* x87 extended */
#define TARGET_LDOUBLE      16      /* aligned to 16 */

/* Integer/float limit macros. target64.h previously omitted these, so
 * front-end sources (ccheck.c etc.) failed on TARGET_FLT_MAX and friends.
 * x64 uses the 386 LLP64-style model (int=4, long=4), so mirror target32.h. */
#define TARGET_CHAR_MAX     127
#define TARGET_UCHAR_MAX    255U
#define TARGET_SHORT_MAX    32767
#define TARGET_USHORT_MAX   65535U
#define TARGET_INT_MAX      2147483647
#define TARGET_INT_MIN      (-2147483647-1)
#define TARGET_UINT_MAX     4294967295U
#define TARGET_LONG_MAX     2147483647
#define TARGET_ULONG_MAX    4294967295U
#define TARGET_FLT_MAX      3.402823466e+38f

/* Remaining type-size macros the front-end needs (cdinit.c wchar, complex/
 * imaginary types, bitfield container, bool). Mirror target32.h — x64 uses
 * the 386 model for these. */
#define TARGET_BOOL         1
#define TARGET_CHAR         1
#define TARGET_WCHAR        2
#define TARGET_FLOAT        4
#define TARGET_UINT         4
#define TARGET_ULONG        4
#define TARGET_ULON64       8
#define TARGET_BITFIELD     8
#define TARGET_FCOMPLEX     8
#define TARGET_FIMAGINARY   4
#define TARGET_DCOMPLEX     16
#define TARGET_DIMAGINARY   8
#define TARGET_LDCOMPLEX    20
#define TARGET_LDIMAGINARY  10

/* Target integer type mappings. target64.h previously defined only the
 * TARGET_* sizes but not these typedefs, so every front-end source that
 * used target_size failed to compile ("unknown type name 'target_size'").
 * x64 uses the 386 code generator, so mirror target32.h. */
typedef short               target_short;
typedef unsigned short      target_ushort;
typedef int                 target_int;
typedef unsigned int        target_uint;
typedef int                 target_long;
typedef unsigned int        target_ulong;
typedef int                 target_ssize;
typedef unsigned int        target_size;
