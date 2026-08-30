#!/bin/bash
# build_win64.sh — Build Win64 CRT library
# Requires: x86_64-w64-mingw32-gcc (cross compiler)
# Produces: build/win64/libmingw64win.a
#
# the crew 4free

set -e
MGWROOT="$(cd "$(dirname "$0")" && pwd)"
BUILDDIR="$MGWROOT/build/win64"
mkdir -p "$BUILDDIR"

CC="${MINGW_CC:-x86_64-w64-mingw32-gcc}"
CFLAGS="-c -w -O2 -I$MGWROOT/headers -I$MGWROOT/win64-headers -I$MGWROOT/include -D__CRT__NO_INLINE -D__USE_MINGW_ANSI_STDIO=1 -D_CRTBLD"

if ! command -v "$CC" >/dev/null 2>&1; then
  echo "  [skip] $CC not found — Win64 CRT not built"
  echo "  Install: apt install gcc-mingw-w64-x86-64"
  exit 0
fi

echo "=== Building Win64 CRT ==="

compile_dir() {
  local dir="$1" prefix="$2" extra="$3"
  local ok=0
  for f in "$MGWROOT/$dir"/*.c; do
    [ -f "$f" ] || continue
    local base=$(basename "$f" .c)
    [ "$base" = "printf_linux" ] && continue
    [ "$base" = "scanf2-argcount-template" ] && continue
    $CC $CFLAGS -I"$MGWROOT/$dir" $extra "$f" -o "$BUILDDIR/${prefix}_${base}.o" 2>/dev/null && ok=$((ok+1)) || true
  done
  echo "  [$dir] $ok objects"
}

compile_dir "math"    "math"    "-I$MGWROOT/math -I$MGWROOT/complex"
compile_dir "string"  "str"     ""
compile_dir "gdtoa"   "gdtoa"   "-I$MGWROOT/gdtoa"
compile_dir "complex" "cplx"    "-I$MGWROOT/complex"
compile_dir "intrincs" "intr"   ""
compile_dir "crt"     "crt"     ""
compile_dir "stdio"   "stdio"   ""
compile_dir "misc"    "misc"    ""
compile_dir "secapi"  "secapi"  ""
compile_dir "ssp"     "ssp"     ""
compile_dir "cfguard" "cfg"     ""
compile_dir "profile" "prof"    ""
# winstorecompat (in libraries/):
ok=0
for f in "$MGWROOT"/libraries/winstorecompat/src/*.c; do
  [ -f "$f" ] || continue
  base=$(basename "$f" .c)
  $CC $CFLAGS "$f" -o "$BUILDDIR/wsc_${base}.o" 2>/dev/null && ok=$((ok+1)) || true
done
echo "  [winstorecompat] $ok objects"

# winpthreads:
ok=0
for f in "$MGWROOT"/libraries/winpthreads/src/*.c; do
  [ -f "$f" ] || continue
  base=$(basename "$f" .c)
  $CC $CFLAGS -I"$MGWROOT/libraries/winpthreads/include" -I"$MGWROOT/libraries/winpthreads/src" \
    "$f" -o "$BUILDDIR/pth_${base}.o" 2>/dev/null && ok=$((ok+1)) || true
done
echo "  [winpthreads] $ok objects"

# Archive:
echo "  [archive]"
if ls "$BUILDDIR"/*.o >/dev/null 2>&1; then
  ar rcs "$BUILDDIR/libmingw64win.a" "$BUILDDIR"/*.o
  OBJ_COUNT=$(ar t "$BUILDDIR/libmingw64win.a" | wc -l)
  SIZE=$(ls -lh "$BUILDDIR/libmingw64win.a" | awk '{print $5}')
  echo "    libmingw64win.a: $OBJ_COUNT objects, $SIZE"
fi

echo "=== Done ==="
