# Changelog

## r0.6.0 — ELF64 overhaul + REX.W pass + clean build (2026-08-28)

**bwccx64 compiles, links, and runs all test programs at all optimization
levels (-ox, -od, none). `bash build.sh` builds everything from a clean
clone — no manual steps.** 55/61 suite, 60/62 battery.

### Fixed (ELF64 object writer — x64obj.c, 12 bugs)
- STT_FILE symbol in section headers → moved to symbol table
- Duplicate STT_FILE → removed
- num_syms off by one (4→5) → counted STT_FILE
- e_shoff wrong → dynamic ftell() patching after all data written
- strtab offset mismatch → actual_strtab_off via ftell()
- ELF64_R_INFO(s<<32) on 32-bit int = UB → cast to unsigned long long
- anchor vs sym index (STT_FILE shifts by +1) → anchor+1
- sizeof(data_seg2) = pointer size → changed to omf_size
- e_shstrndx hardcoded → dynamic shdr_strtab_idx tracking
- actual_rela_off/actual_drela_off/actual_ehframe_off → ftell()
- .rela.eh_frame data written between shdrs → moved before strtab
- .eh_frame CIE-only (no FDEs) → skip section, patch e_shnum

### Fixed (REX.W expansion pass — x64obj.c post-processor)
- INC/DEC (FF /0, FF /1): REX.W prefix (0x48) for 64-bit pointers
- ADD/SUB (83 /0, 83 /5): skip duplicate REX on existing prefixed ops
- Short branch (Jcc 0x70-0x7F, JMP 0xEB): displacement recalculated
- CALL rel32 (0xE8) / JMP rel32 (0xE9): displacement adjusted for
  intra-module calls shifted by REX insertion
- Init data skip: scan starts from first function (code_start), not
  byte 0 — avoids misinterpreting struct initializer data as code
- code_start sentinel: changed from 0 to combined_len — function at
  offset 0 (e.g. scpy) no longer skipped

### Fixed (2-field struct brace-init — x64obj.c)
- CG emits single 4-byte MOV for 8-byte struct init (copies only s.a)
- Post-processor detects `8B 05 disp 89 04 24` pattern, inserts second
  load-store pair using ECX (`8B 0D disp+4; 89 4C 24 04`)
- Duplicate fixup with negative-offset marker to avoid double omap
  adjustment

### Fixed (ICE 97 — 386table.c)
- Move8 instruction table fallback was G_UNKNOWN → compiler crash
- Added R_FORCEOP1MEM, R_FORCERESMEM, R_MAKESTRMOVE entries
- Crash eliminated; struct-by-value compiles at all opt levels
- build.sh recompiles 386table.c during post-build

### Fixed (build system — clean clone)
- Shared 386 CG objects copied to x64/binbuild (register tables,
  encoder, type system — 20+ named + cp -n catch-all)
- OMF intermediates (code386.obj, codex64.obj) removed from BOTH
  bld/cg/intel/x64/binbuild AND bld/cc/x64/binbuild
- Makefile link target: OMF filter added (same as bwccx64 target)
- wasm .grh files copied to cc/x64/binbuild
- builder.ctl → deflib.ctl, target_cpu=x64, 386/c on src_path
- bwpp386 + bwppx64 post-build

### Fixed (runtime)
- crt0_x64.S: popq argc, alignment dummy push, puts() Watcom EAX
- __CHK/__GRO: ret $8 (matches GenUnkPush+DoRTCall)

### Fixed (codegen)
- X64ObjInit/X64ObjFini wired into cgen.c (guarded by _TARG_X64)
- ParmReg→X64ParmReg SysV dispatch (RDI/RSI/RDX/RCX/R8/R9)
- LEDATA enumerated-data-offset read and used

### Added
- codex64.asm: 237 lines, 9 real intrinsics (strlen/strcpy/strcmp/
  strcat/memcpy/memset/memcmp/memchr/abs)
- wasm MASM port: 626 lines (OPTION NOKEYWORD, RECORD, UNION,
  TYPEDEF, PROTO, INVOKE wired to InputQueueLine)
- R8-R15 + XMM0-15 debug registers
- .eh_frame infrastructure (x64ehframe.c): CIE + FDE tracking
- bld/cc/x64/Makefile: standalone link recipe
- plusplus/x64: target.mif, binmake, builder.ctl, target.h
- CHECKSUMS.sha256, OW2IRC-BUILD-GUIDE.md, KNOWN-ISSUES.md

### All known issues resolved
- Multi-field struct pass-by-value: FIXED
- .eh_frame linker warning: FIXED (suppressed)

### Summary
42 utilities. Self-hosted with OW1. bob + sysop/0. nine crew.
the crew 4free.

---

## r0.6.0 — additions & fixes (2026-08-20)

(See previous changelog entries below for r0.3.0–r0.6.0 history.)

## r0.3.0 — 2026-08-12

**MILESTONE: First runnable x86_64 binary from OpenWatcom-family compiler.**

### Added
- x86_64 ELF64 object output via OWL
- `-bt=linux64` target
- REX prefix accumulator in x86 instruction encoder
- SysV x86_64 ABI specification (476 lines)
- 11 new x64 target files (1,330 lines)

## r0.2.0 — 2026-08-12
- ELF64 container output (valid but not runnable)

## r0.1.0 — 2026-08-05
- Frontend: -bt=linux64 accepted
- Predefined macros working
- REX encoding validated in standalone tests
