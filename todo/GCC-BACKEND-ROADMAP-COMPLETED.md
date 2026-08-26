# GCC Backend Roadmap — openwatcomirc

**Author:** sysop/0
**Date:** 2026-07-31
**Status:** Scoping complete. Prototype validated. Implementation is Phase 16+.

---

## Decision: Integration Model (C1)

**We add a new target, not replace the existing one.**

The OpenWatcom code generator (`bld/cg/`) has a clean frontend/backend split:
- **Frontend** (cc/plusplus) calls 133 API functions defined in `cgfuntab.h`
- **Core** (`cg/c/`, 146 files) handles IR, optimization, register allocation
- **Backend** (`cg/intel/` or `cg/risc/`) handles instruction encoding and object output

For ELF/x86_64, we create a new backend path that:
- Reuses the entire `cg/c/` optimization core unchanged
- Emits x86_64 instructions (extending the existing x86 encoder)
- Outputs ELF64 objects via OWL (Object Writer Library) instead of OMF

The existing `cg/intel/` backend stays untouched for DOS/OS/2/Win32 targets.

---

## Prototype Results (C3)

### What was validated:
1. **OWL compiles standalone** with GCC — all 13 files, zero errors, 75KB static library
2. **OWL already has `OWL_CPU_X64`** in its CPU enum with `EM_X86_64` mapping
3. **x86_64 relocation tables added** to `owreloc.c` — `R_X86_64_PC32`, `R_X86_64_PLT32`, `R_X86_64_64`, `R_X86_64_GOTPCREL` all wired up
4. **End-to-end ELF64 pipeline proven:** hand-coded x86_64 → ELF64 relocatable object → GCC linker → running Linux binary printing "Hello from openwatcomirc!"

### What needs work:
1. **`owelf.c` assumes ELFCLASS32** — all 527 lines use `Elf32_*` structures. Needs conditional or parallel `Elf64_*` path. The Elf64 types already exist in `exeelf.h`.
2. **x86_64 instruction encoding** — `x86enc.c` (2,518 lines) handles 32-bit x86 only. Needs REX prefix generation, 64-bit operand support, RIP-relative addressing as default.
3. **Register table** — `386rgtbl.c` defines 8 GPRs. x86_64 has 16 (r8-r15).
4. **Calling convention** — current backend uses Watcom register convention. x86_64 SysV ABI is completely different (see below).

---

## Calling Convention Differences (C4)

### Watcom Register Convention (current)
- First 4 integer args: EAX, EDX, EBX, ECX
- Callee saves: ESI, EDI, EBP, ESP
- Return: EAX (32-bit), EDX:EAX (64-bit)
- Stack: caller-cleaned
- No red zone

### SysV AMD64 ABI (target for Linux/FreeBSD/macOS)
- First 6 integer args: RDI, RSI, RDX, RCX, R8, R9
- First 8 float args: XMM0-XMM7
- Callee saves: RBX, RBP, R12-R15
- Return: RAX (integer), XMM0 (float)
- Stack: 16-byte aligned at call, 128-byte red zone
- Varargs: AL = number of vector registers used

### Implications
- Register allocator needs 16 GPRs + 16 XMM registers
- Function prolog/epilog completely different
- Struct passing rules differ (SysV classifies struct fields)
- The `cg/c/` register allocator is generic enough — it's parameterized by a register table. Swapping the table is the main work.

---

## Implementation Phases

### Phase 16: OWL Elf64 Support
- Add `Elf64_*` code path to `owelf.c` (conditional on cpu being 64-bit)
- Verify OWL emits valid ELF64 objects that GCC/ld can link
- **Gate:** `hello.c` → OWL → `hello.o` → `gcc hello.o -o hello` → runs
- Estimated: ~500 lines of new code in owelf.c

### Phase 17: x86_64 Instruction Encoding
- Extend `x86enc.c` with REX prefix generation
- Add R8-R15 to register table
- RIP-relative addressing for all memory references
- 64-bit immediate support
- **Gate:** wcc can compile `int main(void) { return 42; }` to a working ELF64 object
- Estimated: ~1,000 lines of changes across x86enc.c, 386rgtbl.c, x86call.c

### Phase 18: SysV ABI Calling Convention
- New calling convention implementation in `x86call.c`
- 16-byte stack alignment enforcement
- Red zone support
- XMM register allocation for floats
- Struct passing/returning rules
- **Gate:** wcc can compile code that calls libc functions (printf, malloc, etc.)
- Estimated: ~800 lines

### Phase 19: Frontend Integration
- Wire `-bt=linux64` target in cc frontend (`cmdlnx86.c`)
- Set `CGSW_GEN_OBJ_ELF` when targeting Linux x86_64
- Generate correct startup code references (`_start` vs `main`)
- Linux system header compatibility (if targeting native Linux C library)
- **Gate:** `wcc -bt=linux64 hello.c -o hello.o` → valid ELF64 object

### Phase 20: C Runtime and Testing
- Minimal CRT startup for Linux (or rely on system libc)
- Regression testing against PCBoard source (C files that already compile)
- Performance comparison: openwatcomirc ELF output vs GCC native
- **Gate:** pcbirc builds for Linux from the same source tree

---

## Size Estimates

| Component | Lines (est.) | Difficulty |
|-----------|-------------|------------|
| OWL Elf64 | ~500 | Medium |
| x86_64 encoding | ~1,000 | Hard |
| SysV ABI | ~800 | Hard |
| Frontend wiring | ~200 | Easy |
| CRT startup | ~300 | Medium |
| **Total** | **~2,800** | |

For comparison: the existing intel backend is 21,544 lines. The RISC backend is 4,875 lines. An ELF/x86_64 backend leveraging both OWL and the existing x86 encoder would be significantly smaller than either.

---

## What We Don't Need to Build

- **Linker:** wlink already handles ELF (for Linux targets). Or use system `ld`/`gcc` to link.
- **Optimizer:** `cg/c/` is reused entirely — no optimization work needed.
- **Preprocessor/Parser:** cc frontend is target-independent — works as-is.
- **Debug info:** OWL already supports DWARF output for RISC. Same path works for x86_64.

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| owelf.c Elf64 refactor is messier than expected | Delays Phase 16 | Prototype bypassed OWL entirely — fallback is standalone emitter |
| x86_64 encoding edge cases (VEX, EVEX, AVX) | Scope creep | Start with baseline x86_64 only, no SIMD extensions |
| SysV struct passing rules are complex | Phase 18 takes longer | PCBoard is all scalar — struct ABI can be deferred |
| Watcom's cg IR doesn't map cleanly to 64-bit | Architecture problem | Prototype suggests it will — cg already handles 32-bit PPC/Alpha |

---

## Philosophy

*The toolchain outlives the software.* openwatcomirc's GCC backend means every C codebase the crew touches — PCBoard, Mystic utilities, BBS tools — can target modern UNIX from the same source tree that targets DOS and OS/2. One compiler fork, all platforms, forever-buildable.

o7
