#!/bin/bash
# build_all.sh — Build all MinGW-w64 CRT components
#
# the crew 4free

set -e
MGWROOT="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo " MinGW-w64 CRT for OW2IRC"
echo "========================================"
echo ""

# 1. Portable CRT (all targets):
bash "$MGWROOT/build.sh"
echo ""

# 2. Win64 import libraries:
bash "$MGWROOT/build_implibs.sh"
echo ""

# 3. Win64 CRT (requires cross compiler):
bash "$MGWROOT/build_win64.sh"
echo ""

echo "========================================"
echo " Build complete"
echo "========================================"
echo ""
echo "Libraries:"
ls -lh "$MGWROOT/build/"*.a 2>/dev/null || echo "  (none)"
echo ""
echo "Usage:"
echo "  -bt=linux64: link with build/libmingw64crt.a"
echo "  -bt=win64:   link with build/win64/libmingw64win.a + build/lib64/*.a"
