# Installing / Building openwatcom2irc

## Requirements

- Linux x86_64 host
- GCC 13 or later
- GNU Make
- ~2 GB disk space for a full build

## Full build (bootstrap from source)

This follows the standard Open Watcom v2 build: GCC bootstraps the Watcom
tools, then the tools build themselves and the runtime.

```bash
git clone https://github.com/verta1878/openwatcom2irc.git
cd openwatcom2irc

export OWROOT=$(pwd)
export OWTOOLS=GCC
export OWOBJDIR=binbuild
export OWTOOLSVER=13
source cmnvars.sh

# Bootstrap the tools (GCC builds wmake + builder), then build everything
./build.sh
# then build the release tree
builder rel
```

After the build:

```bash
export PATH="$OWROOT/build/binbuild:$OWROOT/rel/binl64:$PATH"
export WATCOM="$OWROOT/rel"
```

## What gets built

| Binary | Target |
|--------|--------|
| `bwcc` / `wcc`     | C compiler, i8086 16-bit real mode |
| `bwcc386` / `wcc386` | C compiler, i386 32-bit |
| `bwcc64`           | C compiler, x86-64 (ELF64) — new in this fork |
| `wlink`            | linker |
| `wlib`             | librarian |
| `wasm`             | assembler |
| `wrc`              | resource compiler |

plus the runtime libraries and Win32 import libraries.

## Verify the build

```bash
# x86-64 backend: 61 runtime tests
tests/x64/run_tests.sh $OWROOT
# expected: 61/61 PASS

# behavioural diff against gcc as an oracle
tests/x64/difftest.sh
```

## Quick compile examples

```bash
# 16-bit DOS (real mode, no extender)
printf 'int main(void){ return 42; }\n' > t.c
wcc t.c -fo=t.obj -bt=dos -ms

# 32-bit DOS
wcc386 t.c -fo=t.o -bt=dos

# x86-64 ELF64 (freestanding, no libc)
printf 'extern int puts(const char*);\nint main(void){ puts("hi"); return 42; }\n' > h.c
bwcc64 h.c -fo=h.o -i=$WATCOM/h -bt=linux64 -ox -s
ld -o h bld/clib/linux/x64/crt0_x64.o h.o
./h        # prints "hi", exits 42
```

## Rebuilding just the x86-64 backend after a codegen edit

If you only change a code-generator source under `bld/cg/`, you can
recompile that file and relink `bwcc64` without a full bootstrap. The
codegen objects are compiled with GCC (bootstrap mode) and archived into
`cgx64.lib`, which links into `bwcc64` alongside the front-end objects.
See `docs/GCC-BACKEND-ROADMAP.md` for the object layout.

## Notes

- 16-bit targets do not run on 64-bit Windows (no NTVDM); use DOSBox.
- The x86-64 backend post-processes OMF into ELF64; see the README
  Architecture section.
