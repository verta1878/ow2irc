#!/bin/bash
# Differential test harness for the openwatcom2irc x86_64 backend.
#
# The failure mode that matters here is not a crash, it is a plausible wrong
# answer: a struct field read returning the neighbouring field, an array index
# off by one, a shift helper returning zero. Those only get caught if someone
# already knows the right answer.
#
# So we do not hand-write expected values. We compile each program twice --
# once with the native compiler, once through the x64 path -- run both, and
# compare exit status and stdout. The native build is the oracle: it defines
# what the C program means. Any disagreement is our bug.
#
# Usage:  difftest.sh [-v] [dir-of-.c-files]

set -u
VERBOSE=0
[ "${1:-}" = "-v" ] && { VERBOSE=1; shift; }
CASES="${1:-$(dirname "$0")/cases}"

: "${OWROOT:?set OWROOT to the openwatcomirc tree}"
WATCOM="$OWROOT/rel"
BWCC="$OWROOT/build/binbuild/bwcc386"
CRT0="$OWROOT/bld/clib/linux/x64/crt0_x64.o"
WORK=$(mktemp -d); trap 'rm -rf "$WORK"' EXIT

for tool in "$BWCC" "$CRT0"; do
    [ -e "$tool" ] || { echo "missing: $tool"; exit 1; }
done
command -v gcc >/dev/null || { echo "gcc required as oracle"; exit 1; }

pass=0; fail=0; skip=0
declare -a FAILURES=()

# The oracle build needs the same freestanding shape as ours: no libc, our
# crt0, and the Watcom register convention is irrelevant because gcc compiles
# the same source under its own rules and we compare only observable results.
oracle_run() {
    local src="$1"
    gcc -w -O0 -o "$WORK/oracle" "$src" 2>/dev/null || return 1
    local out; out=$(timeout 5 "$WORK/oracle" 2>/dev/null); local code=$?
    printf '%s\n---%d' "$out" "$code"
}

ours_run() {
    local src="$1" flags="$2"
    "$BWCC" "$src" -fo="$WORK/t.o" -i="$WATCOM/h" -bt=linux64 $flags \
        >/dev/null 2>&1 || { echo "__COMPILE_FAIL__"; return; }
    ld -o "$WORK/t" "$CRT0" "$WORK/t.o" 2>/dev/null \
        || { echo "__LINK_FAIL__"; return; }
    local out; out=$(timeout 5 "$WORK/t" 2>/dev/null); local code=$?
    printf '%s\n---%d' "$out" "$code"
}

echo "differential test: gcc oracle vs x64 backend"
echo

for src in "$CASES"/*.c; do
    [ -e "$src" ] || { echo "no cases in $CASES"; exit 1; }
    name=$(basename "$src" .c)

    expected=$(oracle_run "$src") || { skip=$((skip+1))
        printf '  %-22s SKIP (oracle will not build it)\n' "$name"; continue; }

    for flags in "-ox -s" "-od"; do
        got=$(ours_run "$src" "$flags")
        if [ "$got" = "$expected" ]; then
            pass=$((pass+1))
            [ $VERBOSE -eq 1 ] && printf '  %-22s %-8s ok\n' "$name" "$flags"
        else
            fail=$((fail+1))
            printf '  %-22s %-8s MISMATCH\n' "$name" "$flags"
            printf '      expected: %s\n' "$(echo "$expected" | tr '\n' '|')"
            printf '      got:      %s\n' "$(echo "$got" | tr '\n' '|')"
            FAILURES+=("$name($flags)")
        fi
    done
done

echo
echo "  $pass agree, $fail disagree, $skip skipped"
[ ${#FAILURES[@]} -gt 0 ] && { echo "  failing: ${FAILURES[*]}"; exit 1; }
exit 0
