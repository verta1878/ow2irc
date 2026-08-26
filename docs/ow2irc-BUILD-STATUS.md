# ow2irc bwcc64 build status — bob, this session

Attempting to build bwcc64 from the refreshed clone (b02b7a9b) so I can
build the 3dfx drivers. The refresh's "build wiring complete" claim doesn't
hold for a CLEAN clone: the C front-end + x64 CG library build hit a chain
of missing/incomplete build wiring. verta1878 likely had generated files or
a dirty tree locally (same class as the earlier stale-object bug).

## Fixed this session (9 build-wiring defects) — all UNCOMMITTED

Tracked-file edits (patch: ow2irc-x64-buildwiring-fixes.patch):
1. bld/cc/h/target64.h — added the target_size/target_ssize typedefs, the
   integer/float limit macros (TARGET_CHAR_MAX..TARGET_FLT_MAX), and the
   remaining type-size macros (TARGET_WCHAR, TARGET_BOOL, TARGET_FLOAT,
   complex/imaginary types, TARGET_BITFIELD, etc.). The file had only the
   TARGET_* sizes, not the types/limits the front-end needs.
2. bld/cc/master.mif — (a) added target_as_x64 assembler def (was undefined
   -> include path executed as a command); (b) mapped x64->386 for
   optencod_targets so x64 inherits all 386 command-line options (fixes
   OPT_ENUM_opt_level_ox and ~71 other options gated to "386" not "x64");
   (c) added wasm/h to inc_dirs so asminlin.h is found.
3. bld/cg/builder.ctl — added [ INCLUDE intel/x64/builder.ctl ].
4. bld/cg/intel/master.mif — (a) added the 8 newer x64 CG objects
   (x64asm, x64c99compat, x64clib, x64obj_integration, x64parm, x64pe,
   x64seh, x64win64) to intel_objs; (b) added 386/h to inc_dirs_targ so the
   x64 CG build finds cg386wrg.h.

New files (untracked):
5. bld/cc/a/codex64.asm — MINIMAL STUB (empty intrinsic table). The build
   requires it but only code386.asm/codei86.asm existed. With the stub,
   wcc64 falls back to library calls instead of inlining intrinsics
   (correct, just unoptimized). NEEDS real x64 intrinsics eventually.
6. bld/cg/intel/x64/builder.ctl — x64 CG library build wiring (mirror 386).
7. bld/cg/intel/x64/master.mif — x64 CG master (mirror 386).
8. bld/cg/intel/x64/binmake — x64 CG binmake (mirror 386).

## Build progression (each fix advanced further)
wmake OK -> builder OK -> 13 x64 CG sources compile OK -> [fixes 1-7] ->
front-end compiles -> link needs cgx64lnx.lib -> [fix 8: CG build wiring] ->
x64 CG lib builds -> [fix 9: 386/h path] -> compiles x64 CG objs ->
BLOCKED building x86enc.obj.

## BLOCKER (needs crew — x64 backend internals, not build plumbing)
x86enc.c builds RegsTab[] which references WV_REG_R8..R15 and
DW_REG_R8..R15 (via x64/h/regindex.h). These are undefined because:
- watdbreg.h (WV regs) has no R8-R15
- dwregx86.h (DWARF regs) has no R8-R15
- CI_R8..R15 class indices don't exist in bld/dig/h/digtypes.h

x86enc.c IS required for x64 (per INTEGRATION.md sec 7: the x64 REX hooks
live inside x86enc.c's GenObjCode). So R8-R15 must be added to the debugger
/DWARF register model — coordinated edits to digtypes.h (CI_ enum),
watdbreg.h, dwregx86.h — following the DWARF x86-64 register numbering
(R8-R15 = DWARF regs 8-15). This touches the DIG debugger subsystem, so
it's a design call for whoever owns the x64 backend (sysop/0 / verta1878),
not something to improvise mid-build.

## Also seen (not blocking bwcc64)
- asmscan.obj get_id: link error in the bwcc/bwcc386 (386/86) builds. Not
  diagnosed; may be a separate pre-existing issue in those targets.

## Net
- 9 real build defects fixed (patch + 4 new files ready for review).
- bwcc64 NOT yet built; one well-defined blocker remains (R8-R15 debug regs).
- 3dfx driver build is downstream of bwcc64, so still pending.
- The refresh's 133/0 test claim remains bob-unverified (no working bwcc64).
