# OW2IRC Changelog

## r0.6.1 — MinGW-w64 CRT Port (2026-08-29)

### MinGW-w64 Runtime Library
- Full MinGW-w64 CRT ported into `bld/mingw64/` (5,296 source files)
- Portable CRT library: math(90), string(12), gdtoa(21) — all targets
- Win64 CRT library: 1,080 objects covering stdio, misc, secapi, ssp,
  intrincs, complex, winpthreads, winstorecompat, crt startup
- Win64 API headers: 1,794 headers (windows.h chain verified)
- Import libraries: lib64(480), lib-common(822), lib32(816)
- printf_linux.c: Watcom-ABI printf with asm wrapper for Linux x64
- _mingw.h generated from template with all substitutions

### Build System
- `bld/mingw64/build.sh` — portable CRT (libmingw64crt.a)
- `bld/mingw64/build_win64.sh` — Win64 CRT (libmingw64win.a)
- `bld/mingw64/build_implibs.sh` — import libraries from .def
- `bld/mingw64/build_all.sh` — master build
- Main `build.sh` wired to build portable CRT automatically

### Cleanup
- `cleanup.sh` — moves x64 post-processor hacks to attic/
- 386table.c struct fixes retained (valid i386 improvements)
- x86enc.c G_UNKNOWN → Zoiks restored for i386

### Targets
- `-bt=linux64` → crt0_x64.S + libmingw64crt.a
- `-bt=win64`   → MinGW-w64 CRT + Win64 API headers + import libs
- `-bt=dos`     → OW CRT (existing)
- `-bt=os2`     → OW CRT (existing)
- `-bt=win32`   → OW CRT + lib32 imports (existing + new)

### Verified
- Win64 GUI app (MessageBox): compiles + links
- Win64 console app (WriteFile): compiles + links
- Linux x64 printf: compiles + links + runs (exit 42)
- 14/14 Win64 API headers compile
- 62/62 test battery (existing)

## r0.6.0 — x64 Post-Processor (2026-08-28)
- ELF64 object writer (OMF → ELF64 conversion)
- REX.W expansion pass for 64-bit operands
- Branch displacement fixup (is_branch + forward pass)
- Jump table rewrite (32-bit → mov+jmp)
- Struct init/by-value fixes
- Float optimizer segfault fix
- .eh_frame suppression
- 62-test battery passing

## the crew 4free
