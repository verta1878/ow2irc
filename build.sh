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
  # Copy ALL 386 CC objects to x64
  cp -f "$OWROOT/bld/cc/386/binbuild/"*.obj "$OWROOT/bld/cc/x64/binbuild/" 2>/dev/null
  # Recompile x86enc.c (G_UNKNOWN → silent skip for struct ops):
  gcc -c -w -I"$OWROOT/bld/cg/intel/386/binbuild" \
    -I"$OWROOT/bld/cg/h" -I"$OWROOT/bld/cg/intel/h" -I"$OWROOT/bld/cg/intel/386/h" \
    -I"$OWROOT/bld/watcom/h" -I"$OWROOT/bld/comp_cfg/h" -I"$OWROOT/bld/owl/h" \
    -I"$OWROOT/bld/dwarf/dw/h" -I"$OWROOT/bld/cfloat/h" \
    -D_CPU=386 -DBOOTSTRAP -D__UNIX__ -D__LINUX__ \
    "$OWROOT/bld/cg/intel/c/x86enc.c" -o "$OWROOT/bld/cg/intel/386/binbuild/x86enc.obj" 2>/dev/null
  # Recompile 386table.c with Move8/Push8 fix:
  gcc -c -w -I"$OWROOT/bld/cg/intel/386/binbuild" \
    -I"$OWROOT/bld/cg/h" -I"$OWROOT/bld/cg/intel/h" -I"$OWROOT/bld/cg/intel/386/h" \
    -I"$OWROOT/bld/watcom/h" -I"$OWROOT/bld/comp_cfg/h" -I"$OWROOT/bld/owl/h" \
    -I"$OWROOT/bld/dwarf/dw/h" -I"$OWROOT/bld/cfloat/h" \
    -D_CPU=386 -DBOOTSTRAP -D__UNIX__ -D__LINUX__ \
    "$OWROOT/bld/cg/intel/386/c/386table.c" -o "$OWROOT/bld/cg/intel/386/binbuild/386table.obj" 2>/dev/null
  # Recompile x64-specific files with _TARG_X64 (enables OMF→ELF64 conversion)
  X64FLAGS="-w -I$OWROOT/bld/cc/x64/binbuild -I$OWROOT/bld/cc/h -I$OWROOT/bld/cc/x64 \
    -I$OWROOT/bld/cg/h -I$OWROOT/bld/cg/intel/h -I$OWROOT/bld/cg/intel/386/h \
    -I$OWROOT/bld/cg/intel/x64/h -I$OWROOT/bld/watcom/h -I$OWROOT/bld/dwarf/dw/h \
    -I$OWROOT/bld/wasm/h -I$OWROOT/bld/fe_misc/h -I$OWROOT/bld/owl/h \
    -I$OWROOT/bld/comp_cfg/h -I$OWROOT/bld/as/h \
    -D_CPU=386 -D_TARG_X64=1 -DBOOTSTRAP -D__UNIX__ -D__LINUX__"
  gcc -c $X64FLAGS "$OWROOT/bld/cc/c/cgen.c" -o "$OWROOT/bld/cc/x64/binbuild/cgen.obj" 2>/dev/null
  gcc -c $X64FLAGS "$OWROOT/bld/cc/c/cmdlnx86.c" -o "$OWROOT/bld/cc/x64/binbuild/cmdlnx86.obj" 2>/dev/null
  # Recompile x64obj.c with all ELF writer fixes:
  gcc -c -w -I"$OWROOT/bld/cg/intel/x64/binbuild" \
    -I"$OWROOT/bld/cg/h" -I"$OWROOT/bld/cg/intel/h" -I"$OWROOT/bld/cg/intel/386/h" \
    -I"$OWROOT/bld/cg/intel/x64/h" -I"$OWROOT/bld/watcom/h" -I"$OWROOT/bld/dwarf/dw/h" \
    -I"$OWROOT/bld/owl/h" -I"$OWROOT/bld/comp_cfg/h" -I"$OWROOT/bld/cfloat/h" \
    -D_CPU=386 -D_TARG_X64=1 -DBOOTSTRAP -D__UNIX__ -D__LINUX__ \
    "$OWROOT/bld/cg/intel/x64/c/x64obj.c" -o "$OWROOT/bld/cg/intel/x64/binbuild/x64obj.obj" 2>/dev/null
  # Copy shared 386 CG objects that x64 depends on (register tables,
  # instruction encoder, type system — x64 uses the 386 code generator)
  echo "  Copying shared 386 CG objects to x64..."
  for obj in 386rgtbl 386table 386ilen 386enc 386score 386conv 386type \
    386rtrtn 386optab 386ptype 386opseg 386sib 386splt2 386tls \
    rtcall sib encode x86esc x86enc x86proc x86sel x86obj \
    verify optrel split regalloc conflict peepopt \
    386funit i87data i87exp i87opt i87reg i87sched \
    x64dispatch; do
    cp -f "$OWROOT/bld/cg/intel/386/binbuild/${obj}.obj" \
          "$OWROOT/bld/cg/intel/x64/binbuild/" 2>/dev/null
  done
  # Copy ALL 386 CG objects that aren't already in x64 (catch stragglers)
  cp -n "$OWROOT/bld/cg/intel/386/binbuild/"*.obj \
        "$OWROOT/bld/cg/intel/x64/binbuild/" 2>/dev/null
  # Remove OMF mkcode intermediates (not linkable ELF)
  rm -f "$OWROOT/bld/cg/intel/x64/binbuild/code386.obj" \
        "$OWROOT/bld/cg/intel/x64/binbuild/codex64.obj" 2>/dev/null
  rm -f "$OWROOT/bld/cc/x64/binbuild/code386.obj" \
        "$OWROOT/bld/cc/x64/binbuild/codex64.obj" 2>/dev/null
  # Rebuild CG library with all objects:
  cd "$OWROOT/bld/cg/intel/x64/binbuild"
  ar rcs cgx64.lib *.obj 2>/dev/null
  cp cgx64.lib cgx64lnx.lib 2>/dev/null
  cd "$OWROOT"  2>/dev/null
  cp -n "$OWROOT/bld/cc/386/binbuild/"*.gh  "$OWROOT/bld/cc/x64/binbuild/" 2>/dev/null
  cp -n "$OWROOT/bld/cc/386/binbuild/"*.grh "$OWROOT/bld/cc/x64/binbuild/" 2>/dev/null
  cp -n "$OWROOT/bld/wasm/binbuild/"*.grh   "$OWROOT/bld/cc/x64/binbuild/" 2>/dev/null
  cd "$OWROOT/bld/cc/x64"
  make -s OWROOT="$OWROOT" asm_objs link 2>&1 || true
  cd "$OWROOT"
fi

# === OW2IRC: bwpp386 build (if not built by builder) ===
if [ ! -f "$OWROOT/build/binbuild/bwpp386" ] && [ -d "$OWROOT/bld/plusplus/386" ]; then
  echo "=== Building bwpp386 ==="
  # Copy CC/386 objects as base (plusplus shares most CC code)
  mkdir -p "$OWROOT/bld/plusplus/386/binbuild"
  cp -n "$OWROOT/bld/cc/386/binbuild/"*.obj "$OWROOT/bld/plusplus/386/binbuild/" 2>/dev/null
  cp -n "$OWROOT/bld/cc/386/binbuild/"*.gh  "$OWROOT/bld/plusplus/386/binbuild/" 2>/dev/null
  cp -n "$OWROOT/bld/cc/386/binbuild/"*.grh "$OWROOT/bld/plusplus/386/binbuild/" 2>/dev/null
  cd "$OWROOT/bld/plusplus/386/binbuild"
  gcc -o bwpp386 *.obj \
    "$OWROOT/bld/cg/intel/386/binbuild/cg386.lib" \
    "$OWROOT/bld/cg/intel/386/binbuild/cg386lnx.lib" \
    "$OWROOT/bld/watcom/binbuild/clibext.lib" \
    "$OWROOT/bld/dwarf/dw/binbuild/dwarfw.lib" \
    "$OWROOT/bld/cfloat/binbuild/cf.lib" \
    -lm -no-pie 2>/dev/null && {
      chmod +x bwpp386
      cp bwpp386 "$OWROOT/build/binbuild/"
      echo "=== bwpp386 linked ==="
    } || true
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
