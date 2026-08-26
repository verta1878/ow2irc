@echo off
rem ============================================================================
rem  cleanup-ow2irc.bat — Remove unused OW2IRC directories
rem  Saves ~36 MB. Safe to run from OW2IRC root.
rem
rem  Output: CLEANUP.LOG in repo root
rem
rem  DO NOT delete: bld\cc, bld\plusplus, bld\cg, bld\wasm,
rem  bld\wl, bld\owl, bld\clib, bld\mathlib, bld\hdr,
rem  bld\watcom, bld\wmake, bld\wrc, *.awk
rem
rem  the crew 4free — sysop/0
rem  Date: 2026-08-25
rem ============================================================================

if not exist bld\cc (
    echo ERROR: Run this from the OW2IRC repo root.
    echo        bld\cc not found — wrong directory.
    pause
    goto :EOF
)

set LOGFILE=CLEANUP.LOG
echo OW2IRC cleanup > %LOGFILE%
echo Date: %DATE% %TIME% >> %LOGFILE%
echo. >> %LOGFILE%
set ERRORS=0
set REMOVED=0
set SKIPPED=0

rem --- contrib (16 MB) — third-party contributed tools ---
if exist contrib (
    echo  Removing contrib\...
    rmdir /s /q contrib
    if not exist contrib (
        echo OK: Removed contrib\ (16 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove contrib\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: contrib\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- distrib (2 MB) — distribution packaging scripts ---
if exist distrib (
    echo  Removing distrib\...
    rmdir /s /q distrib
    if not exist distrib (
        echo OK: Removed distrib\ (2 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove distrib\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: distrib\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\browser (3.6 MB) — source code browser IDE ---
if exist bld\browser (
    echo  Removing bld\browser\...
    rmdir /s /q bld\browser
    if not exist bld\browser (
        echo OK: Removed bld\browser\ (3.6 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\browser\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\browser\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\ide (2 MB) — Watcom IDE for Windows ---
if exist bld\ide (
    echo  Removing bld\ide\...
    rmdir /s /q bld\ide
    if not exist bld\ide (
        echo OK: Removed bld\ide\ (2 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\ide\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\ide\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\gui (2.8 MB) — GUI framework for IDE ---
if exist bld\gui (
    echo  Removing bld\gui\...
    rmdir /s /q bld\gui
    if not exist bld\gui (
        echo OK: Removed bld\gui\ (2.8 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\gui\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\gui\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\wclass (1.1 MB) — GUI class library (IDE only) ---
if exist bld\wclass (
    echo  Removing bld\wclass\...
    rmdir /s /q bld\wclass
    if not exist bld\wclass (
        echo OK: Removed bld\wclass\ (1.1 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\wclass\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\wclass\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\aui (1.1 MB) — Advanced UI library (IDE only) ---
if exist bld\aui (
    echo  Removing bld\aui\...
    rmdir /s /q bld\aui
    if not exist bld\aui (
        echo OK: Removed bld\aui\ (1.1 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\aui\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\aui\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\vi (4.6 MB) — VI editor clone ---
if exist bld\vi (
    echo  Removing bld\vi\...
    rmdir /s /q bld\vi
    if not exist bld\vi (
        echo OK: Removed bld\vi\ (4.6 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\vi\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\vi\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\fe_misc (960 KB) — miscellaneous FE tools ---
if exist bld\fe_misc (
    echo  Removing bld\fe_misc\...
    rmdir /s /q bld\fe_misc
    if not exist bld\fe_misc (
        echo OK: Removed bld\fe_misc\ (960 KB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\fe_misc\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\fe_misc\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\bdiff (316 KB) — binary diff tool ---
if exist bld\bdiff (
    echo  Removing bld\bdiff\...
    rmdir /s /q bld\bdiff
    if not exist bld\bdiff (
        echo OK: Removed bld\bdiff\ (316 KB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\bdiff\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\bdiff\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\wdisasm (512 KB) — old disassembler ---
if exist bld\wdisasm (
    echo  Removing bld\wdisasm\...
    rmdir /s /q bld\wdisasm
    if not exist bld\wdisasm (
        echo OK: Removed bld\wdisasm\ (512 KB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\wdisasm\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\wdisasm\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\bench (1.3 MB) — benchmarks ---
if exist bld\bench (
    echo  Removing bld\bench\...
    rmdir /s /q bld\bench
    if not exist bld\bench (
        echo OK: Removed bld\bench\ (1.3 MB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\bench\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\bench\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- bld\bmp2eps (200 KB) — bitmap to EPS converter ---
if exist bld\bmp2eps (
    echo  Removing bld\bmp2eps\...
    rmdir /s /q bld\bmp2eps
    if not exist bld\bmp2eps (
        echo OK: Removed bld\bmp2eps\ (200 KB) >> %LOGFILE%
        set /a REMOVED+=1
    ) else (
        echo FAIL: Could not remove bld\bmp2eps\ >> %LOGFILE%
        set /a ERRORS+=1
    )
) else (
    echo SKIP: bld\bmp2eps\ not found >> %LOGFILE%
    set /a SKIPPED+=1
)

rem --- Verification: core dirs must still exist ---
echo. >> %LOGFILE%
echo === VERIFICATION === >> %LOGFILE%
set MISSING=0
for %%D in (bld\cc bld\plusplus bld\cg bld\wasm bld\wl bld\owl bld\clib bld\mathlib bld\hdr bld\watcom bld\wmake bld\wrc) do (
    if exist %%D (
        echo FOUND: %%D >> %LOGFILE%
    ) else (
        echo MISSING: %%D >> %LOGFILE%
        set /a MISSING+=1
    )
)

echo. >> %LOGFILE%
echo === SUMMARY === >> %LOGFILE%
echo Removed: %REMOVED% directories >> %LOGFILE%
echo Skipped: %SKIPPED% (already gone) >> %LOGFILE%
echo Errors:  %ERRORS% >> %LOGFILE%
echo Missing core dirs: %MISSING% >> %LOGFILE%
echo. >> %LOGFILE%

rem --- Display result ---
echo.
echo  Cleanup complete.
echo  Removed: %REMOVED%  Skipped: %SKIPPED%  Errors: %ERRORS%
echo  See %LOGFILE% for details.
echo.
if %ERRORS% GTR 0 (
    echo  ** ERRORS FOUND — check %LOGFILE% **
    echo.
)
if %MISSING% GTR 0 (
    echo  ** CORE DIRECTORIES MISSING — check %LOGFILE% **
    echo.
)
type %LOGFILE%
pause
