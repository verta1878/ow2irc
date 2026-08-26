# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-25). x86-64 backend passes
**61/61** runtime tests + **59/59** musl-ow tests.

## Open / Limitations

### Pointer-through-function above 4 GB
Watcom ABI passes pointers in EAX (32-bit). Pointer increment
inside callee truncates above 4 GB. SysV ABI (x64parm.c) fixes
this by using RDI/RSI (64-bit) — framework written, needs CG wiring.
**Workaround:** use array indexing, or allocate with MAP_32BIT.

### LEDATA enumerated offset (LATENT)
Post-processor concatenates LEDATA chunks in file order and
ignores enumerated-data-offset field. Every object tested reports
offset 0, so nothing is broken. Would surface with sparse emitters.

## All other issues: RESOLVED

See `todo/RESOLVED-ISSUES.md` for history.
