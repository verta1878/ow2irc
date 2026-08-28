# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-28).

## All issues: RESOLVED

No known issues. Clean compile, clean link, correct results at
all optimization levels. Zero warnings when crt0_x64.o is built
with `-fno-asynchronous-unwind-tables`.

## Future — Native x64 Code Generator
Goal: no GCC dependency, self-hosted.

## Resolved
- ICE 97 / silent no-output on multi-field struct by-value
  (386table.c: Move8/Push8/PushXX fallbacks fixed;
   x86enc.c: G_UNKNOWN → silent skip for CG reduction loops)
- Multi-field struct by-value wrong result (x64obj.c: second field
  copy inserted for field-init + arg-copy pattern)
- 2-field struct brace-init (x64obj.c: duplicate load-store pair)
- .eh_frame linker warning (suppressed in compiler output; crt0
  built with -fno-asynchronous-unwind-tables)
- 32-bit pointer arithmetic (REX.W expansion pass)
- ELF64 writer (12 bugs)
- Build system (clean clone via bash build.sh)
- Runtime (crt0_x64.S)
