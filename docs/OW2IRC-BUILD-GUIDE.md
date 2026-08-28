# OW2IRC Build Guide

## Prerequisites
- GCC (any recent version, tested with GCC 13)
- GNU make
- ar, ld (GNU binutils)
- bash

## Building from source

```bash
git clone https://github.com/verta1878/ow2irc
cd ow2irc
bash build.sh
```

That's it. `build.sh` does everything:
1. Builds all 386 targets (bwcc386, bwasm, bwlink, etc.)
2. Copies 386 CC objects to x64 directory
3. Recompiles x64obj.c + cgen.c + cmdlnx86.c + 386table.c with `-D_TARG_X64=1`
4. Copies shared 386 CG objects to x64 CG library
5. Removes OMF intermediates (code386.obj, codex64.obj)
6. Rebuilds cgx64.lib
7. Links bwccx64 (C x64 compiler)
8. Links bwppx64 (C++ x64 compiler)

## Testing

```bash
# Compile:
build/binbuild/bwccx64 hello.c -fo=hello.o -bt=linux64 -ox

# Assemble crt0:
gcc -c bld/clib/linux/x64/crt0_x64.S -o crt0_x64.o

# Link:
ld -o hello crt0_x64.o hello.o

# Run:
./hello
```

## Output
- `build/binbuild/bwccx64` — C compiler (x86-64 ELF64)
- `build/binbuild/bwppx64` — C++ compiler (x86-64 ELF64)
- `build/binbuild/bwcc386` — C compiler (i386)
- `build/binbuild/bwasm` — MASM-compatible assembler
- `build/binbuild/bwlink` — linker
- 42 utilities total

## Status
All known issues resolved. Clean compile, clean link, zero warnings.
