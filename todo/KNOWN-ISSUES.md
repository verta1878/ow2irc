# openwatcom2irc — Known Issues

Status as of r0.6.0 (2026-08-28).

## CG Limitations

### 32-bit pointer arithmetic on 64-bit addresses
The 386-based CG emits 32-bit INC/DEC/ADD for pointer operations.
Stack addresses on Linux x64 are above 4GB (0x7fff...). When a
pointer to a stack-local variable (char buf[N]) is incremented,
the upper 32 bits are zeroed → segfault.

**Works:** globals, string literals, function pointers, all .data/.text
addresses (below 4GB with static linking).

**Fails:** pointer arithmetic on stack-allocated buffers passed to
functions (e.g. `scpy(buf, "AB")` where buf is local char[32]).

**Fix requires:** REX.W prefix on pointer-width INC/DEC/ADD in the
x86 instruction encoder when operating on pointer-type operands.
This is a deep CG change in x86enc.c.

### .eh_frame linker warning (cosmetic)
CIE uses minimal augmentation. Linker warns but links successfully.
Programs run correctly. GDB backtraces may not work.

## Resolved
All ELF section header bugs, e_shstrndx, string literals,
.rela.eh_frame layout, build system, runtime startup.
See CHANGELOG.md.

## Future — Native x64 Code Generator

The current x64 backend uses the 386 CG + post-processor (REX.W
expansion pass). This works but is "high emulation" — upgrade 32-bit
instructions to 64-bit after the fact.

**Goal:** native x64 code generator for OW2IRC. No GCC dependency.
Self-hosted. Port the approach MinGW-64 uses (native x64 register
allocator, 64-bit instruction selection) but implemented inside the
OW CG framework, not imported from GCC.

**What's needed:**
- Native 64-bit register allocator (RAX-R15, XMM0-15)
- Direct REX.W emission during instruction selection
- RIP-relative addressing for position-independent code
- 64-bit immediate/displacement handling
- SSE2 floating point (replace x87 for x64)
- Remove the post-processor REX expansion pass
- Self-hosted: bwccx64 compiles itself without GCC

**Not needed from MinGW/GCC:**
- GCC frontend (we have our own C/C++ frontend)
- GCC optimizer (we have our own)
- GCC assembler (we have wasm)
- GCC linker (we have wlink)
- MSVCRT/UCRT (we have musl-ow)
