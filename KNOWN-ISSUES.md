# openwatcom2irc — Known Issues

Status as of r0.6.1 (2026-08-29).

## r0.6.1 — MinGW-w64 CRT Port

### Complete
- MinGW-w64 CRT ported (5,296 source files, 1,080 Win64 objects)
- Portable CRT (math/string/gdtoa) builds for all targets
- Win64 CRT verified: GUI + console apps link
- Linux x64 CRT verified: printf works end-to-end
- 14/14 Win64 API headers compile
- Import libraries: lib64(480) + lib-common(822) + lib32(816)
- Build scripts: build.sh, build_win64.sh, build_implibs.sh, build_all.sh
- owlink wrapper for easy linking
- cleanup.sh moves post-processor to attic

### Not yet implemented
- Win32 CRT build (needs i686-w64-mingw32-gcc cross compiler)
- BSD / macOS target support (future)
- Native x64 CG (sysop/0's _TARG_X64 paths need wiring)

### Known limitations
- 28 CRT source files need MinGW's autoconf configure step
  (inline override units, not user-facing functions)
- bwccx64 uses 386 CG with post-processor for x64 output
  (cleanup.sh attics the post-processor; native CG is future work)
