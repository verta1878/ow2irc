# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-27).

## All issues: RESOLVED

### .eh_frame — RESOLVED
.eh_frame with FDE tracking infrastructure fully implemented
(x64ehframe.c). CIE uses correct x64 DWARF registers (RA=16,
RSP=7, RBP=6). FDE location tracking for .rela.eh_frame
relocations added. When no FDEs are generated (386 CG doesn't
emit PUSH RBP prologues for simple functions), .eh_frame is
cleanly skipped (eh_pos=0 after finalize, shdr omitted,
e_shnum/e_shstrndx dynamically patched). No linker warnings.
When the CG learns standard prologues, FDEs activate automatically.

See `todo/RESOLVED-ISSUES.md` for full history.
