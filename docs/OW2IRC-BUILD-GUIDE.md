# OW2IRC Build Guide

## Quick Start

```bash
# Clone and build compiler:
git clone https://github.com/verta1878/ow2irc
cd ow2irc
bash build.sh

# Build MinGW-w64 CRT:
cd bld/mingw64
bash build_all.sh
```

## Compiler Usage

### Linux x64

```bash
# Compile:
bwccx64 hello.c -fo=hello.o -bt=linux64 -ox -s

# Link:
ld -o hello crt0_x64.o hello.o bld/mingw64/build/libmingw64crt.a
```

### Win64 (cross-compile from Linux)

```bash
# Compile:
bwccx64 hello.c -fo=hello.o -bt=win64 -ox -s

# Link (requires MinGW-w64 cross tools):
x86_64-w64-mingw32-ld -o hello.exe hello.o \
  -Lbld/mingw64/build/win64 -lmingw64win \
  -Lbld/mingw64/build/lib64-system -lkernel32 -luser32
```

## Build Requirements

### Always needed:
- GCC (host compiler for building bwccx64)
- GNU make, ar, ld

### For Win64 target:
- `gcc-mingw-w64-x86-64` (cross compiler)
- `mingw-w64-tools` (dlltool for import libraries)

Install: `apt install gcc-mingw-w64-x86-64 mingw-w64-tools`

## Directory Layout

```
build/binbuild/
  bwccx64          — C compiler (x64 target)
  bwppx64          — C preprocessor

bld/mingw64/
  build/
    libmingw64crt.a    — portable CRT (Linux x64)
    win64/
      libmingw64win.a  — Win64 CRT
    lib64/             — Win64 import libs
    lib-common/        — shared import libs
    lib32/             — Win32 import libs
    lib64-system/      — system import libs (kernel32, etc.)

bld/clib/linux/x64/
  crt0_x64.S         — Linux x64 startup
```

## Test Battery

```bash
# Run the 62-test battery:
bash tests/run_tests.sh    # (if present)

# Manual test:
echo 'int main(void){return 42;}' > test.c
bwccx64 test.c -fo=test.o -bt=linux64 -ox -s
ld -o test crt0_x64.o test.o
./test; echo $?   # should print 42
```

## the crew 4free
