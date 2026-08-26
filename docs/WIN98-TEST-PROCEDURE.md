# FOSSIL VxD — Win98 Load-Test Procedure

_Crew: wrench (test), dotmatrix (recovery)_
_Date: 2026-08-25_

## Requirements
- Windows 98 SE (real hardware or VMware/VirtualBox)
- FOSSIL.VXD from verified/ directory
- Terminal program (HyperTerminal, Telix, or BBS client)
- COM port (real or virtual) OR null modem cable + second PC

## Step 1: Copy VxD to System Directory
```
copy FOSSIL.VXD C:\WINDOWS\SYSTEM
```

## Step 2: Add to SYSTEM.INI
Edit C:\WINDOWS\SYSTEM.INI, add under [386Enh]:
```
[386Enh]
device=FOSSIL.VXD
```

## Step 3: Reboot
Restart Windows 98. Check for:
- Boot completes without errors → VxD loaded
- Blue screen → VxD init failed (check DDB)
- No message → VxD loaded silently (expected)

## Step 4: Verify INT 14h Hook
Run a FOSSIL-aware program (any BBS door or terminal):
```
C:\> FOSTEST.EXE
```
Expected: FOSSIL driver responds with signature 1954h.
If FOSTEST not available, run DEBUG:
```
C:\> DEBUG
-A 100
MOV AH,04
MOV DX,00
INT 14
INT 20
-G=100
```
AX should contain 1954h (FOSSIL active) after INT 14h AH=04.

## Step 5: Loopback Test
Connect COM1 to COM2 with null modem cable (or use virtual ports):
1. Open HyperTerminal on COM1
2. Open second HyperTerminal on COM2
3. Type on COM1 → should appear on COM2
4. Type on COM2 → should appear on COM1

## Step 6: BBS Test
Run PCBoard or Mystic BBS in local mode:
```
C:\PCBOARD\PCBOARD.EXE /LOCAL
```
If BBS starts and accepts input → FOSSIL driver works.

## Pass Criteria
- [x] Win98 boots with VxD loaded
- [x] INT 14h returns 1954h signature
- [x] Character TX/RX through FOSSIL API
- [x] BBS software runs in local mode

## Fail Criteria
- Blue screen on boot → DDB or init code error
- INT 14h returns 0 → VxD didn't hook interrupt
- TX works but RX doesn't → IRQ/buffer issue
- BBS hangs → FOSSIL flow control bug
