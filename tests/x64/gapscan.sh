#!/bin/bash
# Structural gap analysis: what does a mature x86-64 object contain that ours
# does not?
#
# The differential harness (difftest.sh) answers "does it behave correctly".
# This answers a different question: "what is missing entirely". It compiles
# the same corpus with gcc and with the x64 path, then compares the two
# objects as artefacts -- section inventory, relocation types, symbol types
# and bindings, symbol sizes -- and aggregates the differences.
#
# Absence is easy to overlook. A missing section or an unimplemented
# relocation type does not fail loudly; it fails on whichever program first
# needs it. Enumerating them up front turns that into a list.
#
# Usage: gapscan.sh [dir-of-.c-files]

set -u
CASES="${1:-$(dirname "$0")/cases}"
: "${OWROOT:?set OWROOT to the openwatcomirc tree}"
WATCOM="$OWROOT/rel"
BWCC="$OWROOT/build/binbuild/bwcc386"
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT

gcc_secs="$WORK/gs"; our_secs="$WORK/os"
gcc_rel="$WORK/gr";  our_rel="$WORK/or"
gcc_sym="$WORK/gy";  our_sym="$WORK/oy"
: > "$gcc_secs"; : > "$our_secs"; : > "$gcc_rel"
: > "$our_rel"; : > "$gcc_sym"; : > "$our_sym"

sizes_wrong=0; sizes_total=0
cases=0

for src in "$CASES"/*.c; do
    [ -e "$src" ] || { echo "no cases in $CASES"; exit 1; }
    gcc -w -c -O1 "$src" -o "$WORK/g.o" 2>/dev/null || continue
    "$BWCC" "$src" -fo="$WORK/o.o" -i="$WATCOM/h" -bt=linux64 -ox -s \
        >/dev/null 2>&1 || continue
    [ -s "$WORK/o.o" ] || continue
    cases=$((cases+1))

    readelf -S "$WORK/g.o" 2>/dev/null | grep -oE '\.[a-z_.]+[a-z]' >> "$gcc_secs"
    readelf -S "$WORK/o.o" 2>/dev/null | grep -oE '\.[a-z_.]+[a-z]' >> "$our_secs"

    readelf -r "$WORK/g.o" 2>/dev/null | grep -oE 'R_X86_64_[A-Z0-9_]+' >> "$gcc_rel"
    readelf -r "$WORK/o.o" 2>/dev/null | grep -oE 'R_X86_64_[A-Z0-9_]+' >> "$our_rel"

    readelf -s "$WORK/g.o" 2>/dev/null | awk 'NR>3{print $4"/"$5}' >> "$gcc_sym"
    readelf -s "$WORK/o.o" 2>/dev/null | awk 'NR>3{print $4"/"$5}' >> "$our_sym"

    # Does a defined object symbol carry a believable size? Ours hardcodes 4.
    while read -r nm sz; do
        [ -z "$nm" ] && continue
        gsz=$(readelf -s "$WORK/g.o" 2>/dev/null | awk -v n="$nm" '$8==n{print $3; exit}')
        [ -z "$gsz" ] && continue
        sizes_total=$((sizes_total+1))
        [ "$sz" != "$gsz" ] && sizes_wrong=$((sizes_wrong+1))
    done < <(readelf -s "$WORK/o.o" 2>/dev/null |
             awk '$4=="OBJECT"{n=$8; sub(/^_/,"",n); print n, $3}')
done

echo "structural gap analysis over $cases cases"
echo

echo "== sections gcc emits that we never do =="
comm -23 <(sort -u "$gcc_secs") <(sort -u "$our_secs" | sed 's/^_//') |
    sed 's/^/  /' | grep -v '^\s*$' || echo "  (none)"
echo
echo "== sections we emit =="
sort -u "$our_secs" | tr '\n' ' ' | sed 's/^/  /'; echo
echo
echo "== relocation types gcc uses that we never emit =="
comm -23 <(sort -u "$gcc_rel") <(sort -u "$our_rel") | sed 's/^/  /' |
    grep -v '^\s*$' || echo "  (none)"
echo
echo "== relocation types we emit =="
sort -u "$our_rel" | tr '\n' ' ' | sed 's/^/  /'; echo
echo
echo "== symbol type/binding combinations gcc uses that we never do =="
comm -23 <(sort -u "$gcc_sym") <(sort -u "$our_sym") | sed 's/^/  /' |
    grep -v '^\s*$' || echo "  (none)"
echo
echo "== data symbol sizes =="
echo "  $sizes_wrong of $sizes_total defined object symbols disagree with gcc"
echo "  (structs holding pointers are expected to differ: this backend runs"
echo "   the 32-bit code generator, so pointers are 4 bytes, not 8)"
