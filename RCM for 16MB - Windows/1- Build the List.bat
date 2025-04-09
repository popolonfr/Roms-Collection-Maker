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

	FOR /F "tokens=*" %%h IN ('certutil -hashfile "%%i" SHA1 ^| FINDSTR /v "hash" ^| FINDSTR /v "CertUtil"') DO (
		SET sha1[!count!]=%%h
	)

	SET fname[!count!]=%%~ni
	SET /A fsize[!count!]= %%~zi / 8192
	SET /A maxfile=!maxfile!+1
	SET /A count=!count!+1
	SET /A step= %%~zi / 8192
	SET /A bank=!bank!+!step!
	SET fbank[!count!]=    !bank!
)

REM To apply patches based on checksums
IF EXIST "Patched.log" (DEL "Patched.log")

SET /A count=!count!-1
SET patchesDir=Patches

SET patch1Dir=".\%patchesDir%\For Megaroms to SCC Mapper with offset Register"
CALL :APPLYPATCH

SET patch1Dir=".\%patchesDir%\For Roms"
CALL :APPLYPATCH

IF %bank% GTR 2047 (ECHO ROMs exceeds 2032KB. Can not continue^^! && ECHO. && PAUSE && GOTO :STOP)
IF %maxfile% EQU 0 (ECHO File not found^^! && ECHO. && PAUSE && GOTO :STOP)
IF EXIST "!target!.asm" (DEL !target!.asm)

COPY Data !target!.asm

SET /A maxfile=!maxfile!-1
SET maxlist=  0

FOR /L %%n IN (0,1,!maxfile!) DO (
        FINDSTR /m /c:"Offset		equ	1	" "RCM Menu.asm" >nul
       	IF !errorlevel!==0 (
		IF !sha1[%%n]! EQU d08d4e2a8d92c01551ff012a71a1f3e57fe2d09c (SET maxlist= 32)
		IF !sha1[%%n]! EQU 2feff37d593683ce1c7dfac33ed3207895e01a03 (SET maxlist= 32)
	)
	IF %maxfile% EQU %%n (SET maxlist=128)
	SET sname=!fname[%%n]!!empty!
	SET /A "L=    !fbank[%%n]!&255"
	SET /A "H=    !fbank[%%n]!>>8"
	SET L=   !L!
	SET H=   !H!
	ECHO 	db	!L:~-3!, !H:~-3!, !maxlist!, "  !sname:~0,38!">> !target!.asm
	SET maxlist=  0
)

SET /A ebank=fbank[!maxfile!]+!step!
SET /A "L=    !ebank!&255"
SET /A "H=    !ebank!>>8"
SET L=   !L!
SET H=   !H!
ECHO 	db	!L:~-3!, !H:~-3!, 255, "                                        " ; Do not modify this line>> !target!.asm 

:STOP
IF EXIST "Patched.log" (DEL "Patched.log")
DEL ".\Build\Work in progress.tmp"
ENDLOCAL
@ECHO ON
GOTO :EOF

:APPLYPATCH
FOR /L %%j IN (0, 1, !count!) DO (
    	SET currentSha1=!sha1[%%j]!
	SET sourceFile=!location!!fname[%%j]!.rom
	SET targetFile=!location!!fname[%%j]!.bin

	FOR /R %patch1Dir% %%k IN (*.txt) DO (

        	FINDSTR /m /c:"sha1=!currentSha1!" "%%k" >nul
  
        	IF !errorlevel!==0 (
            	SET patchFile=%%~dpnk.ips
		ECHO Applying patch on "!fname[%%~nxj]:~0,80!"
		ECHO Applying patch on "!fname[%%~nxj]:~0,80!" >> "Patched.log"
		IPSPatcher "!sourceFile!" "!patchFile!" "!targetFile!" >> "Patched.log"

			IF EXIST "!targetFile!" (
				DEL "!sourceFile!"
				REN "!targetFile!" "!fname[%%j]!.rom"
			)
        	)
	)
)
GOTO :EOF