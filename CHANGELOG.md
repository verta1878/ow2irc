# Changelog

## r0.6.0 — ELF64 writer overhaul + end-to-end verified (2026-08-27)

**bwccx64 compiles, links, and runs "Hello from bwccx64!" — zero
warnings, zero errors, clean link.** build.sh builds everything
automatically. All known issues resolved.

### Fixed (ELF64 object writer — x64obj.c)
- STT_FILE symbol written between section headers — moved to symbol table.
- Duplicate STT_FILE symbol — removed.
- num_syms off by one (4→5) — STT_FILE not counted.
- e_shoff wrong — dynamic ftell() patching after all data written.
- strtab offset mismatch — actual_strtab_off via ftell().
- ELF64_R_INFO(s<<32) on 32-bit int = UNDEFINED BEHAVIOR — #undef +
  cast to unsigned long long. Root cause of all relocations having sym=0.
- anchor vs sym index — anchor=SEC_DATA=2 but sym .data=3 (STT_FILE
  shifts by 1). Added anchor+1 in ELF64_R_INFO.
- sizeof(data_seg2) returned pointer size (8) not allocated size —
  changed to omf_size. Root cause of string literals missing from .data.
- .eh_frame CIE-only output with no FDEs — skip when
  eh_frame_get_num_fdes()==0. Dynamic e_shnum/e_shstrndx patching.
  Clean link, no warnings.

### Fixed (build system)
- inc_dirs broken line continuation (space instead of &) — merged into
  single line. Root cause of all x64 CC header-not-found errors.
- cdirs.mif not included in CC master.mif — added after tree_depth.
  Resolves wasm_dir, cg_dir, dwarfw_dir, comp_cfg_dir for x64.
- x64/target.h missing target64.h + targdef.h — added. Provides
  target_size typedef and _INTEL_CPU macro.
- asclient.mif — uses depth_N for wasm_dir resolution.
- target_as_x64 — added -i=watcom/h for struct.inc.
- build.sh post-build after exit — moved before exit.
- build.sh recompiles cgen.c + cmdlnx86.c + x64obj.c with
  -D_TARG_X64=1 so OMF→ELF64 conversion activates.
- build.sh copies 386 CC objects to x64 + links with x64 CG.
- build.sh builds bwpp386 + bwppx64 (C++ x64 compiler).

### Fixed (runtime)
- crt0_x64.S _start: popq argc instead of movq (stack frame corruption
  after AND alignment). Alignment dummy push before call main.
- puts() uses EAX (Watcom calling convention, matches 386 CG output).
- __CHK / __GRO verified correct (ret $8, matching GenUnkPush+DoRTCall).

### Fixed (codegen)
- X64ObjInit/X64ObjFini wired into cgen.c (guarded by _TARG_X64).
  Enables OMF→ELF64 post-processing during compilation.
- ParmReg() dispatches to X64ParmReg() when _TARG_X64 defined.
  SysV ABI parameter passing: RDI/RSI/RDX/RCX/R8/R9.
- LEDATA enumerated-data-offset read and used. Handles sparse
  emitters, zero-fills gaps.

### Added
- codex64.asm — 237 lines, 9 real intrinsics (strlen, strcpy, strcmp,
  strcat, memcpy, memset, memcmp, memchr, abs). Same macro format as
  code386.asm. Assembles with bwasm. No stubs.
- wasm MASM port — 626 lines (asmoption.c, asmrecord.c, asminvoke.c).
  OPTION NOKEYWORD wired into scanner. RECORD bit-fields MASK/WIDTH.
  UNION overlapping fields. TYPEDEF type aliases. PROTO function
  prototypes with calling conventions. INVOKE high-level CALL with
  PUSH+CALL codegen wired to InputQueueLine. 9/9 tests pass.
- R8-R15 + XMM0-15 debug registers (digtypes.h, dwregx86.h, watdbreg.h).
- .eh_frame infrastructure (x64ehframe.c): CIE with correct x64 DWARF
  registers (RA=16, RSP=7, RBP=6). FDE tracking (fde_eh_offset[],
  fde_code_addr[]). .rela.eh_frame section code. Activates automatically
  when CG emits standard prologues.
- bld/cc/x64/Makefile — standalone link recipe (85 lines).
- plusplus/x64 — target.mif, binmake, builder.ctl, target.h.
- Bob's 6 SET64 fixes (unsigned_64 struct assigns in x64obj.c).
- Bob's 9 build-wiring fixes (target64.h, master.mif, builder.ctl,
  intel/master.mif objects+paths).
- _STANDALONE_ guards on asmscan.c, breakout.c, main.c.
- CHECKSUMS.sha256 annotated (.obj files are gitignored).
- OW2IRC-BUILD-GUIDE.md updated (99 lines).
- KNOWN-ISSUES.md: all resolved, moved to todo/.

### Summary
42 utilities built. 4,871 lines x64 CG + 1,196 lines musl-ow + 626
lines wasm MASM + 237 lines codex64.asm. Self-hosted with OW1.
133 tests, 0 failures. bob + sysop/0. nine crew. the crew 4free.

---

## r0.6.0 — additions & fixes (2026-08-20)

No new feature surface vs r0.6.0 — additions and bug fixes on the same
x86-64 backend. Kept at r0.6.0 intentionally.

### Fixed (codegen correctness)
- Jump-relocation scanner (x64obj.c): added a real x86 instruction-length
  decoder (modrm_len/x86_insn_len). The relocation pass had walked
  byte-by-byte and mistook a ModRM byte (0x7d) for a short JGE, silently
  corrupting lea displacements. Root cause behind several intermittent
  miscompiles (loops, in particular).
- Frame-register / stack-parameter offsets (x86proc.c): x64 always uses an
  RBP frame; parameter and local references now resolve correctly. Fixes
  5+ argument functions read across an intervening call.
- DGInteger buffer overflow (intrface.c): constant-emit buffer was byte[6],
  overflowed on 8-byte pointer constants once pointers went 64-bit. Sized
  to the largest emittable type. Found with ASan.
- 8-byte pointers finalised (386type.c, 386ptype.c, targsys.h).
- Prime-sieve test restored to expect the correct count (had been patched
  to a wrong value to match a buggy build).

### Added
- tests/x64/run_tests.sh + 72 test cases — 61/61 x86-64 runtime tests.
- bld/clib/linux/x64/ — freestanding crt0 and mini runtime.
- Validated the backend against a large real-world codebase (a 3dfx Glide
  SST-1 driver, ~23k lines). That driver work lives in a separate repo,
  not here, keeping this a clean compiler toolchain.

### Docs
- README and INSTALL rewritten to current state (bwcc64 not bwcc386;
  61/61; DOS target matrix). KNOWN-ISSUES updated: loops/recursion/globals
  were marked open but are fixed.


## r0.3.0 — 2026-08-12

**MILESTONE: First runnable x86_64 binary from OpenWatcom-family compiler.**

```
$ bwcc386 hello.c -fo=hello.o -bt=linux64 -ox
$ gcc hello.o -o hello -no-pie
$ ./hello; echo $?
42
```

### Added
- x86_64 ELF64 object output via OWL (Object Writer Library)
- `-bt=linux64` target: `__X86_64__`, `__LP64__`, `__amd64__`, `__LINUX__`, `__UNIX__`
- REX prefix accumulator in x86 instruction encoder
- OWL ELF64 emitter (ELFFileEmit64, x86_64 relocation tables)
- SysV x86_64 ABI specification (476 lines)
- Parallel OWL+OMF initialization (no cg refactoring needed)
- Symbol table export (main visible via FEName + OWLEmitLabel)
- OWL library linked into 386 cg (use_owl_lib_386 = 1)
- 11 new x64 target files (1,330 lines)

### Changed
- x86obj.c: Out* functions redirect to OWL when X64IsActive()
- x86enc.c: REX accumulator, LayReg/LayRM extended register detection
- x86enc.c: INC/DEC remapping (0x40-0x4F → FF /0, FF /1)
- intel/master.mif: x64 objects, include paths, OWL headers
- cg/client.mif: OWL linked for 386 target
- bwpp386: fmtsym.obj bootstrap fix (C++ compiler working)

### Fixed
- hw_reg_set member access: `._1` not `.u.word[1]`
- TransferIns REX insertion after legacy prefixes
- OutDataByte routing to .text for code bytes (RET)

### Upstream
- Base: open-watcom/open-watcom-v2 @ d44c56f4
- 15 files patched, zero upstream regressions
- 21/21 test suite pass

## r0.2.0 — 2026-08-12 (earlier)
- ELF64 container output (valid but not runnable)
- Symbol table (main exported)
- GCC linking (successful)

## r0.1.0 — 2026-08-05
- Frontend: -bt=linux64 accepted
- Predefined macros working
- OWL ELF64 sections created
- REX encoding validated in standalone tests
- SysV ABI validated (7 args, callee-save, varargs)
