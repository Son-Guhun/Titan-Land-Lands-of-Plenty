@echo off
cd %~dp0
cd ../_tests

set PJASS=pjass.exe
set COMMON="..\..\..\development\scripts\common.j"
set BLIZZARD="..\..\..\development\scripts\blizzard.j"
set SCRIPT=%1

Rem set /p SCRIPT="Enter script path: "
Rem set SCRIPT="%SCRIPT%"

%PJASS% %COMMON% %BLIZZARD% %SCRIPT%
pause