# bob — Session Notes

Compiler engineer: OpenWatcom, Glide, 3dfx drivers.

This is bob's fresh notes file. sysop/0's history lives separately in
SYSOP0-SESSION-NOTES.md (FPC, Tang Console, USB track). Same engineer
role, split handle — no shared file.

---

## The Crew (8)

| Handle | Role |
|---|---|
| verta1878 | Project lead |
| sysop/0 | Compiler engineer — FPC, Tang Console, USB |
| bob | Compiler engineer — OpenWatcom, Glide, 3dfx drivers |
| evga | Display, Mystic, SIO rebuild |
| kiddo | Protocols, RIPscrip |
| wrench | Transport, FOSSIL, DVI/HDMI |
| hexadecimal | PCBoard, Cyclades |
| byte | Program recovery |

the crew 4free — x86 little endian.

---

## Current state (verified)

- **openwatcom2irc: r0.6.0**, branch `merge-wcc64-glide`, 8 commits ahead
  of base `42d8f0b7`. Compiler repo is Glide-free.
- **wcc64 (x86-64 ELF64): 61/61 runtime tests.** Verified from a clean
  build (bwcc64 rebuilt from pristine checkout, md5-identical to working).
- **DOS targets:** wcc (16-bit real, no extender), wcc386 (32-bit flat,
  DOS/32A). All build `-bt=dos` clean.
- **Glide3x SST-1:** 24/24 TUs on both wcc64 and wcc386-DOS. DOS harness
  runs under DOSBox (DOS/32A), prints version/vendor/renderer/hardware/
  boards. Kept in the SEPARATE `voodoo-glide-ow` repo (4 commits).
- Both repos released, datestamped 20260821.

## ow2irc COMPILER ROADMAP — x64 backend phases (verified vs source)

Status corrected by crew + verified against tree source (not binaries) this
session. This is the COMPILER track (distinct from the 3dfx DRIVER phases).

| Phase | Status | Evidence (source-verified) |
|-------|--------|----------------------------|
| 5 — SysV ABI (full) | ✅ DONE | `x64sysv.h` present; `CGSW_X64_SYSV_ABI=0x2` wired in cgtargsw.h; part of CGSW_X64_LINUX_DEFAULT (RIP_REL\|SYSV\|RED_ZONE) |
| 6 — .eh_frame / GDB | ❌ not started | no eh_frame/CFI in x64 source; x64obj.c emits only .text/.data/.bss/.rela.text |
| 7 — .rodata | ❌ not started | no rodata in x64 CG; read-only constants currently land in .data |
| 8 — Win64 ABI | ❌ not started | no x64 Win64 code (only SysV ABI wired) |
| 9 — SEH | ❌ not started | no pdata/xdata files |
| 10 — wasm x64 | ❌ not started | no x64 assembler files |
| 11 — Full C library | ❌ not started | x64 runtime is the freestanding mini crt0/printf/alloc only |

Current x64 CG source: x64dispatch.c, x64enc.c, x64obj.c + headers
(cgtargsw.h, cgx64reg.h, x64enc.h, x64obj.h, x64sysv.h, hwreg.h,
regindex.h, deftarg.h). 61/61 runtime tests on this.

Note: Phases 6-11 are additive to the working 61/61 backend. 6 (.eh_frame)
+ 7 (.rodata) are ELF64 section-emitter work in x64obj.c (which already
does .text/.data/.bss/.rela.text, so it's extending a known emitter). 8+9
(Win64/SEH) are a whole second ABI. 11 (full C library) is the big one —
current x64 libc is the freestanding mini runtime only.

## BUILD FIXES for ow2irc clone (REMEMBER across refresh) — 2026-08-26

Repo renamed: openwatcom2irc -> **ow2irc** (https://github.com/verta1878/ow2irc).
Deleted stale openwatcomirc + all scratch dirs. Cloned fresh ow2irc
(main @ c5bd0f99, r0.6.0).

**The clone is AHEAD of my old tree**: crew pushed Phase 6-11 SOURCE —
x64ehframe.c (P6), .rodata in x64obj.c (P7), x64pe.c/x64win64.c (P8),
x64seh.c (P9), x64asm.c (P10), x64clib.c (P11), x64parm.c, x64c99compat.c,
x64obj_integration.c, + INTEGRATION.md spec.

**It did NOT build — I fixed 6 build-blocking bugs in x64obj.c** (the
Phase 6/7 ELF-writer splice):
1. Stray `}` in .eh_frame section header — closed X64ObjFini() early
   (brace balance -1, error at ~line 1500).
2. .eh_frame header used raw `v=…;memcpy` (undeclared v) -> SET64().
3. .rodata header same raw pattern -> SET64().
4. drela.r_offset plain assign -> SET64 (Elf64 fields are Watcom
   unsigned_64 struct in bootstrap; `field=int` is a type error).
5. drela.r_addend plain assign -> SET64.
6. two sym.st_size plain assigns -> SET64.
Result: x64obj.c compiles clean; x64obj.obj builds in bootstrap.

**Root-cause pattern:** phase splice didn't follow the file's SET64
convention for 64-bit ELF fields + dropped a brace.

**Saved (survives refresh):** outputs/ow2irc-build-fixes-20260826.zip
(fixed x64obj.c + patch + README with each bug).

**NOT done yet (next session):**
- bwcc64 not fully linked. build.sh bootstrap makes bwcc/bwcc386/etc but
  NOT the x64 target — needs INTEGRATION.md wiring applied
  (bld/cg/intel/x64/binmake + target.mif + client.mif).
- Other phase files compile-check individually, not built into bwcc64/tested.
- run_phase_tests.sh not yet re-run vs a freshly-built bwcc64 from this tree.
- Also: exec bits (configure/build.sh) were lost in the repo re-squash;
  restore before build.sh.

**NEW INCOMING (per verta1878):** next ow2irc release adds FULL MASM SUPPORT
IN WASM. Chat refreshing. When resuming: the masm/wasm work is being ADDED
by the crew; expect x64asm.c (Phase 10) to grow / new masm files. Rebuild
from the refreshed clone, re-apply the x64obj.c SET64 fixes if not yet
upstreamed, then wire + link bwcc64.

## Compiler quick reference (bob's lane)

- Build tree: `/home/claude/openwatcomirc` (working), `/home/claude/gh-ow2irc`
  (GitHub clone, r0.6.0 merge branch).
- wcc64 tests: `tests/x64/run_tests.sh $OWROOT` → 61/61.
- DOS Glide (voodoo repo): `tests/run_dos_glide.sh <owroot> <glide> <libdir>`
  → 8/8 (compile+link+DOSBox+verify).
- From-clean build entry point: `./build.sh` (bootstraps wmake+builder
  from GCC), then `builder rel`. NOT `wmake bootstrap=1` directly.
- Compiler/extender matrix: PCBoard 15.3/15.4 + QFront = wcc 16-bit real,
  no extender. 32-bit flat (if any) = wcc386 + DOS/32A. Nothing current
  uses an extender.

## Methodology (carried from the compiler work)

MEASURE THREE TIMES: capture known-good baseline, change exactly one
thing, prove which side is wrong against an invariant. Print real bytes;
don't reason from disassembly. Reach for ASan on memory corruption. It's
in run_tests.sh's header. Earned the hard way — three wrong root causes
before instrumentation found the jump-scanner bug.

---

## 3dfx revival — scoped, phases assigned

Archive `3dfx-zxc64-complete-20260818.zip` (454 MB, 5,014 files) scoped in
`3DFX-SCOPE-AND-PHASES.md`. The archive's build note said "Glide: TODO —
needs OpenWatcom" — now delivered.

Four tracks:
- **A — silicon (V1→V5-6000):** uneven source coverage per generation.
  V1 reference (Glide SST-1 builds), V2 CVG source, V3 Avenger (H3 Glide
  1/27, C89 header porting), V4/5 complete, V5-6000 4-chip (archive
  sub-phases V6K-1..6).
- **B — OS (DOS/Win/Linux):** DOS furthest (runs today), Win = most files
  + most RE, Linux = catalogued bugs.
- **C — UI/GUI:** TV app + control panel are binary-only → rebuild, not
  port.
- **D — FPGA/HDL:** 30 Verilog files, hardware track, not compiler lane.

Suggested first move: replace the stale bundled compiler zip
(openwatcom2irc_20260812, pre-61/61) with r0.6.0; then extend the DOS
harness to VSA-100; then V2/CVG (most known-good source).

## Open items / next steps

- Push r0.6.0 (branch + PR recommended; bob merged only the compiler
  workstream, can't see other crew's commits).
- 3dfx Track A/B/C per the scope doc.
- V3 H3 Glide: 1/27, needs C89 header porting (GCC-extension headers).
- Struct-ptr fields at 4-byte offsets: latent codegen limitation.

---

## "200 chip" investigation (resolved)

Checked sysop/0's notes + full archive for a VSA-200 / "200 chip". Finding:
**no such chip exists.** VSA-100 (Napalm) is the whole Voodoo 4/5 line
(Napalm databook Rev 1.12). "200" hits were voodoo3 2000AGP etc.

Two REAL future items surfaced instead, both kept separate from shipping
VSA-100 work (see 3DFX-V5-DOS-BUILD-PLAN.md):
**CORRECTED after specs search + finding sysop/0's emu code:**

The "200 chip" IS REAL: **Rampage = VSA-200**, 3dfx's unreleased next-gen
chip (prototypes ran Quake 3 days before 3dfx died). It paired with a
separate **Sage** T&L unit (Spectre 1000/2000/3000/4000 boards). User's
model is correct:
- VSA-100 ("100") = rasterizer, NO hardware T&L (the missing feature).
- Rampage ("200") = designed with T&L built in (via Sage).
- VSA-100 needs an external T&L "companion/campaign" chip to match it.

No Rampage source anywhere (pre-production). Device ID 0x000B "Napalm2
(unreleased)" from AmigaMerlin INF = ID only, detection stub at most.

**How we deliver T&L for the 100 — sysop/0 ALREADY wrote it:**
- `src/emulate/emu_d3d7_tl.c` (GPLv3, sysop/0): CPU emulation of GeForce
  256-style HW T&L — 4x4 transform, 8 lights, Blinn-Phong specular, fog,
  texgen, multi-chip dispatch. Feeds pre-transformed vertices to VSA-100.
- `emu_vs11.c`: Vertex Shader 1.1 emu. Both in the passing 39/39
  (test_emu_tl.c).
- `spinalvoodoo1-spinalhdl.zip` + FPGA-companion proposal = the HARDWARE
  version of the same math (future, hardware-track).

**Bob's actual T&L task (D-TL-1, buildable now):** integrate emu_d3d7_tl +
emu_vs11 as the software T&L front-end to the DOS Glide driver, build with
wcc386, extend harness for a transformed/lit triangle. Gives the 100 its
missing D3D7 T&L / VS1.1 in software, no new hardware. The emu C is also
the executable spec for the future FPGA/companion HDL.

**D-TL-1 first concrete finding (spot-checked this session):**
emu_d3d7_tl.c compiles with wcc386 EXCEPT for C99 non-constant array
initializers, e.g. line 362:
  float objPos[4] = { in[vertIndex].x, in[vertIndex].y, ... };
Watcom C89 requires constant initializers -> "E1054: Expression must be
constant". Fix = split into declaration + runtime assignment. This is the
SAME class as the V3 H3 Glide 1/27 issue (C89 vs GCC/C99 extensions), and
it's squarely a bob compiler task. Low-risk, mechanical port.

## VSA-101 "Daytona" + thermal (added)

**VSA-101** (verified from specs): a 0.18 µm die-shrink of the VSA-100
(which was 0.25 µm), ~200 MHz, 64-bit DDR, codename Daytona. A few shipped.
NOT Rampage — period naming confused the two ("VSA-200" got applied to
both); Daytona = process shrink of the 100, Rampage = true next-gen w/
Sage T&L. **Same PCI device ID 0x0009 → drives as a VSA-100, no separate
driver code.** Differences are physical (process/clock/DDR/thermal), not programmable.
CONFIRMED: the 101 does exactly TWO things over the 100 — die shrink
(0.25->0.18 µm) + 128-bit SDR->64-bit DDR. No new features, no T&L, no new
API. Higher clock is just a consequence of the shrink. Software-identical
to VSA-100. Covered by the existing 0x0009 path; only BIOS clock/DDR
tables differ.

**Thermal — real constraint for 2/4/8 chips.** Heat scales ~linearly;
VSA-100 already runs hot. 1 chip ~15-20W, 2 ~40W, 4 ~80W (exceeds 75W PCIe
slot → external Molex on V5 6000), 8 ~160W (dedicated supply). Archive's
V6K-4 already plans: Molex detection, 2-chip fallback if no ext power,
thermal throttling. PLL clock drifts with temp (arch doc) → hotter = more
sync drift between chips (couples to V6K-5 sync). VSA-101's shrink was the
historical fix (cooler per chip = more chips viable).

**Bob's thermal task (D-THERM-1, folds into D2/D3):** driver detects
available power/chip health, falls back to fewer chips if budget not met,
respects throttle signal — never blindly light all N chips. Cooling/power
HARDWARE design is not bob's lane (verta1878 + hardware).

## THE crew target: Voodoo 5 6500 "Ultra" on Tang 60K (ZXC64)

Our own card, not a historical 3dfx part:
- **Tang 60K** = Gowin GW5AT-60K FPGA board hosting the replica (the
  "Strange God/ZXC64 hardware" the archive's V6K phases defer to).
- **Voodoo 5 6500 Ultra** = a step BEYOND the never-shipped 4-chip V5 6000.
- **"200+"** = the on-FPGA chip is Rampage-class (VSA-200) OR BETTER:
  VSA-100/101 Glide compatibility PLUS integrated hardware T&L (Sage folded
  into the core, not a separate companion chip).
- "dot" = dotmatrix (naming wink).

Driver design consequence — ONE vertex API, two backends:
- On real VSA-100/101 (no T&L): use sysop/0's CPU emu (emu_d3d7_tl.c).
- On the 6500 Ultra (integrated T&L): DMA to the FPGA T&L unit.
- Same Glide/driver code (0x0009 compat path) runs on both.
The "third chip/companion" question resolves: on OUR card T&L is
integrated (200+), so no companion needed; the CPU emu covers legacy 100
silicon that lacks it.

Lane split: bob = driver/Glide/emu software (compat path + vertex API w/
CPU-emu & FPGA-T&L backends, DOS-first). Hardware track (verta1878 + HDL
crew) = the Tang 60K FPGA, the Rampage-class T&L HDL core, thermal/power.

## Tang 60K = one V5-class card presenting V1-V5, DOS first (current work)

verta1878: Tang 60K is a SINGLE V5-class emu video card that answers the
whole Voodoo 1-5 range (the 6500 Ultra / 200+). Not five cards — one card,
multiple presented identities. Start with DOS.

**Big find: the archive's `src/glide-sezero/glide3x/Makefile.wat` is an
"DOS / OpenWatcom makefile"** and builds for ALL the ASICs the Tang card
presents via FX_GLIDE_HW:
- sst1  = Voodoo1
- cvg   = Voodoo2
- h3    = Banshee
- h5    = Voodoo3/4/5 (H4=1 = Napalm/VSA-100 high-speed)
One makefile, all generations, Watcom+DOS = exactly bob's toolchain.

**DOS build order (native-first for a V5 card):**
1. Glide3x / h5 (H4=1) = VSA-100 native (V3-V5). START HERE - already
   builds 24/24, harness 8/8 (re-verified this session). Card's real
   identity.
2. Glide2x/3x sst1 = V1 presentation.
3. cvg = V2 presentation (+SLI).
4. h3 = Banshee (C89 header work).
Then D-TL-1 (sysop/0 emu) layers onto the h5 path.

**Verified this session:** DOS Glide3x native path still 8/8 under DOSBox
(version 3.01.0001 / 3Dfx / Glide / Voodoo Graphics). Step 1 baseline is
solid.

**Immediate next:** drive glide3x/Makefile.wat with r0.6.0 wcc386 for
FX_GLIDE_HW=h5 H4=1; compare output to the hand-built lib; that's the
card's native DOS driver build via the archive's own makefile.

## Corrected architecture (verta1878) — cards + companion + hw/emu dispatch

- **V1-V5 are REAL SEPARATE video cards** (not identities of one card).
- **Tang 60K = emulated Voodoo 5 6500 TV Ultra** — video card WITH TV tuner
  (tv-tuner/linux-driver has source, not just the app shell).
- **Companion ("campaign") chip** adds HW: D3D, OpenGL, updated Glide, T&L.
- **Any V1-V5 card can be built/upgraded with 200-class (Rampage) chips**
  as companion; driver MUST support+detect that config.

**Driver spine = capability dispatch (D-CAP-1, bob to build):**
one API, per-card backend:
- original card (no HW feature) -> SOFTWARE EMU (sysop/0 emu_d3d7_tl/vs11)
- companion/200+/Tang present  -> HARDWARE PATH (DMA to companion T&L/D3D/GL)
Same Glide/driver ABI both ways. Archive has emu + EMU_DISPATCH_* concept
but NOT a formal hw-present probe -> bob adds: chip ID + companion detect +
feature bits + per-call routing.

**Hardware bug rule (verta1878): note every hw bug, add workaround if
possible, flag if none.** Formalized as HARDWARE-ERRATA.md (seeded, 9
entries) from src/fixes/* (already a numbered registry: 023 tnldp2 crash,
026 crash recovery, 028 dual-card) + known history (Rampage flipped-DAC ->
HDL fix; TACO FIFO hack; PLL temp drift; 4-chip thermal).

**Phases updated:** D-CAP-1 (dispatch spine, foundational) -> D-TL-1 (emu
backend) + D-HW-1 (companion hw backend) route through it. ERRATA
continuous. DOS-first / native-Glide3x-first order unchanged.

## Phase test suite (5-11) + stale-object bug fix — this session

Started Phases 6-11 work by first building the PHASE TEST FRAMEWORK
(tests/x64/run_phase_tests.sh) — checks each phase's observable ELF output
(section presence, flags, ABI) via readelf, skips cleanly for unimplemented
phases.

**It immediately earned its keep** — caught a segfault the 61/61 suite
never could:
- 6-arg call at DEFAULT opt (no flags) segfaulted; -ox/-od/-s all fine.
  The suite always uses -ox -s or -od, never bare default → coverage gap.
- Root cause (objdump, measure-three-times): default opt emits stack-check
  prologue `push $size; call __CHK`. __CHK must `ret $8` to pop the size,
  but the committed crt0_x64.o was STALE (older __CHK did bare `ret`). Stack
  left 8 bytes off → return to garbage → segfault.
- Also: committed .o had 4 stubs (__GRO/__STK/__CHP/__init_387_emulator)
  MISSING from crt0_x64.S — inconsistent source/object. __GRO also needs
  `ret $8` (RT_GROW pushes its arg too).

**Fixes (committed ceb15b0d on merge-wcc64-glide):**
- crt0_x64.S: added the 4 missing stubs; __GRO does `ret $8`.
- run_tests.sh: now assembles runtime .o from .S when source is newer —
  stale-object bug class can NEVER recur.
- run_phase_tests.sh: the new Phase 5-11 suite.
Verified: 61/61 + phase 4/4 (7 skip = phases 6-11 pending).

**Phase status now:** 5 DONE (+ now properly tested at all opt levels).
6/7/8/9/10/11 still to implement. Phase 7 (.rodata) is the cleanest next —
x64obj.c already routes CONST segments; add a .rodata section (SHF_ALLOC,
no WRITE). Phase 6 (.eh_frame) next. Test scaffolding for all is in place.

## REPO REFRESH — renamed to ow2irc, phases 6-11 materialized (verta1878)

Repo renamed openwatcom2irc -> **ow2irc** (shortened). Old clones
(openwatcomirc, gh-ow2irc, openwatcom2irc) DELETED per instruction. Fresh
clone: https://github.com/verta1878/ow2irc @ b02b7a9b (r0.6.0 refresh).

**This is a big integration by verta1878.** Commit b02b7a9b:
- **My work is IN it:** "Bob's 6 x64obj.c SET64 fixes applied"; crt0 stubs
  (13 refs), phase test suite, run_tests auto-rebuild all survived.
- **Phases 6-11 now materialized as dedicated source files:**
  - x64ehframe.c    -> Phase 6 (.eh_frame DWARF)
  - x64rodata.c     -> Phase 7 (.rodata)
  - x64win64.c/x64pe.c -> Phase 8 (Win64 ABI + PE32+ COFF)
  - x64seh.c        -> Phase 9 (SEH / DWARF exceptions)
  - x64asm.c        -> Phase 10 (assembler path)
  - x64clib.c       -> Phase 11 (musl-ow libc, per commit: 95K lines MIT,
    static hello 18KB)
  - x64c99compat.c  -> the C99 non-const-initializer compat (the class I
    flagged for the emu port)
- **MASM in wasm:** full MASM port, no JWasm dependency. asminvoke.c (268),
  asmoption.c (OPTION NOKEYWORD), asmrecord.c (RECORD/UNION/TYPEDEF/PROTO/
  INVOKE). 626 lines. Commit says 9/9 MASM tests pass.
- Commit claims: 133 tests 0 failures, self-hosted with OW1 (no GCC),
  LP64, REX.W, SysV+Win64 ABI, musl-ow libc, Itanium mangling, DWARF
  exceptions. Build wiring complete (target64.h TARGET_POINTER=8, etc).

**NOT yet independently verified by bob:** the 133/0 and 9/9 counts are
from the commit message; repo is source-only (no prebuilt bwcc64), so I
have not rebuilt + rerun the suites myself this session. Next session:
build bwcc64 from b02b7a9b and re-run tests/x64/run_tests.sh +
run_phase_tests.sh to confirm the phase suite now PASSES (not skips) 6/7/
8/9/11, and the 133-test claim.

**Repo hygiene done:** deleted old openwatcom2irc/openwatcomirc/gh-ow2irc
clones; single clone at /home/claude/ow2irc @ b02b7a9b, clean tree.

*bob — compiler + 3dfx · the crew 4free*
