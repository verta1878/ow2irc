# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-28).

## All issues: RESOLVED

No known issues. Clean compile, clean link, correct results at
all optimization levels (-ox, -od, none).

.eh_frame suppressed (no linker warning). Infrastructure retained
in x64ehframe.c for future re-enable when native x64 CG is built.

## Future — Native x64 Code Generator
Goal: no GCC dependency, self-hosted.

## Resolved
- ICE 97 crash (386table.c Move8: G_UNKNOWN → R_MAKESTRMOVE)
- Multi-field struct pass-by-value wrong result (x64obj.c: detect
  field-init + arg-copy pattern, insert second field copy via ECX)
- 2-field struct brace-init drops second field (x64obj.c: duplicate
  load-store pair using ECX + duplicate fixup)
- .eh_frame linker warning (suppressed: eh_pos=0 after finalize)
- 32-bit pointer arithmetic on 64-bit addresses (REX.W expansion:
  INC/DEC/ADD/SUB + branch/CALL/JMP displacement fixup)
- ELF64 writer (12 bugs: STT_FILE, ELF64_R_INFO, sizeof, offsets)
- Build system (shared 386 CG objects, OMF filter, clean clone)
- Runtime (crt0_x64.S: popq argc, alignment, puts() Watcom EAX)
