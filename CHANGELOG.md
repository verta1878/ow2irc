# Changelog

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
