# MinGW-w64 Runtime Port for OW2IRC

Ported from: https://github.com/mirror/mingw-w64
License: MinGW-w64 runtime license (GPL-compatible, see COPYING files)

## Complete port — 5,296 files

### Shared (all targets)
- `math/`        — 95 files: cbrt, copysign, fabs, fdim, fmax, log2, etc.
- `string/`      — 12 files: memchr, memcmp, memcpy, memmove, strchr, strstr
- `gdtoa/`       — 26 files: float-to-string (dtoa, strtod)
- `complex/`     — 76 files: complex math
- `intrincs/`    — 100 files: compiler intrinsics

### Win64 target (-bt=win64)
- `win64-headers/` — 1,794 headers: full Windows API (windows.h, etc.)
- `headers/`       — 86 headers: MinGW CRT headers
- `lib64/`         — 480 .def: Win64 import library definitions
- `crt/`           — 42 files: Win64 CRT startup (crtexe.c)
- `stdio/`         — 112 files: full stdio
- `misc/`          — 135 files: runtime utilities
- `secapi/`        — 43 files: secure CRT (_s variants)
- `ssp/`           — 13 files: stack smashing protection
- `cfguard/`       — 1 file: control flow guard
- `profile/`       — 4 files: profiling support

### Win32 target (-bt=win32)
- `lib32/`         — 816 .def: Win32 import library definitions
- `lib-common/`    — 822 .def: shared import definitions

### Libraries
- `libraries/winpthreads/` — POSIX threads for Windows
- `libraries/pseh/`        — structured exception handling
- `libraries/libmangle/`   — name mangling
- `libraries/winstorecompat/` — Windows Store compatibility

### Tools
- `tools/gendef/`   — import def generator
- `tools/widl/`     — MIDL compiler (IDL → headers)
- `tools/genidl/`   — IDL generator
- `tools/genpeimg/`  — PE image tool

### Linux x64 target (-bt=linux64)
Uses crt0_x64.S (in bld/clib/linux/x64/) + syscalls.
Shares math/, string/, gdtoa/ from this directory.
printf provided by crt/printf_linux.c with Watcom ABI wrapper.

## Two targets, one compiler
```
bwccx64 -bt=linux64  →  crt0_x64.S + syscalls + portable CRT
bwccx64 -bt=win64    →  MinGW-w64 CRT + Windows API
```

## the crew 4free
