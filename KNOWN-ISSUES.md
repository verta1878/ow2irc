# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-27). x86-64 backend passes
**61/61** runtime tests + **59/59** musl-ow tests.

## Open / Limitations

### Pointer-through-function above 4 GB — FIXED
SysV ABI parameter passing wired: ParmReg() dispatches to
X64ParmReg() when _TARG_X64 is defined. Uses RDI/RSI/RDX/RCX/R8/R9
(64-bit registers). No more pointer truncation.

### LEDATA enumerated offset — FIXED
Post-processor now reads and uses the enumerated-data-offset field
from LEDATA/LEDATA32 records. Handles sparse emitters correctly.
Zero-fills gaps. Data positioned at the offset specified in the record.

## All issues: RESOLVED

See `todo/RESOLVED-ISSUES.md` for history.
