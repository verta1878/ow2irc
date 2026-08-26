# Phase 19 — Frontend Integration Patches Applied

## 1. bld/cc/h/ctypes.h
Added `TS_LINUX64` to target_system enum.

## 2. bld/cc/c/cmdlnx86.c — Target Recognition
Added `"LINUX64"` → `TS_LINUX64` in target name switch (~line 178).

## 3. bld/cc/c/cmdlnx86.c — Target Setup
Added `case TS_LINUX64:` block (~line 470) that:
- Predefines `__UNIX__`, `__LINUX__`, `__X86_64__`, `__LP64__`, `__amd64__`
- Sets `GenSwitches |= CGSW_GEN_OBJ_ELF`

## 4. bwcc386 Rebuilt
- cmdlnx86.obj recompiled with patched source
- bwcc386 relinked with new cmdlnx86.obj
- Verified: `-bt=linux64` sets all 5 macros correctly
- Verified: `-bt=dos` does NOT set x64 macros (no regression)

## Status
- Frontend: ✅ `-bt=linux64` accepted, macros defined, ELF flag set
- Backend: Still outputs OMF (cg doesn't have ELF path for x86 yet)
- Full pipeline: Requires INTEGRATION.md steps 4-7 (cg x64 backend wiring)

## Test Results
```
$ bwcc386 test.c -bt=linux64 -pc | grep MACRO_
MACRO_UNIX_DEFINED
MACRO_LINUX_DEFINED
MACRO_X64_DEFINED
MACRO_LP64_DEFINED
MACRO_AMD64_DEFINED
MACRO_WATCOMC_DEFINED
```

```c
// With -bt=linux64, this resolves correctly:
strcat(buf, "x86_64 Linux");   // PLATFORM = "x86_64 Linux"
typedef unsigned long size_type; // __LP64__ selects long
```
