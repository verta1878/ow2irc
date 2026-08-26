# OpenWatcom 2.0 Source Tree Map

**Upstream:** `open-watcom/open-watcom-v2` @ `d44c56f4`
**Purpose:** Guide for openwatcomirc development — where things live, how they connect.

---

## Architecture Overview

```
  cc (C frontend)  ──┐
                     ├──▶  cg (code generator)  ──▶  object file (.obj / .o)
  plusplus (C++ fe) ──┘         │
                           ┌───┴───┐
                        intel    risc
                        │         │
                     ┌──┴──┐   ┌──┴──┐
                    386   i86  axp  ppc/mps
```

The **cc** and **plusplus** frontends parse source and call the **cg** API (defined in `cgfuntab.h`) to emit code. The cg has a platform-independent core (`cg/c/`) and platform-specific backends (`cg/intel/`, `cg/risc/`).

The **wl** linker is completely separate — reads object files, not cg IR.

---

## Core Components

### `bld/cc/` — C Compiler Frontend (wcc / wcc386)
- `c/` — 146 source files: parser, type checker, preprocessor, pragma handling
- `h/` — headers, includes `cgswitch.h` and `cgapi.h` from cg
- `i86/` — 16-bit target-specific codegen integration
- `386/` — 32-bit target-specific codegen integration
- Calls cg API: `BEInit()`, `CGProcDecl()`, `CGBinary()`, `CGReturn()`, etc.
- Frontend-to-cg callbacks defined in `cfeinfo.c` (implements `FEAttr()`, `FEName()`, etc.)

### `bld/plusplus/` — C++ Compiler Frontend (wpp / wpp386)
- Same architecture as cc, adds: templates, RTTI, exception handling, name mangling
- `c/fmtsym.c` — **known issue:** compiles to 0 bytes during bootstrap, blocks bwpp386 link
- Same cg API consumer as cc

### `bld/cg/` — Code Generator (THE backend)
- **`c/`** — 146 platform-independent files: IR construction, optimization, register allocation, instruction scheduling
- **`h/`** — 218 headers including the critical API surface:
  - `cgfuntab.h` — complete CG API table (133 functions via CGAPIDEF macro)
  - `cgswitch.h` — switches controlling codegen behavior (ELF, COFF, PIC, etc.)
  - `cg.h` — types, constants, FE attribute flags
  - `cgapi.h` — API export/import decorators
- **`intel/`** — x86 backend
  - `c/` — 39 files: x86 encoding, register allocation, FPU scheduling, calling conventions
  - `h/` — x86-specific headers
  - `386/` — 32-bit x86 specifics (flat model, 386+ instructions)
  - `i86/` — 16-bit x86 specifics (segmented model, 8086 instructions)
- **`risc/`** — RISC backends
  - `axp/` — Alpha AXP
  - `ppc/` — PowerPC
  - `mps/` — MIPS
  - These backends use the OWL (Object Writer Library) in `bld/owl/`

### `bld/wl/` — Linker (wlink)
- `c/` — linker source: format handlers (OMF, ELF, COFF, PE, LX, LE, NLM)
- `h/` — linker headers
- `lnk/` — system definition templates (`specs.sp`, `wlink.sp`)
- `exe2bin/` — raw binary output tool
- Completely independent of cg — reads object files only

### `bld/as/` — Assemblers
- `c/` — architecture-independent assembler framework
- `axp/`, `mps/`, `ppc/` — RISC assemblers
- WASM (x86 assembler) lives separately in `bld/wasm/`

### `bld/wasm/` — Watcom x86 Assembler (WASM)
- Handles TASM-compatible syntax
- Independent tool, not part of the cg pipeline

---

## Runtime Libraries

### `bld/clib/` — C Runtime Library
- `library/` — final combined .lib files per target (1,011 libraries total)
- Subdirectories by function group: `file/`, `handleio/`, `startup/`, `string/`, `time/`, etc.
- Each group builds per-target variants: `msdos.086/`, `msdos.386/`, `winnt.386/`, `os2.386/`, etc.

### `bld/mathlib/` — Math Library (95 libraries)
### `bld/cpplib/` — C++ Runtime Library (needs wpp386)
### `bld/w32api/` — Win32 API Import Libraries (105 .lib files)
### `bld/os2api/` — OS/2 API Libraries

---

## Build System

### `bld/builder/` — The `builder` tool (orchestrates multi-project builds)
### `bld/wmake/` — Watcom Make (wmake)
### `build/mif/` — Shared makefile includes
- `local.mif` — compiler flags, toolchain detection (__GCC_TOOLS__ etc.)
- `cproj.mif` — project configuration
- `cpuoscfg.mif` — CPU/OS detection
### `build/makeinit` — wmake initialization (sets __GCC_TOOLS__ from OWTOOLSVER)

---

## The CG API — Frontend/Backend Interface

The CG API (`cgfuntab.h`) is the seam between frontends and the code generator. 133 functions in three groups:

**BE* (Backend control):** `BEInit`, `BEStart`, `BEStop`, `BEFini`, `BEDefSeg`, `BENewBack`, `BEDefType`, `BENewLabel`, `BEPatch`

**CG* (Code generation):** `CGProcDecl`, `CGParmDecl`, `CGInteger`, `CGFloat`, `CGBinary`, `CGUnary`, `CGAssign`, `CGCall`, `CGReturn`, `CGCompare`, `CGControl`, `CGSelect`, `CGTemp`, `CGFEName`, `CGBackName`

**DG* (Data generation):** `DGLabel`, `DGInteger`, `DGFloat`, `DGString`, `DGBytes`, `DGAlign`

**DB* (Debug info):** `DBLineNum`, `DBModSym`, `DBLocalSym`, `DBBegStruct`, `DBAddField`, `DBEndStruct`, `DBBegBlock`, `DBEndBlock`

The frontend calls these in order: `BEInit` → `BEStart` → per-function (`CGProcDecl` → `CGParmDecl` → tree of `CG*` ops → `CGReturn`) → `BEStop` → `BEFini`.

The cg builds an internal IR (expression trees), runs optimization passes, then the platform backend (`intel/386/` or `risc/*/`) does register allocation and instruction encoding.

---

## GCC Backend Hook Point (for openwatcomirc Phase C)

The seam for a GCC/ELF backend would replace `cg/intel/` with a new `cg/elf64/` that:
1. Implements the same 39-file interface as `cg/intel/c/`
2. Targets x86_64 SysV ABI instead of Watcom register calling convention
3. Emits ELF64 objects instead of OMF
4. Uses the existing `cg/c/` optimization and IR infrastructure unchanged

The `CGSW_GEN_OBJ_ELF` flag already exists in `cgswitch.h` — the RISC backends already emit ELF via OWL. The intel backend currently only emits OMF (and optionally COFF for Win32).

Key files to study for the backend interface:
- `cg/intel/c/x86enc.c` — instruction encoding (this is what gets replaced)
- `cg/intel/c/x86call.c` — calling convention implementation
- `cg/intel/386/c/386rgtbl.c` — register table (would need x86_64 extension)
- `cg/c/generate.c` — backend-independent code generation loop
- `cg/c/regalloc.c` — register allocator (reusable)
- `cg/c/objout.c` — object file output dispatch

---

## File Counts

| Component | C files | Headers | Notes |
|-----------|---------|---------|-------|
| cc (C frontend) | ~80 | ~50 | Plus per-target dirs |
| plusplus (C++ frontend) | ~200 | ~100 | Much larger than cc |
| cg core | 146 | 218 | Platform-independent |
| cg/intel | 39 | ~30 | x86 backend |
| cg/risc | ~30 | ~20 | AXP/PPC/MIPS |
| wl (linker) | ~80 | ~60 | |
| wasm (x86 asm) | ~40 | ~30 | |
| clib (C runtime) | ~300 | ~100 | Per-target variants |

Total `bld/` tree: 120 top-level directories, thousands of source files.
