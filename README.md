# openwatcom2irc

A fork of [Open Watcom v2](https://github.com/open-watcom/open-watcom-v2)
that adds a native **x86-64 C backend** (`wcc64`) while keeping the
original 16-bit and 32-bit compilers intact.

One C front end drives three code generators:

| Compiler | Target | Status |
|----------|--------|--------|
| `wcc`    | i8086 16-bit real mode | stock upstream, unchanged |
| `wcc386` | i386 32-bit | stock upstream, unchanged |
| `wcc64`  | x86-64 (ELF64) | **new in this fork** |

## What works

### x86-64 backend (`wcc64`) — new

`wcc64 -bt=linux64` compiles C to x86-64 ELF64 objects. **61/61 runtime
tests pass.** Coverage includes return values, arithmetic, switch/case,
loops, recursion, globals, arrays, structs, function pointers, unions,
`long long` shifts, nested struct arrays, pointer initialisers, multi-file
linking, string routines, and 5+ argument functions with intervening
calls.

Pointers are 8 bytes. The backend uses a 386 code generator feeding an
OMF-to-ELF64 post-processor (`x64obj.c`) that rewrites i386-incompatible
encodings, adds REX prefixes where the frame register requires them, and
resolves relocations with a real x86 instruction-length decoder.

Run the suite:

```bash
export OWROOT=$(pwd)
tests/x64/run_tests.sh $OWROOT      # 61/61
```

### DOS targets — 16-bit and 32-bit

The stock compilers cover DOS unchanged:

| Model | Compiler | Extender |
|-------|----------|----------|
| 16-bit real mode | `wcc` | none |
| 32-bit flat | `wcc386` | DOS/32A (open source, bundled) |

16-bit real mode is the target for the BBS software in the related repos
(PCBoard, QFront). No extender is used there. DOS/32A is available for
any 32-bit flat-model program that needs it.

### Real-world validation

As a large real-world test, the compilers build a full 3dfx Glide3x SST-1
driver (~23k lines) from original source. That work — the driver builds,
libraries, and DOS test harness — lives in a **separate repository**, not
here, to keep this repo a clean compiler toolchain.

### i386 / OS/2 / Win32 — unchanged from upstream

The original 32-bit targets are not modified: DOS, DOS/4G, Pharlap, OS/2
16-/32-bit, and Win32 (OMF to PE32) all behave exactly as pristine
upstream. Object output is byte-identical to the unmodified compiler
across 80+ comparisons.

Note: 16-bit targets do not run on 64-bit Windows (no NTVDM); use DOSBox.

## Quick start

```bash
export OWROOT=$(pwd)
export OWTOOLS=GCC OWOBJDIR=binbuild OWTOOLSVER=13
. cmnvars.sh
export PATH="$OWROOT/build/binbuild:$OWROOT/rel/binl64:$PATH"
export WATCOM="$OWROOT/rel"

# x86-64 (freestanding, no libc)
printf 'extern int puts(const char*);\nint main(void){ puts("hello"); return 42; }\n' > hello.c
bwcc64 hello.c -fo=hello.o -i=$WATCOM/h -bt=linux64 -ox -s
ld -o hello bld/clib/linux/x64/crt0_x64.o hello.o
./hello        # prints "hello", exits 42

# 16-bit DOS
printf 'int main(void){ return 42; }\n' > dos.c
wcc dos.c -fo=dos.o -bt=dos -ms
```

## Pre-built tools

```
rel/binl64/
  wcc       C compiler (16-bit real mode)
  wcc386    C compiler (32-bit)
  wlink     linker
  wasm      assembler
  wlib      librarian
  wsplice   text preprocessor
  wrc       resource compiler
build/binbuild/
  bwcc64    C compiler (x86-64)
```

## Testing

```bash
tests/x64/run_tests.sh $OWROOT      # wcc64: 61/61 x86-64 runtime tests
tests/x64/difftest.sh               # gcc oracle vs wcc64, behavioural diff
tests/x64/gapscan.sh                # structural section/relocation diff
```

`difftest.sh` runs each case under both gcc and wcc64 and compares exit
status and stdout — no hand-written expected values.

## Architecture

The x64 path post-processes OMF into ELF64:

1. **Front end** — `-bt=linux64` selects x64 macros and codegen settings.
2. **Code generator** — the 386 code generator emits OMF, with pointer
   sizes and frame handling adjusted for the 64-bit ABI.
3. **Post-processor** (`x64obj.c`) — reads OMF, length-decodes each
   instruction, applies REX prefixes and encoding fixups, extracts
   symbols from PUBDEF/LPUBDEF, resolves relocations, and writes ELF64
   with `.text`/`.data`/`.bss`/`.rela.text`/`.rela.data`.

The instruction-length decoder is what lets the relocation pass skip
whole instructions safely, rather than walking byte-by-byte and
mistaking a ModRM or displacement byte for an opcode.

## Related repos

| Repo | What |
|------|------|
| verta1878/pcbirc | PCBoard 15.3/15.4 revival (16-bit DOS) |
| verta1878/fpc264irc | Free Pascal 2.6.4 fork (architecture reference) |
| verta1878/netmodem2irc | FOSSIL/TCP bridge |
| verta1878/mystic-bbs-irc | Mystic BBS fork |

---

*the crew 4free — x86 little endian*
