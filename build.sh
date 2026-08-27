#!/bin/sh
#
# Script to build the Open Watcom tools
# using the host platform's native C/C++ compiler or OW tools.
#
# Expects POSIX or OW tools.

if [ -z "$OWROOT" ]; then
    . ./setvars.sh
fi

if [ ! -d build/$OWOBJDIR ]; then mkdir build/$OWOBJDIR; fi

OWBUILDER_BOOTX_OUTPUT="$OWROOT/build/$OWOBJDIR/bootx.log"

output_redirect()
{
    $@ >>$OWBUILDER_BOOTX_OUTPUT 2>&1
}

rm -f "$OWBUILDER_BOOTX_OUTPUT"
cd bld/wmake
if [ ! -d $OWOBJDIR ]; then mkdir $OWOBJDIR; fi
cd $OWOBJDIR
rm -f ../../../build/$OWOBJDIR/wmake
if [ "$OWTOOLS" = "WATCOM" ]; then
    output_redirect wmake -m -f ../wmake clean
    output_redirect wmake -m -f ../wmake
else
    output_redirect make -f ../posmake clean
    case `uname` in
        FreeBSD)
            output_redirect make -f ../posmake TARGETDEF=-D__FREEBSD__
            ;;
        DragonFly)
            output_redirect make -f ../posmake TARGETDEF=-D__DRAGONFLY__
            ;;
        NetBSD)
            output_redirect make -f ../posmake TARGETDEF=-D__NETBSD__
            ;;
        OpenBSD)
            output_redirect make -f ../posmake TARGETDEF=-D__OPENBSD__
            ;;
        Darwin)
            output_redirect make -f ../posmake TARGETDEF=-D__OSX__
            ;;
        Haiku)
            output_redirect make -f ../posmake TARGETDEF=-D__HAIKU__
            ;;
#        Linux)
        *)
            output_redirect make -f ../posmake TARGETDEF=-D__LINUX__
            ;;
    esac
fi
RC=$?
if [ $RC -ne 0 ]; then
    echo "wmake bootstrap build error"
else
    cd "$OWROOT"
    cd bld/builder
    if [ ! -d $OWOBJDIR ]; then mkdir $OWOBJDIR; fi
    cd $OWOBJDIR
    rm -f ../../../build/$OWOBJDIR/builder
    output_redirect ../../../build/$OWOBJDIR/wmake -f ../preboot clean
    output_redirect ../../../build/$OWOBJDIR/wmake -f ../preboot
    cd "$OWROOT"
    if [ "$1" != "preboot" ]; then
        cd bld
        builder boot
        RC=$?
        if [ $RC -ne 0 ]; then
            echo "builder bootstrap build error"
        elif [ "$1" != "boot" ]; then
            if [ -z "$1" ]; then
                builder build
            else
                builder $1
            fi
            RC=$?
        fi
    fi
fi
# === OW2IRC: bwccx64 post-build ===
if [ -d "$OWROOT/bld/cc/x64" ]; then
  echo "=== Building bwccx64 ==="
  # Copy ALL 386 CC objects to x64 (overwrite inline asm with non-_STANDALONE_ versions)
  cp -f "$OWROOT/bld/cc/386/binbuild/"*.obj "$OWROOT/bld/cc/x64/binbuild/" 2>/dev/null 2>/dev/null
  cp -n "$OWROOT/bld/cc/386/binbuild/"*.gh  "$OWROOT/bld/cc/x64/binbuild/" 2>/dev/null
  cp -n "$OWROOT/bld/cc/386/binbuild/"*.grh "$OWROOT/bld/cc/x64/binbuild/" 2>/dev/null
  cd "$OWROOT/bld/cc/x64"
  make -s OWROOT="$OWROOT" asm_objs link 2>&1 || true
  cd "$OWROOT"
fi

# === OW2IRC: bwppx64 post-build ===
if [ -d "$OWROOT/bld/plusplus/x64" ] && [ -d "$OWROOT/bld/plusplus/386/binbuild" ]; then
  echo "=== Building bwppx64 ==="
  mkdir -p "$OWROOT/bld/plusplus/x64/binbuild"
  cp -f "$OWROOT/bld/plusplus/386/binbuild/"*.obj "$OWROOT/bld/plusplus/x64/binbuild/" 2>/dev/null
  cp -f "$OWROOT/bld/plusplus/386/binbuild/"*.gh  "$OWROOT/bld/plusplus/x64/binbuild/" 2>/dev/null
  cp -f "$OWROOT/bld/plusplus/386/binbuild/"*.grh "$OWROOT/bld/plusplus/x64/binbuild/" 2>/dev/null
  cd "$OWROOT/bld/plusplus/x64/binbuild"
  gcc -o bwppx64 *.obj \
    "$OWROOT/bld/cg/intel/x64/binbuild/cgx64.lib" \
    "$OWROOT/bld/cg/intel/x64/binbuild/cgx64lnx.lib" \
    "$OWROOT/bld/watcom/binbuild/clibext.lib" \
    "$OWROOT/bld/dwarf/dw/binbuild/dwarfw.lib" \
    "$OWROOT/bld/cfloat/binbuild/cf.lib" \
    -lm -no-pie 2>/dev/null && echo "=== bwppx64 linked ===" || true
  [ -f bwppx64 ] && cp bwppx64 "$OWROOT/build/binbuild/"
  cd "$OWROOT"
fi

cd "$OWROOT"
exit $RC
