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
