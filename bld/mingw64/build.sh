#!/bin/bash
# build.sh — Build MinGW-w64 portable CRT library
# Run from bld/mingw64/ directory
# Produces: build/libmingw64crt.a
#
# the crew 4free

set -e
MGWROOT="$(cd "$(dirname "$0")" && pwd)"
BUILDDIR="$MGWROOT/build"
mkdir -p "$BUILDDIR"

CC="${CC:-gcc}"
CFLAGS="-c -w -O2 -fno-stack-protector -fno-builtin"

echo "=== Building MinGW-w64 portable CRT ==="

# Math library
echo "  [math]"
for f in "$MGWROOT"/math/*.c; do
  base=$(basename "$f" .c)
  $CC $CFLAGS -I"$MGWROOT/math" "$f" -o "$BUILDDIR/math_${base}.o" 2>/dev/null || true
done
MATH_COUNT=$(ls "$BUILDDIR"/math_*.o 2>/dev/null | wc -l)
echo "    $MATH_COUNT objects"

# String library
echo "  [string]"
for f in "$MGWROOT"/string/*.c; do
  base=$(basename "$f" .c)
  $CC $CFLAGS "$f" -o "$BUILDDIR/str_${base}.o" 2>/dev/null || true
done
STR_COUNT=$(ls "$BUILDDIR"/str_*.o 2>/dev/null | wc -l)
echo "    $STR_COUNT objects"

# gdtoa (float-to-string)
echo "  [gdtoa]"
for f in "$MGWROOT"/gdtoa/*.c; do
  base=$(basename "$f" .c)
  $CC $CFLAGS -I"$MGWROOT/gdtoa" "$f" -o "$BUILDDIR/gdtoa_${base}.o" 2>/dev/null || true
done
GDTOA_COUNT=$(ls "$BUILDDIR"/gdtoa_*.o 2>/dev/null | wc -l)
echo "    $GDTOA_COUNT objects"

# printf for Linux x64
echo "  [printf_linux]"
$CC $CFLAGS "$MGWROOT/crt/printf_linux.c" -o "$BUILDDIR/printf_linux.o"
echo "    1 object"

# Archive
echo "  [archive]"
ar rcs "$BUILDDIR/libmingw64crt.a" "$BUILDDIR"/*.o
OBJ_COUNT=$(ar t "$BUILDDIR/libmingw64crt.a" | wc -l)
SIZE=$(ls -lh "$BUILDDIR/libmingw64crt.a" | awk '{print $5}')
echo "    libmingw64crt.a: $OBJ_COUNT objects, $SIZE"

echo "=== Done ==="
