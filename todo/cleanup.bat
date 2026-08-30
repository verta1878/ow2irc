@echo off
REM cleanup.bat — OW2IRC r0.6.0 to r0.6.1
REM Run from repo root: cleanup.bat
REM the crew 4free

cd /d "%~dp0"

REM === Check if already ran ===
if exist attic\x64obj_postprocessor.c (
    echo OW2IRC r0.6.1 cleanup already ran. Nothing updated.
    echo %date% %time% — already ran, nothing updated. >> cleanup.log
    goto :eof
)

REM === First run — log and execute ===
echo ===========================================>> cleanup.log
echo  OW2IRC r0.6.1 cleanup>> cleanup.log
echo  the crew 4free>> cleanup.log
echo  %date% %time%>> cleanup.log
echo ===========================================>> cleanup.log

echo ===========================================
echo  OW2IRC r0.6.1 cleanup
echo  the crew 4free
echo ===========================================
echo.

echo === Phase 1: Attic x64 post-processor ===
if not exist attic mkdir attic
copy /y bld\cg\intel\x64\c\x64obj.c attic\x64obj_postprocessor.c >nul
echo   x64obj.c snapshot saved
echo   x64obj.c snapshot saved>> cleanup.log
copy /y bld\cg\intel\c\x86enc.c attic\x86enc_with_skip.c >nul
echo   x86enc.c snapshot saved
echo   x86enc.c snapshot saved>> cleanup.log

echo.
echo === Phase 2: Cleanup ===
if exist cleanup.sh (
    del cleanup.sh
    echo   cleanup.sh removed
    echo   cleanup.sh removed>> cleanup.log
) else (
    echo   cleanup.sh not found, skipped
    echo   cleanup.sh not found, skipped>> cleanup.log
)

echo.
echo === Phase 3: Attic README ===
echo # attic/ — removed x64 post-processor code> attic\README.md
echo.>> attic\README.md
echo Post-processor heuristics from r0.6.0.>> attic\README.md
echo 17 hacks that patched 386 CG output for x64.>> attic\README.md
echo Worked but fragile. Replaced in r0.6.1.>> attic\README.md
echo.>> attic\README.md
echo ## Files>> attic\README.md
echo - x64obj_postprocessor.c — full x64obj.c with all 17 heuristics>> attic\README.md
echo - x86enc_with_skip.c — G_UNKNOWN skip version>> attic\README.md
echo.>> attic\README.md
echo ## the crew 4free>> attic\README.md
echo   attic\README.md written
echo   attic\README.md written>> cleanup.log

echo.
echo ===========================================
echo  Cleanup complete
echo ===========================================
echo  ATTIC: x64obj.c post-processor + x86enc.c skip
echo  KEPT:  386table.c struct fixes, build system, ELF64 writer
echo  CRT:   bash bld/mingw64/build_all.sh (Linux)
echo  Log:   cleanup.log
echo.
echo Cleanup complete %date% %time%>> cleanup.log
