@ECHO OFF

IF NOT EXIST ".\Build\EditThisList.asm" CALL "1- Build the List.bat" && @ECHO OFF
IF %ERRORLEVEL% NEQ 0 EXIT

IF EXIST ".\Zasm\ZASM.EXE" (
	.\Zasm\ZASM -w "RCM Menu.asm" "RCM Menu.bin"
) else (
	ZASM -w "RCM Menu.asm" "RCM Menu.bin"
)

COPY /b "RCM Menu.bin"+".\Roms\*.rom" ".\Build\LoadThis.rom"

DEL "RCM Menu.lst"
DEL "RCM Menu.bin"

PAUSE
@ECHO ON