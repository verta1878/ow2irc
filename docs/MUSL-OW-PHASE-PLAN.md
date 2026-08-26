# musl-ow — Self-Contained C/C++ Library for OW2IRC

_Version: Phase Plan v1.0_
_Crew: sysop/0 (lead), bob (compiler integration)_
_License: MIT (musl) + GPLv3 (our additions)_

## Goal
Compile musl-libc with wcc/wcc386/wcc64.
Static link into every OW2IRC binary.
Zero external dependencies. Runs anywhere.

## Phase M-0: Clone + Inventory
- [ ] Clone musl (git.musl-libc.org/cgit/musl, ~95,000 lines)
- [ ] Inventory: count .c files, identify ASM files per arch
- [ ] Identify x86_64 arch directory (arch/x86_64/)
- [ ] Check for GCC extensions that wcc can't handle
- [ ] Document: which .c files compile clean with wcc

## Phase M-1: Core libc (string + stdlib + stdio)
- [ ] Compile string/*.c (memcpy, strlen, strcmp, etc.)
- [ ] Compile stdlib/*.c (malloc, free, qsort, atoi, etc.)
- [ ] Compile stdio/*.c (printf, scanf, fopen, fclose, etc.)
- [ ] Compile ctype/*.c (isalpha, toupper, etc.)
- [ ] Compile errno/*.c (strerror, errno)
- [ ] Test: 20 basic tests (malloc+free, sprintf, fopen+fread)

## Phase M-2: Math library
- [ ] Compile math/*.c (sin, cos, sqrt, pow, etc.)
- [ ] Compile fenv/*.c (floating-point environment)
- [ ] Test: 10 math tests (trig, sqrt, pow, edge cases)

## Phase M-3: POSIX threads
- [ ] Compile thread/*.c (pthread_create, mutex, cond, etc.)
- [ ] x86_64 thread ASM (clone syscall, TLS setup)
- [ ] Test: 5 thread tests (create+join, mutex lock, cond wait)

## Phase M-4: Network + DNS
- [ ] Compile network/*.c (socket, connect, bind, etc.)
- [ ] Compile dns/*.c (getaddrinfo, gethostbyname)
- [ ] Test: 5 network tests (TCP connect, DNS resolve)

## Phase M-5: Extensions (our additions)
- [ ] Port full iconv (~800 lines, CP437/Shift-JIS/UTF-8)
- [ ] Port NSS static resolver (~200 lines)
- [ ] Port GNU compat functions (~100 lines)
- [ ] Test: 5 extension tests (iconv roundtrip, getline, asprintf)

## Phase M-6: x86_64 ASM Port
- [ ] Port arch/x86_64/*.s to wasm64 or JWasm syntax
- [ ] Key files: crt1.s, crti.s, crtn.s (startup)
- [ ] syscall.s (Linux system call wrapper)
- [ ] setjmp.s (our x64clib.c already has this!)
- [ ] clone.s (thread creation)
- [ ] Test: startup + syscall + setjmp all work

## Phase M-7: Static Library Build
- [ ] Build libmusl-ow.a from all compiled .o files
- [ ] Link test program statically: wcc64 + wlink + libmusl-ow.a
- [ ] Verify: ldd shows "not a dynamic executable"
- [ ] Verify: runs on clean system with no libraries installed
- [ ] Size check: static hello world < 100 KB

## Phase M-8: C++ Library (libc++)
- [ ] Clone LLVM libc++ (llvm-project/libcxx)
- [ ] Compile with wpp64 against musl-ow headers
- [ ] Key: string, vector, iostream, memory, algorithm
- [ ] Test: 10 C++ tests (string, vector, cout, shared_ptr)

## Phase M-9: Integration + Full Test Bed
- [ ] Rebuild wcc64 linked against musl-ow (self-hosted!)
- [ ] Rebuild bwpp64 linked against musl-ow + libc++
- [ ] Full regression: 61/61 original + 4 phase suites
- [ ] Binary portability: copy to 3 different distros, all run
- [ ] Size comparison: musl-ow static vs glibc dynamic

## Test Bed — 60 Tests Total

### Core Tests (Phase M-1): 20 tests
```
T01  malloc + free (no leak)
T02  realloc (grow + shrink)
T03  calloc (zero-filled)
T04  sprintf (format string)
T05  snprintf (buffer limit)
T06  sscanf (parse int + float)
T07  fopen + fwrite + fclose
T08  fopen + fread (verify content)
T09  fseek + ftell
T10  strcmp + strncmp
T11  memcpy + memcmp
T12  strlen + strnlen
T13  strchr + strrchr
T14  strtol + strtoul
T15  atoi + atof
T16  qsort (10 elements)
T17  bsearch (sorted array)
T18  getenv + setenv
T19  atexit (2 handlers)
T20  abort (signal raised)
```

### Math Tests (Phase M-2): 10 tests
```
T21  sin(0) == 0, sin(PI/2) == 1
T22  cos(0) == 1, cos(PI) == -1
T23  sqrt(4) == 2, sqrt(2) ~= 1.414
T24  pow(2, 10) == 1024
T25  log(1) == 0, log(E) == 1
T26  floor + ceil + round
T27  fabs + fmod
T28  INFINITY + NAN handling
T29  exp(0) == 1
T30  atan2(1, 1) ~= PI/4
```

### Thread Tests (Phase M-3): 5 tests
```
T31  pthread_create + join (return value)
T32  mutex lock + unlock (no deadlock)
T33  cond wait + signal (producer-consumer)
T34  thread-local storage (__thread)
T35  10 threads incrementing shared counter with mutex
```

### Network Tests (Phase M-4): 5 tests
```
T36  socket(AF_INET, SOCK_STREAM)
T37  connect to localhost:80 (or skip if no server)
T38  getaddrinfo("localhost") → 127.0.0.1
T39  gethostname() returns non-empty
T40  inet_pton + inet_ntop roundtrip
```

### Extension Tests (Phase M-5): 5 tests
```
T41  iconv: UTF-8 → CP437 roundtrip
T42  iconv: Shift-JIS → UTF-8
T43  getline (read line from file)
T44  asprintf (allocating sprintf)
T45  strndup (bounded string copy)
```

### Integration Tests (Phase M-9): 15 tests
```
T46  Static hello world runs on 3 distros
T47  wcc64 self-hosted compile (compile wcc64 with wcc64)
T48  Glide library compiles with musl-ow headers
T49  FOSSIL NT driver compiles with musl-ow
T50  printf format edge cases (%lld, %zu, %p)
T51  FILE I/O with binary mode (fwrite struct)
T52  signal handler (SIGINT, SIGSEGV)
T53  mmap (MAP_ANONYMOUS)
T54  clock_gettime (CLOCK_MONOTONIC)
T55  opendir + readdir + closedir
T56  stat + chmod + unlink
T57  pipe + fork + exec (if fork supported)
T58  Static binary < 100 KB (hello world)
T59  Static binary < 2 MB (wcc64)
T60  ldd confirms "not a dynamic executable"
```

### Test Runner
```bash
#!/bin/sh
# musl-ow-test.sh — run all 60 tests
PASS=0; FAIL=0; SKIP=0
for t in test_t*.exe; do
  result=$(./$t 2>&1)
  rc=$?
  name=$(echo $t | sed 's/test_//;s/.exe//')
  if [ $rc -eq 0 ]; then
    echo "  ✅ $name"
    PASS=$((PASS + 1))
  elif [ $rc -eq 77 ]; then
    echo "  ⏭️  $name (skipped)"
    SKIP=$((SKIP + 1))
  else
    echo "  ❌ $name: $result"
    FAIL=$((FAIL + 1))
  fi
done
echo ""
echo "PASS: $PASS  FAIL: $FAIL  SKIP: $SKIP  TOTAL: $((PASS+FAIL+SKIP))/60"
```

## Phase M-10: Itanium C++ ABI Name Mangling

Needed for wpp64 to produce symbols that libc++ and system
libraries understand. Without this, C++ functions are invisible
to the linker.

### Itanium Mangling Spec (public, well-documented)
```
void foo(int)           → _Z3fooi
std::string::size()     → _ZNKSs4sizeEv
namespace::Class::func  → _ZN9namespace5Class4funcE...
```

### Implementation (~500 lines in wpp front-end)
- [ ] M-10a: Basic mangling (functions, namespaces, classes)
- [ ] M-10b: Template mangling (substitution, compression)
- [ ] M-10c: Operator mangling (operator+, operator<<)
- [ ] M-10d: Special functions (__cxa_atexit, __cxa_pure_virtual)
- [ ] M-10e: RTTI type_info mangling
- [ ] Test: 10 demangling roundtrip tests (mangle → c++filt → verify)

Location: bld/plusplus/c/mangle_itanium.c (new file)
Activated by: -bt=linux64 or -abi=itanium flag
OW mangling kept for -bt=dos, -bt=nt (backward compat)

## Phase M-11: DWARF Exception Tables (.gcc_except_table)

Phase 6 (.eh_frame) handles stack unwinding.
C++ exceptions also need .gcc_except_table for:
  - Landing pad addresses (where catch blocks start)
  - Type info pointers (which exception types are caught)
  - Action table (which handler handles which type)

### Implementation (~300 lines)
- [ ] M-11a: LSDA (Language-Specific Data Area) header
- [ ] M-11b: Call site table (PC range → landing pad mapping)
- [ ] M-11c: Action table (type filter → handler chain)
- [ ] M-11d: Type table (RTTI pointers for catch clauses)
- [ ] M-11e: Wire into .eh_frame FDE augmentation data
- [ ] Test: try/catch with int, string, custom class

Location: bld/cg/intel/x64/c/x64except.c (new file)
              bld/cg/intel/x64/h/x64except.h (new file)

### How It Works
```
try {
    may_throw();        // call site in call site table
} catch (int e) {       // landing pad + type filter
    handle(e);
} catch (std::exception& e) {  // second landing pad
    handle2(e);
}
```
Compiler emits:
  .eh_frame FDE → stack unwinding (Phase 6 ✅ done)
  .gcc_except_table → which catch blocks handle which types

### Integration with libc++
libc++ provides:
  __cxa_throw()         — throw an exception
  __cxa_begin_catch()   — enter catch block
  __cxa_end_catch()     — leave catch block
  __cxa_allocate_exception() — allocate exception object
  _Unwind_RaiseException()  — trigger stack unwinding

Our .gcc_except_table tells the unwinder WHERE to land.
The unwinder reads .eh_frame to unwind the stack,
then reads .gcc_except_table to find the right catch block.

## Phase M-12: libc++ Build with wpp64

### Build Order
1. musl-ow (Phase M-1 through M-7) — C library
2. Itanium mangling (Phase M-10) — C++ symbols
3. DWARF exceptions (Phase M-11) — try/catch
4. libc++ (this phase) — C++ standard library

### libc++ Components
```
libc++ source (~150,000 lines, Apache 2.0):
  include/     — C++ headers (string, vector, map, etc.)
  src/
    string.cpp         — std::string implementation
    vector.cpp         — (header-only, no .cpp needed)
    iostream.cpp       — cin, cout, cerr
    locale.cpp         — locale support
    filesystem.cpp     — std::filesystem
    memory.cpp         — allocator, shared_ptr support
    exception.cpp      — exception handling runtime
    typeinfo.cpp       — RTTI support
    new.cpp            — operator new/delete
    algorithm.cpp      — (mostly header-only)
    chrono.cpp         — time support
    mutex.cpp          — std::mutex (needs pthreads)
    thread.cpp         — std::thread (needs pthreads)
    random.cpp         — random number generators
```

### Sub-phases
- [ ] M-12a: Build libc++ headers (copy, verify includes work)
- [ ] M-12b: Compile src/*.cpp with wpp64
- [ ] M-12c: Fix any wpp64 parser issues (C++17 features)
- [ ] M-12d: Build static libcxx-ow.a
- [ ] M-12e: Link test program: wpp64 + musl-ow + libcxx-ow
- [ ] Test: 10 C++ standard library tests

### Test: C++ Standard Library (10 tests)
```
T61  std::string create + append + find
T62  std::vector push_back + sort + iterate
T63  std::map insert + lookup + erase
T64  std::cout << "hello" << std::endl
T65  std::shared_ptr create + copy + destroy
T66  std::unique_ptr move semantics
T67  try/catch std::runtime_error
T68  std::thread create + join
T69  std::mutex lock + unlock
T70  std::filesystem::exists (if supported)
```

## Updated Test Bed — 70 Tests Total

Phase M-1:   T01-T20  Core libc          (20 tests)
Phase M-2:   T21-T30  Math               (10 tests)
Phase M-3:   T31-T35  Threads            (5 tests)
Phase M-4:   T36-T40  Network            (5 tests)
Phase M-5:   T41-T45  Extensions         (5 tests)
Phase M-9:   T46-T60  Integration        (15 tests)
Phase M-12:  T61-T70  C++ stdlib         (10 tests)
─────────────────────────────────────────────────
Total:                                    70 tests

70/70 = ship it.

## Complete Self-Contained Stack

```
wpp64 binary (our x64 C++ compiler):
  ├── musl-ow      95K lines   MIT         C library
  ├── + iconv       800 lines  GPLv3       Character encodings
  ├── + NSS         200 lines  GPLv3       Name resolution
  ├── + GNU compat  100 lines  GPLv3       getline, asprintf
  ├── libc++       150K lines  Apache 2.0  C++ standard library
  ├── Itanium ABI   500 lines  GPLv3       Name mangling
  ├── DWARF except  300 lines  GPLv3       try/catch tables
  ├── .eh_frame     322 lines  GPLv3       Stack unwinding (Phase 6)
  ├── All statically linked
  └── ZERO external dependencies

Total: ~247K lines of library code
Our additions: ~2,222 lines
Everything else: MIT or Apache 2.0
```

## Phase M-13: Parallel Algorithms (no TBB)

Replace Intel TBB dependency with our own thread pool.
Uses pthreads from musl-ow. ~800 lines total.

- [ ] M-13a: Thread pool (~300 lines, spawn N = CPU cores)
- [ ] M-13b: parallel_sort (~200 lines, split+sort+merge)
- [ ] M-13c: parallel_for_each (~150 lines)
- [ ] M-13d: parallel_reduce (~150 lines)
- [ ] Test: 5 tests (T71-T75)

```
T71  parallel sort 10,000 ints (verify sorted)
T72  parallel for_each (sum array, compare sequential)
T73  parallel reduce (dot product)
T74  par vs par_seq timing (par must be faster on 4+ cores)
T75  parallel sort stability test
```

## Phase M-14: __gnu_cxx Extensions

Implement the unique ones that C++11+ doesn't replace. ~500 lines.

- [ ] M-14a: __gnu_cxx::rope (~200 lines, scalable string)
- [ ] M-14b: __gnu_cxx::stdio_filebuf (~100 lines, FILE* ↔ stream)
- [ ] M-14c: __gnu_cxx::__pool_alloc (~150 lines)
- [ ] M-14d: Compatibility aliases (hash_map → unordered_map, etc.)
- [ ] Test: 3 tests (T76-T78)

```
T76  rope: concat 1M strings, verify content
T77  stdio_filebuf: fopen → iostream → read back
T78  pool_alloc: allocate+free 10,000 objects
```

## Phase M-15: C++23 Library Completion

Complete the missing C++23 features in libc++. ~2,500 lines.

- [ ] M-15a: std::stacktrace full (~800 lines, uses .eh_frame)
- [ ] M-15b: std::text_encoding (~500 lines, ties to our iconv)
- [ ] M-15c: std::inplace_vector (~400 lines)
- [ ] M-15d: Extended floating point stubs (~300 lines)
- [ ] M-15e: Remaining C++23 library features (~500 lines)
- [ ] Test: 5 tests (T79-T83)

```
T79  stacktrace: capture + print 5 frames
T80  text_encoding: UTF-8 name lookup
T81  inplace_vector: push_back up to capacity, verify no alloc
T82  float16_t: basic arithmetic (if hardware supports)
T83  std::print("hello {}\n", "world")
```

## Phase M-16: C++23 Parser (wpp64)

Upgrade wpp C++ parser from C++98/03 to C++23.
~21,000 lines of parser changes over 5 sub-phases.

### M-16a: C++11 Parser (~5,000 lines)
- [ ] auto type deduction
- [ ] Lambda expressions
- [ ] constexpr functions
- [ ] Move semantics (rvalue references)
- [ ] Variadic templates
- [ ] Range-based for loops
- [ ] nullptr keyword
- [ ] Initializer lists
- [ ] Test: 10 tests (T84-T93)

### M-16b: C++14 Parser (~1,000 lines)
- [ ] Generic lambdas (auto parameters)
- [ ] Relaxed constexpr (loops, local vars)
- [ ] Binary literals (0b1010)
- [ ] Digit separators (1'000'000)
- [ ] Test: 3 tests (T94-T96)

### M-16c: C++17 Parser (~3,000 lines)
- [ ] Structured bindings (auto [x, y] = pair)
- [ ] if constexpr
- [ ] Fold expressions
- [ ] Class template argument deduction (CTAD)
- [ ] inline variables
- [ ] Test: 5 tests (T97-T101)

### M-16d: C++20 Parser (~10,000 lines)
- [ ] Concepts (requires clauses)
- [ ] Coroutines (co_await, co_yield, co_return)
- [ ] Modules (import/export) — optional, very complex
- [ ] Ranges library integration
- [ ] Spaceship operator (<=>)
- [ ] Designated initializers
- [ ] Test: 10 tests (T102-T111)

### M-16e: C++23 Parser (~2,000 lines)
- [ ] Deducing this
- [ ] if consteval
- [ ] Multidimensional subscript operator
- [ ] size_t literals (0uz)
- [ ] Test: 5 tests (T112-T116)

## Final Test Bed — 116 Tests

```
Phase M-1:   T01-T20   Core libc           20 tests
Phase M-2:   T21-T30   Math                10 tests
Phase M-3:   T31-T35   Threads              5 tests
Phase M-4:   T36-T40   Network              5 tests
Phase M-5:   T41-T45   Extensions           5 tests
Phase M-9:   T46-T60   Integration         15 tests
Phase M-12:  T61-T70   C++ stdlib          10 tests
Phase M-13:  T71-T75   Parallel algorithms   5 tests
Phase M-14:  T76-T78   __gnu_cxx            3 tests
Phase M-15:  T79-T83   C++23 library        5 tests
Phase M-16:  T84-T116  C++23 parser        33 tests
─────────────────────────────────────────────────────
Total:                                    116 tests

116/116 = fully self-contained C++23 toolchain.
```

## Timeline Estimate

| Phase | Effort | Time |
|-------|--------|------|
| M-0 to M-9 | musl + integration | 2-4 weeks |
| M-10 | Itanium mangling | 1 week |
| M-11 | DWARF exceptions | 1 week |
| M-12 | libc++ build | 1-2 weeks |
| M-13 | Parallel algorithms | 1 week |
| M-14 | __gnu_cxx | 3 days |
| M-15 | C++23 library | 1-2 weeks |
| M-16a | C++11 parser | 4-6 weeks |
| M-16b | C++14 parser | 1 week |
| M-16c | C++17 parser | 2-3 weeks |
| M-16d | C++20 parser | 6-10 weeks |
| M-16e | C++23 parser | 1-2 weeks |
| **Total** | **~21,000 parser + ~5,000 library** | **6-12 months** |

## Complete Self-Contained Stack (Final)

```
wpp64 (C++23 compiler):
  ├── musl-ow         95K lines  MIT         Full C library
  ├── + iconv          800 lines GPLv3       All character encodings
  ├── + NSS            200 lines GPLv3       Name resolution
  ├── + GNU compat     100 lines GPLv3       getline, asprintf
  ├── libc++         150K lines  Apache 2.0  C++ standard library
  ├── + parallel       800 lines GPLv3       Thread pool (no TBB)
  ├── + __gnu_cxx      500 lines GPLv3       rope, stdio_filebuf
  ├── + C++23        2.5K lines  GPLv3       stacktrace, text_encoding
  ├── Itanium ABI      500 lines GPLv3       Name mangling
  ├── DWARF except     300 lines GPLv3       try/catch tables
  ├── C++23 parser    21K lines  GPLv3       Full language support
  ├── All statically linked
  └── ZERO external dependencies

Total library:     ~250K lines
Our additions:      ~26K lines
Everything else:    MIT or Apache 2.0
```
