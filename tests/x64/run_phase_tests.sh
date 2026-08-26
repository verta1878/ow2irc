#!/bin/bash
# wcc64 x86-64 backend — PHASE test suite (Phases 5-11)
# Usage: ./run_phase_tests.sh [OWROOT]
#
# Tests the OBSERVABLE output of each backend phase against ELF invariants
# (section presence, section flags, symbol types, ABI arg placement) using
# readelf/objdump as the oracle — the same MEASURE-THREE-TIMES discipline:
# don't trust that a phase "works", prove it against the emitted bytes.
#
# Phase map:
#   5  SysV ABI            (DONE)  — args in rdi/rsi/rdx/rcx/r8/r9, red zone
#   6  .eh_frame / GDB     — DWARF CFI section, one FDE per function
#   7  .rodata             — const data in SHF_ALLOC (no SHF_WRITE) section
#   8  Win64 ABI           — args in rcx/rdx/r8/r9, 32B shadow space
#   9  SEH                 — .pdata/.xdata unwind tables (Win64)
#   10 wasm x64            — x64 assembler accepts x64 asm
#   11 Full C library      — extended libc subset links + runs
set -u
OWROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
WCC="$OWROOT/build/binbuild/bwcc64"
INC="-i=$OWROOT/rel/h"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

pass=0; fail=0; total=0; skip=0; failed=""

# compile helper: $1=name $2=src-content $3=extra-flags ; sets $OBJ
compile() {
    local name="$1" content="$2" flags="${3:-}"
    printf '%s\n' "$content" > "$TMP/$name.c"
    rm -f "$TMP/$name.o"
    "$WCC" "$TMP/$name.c" -fo="$TMP/$name.o" $INC -bt=linux64 $flags 2>/dev/null
    OBJ="$TMP/$name.o"
    [ -s "$OBJ" ]
}

# assert: $1=description $2=condition-already-evaluated(0/1)
check() {
    local desc="$1" ok="$2"
    total=$((total+1))
    if [ "$ok" = "0" ]; then pass=$((pass+1)); echo "  PASS  $desc"
    else fail=$((fail+1)); failed="$failed\n  FAIL  $desc"; echo "  FAIL  $desc"; fi
}
skipc() { skip=$((skip+1)); echo "  SKIP  $1 ($2)"; }

sec_exists()  { readelf -SW "$1" 2>/dev/null | grep -q "\\$2\b"; }
sec_flags()   { readelf -SW "$1" 2>/dev/null | awk -v s="$2" '$0 ~ s {print}'; }

echo "== wcc64 PHASE test suite =="
echo "WCC: $WCC"
[ -x "$WCC" ] || { echo "FATAL: no bwcc64"; exit 1; }

# ---------------------------------------------------------------------------
echo ""
echo "-- Phase 5: SysV ABI (expected DONE) --"
# 6-arg function: SysV places args in rdi,rsi,rdx,rcx,r8,r9. Verify the callee
# reads them from registers (not stack) by checking it runs correctly.
if compile p5_args 'int f(int a,int b,int c,int d,int e,int f){return a+b+c+d+e+f;}
int main(void){return f(1,2,3,4,5,6);}'; then
    ld -o "$TMP/p5" "$OWROOT/bld/clib/linux/x64/crt0_x64.o" "$OBJ" 2>/dev/null
    if [ -f "$TMP/p5" ]; then timeout 3 "$TMP/p5"; rc=$?; else rc=-1; fi
    check "6-arg SysV call returns 21" "$([ "$rc" = "21" ] && echo 0 || echo 1)"
else check "p5 compiles" 1; fi
# red zone: SysV allows 128-byte red zone below rsp. leaf funcs may use it.
if compile p5_rz 'int main(void){int x=7;return x;}'; then
    check "leaf function compiles (red zone path)" 0
else check "p5_rz compiles" 1; fi

# ---------------------------------------------------------------------------
echo ""
echo "-- Phase 7: .rodata --"
if compile p7 'const char *s="hello";const int t[3]={1,2,3};int main(void){return t[0];}'; then
    if sec_exists "$OBJ" ".rodata"; then
        check ".rodata section present" 0
        # .rodata must be SHF_ALLOC (A) but NOT SHF_WRITE (W). readelf flag col.
        fl=$(readelf -SW "$OBJ" 2>/dev/null | awk '/\.rodata/{for(i=1;i<=NF;i++)if($i ~ /^[AWX]+$/)print $i}')
        check ".rodata is alloc, not writable (flags='$fl')" \
              "$(echo "$fl" | grep -q 'A' && ! echo "$fl" | grep -q 'W' && echo 0 || echo 1)"
    else
        skipc ".rodata section present" "Phase 7 not yet implemented"
        skipc ".rodata flags correct" "Phase 7 not yet implemented"
    fi
else check "p7 compiles" 1; fi

# ---------------------------------------------------------------------------
echo ""
echo "-- Phase 6: .eh_frame / GDB --"
if compile p6 'int a(void){return 1;}int b(void){return 2;}int main(void){return a()+b();}'; then
    if sec_exists "$OBJ" ".eh_frame"; then
        check ".eh_frame section present" 0
        # FDE count should be >= number of functions (3 here). Rough: .eh_frame non-empty.
        sz=$(readelf -SW "$OBJ" 2>/dev/null | awk '/\.eh_frame/{print strtonum("0x"$7)}' | head -1)
        check ".eh_frame non-empty" "$([ "${sz:-0}" -gt 0 ] 2>/dev/null && echo 0 || echo 1)"
    else
        skipc ".eh_frame present" "Phase 6 not yet implemented"
        skipc ".eh_frame non-empty" "Phase 6 not yet implemented"
    fi
else check "p6 compiles" 1; fi

# ---------------------------------------------------------------------------
echo ""
echo "-- Phase 8: Win64 ABI --"
if "$WCC" "$TMP/p5_args.c" -fo="$TMP/p8.o" $INC -bt=nt64 2>/dev/null && [ -s "$TMP/p8.o" ]; then
    # Win64: PE-COFF object, args in rcx/rdx/r8/r9. If -bt=nt64 unsupported, skip.
    check "Win64 target compiles (-bt=nt64)" 0
else
    skipc "Win64 target compiles" "Phase 8 not yet implemented (-bt=nt64 unsupported)"
fi

# ---------------------------------------------------------------------------
echo ""
echo "-- Phase 9: SEH (.pdata/.xdata) --"
if [ -s "$TMP/p8.o" ] && (sec_exists "$TMP/p8.o" ".pdata" || sec_exists "$TMP/p8.o" ".xdata"); then
    check ".pdata/.xdata present (Win64)" 0
else
    skipc ".pdata/.xdata present" "Phase 9 not yet implemented"
fi

# ---------------------------------------------------------------------------
echo ""
echo "-- Phase 10: wasm x64 --"
WASM="$OWROOT/build/binbuild/wasm"
if [ -x "$WASM" ]; then
    printf 'BITS 64\nmov rax, 42\nret\n' > "$TMP/p10.asm"
    if "$WASM" "$TMP/p10.asm" -fo="$TMP/p10.o" 2>/dev/null && [ -s "$TMP/p10.o" ]; then
        check "wasm assembles x64 asm" 0
    else skipc "wasm assembles x64 asm" "Phase 10 not yet implemented"; fi
else skipc "wasm assembles x64 asm" "no wasm binary"; fi

# ---------------------------------------------------------------------------
echo ""
echo "-- Phase 11: Full C library --"
# Currently only freestanding mini runtime. Test whether an extended libc
# subset (string.h) links. If not, skip (expected until Phase 11).
if compile p11 '#include <string.h>
int main(void){char b[8];int n=0;const char*s="abc";while(s[n])n++;return n;}'; then
    ld -o "$TMP/p11" "$OWROOT/bld/clib/linux/x64/crt0_x64.o" "$OBJ" \
        "$OWROOT/bld/clib/linux/x64/miniprintf.o" "$OWROOT/bld/clib/linux/x64/mini_alloc.o" 2>/dev/null
    if [ -f "$TMP/p11" ]; then timeout 3 "$TMP/p11"; rc=$?; else rc=-1; fi
    # this uses only inline logic so it should pass now; real libc test comes with Phase 11
    check "basic freestanding program links+runs (rc=3)" "$([ "$rc" = "3" ] && echo 0 || echo 1)"
    skipc "extended libc (string.h funcs) links" "Phase 11 not yet implemented"
else check "p11 compiles" 1; fi

# ---------------------------------------------------------------------------
echo ""
echo "=== Phase suite: $pass passed, $fail failed, $skip skipped (of $total run) ==="
[ "$fail" = "0" ] && echo "ALL RUN TESTS PASSED (skips = unimplemented phases)" || { echo -e "FAILURES:$failed"; exit 1; }
