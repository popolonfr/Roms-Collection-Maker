@ECHO OFF

IF NOT EXIST ".\Build\EditThisList.asm" CALL "1- Build the List.bat" && @ECHO OFF
IF %ERRORLEVEL% NEQ 0 EXIT

SET PATH=%PATH%.\zasm;
ZASM -w "RCM Menu.asm" "RCM Menu.bin"
COPY /b "RCM Menu.bin"+".\Roms\*.rom" ".\Build\LoadThis.rom"

REM DEL "RCM Menu.lst"
DEL "RCM Menu.bin"

PAUSE
@ECHO ON