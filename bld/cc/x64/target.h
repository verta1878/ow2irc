/****************************************************************************
*   OpenWatcom 2 IRC — wcc64 target configuration
*   Builds the x86-64 C compiler.
*   GPLv3 — the crew 4free — sysop/0
****************************************************************************/

#ifndef _TARGET_INCLUDED
#define _TARGET_INCLUDED
#include "target64.h"
#include "targdef.h"
#include "langenvd.h"

#define _CPU            386     /* Uses 386 CG with x64 post-processing */
#define _TARG_X64       1       /* Enable x64 code paths */

#define __TGT_SYS       __TGT_SYS_X86

#endif
