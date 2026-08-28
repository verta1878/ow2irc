# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-28).

## Cosmetic

### .eh_frame linker warning
`ld: error in .o(.eh_frame); no .eh_frame_hdr table will be created`

The .eh_frame CIE uses minimal augmentation (no "zR" encoding).
The linker warns but links successfully. Programs run correctly at
all optimization levels. GDB backtraces may not work until the CIE
uses standard GNU augmentation with proper FDE pointer encoding.

## Resolved
All ELF section header bugs, e_shstrndx dynamic tracking,
string literal relocations, .rela.eh_frame layout, build system,
runtime startup. See CHANGELOG.md.
