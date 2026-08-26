#!/bin/bash
# wcc64 x86-64 backend test suite
# Usage: ./run_tests.sh [OWROOT]
#
# MEASURE THREE TIMES when chasing a miscompile:
#   1. baseline  — run this suite + dump the failing function BEFORE editing
#   2. one change — apply exactly ONE edit, rerun, dump the same function
#   3. prove it  — compute byte ranges, check against a known invariant
#                  (e.g. "is this inside the allocated locals region?")
# Then revert and confirm the count returns to baseline.
# Stacking edits produces misleading root causes. See ADDENDUM 60b.
set -u
OWROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
WCC="$OWROOT/build/binbuild/bwcc64"
RTDIR="$OWROOT/bld/clib/linux/x64"
CRT0="$RTDIR/crt0_x64.o"
MPF="$RTDIR/miniprintf.o"
MAL="$RTDIR/mini_alloc.o"
INC="-i=$OWROOT/rel/h"
TD="$OWROOT/tests/x64/cases"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# Rebuild the freestanding runtime objects from source if the .S is newer
# than the .o (or the .o is missing). A stale crt0_x64.o once shipped a
# __CHK that did a bare `ret` instead of `ret $8`, leaving the stack 8 bytes
# off on the default-optimization stack-check path -> segfault. Assemble
# from .S every run so source is the single source of truth.
for base in crt0_x64 miniprintf mini_alloc sysv_wrappers; do
    s="$RTDIR/$base.S"; o="$RTDIR/$base.o"
    if [ -f "$s" ] && { [ ! -f "$o" ] || [ "$s" -nt "$o" ]; }; then
        as "$s" -o "$o" 2>/dev/null && echo "  (rebuilt $base.o from source)"
    fi
done

pass=0; fail=0; total=0; failed=""

run() {
    local name="$1" src="$2" flags="$3" extra="$4" expect="$5"
    total=$((total+1))
    rm -f "$TMP/$name.o" "$TMP/$name"
    "$WCC" "$src" -fo="$TMP/$name.o" $INC -bt=linux64 $flags 2>/dev/null
    [ ! -f "$TMP/$name.o" ] || [ ! -s "$TMP/$name.o" ] && { fail=$((fail+1)); failed="$failed $name:COMPILE"; return; }
    ld -o "$TMP/$name" "$CRT0" "$TMP/$name.o" $extra 2>/dev/null
    [ ! -f "$TMP/$name" ] && { fail=$((fail+1)); failed="$failed $name:LINK"; return; }
    timeout 3 "$TMP/$name" 2>/dev/null; rc=$?
    [ "$rc" = "$expect" ] && pass=$((pass+1)) || { fail=$((fail+1)); failed="$failed $name:got$rc"; }
}

# Inline tests
echo 'int main(void){return 42;}' > "$TMP/r42.c"
echo 'int g=42; int main(void){return g;}' > "$TMP/gv.c"
echo 'int main(void){return sizeof(void*);}' > "$TMP/sz.c"
echo 'int val=42; int main(void){int *p;p=&val;return *p;}' > "$TMP/lp.c"
echo 'int val=42; int *p; int main(void){p=&val;return *p;}' > "$TMP/gp2.c"
echo 'int val=42; int *p=&val; int main(void){return *p;}' > "$TMP/gp3.c"
echo 'extern int puts(const char*); int main(void){puts("hello");return 0;}' > "$TMP/hello.c"
echo 'int f(int *p){return *p;} int main(void){int v=42;return f(&v);}' > "$TMP/pp.c"

echo "wcc64 test suite — $(date)"
echo "compiler: $WCC"
echo ""

# Phase 2: integers, pointers, structs (22)
run r42       "$TMP/r42.c"      "-ox -s" "" 42
run gv        "$TMP/gv.c"       "-ox -s" "" 42
run sz        "$TMP/sz.c"       "-ox -s" "" 8
run lp        "$TMP/lp.c"       "-ox -s" "" 42
run gp2       "$TMP/gp2.c"      "-ox -s" "" 42
run gp3       "$TMP/gp3.c"      "-ox -s" "" 42
run hello     "$TMP/hello.c"    "-ox -s" "" 0
run ptrparam  "$TMP/pp.c"       "-ox -s" "" 42
run arith     "$TD/arith.c"     "-ox -s" "" 42
run switch    "$TD/switch.c"    "-ox -s" "" 42
run loop      "$TD/loop.c"      "-ox -s" "" 55
run static    "$TD/static_var.c" "-ox -s" "" 42
run unions    "$TD/unions.c"    "-ox -s" "" 42
run factgcd   "$TD/fact_gcd.c"  "-ox -s" "" 42
run recursion "$TD/recursion.c" "-ox -s" "" 55
run longlong  "$TD/longlong.c"  "-ox -s" "" 42
run shiftmix  "$TD/shiftmix.c"  "-ox -s" "" 84
run struct    "$TD/struct_ptr.c" "-ox -s" "" 42
run array     "$TD/array.c"     "-ox -s" "" 42
run strings   "$TD/strings.c"   "-ox -s" "" 42
run nested    "$TD/nested_struct.c" "-ox -s" "" 48
run ptrarith  "$TD/ptr_arith.c" "-ox -s" "" 42

# Phase 3: floats (7)
run floats      "$TD/floats.c"      "-ox -s" "" 42
run floatfunc   "$TD/floatfunc.c"   "-ox -s" "" 42
run floatstruct "$TD/floatstruct.c" "-ox -s" "" 42
run floatloop   "$TD/floatloop.c"   "-ox -s" "" 42
run floatcmp    "$TD/floatcmp.c"    "-ox -s" "" 42
run floatarray  "$TD/floatarray.c"  "-ox -s" "" 42
run floatglobal "$TD/floatglobal.c" "-ox -s" "" 42

# Phase 3.5: RIP-relative (6)
run rip_float     "$TD/rip_float.c"     "-ox -s" "" 42
run rip_global    "$TD/rip_global.c"    "-ox -s" "" 42
run rip_regrel    "$TD/rip_regrel.c"    "-ox -s" "" 42
run rip_dattext   "$TD/rip_dattext.c"   "-ox -s" "" 42
run rip_immaddr   "$TD/rip_immaddr.c"   "-ox -s" "" 42
run rip_multfloat "$TD/rip_multfloat.c" "-ox -s" "" 42

# Phase 4: algorithms (13)
run newton     "$TD/newton.c"     "-ox -s" "" 42
run multifunc  "$TD/multifunc.c"  "-ox -s" "" 42
run funcptr    "$TD/funcptr.c"    "-ox -s" "" 42
run bubblesort "$TD/bubblesort.c" "-ox -s" "" 42
run fibonacci  "$TD/fibonacci.c"  "-ox -s" "" 42
run linkedlist "$TD/linkedlist.c" "-ox -s" "" 42
run bitwise    "$TD/bitwise.c"    "-ox -s" "" 42
run strmanip   "$TD/strmanip.c"   "-ox -s" "" 42
run ternary    "$TD/ternary.c"    "-ox -s" "" 42
run enumtest   "$TD/enumtest.c"   "-ox -s" "" 42
run matrix     "$TD/matrix.c"     "-ox -s" "" 42
run dowhile    "$TD/dowhile.c"    "-ox -s" "" 42
run compound   "$TD/compound.c"   "-ox -s" "" 42

# Phase 5: printf/malloc (4)
run printftest "$TD/printftest.c" "-ox -s" "$MPF" 42
run printarr   "$TD/printarr.c"   "-ox -s" "$MPF" 42
run floatprint "$TD/floatprint.c" "-ox -s" "$MPF" 42
run sieve      "$TD/sieve.c"     "-ox -s" "$MPF" 42

# Phase 6: real-world patterns (6)
run callback   "$TD/callback.c"   "-ox -s" "" 42
run breakloop  "$TD/breakloop.c"  "-ox -s" "" 42
run strtable   "$TD/strtable.c"   "-ox -s" "" 42
run typecast   "$TD/typecast.c"   "-ox -s" "" 42
run staticfunc "$TD/staticfunc.c" "-ox -s" "" 42
run bigexpr    "$TD/bigexpr.c"    "-ox -s" "" 42

# Phase 6b: IMUL + combat (2)
run rip_imul   "$TD/rip_imul.c"   "-ox -s" "" 42
run combat     "$TD/combat.c"     "-ox -s" "" 42
run stackparm  "$TD/stackparm.c"  "-ox -s" "$MPF" 42

echo ""
echo "=== Results: $pass/$total PASS ==="
[ -n "$failed" ] && echo "FAILED:$failed"
[ "$fail" -eq 0 ] && echo "ALL TESTS PASSED" || exit 1
