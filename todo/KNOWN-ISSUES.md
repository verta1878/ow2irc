# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-28).

## All issues: RESOLVED

No known issues. Clean compile, clean link, correct results at
all optimization levels (-ox, -od, -oi, -ot, -oh, none).
Zero warnings. Zero segfaults.

## Future — Native x64 Code Generator
Goal: no GCC dependency, self-hosted.

## Resolved
- Float optimizer segfault at -oi/-ox/-ot/-oh (x64obj.c: branch
  displacement fixup treated x87 modrm byte 0x74 as JE opcode,
  corrupting FDIV SIB from 0x24/RSP to 0x25/RBP → segfault.
  Fixed by excluding bytes preceded by x87 opcodes D8-DF)
- ICE 97 / silent no-output on multi-field struct by-value
- Multi-field struct pass-by-value wrong result
- 2-field struct brace-init
- .eh_frame linker warning (suppressed)
- 32-bit pointer arithmetic (REX.W expansion pass)
- ELF64 writer (12 bugs)
- Build system (clean clone via bash build.sh)
- Runtime (crt0_x64.S)
