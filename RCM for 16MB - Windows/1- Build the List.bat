@ECHO OFF

SETLOCAL
SETLOCAL EnableDelayedExpansion
SET location=.\Roms\
SET target=.\Build\EditThisList
SET bank=2
SET maxfile=0
SET count=0
SET empty=                                      "leave as is"
SET fbank[!count!]=   !bank!

IF EXIST ".\Build\Work in progress.tmp" (EXIT 1) ELSE (ECHO Prevent double-click>>".\Build\Work in progress.tmp")

FOR /R %%i IN (!location!*.rom) DO (
	SET fname[!count!]=%%~ni!empty!
	SET /A fsize[!count!]= %%~zi / 8192
	SET /A maxfile=!maxfile!+1
	SET /A count=!count!+1
	SET /A step= %%~zi / 8192
	SET /A bank=!bank!+!step!
	SET fbank[!count!]=    !bank!
)

IF %bank% GTR 2047 (ECHO ROMs exceeds 2032KB. Can not continue^^! && ECHO. && PAUSE && GOTO :STOP)
IF %maxfile% EQU 0 (ECHO File not found^^! && ECHO. && PAUSE && GOTO :STOP)
IF EXIST "!target!.asm" (DEL !target!.asm)

COPY Data !target!.asm

SET /A maxfile=!maxfile!-1
SET maxlist=  0

FOR /l %%n IN (0,1,!maxfile!) DO (
	IF %maxfile% EQU %%n (SET maxlist=128)
	SET /A "L=    !fbank[%%n]!&255"
	SET /A "H=    !fbank[%%n]!>>8"
	SET L=   !L!
	SET H=   !H!
	ECHO 	db	!L:~-3!, !H:~-3!, !maxlist!, "  !fname[%%n]:~0,38!">> !target!.asm
)
	SET /A ebank=fbank[!maxfile!]+!step!
	SET /A "L=    !ebank!&255"
	SET /A "H=    !ebank!>>8"
	SET L=   !L!
	SET H=   !H!
	ECHO 	db	!L:~-3!, !H:~-3!, 255, "                                        " ; Do not modify this line>> !target!.asm 

:STOP
DEL ".\Build\Work in progress.tmp"
ENDLOCAL
@ECHO ON

