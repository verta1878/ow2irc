# wpp64 Builder Control file — x86-64 C++ Compiler
# ==================================================
# Links the C++ front-end (plusplus) with the x64 CG back-end.
# Produces bwpp64 — the x86-64 C++ compiler.
#
# NOT YET BUILT — needs:
#   1. Itanium name mangling (or use OW mangling + -bt=linux64)
#   2. DWARF exception table generation
#   3. vtable layout verification with 8-byte pointers
#
# When ready, add to bld/plusplus/builder.ctl:
#   [ INCLUDE x64/builder.ctl ]
#
# GPLv3 — the crew 4free — sysop/0

set PROJDIR=<CWD>
[ INCLUDE "<OWROOT>/build/master.ctl" ]
cdsay .

# TODO: Build wpp64 when CG x64 is fully integrated
# [ BLOCK <BLDRULE> build rel ]
# ...
