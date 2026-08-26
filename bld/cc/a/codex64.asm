; codex64.asm — x86-64 inline intrinsic table (stub)
; No intrinsics — compiler uses library calls.
; GPLv3 — the crew 4free — sysop/0 + bob

.386p
.MODEL FLAT
.DATA

public _Functions
_Functions:
        dd      0       ; null terminator — empty function table

end
