@ECHO OFF
REM zasm %~n1.asm %~n1.cmp

IF NOT EXIST ".\Build\EditThisList.asm" (GOTO :EOF)

COPY /b .\Roms\*.rom .\Build\Roms.tmp
ZASM Data2 .\Build\Data.tmp
COPY /b Data1+.\Build\data.tmp+.\Build\Roms.tmp .\Build\LoadThis.rom
DEL *.lst
DEL .\Build\*.tmp

PAUSE
@ECHO ON
