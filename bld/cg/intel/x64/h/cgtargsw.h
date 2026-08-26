/*
 * openwatcomirc — x86_64 target-specific code generation switches
 *
 * Includes the shared x86 switches (which define proc_revision and
 * the CPU/FPU flags), then adds x64-specific switches.
 */

#ifndef CG_X64_TARGSW_H
#define CG_X64_TARGSW_H

/* Shared x86 switches — defines proc_revision, CPU_*, FPU_*, etc. */
#include "cgx86swi.h"

/* x86_64 target switches */
typedef enum {
    CGSW_X64_RIP_RELATIVE       = 0x00000001,
    CGSW_X64_SYSV_ABI           = 0x00000002,
    CGSW_X64_RED_ZONE           = 0x00000004,
    CGSW_X64_NO_FRAME_POINTER   = 0x00000008,
} cg_x64_switches;

#define CGSW_X64_LINUX_DEFAULT  (CGSW_X64_RIP_RELATIVE | CGSW_X64_SYSV_ABI | CGSW_X64_RED_ZONE)

#endif
