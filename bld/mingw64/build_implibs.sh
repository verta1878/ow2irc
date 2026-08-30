#!/bin/bash
# build_implibs.sh — Build Win64 import libraries from .def files
# Requires: x86_64-w64-mingw32-dlltool (or dlltool)
# Produces: build/lib64/*.a
#
# the crew 4free

set -e
MGWROOT="$(cd "$(dirname "$0")" && pwd)"
BUILDDIR="$MGWROOT/build/lib64"
mkdir -p "$BUILDDIR"

DLLTOOL="${DLLTOOL:-x86_64-w64-mingw32-dlltool}"

# Check if dlltool is available:
if ! command -v "$DLLTOOL" >/dev/null 2>&1; then
  DLLTOOL="dlltool"
  if ! command -v "$DLLTOOL" >/dev/null 2>&1; then
    echo "  [skip] dlltool not found — Win64 import libs not built"
    echo "  Install: apt install mingw-w64-tools"
    exit 0
  fi
fi

echo "=== Building Win64 import libraries ==="
ok=0; fail=0
for def in "$MGWROOT"/lib64/*.def; do
  base=$(basename "$def" .def)
  $DLLTOOL -d "$def" -l "$BUILDDIR/lib${base}.a" -m i386:x86-64 2>/dev/null
  if [ -s "$BUILDDIR/lib${base}.a" ]; then
    ok=$((ok+1))
  else
    fail=$((fail+1))
  fi
done
echo "  $ok import libraries built, $fail skipped"

# Also build lib-common:
BUILDDIR32="$MGWROOT/build/lib-common"
mkdir -p "$BUILDDIR32"
for def in "$MGWROOT"/lib-common/*.def; do
  base=$(basename "$def" .def)
  $DLLTOOL -d "$def" -l "$BUILDDIR32/lib${base}.a" -m i386:x86-64 2>/dev/null || true
done
echo "  lib-common: $(ls "$BUILDDIR32"/*.a 2>/dev/null | wc -l) libraries"

echo "=== Done ==="

# Build Win32 import libraries:
BUILDDIR32B="$MGWROOT/build/lib32"
mkdir -p "$BUILDDIR32B"
ok=0
for def in "$MGWROOT"/lib32/*.def; do
  base=$(basename "$def" .def)
  $DLLTOOL -d "$def" -l "$BUILDDIR32B/lib${base}.a" -m i386 2>/dev/null && ok=$((ok+1)) || true
done
echo "  lib32: $ok import libraries"
