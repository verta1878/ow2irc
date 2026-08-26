# openwatcom2irc — Resolved Issues

All resolved. Moved from KNOWN-ISSUES.md on 2026-08-25.

## Loops (was ISSUE-1) ✅
INC/DEC-vs-REX opcode collision + backward-jump-into-prologue.
Fixed: instruction-length decoder in x64obj.c + frame-register
handling in x86proc.c. Tests: breakloop, bubblesort.
Resolved by: bob

## Recursion / multi-function objects (was ISSUE-2) ✅
Function boundaries recovered correctly. fib/factorial/gcd link+run.
"Hardcoded main at offset 0" assumption removed.
Resolved by: bob

## Global variables (was ISSUE-3) ✅
Globals, file-scope statics, BSS, pointer initialisers all work.
Resolved by: bob

## DGInteger overflow ✅
Constant-emit buffer was byte[6], overflowed on 8-byte pointers.
Sized to byte[16]. Found with ASan.
Resolved by: bob

## Struct pointer fields at 4-byte offsets ✅
MapPointer returned U4 for pointers on x64. Struct layout computed
4-byte offsets for pointer fields. malloc + linked lists crashed.
Fixed: MapPointer → U8 on x64 (386ptype.c).
Resolved by: sysop/0

## Stale __CHK object ✅
__CHK did `ret` instead of `ret $8`. Stack-check prologue pushes
8 bytes that never got cleaned up. Stack misaligned → segfault.
Fixed: crt0_x64.S __CHK + __GRO use `ret $8`.
Resolved by: bob
