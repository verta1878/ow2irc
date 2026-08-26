# WASM + JWasm Integration Guide

_OW2IRC r0.6.0 — the crew 4free — sysop/0_
_Last updated: 2026-08-25_

## The Two Assemblers

| | wasm (Watcom) | JWasm/UASM |
|--|--------------|------------|
| Syntax | Watcom + MASM subset | Full MASM 6.x compatible |
| x64 | ❌ No (wasm64 planned) | ✅ Yes (jwasm -elf64) |
| OMF output | ✅ | ✅ |
| COFF output | ✅ | ✅ |
| ELF output | ✅ | ✅ |
| RECORD literals | ❌ Limited | ✅ Full MASM 6 support |
| Anonymous unions | ❌ | ✅ |
| Invoke/proto | ❌ | ✅ |
| OW build system | ✅ Native | ❌ External tool |

## Object File Compatibility

Both produce the SAME object format. wlink doesn't care which
assembler made the .obj — it links them identically.

```
wasm file1.asm → file1.obj ─┐
                             ├── wlink → program.exe
jwasm file2.asm → file2.obj ─┘
```

Mix freely. Use wasm for Watcom-syntax files (OW internals).
Use JWasm for MASM-syntax files (FOSSIL, GLaBIOS, drivers).

## Using JWasm in OW2IRC Build System

### Method 1: wmake rule for MASM-syntax files

Add to your makefile:
```makefile
# Watcom-syntax .asm → wasm
.asm.obj:
    wasm $(AFLAGS) $<

# MASM-syntax .masm → JWasm
.masm.obj:
    jwasm -omf -q $<

# Or use file-specific rules:
fossil.obj: fossil.asm
    jwasm -omf -Fo=$@ $<
```

### Method 2: Wrapper script

```bash
#!/bin/sh
# owasm — smart assembler wrapper
# Tries wasm first, falls back to JWasm on failure
FILE=$1
wasm $@ 2>/dev/null
if [ $? -ne 0 ]; then
    echo "wasm failed, trying JWasm..."
    jwasm -omf -Fo=$(basename $FILE .asm).obj $FILE
fi
```

### Method 3: wmake environment variable

```makefile
# Set ASM tool based on syntax needed:
!ifdef USE_JWASM
ASM = jwasm -omf -q
!else
ASM = wasm $(AFLAGS)
!endif
```

## JWasm Command Line for OW Compatibility

```bash
# 16-bit DOS (same as wasm):
jwasm -omf -0 fossil.asm              → fossil.obj (OMF, 8086)

# 32-bit DOS (same as wasm -3):
jwasm -omf -3 driver32.asm            → driver32.obj (OMF, 386)

# 32-bit ELF Linux:
jwasm -elf -3 driver_linux.asm        → driver_linux.o (ELF32)

# 64-bit ELF Linux (wasm CAN'T do this):
jwasm -elf64 driver_x64.asm           → driver_x64.o (ELF64)

# 64-bit COFF Win64 (wasm CAN'T do this):
jwasm -coff -win64 driver_win64.asm   → driver_win64.obj (COFF x64)
```

## FOSSIL Driver Build Example

FOSSIL drivers use MASM syntax (INT 14h TSR).
Use JWasm for assembly, wlink for linking:

```makefile
# FOSSIL driver makefile for OW2IRC
CC = wcc
ASM = jwasm
LINK = wlink

# C source compiled with wcc:
fossil_main.obj: fossil_main.c
    $(CC) -ms -0 fossil_main.c

# ASM source compiled with JWasm (MASM syntax):
fossil_io.obj: fossil_io.asm
    $(ASM) -omf -0 fossil_io.asm

# Link everything with wlink:
fossil.com: fossil_main.obj fossil_io.obj
    $(LINK) system com file fossil_main,fossil_io name fossil
```

## GLaBIOS Build Example

GLaBIOS uses MASM RECORD literals that wasm doesn't support.
JWasm handles them (mostly — some MASM 6 edge cases need UASM):

```bash
# Assemble GLaBIOS with JWasm:
jwasm -bin -Fo GLABIOS.BIN GLABIOS.ASM

# If JWasm fails on RECORD <> literals, use UASM:
uasm -bin -Fo GLABIOS.BIN GLABIOS.ASM
```

## x64 Assembly (until wasm64 is built)

Use JWasm or NASM for x64 assembly files:

```bash
# JWasm x64 ELF:
jwasm -elf64 crt0_x64.asm → crt0_x64.o

# NASM x64 ELF:
nasm -f elf64 crt0_x64.asm -o crt0_x64.o

# Link with wlink:
wlink system elf64 file crt0_x64 name program
```

## Summary

| Task | Use |
|------|-----|
| OW internal .asm | wasm |
| FOSSIL drivers | JWasm |
| GLaBIOS | JWasm or UASM |
| Glide NASM patches | NASM |
| x64 .asm (until wasm64) | JWasm -elf64 or NASM -f elf64 |
| Mix objects from both | ✅ wlink handles all formats |
