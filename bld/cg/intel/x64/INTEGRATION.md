# x86_64 Target Integration — Patch Specification

## Overview
These changes wire the x86_64 target into the existing cg and cc frontend.
Apply them when building with target_cpu=x64.

---

## 1. Target System Enum (bld/cc/h/ctypes.h)

Add `TS_LINUX64` after `TS_UNIX`:
```c
    TS_LINUX,
    TS_RDOS,
    TS_UNIX,
    TS_LINUX64     /* openwatcomirc: x86_64 Linux target */
```

## 2. Target Name Recognition (bld/cc/c/cmdlnx86.c)

In the target name switch (~line 176), add:
```c
        } else if( strcmp( target_name, "LINUX64" ) == 0 ) {
            TargetSystem = TS_LINUX64;
```

## 3. ELF Output Flag (bld/cc/c/cmdlnx86.c)

In the target system setup (~line 461), add:
```c
    case TS_LINUX64:
        PreDefineStringMacro( "__LINUX__" );
        PreDefineStringMacro( "__UNIX__" );
        PreDefineStringMacro( "__X86_64__" );     /* openwatcomirc */
        PreDefineStringMacro( "__LP64__" );        /* openwatcomirc */
        GenSwitches |= CGSW_GEN_OBJ_ELF;          /* enable ELF output */
        break;
```

## 4. Code Generator Init (bld/cg/c/generate.c or beinit.c)

When target_cpu == x64:
```c
    X64Init( true );          /* enable REX prefix generation */
```

## 5. Object Output Dispatch

When target is ELF64/x86_64, link `x64obj.c` instead of `x86obj.c`:
- `ObjInit()` → OWL initialization (x64obj.c)
- `GenObject()` → OWL emission with REX insertion (x64obj.c)
- `ObjFini()` → OWL finalization (x64obj.c)

## 6. Register Table Selection

When target_cpu == x64, use `bld/cg/intel/x64/h/regindex.h` instead of
the 386 version. This adds R8-R15 with QWORD register class.

## 7. Instruction Encoding Path

In `GenObjCode()` (x86enc.c), add x64 hooks at these points:

### a. Before opcode emission (LayOpbyte):
```c
    if( x64_mode && type_class >= I8 ) {
        X64SetRexW();  /* 64-bit operand size */
    }
```

### b. In LayReg() / LayRegRM() / LayRegAC():
```c
    if( X64IsExtReg( r ) ) {
        X64SetRexR();  /* or X64SetRexB() for rm field */
        /* use (RegTrans(r) & 7) for the 3-bit field */
    }
```

### c. In LayModRM() for memory operands:
```c
    if( x64_mode && is_absolute_address ) {
        /* Convert [disp32] to [RIP + disp32] */
        /* Use mod=00 rm=5, emit relocation */
    }
```

### d. Before TransferIns():
```c
    uint8_t rex = X64GetRex();
    if( rex != 0 ) {
        ILen = X64InsertRex( Inst, ILen, opcode_start, rex );
    }
```

## 8. Build System

Create `bld/cg/intel/x64/binmake`:
```
#pmake: binmake
host_os  = $(bld_os)
host_cpu = $(bld_cpu)
!include ../target.mif
```

Create `bld/cg/intel/x64/target.mif`:
```
target_cpu = x64
!include ../../master.mif
```

Add to `bld/cg/client.mif`:
```
o_dir_x64    = $(cg_dir)/intel/x64/$(obj_dir)
i_path_x64   = -I"$(cg_dir)/intel/x64/h" -I"$(cg_dir)/intel/h"
```

---

## File Summary

| File | Lines | Purpose |
|------|-------|---------|
| x64/h/cgx64reg.h | 84 | R8-R15, XMM0-15 register bit definitions |
| x64/h/regindex.h | 94 | Register encoding table with QWORD class |
| x64/h/x64enc.h | 120 | REX prefix helpers and encoding documentation |
| x64/h/cgtargsw.h | 19 | Target-specific switches (RIP-rel, SysV, red zone) |
| x64/c/x64enc.c | 242 | REX prefix accumulator, extended register detection |
| x64/c/x64obj.c | 178 | OWL-based ELF64 object output (replaces x86obj.c) |
| **Total** | **737** | |

Plus ~200 lines of patches to existing files (cmdlnx86.c, x86enc.c, generate.c, client.mif).
