# OW2IRC Build Guide

_the crew 4free — sysop/0 + bob_
_Updated: 2026-08-27_

## Quick Start

```bash
git clone https://github.com/verta1878/ow2irc.git
cd ow2irc
bash build.sh
```

That's it. build.sh builds everything including bwccx64.

## What Gets Built (40 utilities)

```
C compilers:    bwcc, bwcc386, bwccaxp, bwccmps, bwccppc, bwccx64
C++ compilers:  bwpp, bwpp386, bwppaxp
Assembler:      bwasm (MASM-compatible: OPTION, RECORD, PROTO, INVOKE)
Linker:         bwlink
Librarian:      bwlib
Other:          wmake, bwdis, bwrc, bwhc, bwstrip, bwcl, etc.
```

## Prerequisites

Linux x64 with GCC 13+:
```bash
sudo apt install gcc g++ make    # Ubuntu/Debian
sudo dnf install gcc gcc-c++ make  # Fedora
```

Or self-hosted with OW1 (no GCC needed):
```bash
export WATCOM=/opt/watcom
export PATH=$WATCOM/binl:$PATH
wmake -f build.mak
```

## Build System Fixes Applied

| Fix | File | What |
|-----|------|------|
| inc_dirs line break | cc/master.mif | Merged into single line (was broken continuation) |
| cdirs.mif include | cc/master.mif | Added after tree_depth for directory vars |
| target.h includes | cc/x64/target.h | Added target64.h + targdef.h |
| target64.h types | cc/h/target64.h | TARGET_POINTER=8 + typedefs + limits |
| asclient.mif | cc/asclient.mif | Uses depth_N for wasm_dir |
| target_as_x64 | cc/master.mif | bwasm -i=watcom/h for struct.inc |
| codex64.asm | cc/a/codex64.asm | 9 real intrinsics (strlen/memcpy/etc) |
| _STANDALONE_ guards | wasm/c/asmscan.c, breakout.c, main.c | Non-standalone stubs |
| R8-R15 debug regs | dig/h/digtypes.h, watdbreg.h, dwregx86.h | CI_R8-R15 + CI_XMM0-15 |
| bwccx64 post-build | build.sh | Copies 386 objects + links with x64 CG |
| Bob's 6 SET64 | cg/intel/x64/c/x64obj.c | unsigned_64 struct assigns |
| Bob's 9 build-wiring | target64.h, master.mif, builder.ctl, etc. | Full x64 build path |

## bwccx64 Link Recipe

build.sh handles this automatically. Manual link if needed:
```bash
cd bld/cc/x64
make OWROOT=/path/to/ow2irc link
```

Libraries linked: cgx64.lib, cgx64lnx.lib, clibext.lib, dwarfw.lib, cf.lib

## wasm MASM Compatibility

wasm now supports (626 lines, 9/9 tests pass):
- OPTION NOKEYWORD — disable reserved words as identifiers
- RECORD — bit-field types with MASK/WIDTH operators
- UNION — overlapping fields at offset 0
- TYPEDEF — type aliases with PTR support
- PROTO — function prototypes with calling conventions
- INVOKE — high-level CALL with automatic PUSH+cleanup

No JWasm dependency. One assembler for everything.

## codex64.asm Intrinsics

9 inline code bursts (237 lines, assembles with bwasm):
strlen, strcpy, strcmp, strcat, memcpy, memset, memcmp, memchr, abs

## Known Issues

See KNOWN-ISSUES.md:
- Pointer through function above 4 GB (workaround: array indexing)
- LEDATA enumerated offset (latent, no test triggers it)

## Tests

```bash
# After build:
cd tests/x64
./run_tests.sh $OWROOT    # 61 runtime tests
./run_phase_tests.sh       # 11 phase tests
```
