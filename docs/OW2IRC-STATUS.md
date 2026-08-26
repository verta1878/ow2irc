# OpenWatcom 2 IRC — Status

_Version: r0.6.0_
_Last updated: 2026-08-25_

## Crew (9 members)

| Handle | Role |
|--------|------|
| verta1878 | Project lead |
| sysop/0 | Compiler engineer, FPC + OW2IRC maintainer, Tang Console, USB |
| bob | Compiler engineer, wcc64 backend, Glide builds |
| evga | Display, Mystic, SIO rebuild |
| kiddo | Protocols, RIPscrip |
| wrench | Transport, FOSSIL, DVI/HDMI |
| hexadecimal | PCBoard, Cyclades |
| byte | Program recovery |
| dotmatrix | Software recovery |

## Compiler: wcc64 (x86-64)

61/61 runtime tests + 4 test suites. 0 failures.
Glide3x SST-1: 24/24 TUs (22,891 lines). DOS harness prints "Voodoo Graphics".

## x64 Backend: 11 Phases COMPLETE

| Phase | Header | Implementation | Status |
|-------|--------|---------------|--------|
| 1-4 | — | Type model, encoding, floats, stack frames | ✅ bob |
| 5 | x64sysv.h (476) | SysV AMD64 ABI | ✅ bob |
| 6 | x64ehframe.h (42) | x64ehframe.c (322) — .eh_frame DWARF | ✅ sysop/0 |
| 7 | x64rodata.h (10) | x64rodata.c (137) — .rodata section | ✅ sysop/0 |
| 8 | x64win64.h (12) | x64win64.c (117) — Win64 ABI | ✅ sysop/0 |
| 9 | x64seh.h (33) | x64seh.c (195) — SEH .pdata/.xdata | ✅ sysop/0 |
| 10 | x64asm.h (31) | x64asm.c (242) — instruction encoder | ✅ sysop/0 |
| 11 | x64clib.h (11) | x64clib.c (241) — startup + setjmp | ✅ sysop/0 |

Additional: x64obj_integration.c (291), x64parm.c (164), x64pe.c (276), x64c99compat.c (129)
Total x64 CG: 4,871 lines. Wired into x64obj.c (1,492 lines).

## Bug Fixes

| Fix | Who | What |
|-----|-----|------|
| Struct pointer offsets | sysop/0 | MapPointer → U8 on x64 |
| Stale __CHK | bob | ret $8 in crt0_x64.S |
| OWL isElf64Cpu | sysop/0 | Guard for DOS builds |
| x64dispatch protos | sysop/0 | Missing prototypes |
| x64enc unused param | sysop/0 | (void)ilen |
| x64obj.c <elf.h> | sysop/0 | → "exeelf.h" for OW |
| master.mif | sysop/0 | Added x64ehframe.obj + x64rodata.obj |
| configure +x | sysop/0 | chmod on all configure scripts |

## Build Results

39 utilities built. 0 errors in bootstrap.
5 C compilers + 3 C++ compilers + 4 assemblers + linker + tools.

## musl-ow (Self-Contained C/C++ Library)

Phase M-0 through M-7: COMPLETE.
1,538 files compiled. libc.a = 2.6 MB. Static hello world = 18 KB.
Zero external dependencies.

Phase M-8 through M-16e: Frameworks + Tests COMPLETE.
12 files, 1,196 lines. All tests pass:
- M-10: Itanium name mangling (72 lines, 6/6 pass)
- M-11: DWARF exception tables (129 lines, 2/2 pass)
- M-13: Parallel algorithms (87 lines, 2/2 pass)
- M-14: __gnu_cxx rope+filebuf+pool (230 lines, 5/5 pass)
- M-15: C++23 stacktrace+text_encoding+inplace_vector (117 lines, 6/6 pass)
- M-16: C++11/14/17/20/23 parser tokens+types (476 lines, 38/38 pass)
Total: 59/59 tests pass across all musl-ow phases.

## Remaining

| Item | Priority | Status |
|------|----------|--------|
| FOSSIL VxD Win98 test | HIGH | Test procedure written |
| FOSSIL NT .SYS driver | HIGH | 373 lines written |
| musl-ow libc++ actual build | MEDIUM | Needs wpp64 on real tree |
| musl-ow C++23 parser impl | MEDIUM | 21K lines, 6-12 months |
| Full build.sh completion | NEEDED | bob runs it |

## JWasm Integration

wasm (Watcom syntax) + JWasm (MASM syntax) produce same OMF/COFF.
wlink links both. Use JWasm for FOSSIL drivers, GLaBIOS, MASM files.
Use wasm for OW internals. See WASM-JWASM-INTEGRATION.md.
