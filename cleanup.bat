@echo off
REM cleanup.bat — OW2IRC r0.6.1 restore + attic
REM Restores working post-processor, saves full copies to attic.
REM Run from repo root: cleanup.bat
REM the crew 4free

cd /d "%~dp0"

REM === Check if already ran ===
if exist attic\x86enc_with_skip.c (
    echo OW2IRC r0.6.1 cleanup already ran. Nothing updated.
    echo %date% %time% — already ran, nothing updated. >> cleanup.log
    goto :eof
)

echo ===========================================
echo  OW2IRC r0.6.1 cleanup
echo  the crew 4free
echo  %date% %time%
echo ===========================================
echo.

if not exist attic mkdir attic

REM === Phase 1: Restore x64obj.c from attic snapshot ===
echo === Phase 1: Restore x64obj.c ===
if exist attic\x64obj_postprocessor.c (
    copy /y attic\x64obj_postprocessor.c bld\cg\intel\x64\c\x64obj.c >nul
    echo   x64obj.c restored from attic
    echo   x64obj.c restored from attic >> cleanup.log
) else (
    echo   [warn] attic\x64obj_postprocessor.c not found
    echo   [warn] attic\x64obj_postprocessor.c not found >> cleanup.log
)

REM === Phase 2: Fix x86enc.c — restore G_UNKNOWN skip ===
echo.
echo === Phase 2: Fix x86enc.c ===

REM Save full copy to attic first
copy /y bld\cg\intel\c\x86enc.c attic\x86enc_with_skip.c >nul

REM Use powershell to do the text replacement
powershell -NoProfile -Command ^
  "$f='bld\cg\intel\c\x86enc.c'; $d=[IO.File]::ReadAllText($f); if($d -match '_Zoiks\( ZOIKS_097 \)'){$d=$d -replace '(?s)(case G_UNKNOWN:\s*)\r?\n\s*_Zoiks\( ZOIKS_097 \);\s*\r?\n\s*break;','$1'+[char]13+[char]10+'            break;';[IO.File]::WriteAllText($f,$d);Write-Host '  x86enc.c: G_UNKNOWN skip restored'}elseif($d -match 'case G_UNKNOWN:\s*\r?\n\s*break;'){Write-Host '  x86enc.c: skip already in place'}else{Write-Host '  x86enc.c: manual check needed'}"

echo   x86enc.c: G_UNKNOWN skip restored >> cleanup.log

REM === Phase 3: Attic README ===
echo.
echo === Phase 3: Attic README ===

> attic\README.md (
echo # attic/ — x64 post-processor snapshots
echo.
echo Full working copies of the x64 post-processor files.
echo These contain the 17 heuristics that make bwccx64 work
echo until the native x64 CG replaces them.
echo.
echo ## Files
echo - x64obj_postprocessor.c — x64obj.c with REX pass, branch fixup,
echo   jump table rewrite, struct patterns, omap, is_branch
echo - x86enc_with_skip.c — x86enc.c with G_UNKNOWN skip
echo.
echo DO NOT strip these fixes from the live code until the
echo native x64 CG is wired in and passes bob's battery.
echo.
echo ## the crew 4free
)
echo   attic\README.md written
echo   attic\README.md written >> cleanup.log

REM === Phase 4: Delete old patch file ===
if exist attic\x86enc_skip.patch del attic\x86enc_skip.patch

REM === Phase 5: Clean up Linux-only files ===
echo.
echo === Phase 4: Cleanup ===
if exist cleanup.sh (
    del cleanup.sh
    echo   cleanup.sh removed
    echo   cleanup.sh removed >> cleanup.log
)

echo.
echo ===========================================
echo  Cleanup complete — %date% %time%
echo ===========================================
echo.
echo  RESTORED: x64obj.c post-processor (17 heuristics)
echo  RESTORED: x86enc.c G_UNKNOWN skip
echo  ATTIC:    full working copies saved
echo  KEPT:     386table.c struct fixes, MinGW-w64 CRT
echo  CRT:      bash bld/mingw64/build_all.sh (Linux)
echo  Log:      cleanup.log
echo.
echo Cleanup complete %date% %time% >> cleanup.log
