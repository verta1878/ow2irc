# OW2IRC Build Guide — How to Build from Source

_the crew 4free — sysop/0 + bob_
_Fixes applied: 2026-08-25_

## Quick Answer for wrench

**wasm does NOT replace JWasm for VxD work.** wasm has MASM references
in its source but does NOT support the MASM features VxDs need:
`OPTION NOKEYWORD`, `&&` in macros, `RECORD <>` literals.
Keep using JWasm for FOSSIL VxD assembly. They produce the same
object format — wlink links both. See WASM-JWASM-INTEGRATION.md.

## Option 1: Build on Linux with GCC (fast, what we tested)

### Prerequisites
```bash
sudo apt install gcc g++ make
```

### Steps
```bash
# 1. Clone or extract
git clone <repo> && cd openwatcom2irc-r0.6.0

# 2. MUST use bash, not sh
export SHELL=/bin/bash

# 3. Source environment (sets OWROOT, OWTOOLS, OWOBJDIR)
. ./setvars.sh

# 4. Fix permissions (our fix)
find bld -name "configure" -exec chmod +x {} \;

# 5. Build
bash build.sh
```

### Known Build Errors + Our Fixes

| Error | File | Fix |
|-------|------|-----|
| `source: not found` | build.sh | Use `bash build.sh` not `sh build.sh` |
| `_BLDVER` empty | cmnvars.sh | setvars.sh sets it — make sure you source it first |
| W202 isElf64Cpu unused | bld/owl/c/owelf.c | Made non-static or called from writeFileHeader64 |
| W131 no prototype | bld/cg/intel/c/x64dispatch.c | Added 3 prototypes before functions |
| W131 no prototype + unused param | bld/cg/intel/x64/c/x64enc.c | Added prototype + `(void)ilen` |
| `<elf.h>` not found | bld/cg/intel/x64/c/x64obj.c | Changed to `"exeelf.h"` (OW's ELF header) |
| unsigned_64 struct assign | bld/cg/intel/x64/c/x64obj.c | SET64 macro for cross-compile |
| x64ehframe.obj missing | bld/cg/intel/master.mif | Added x64ehframe.obj + x64rodata.obj |
| configure not executable | bld/wipfc/configure | `chmod +x` on all configure scripts |
| C++ compiler skipped | bld/builder.ctl | Removed `# SKIP:` on plusplus line |

### What Gets Built (39 utilities)
```
C compilers:   bwcc, bwcc386, bwccaxp, bwccmps, bwccppc
C++ compilers: bwpp, bwpp386, bwppaxp
Assemblers:    bwasm, bwasaxp, bwasmps, bwasppc
Linker:        bwlink
Librarian:     bwlib
Disassembler:  bwdis
Resource comp: bwrc
Strip:         bwstrip
Help comp:     bwhc, bwipfc
CL drivers:    bwcl, bwcl386, bwclaxp, bwclmps, bwclppc
Other:         wmake, builder, byacc, bowcc, bdmpobj, bwbind
```

## Option 2: Self-hosted build with OW1 (no GCC needed)

### Prerequisites
- OW1 installed (C:\WATCOM or /opt/watcom)
- OW1 binaries: wcc386, wlink, wmake, wasm

### Steps (DOS/Windows)
```bat
set WATCOM=C:\WATCOM
set PATH=%WATCOM%\BINW;%PATH%
set INCLUDE=%WATCOM%\H
cd openwatcom2irc-r0.6.0
wmake -f build.mak
```

### Steps (Linux with OW1)
```bash
export WATCOM=/opt/watcom
export PATH=$WATCOM/binl:$PATH
cd openwatcom2irc-r0.6.0
wmake -f build.mak
```

OW1 compiles OW2IRC. No GCC. No external dependencies.
Self-contained toolchain builds self-contained toolchain.

## Building JUST wasm (assembler only)

If you only need the assembler and don't want the full build:

```bash
# After bootstrapping wmake:
cd bld/wasm
../../build/binbuild/builder -i boot
# Result: build/binbuild/bwasm
```

## wasm vs JWasm — Which to Use

| Task | Use | Why |
|------|-----|-----|
| OW internal .asm | wasm | Watcom syntax, OW build system |
| FOSSIL VxD | **JWasm** | Needs OPTION NOKEYWORD, && macros |
| GLaBIOS | **JWasm** | Needs RECORD <> literals |
| x64 assembly | **JWasm -elf64** | wasm has no x64 support |
| Glide NASM patches | **NASM** | Different syntax entirely |

Both produce same OMF/COFF objects. wlink links all of them.
See WASM-JWASM-INTEGRATION.md for full details + examples.
