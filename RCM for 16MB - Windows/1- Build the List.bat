@ECHO OFF

SETLOCAL
SETLOCAL ENABLEDELAYEDEXPANSION

REM ---------------------------------------------------------
REM 0: Keeps the ROM file name
REM 1: Changes the file name to the one found in the database
REM 2: Same as above, but takes the second name

SET /A "nameSelectionMode=0"

REM ---------------------------------------------------------

SET "romDatabase=.\Rom database.txt"
SET "location=.\Roms\"
SET "target=.\Build\EditThisList"
SET "bank=2"
SET "maxfile=0"
SET "count=0"
SET "empty=                                      \"leave as is\""
SET "fbank[!count!]=   !bank!"

IF EXIST ".\Build\Work in progress.tmp" (EXIT 1) ELSE (ECHO Prevent double-click>>".\Build\Work in progress.tmp")

REM -----------------------------------
REM To get the information of each file
REM -----------------------------------

FOR /R %%i IN (!location!*.rom) DO (
	FOR /F "tokens=*" %%h IN ('certutil -hashfile "%%i" SHA1 ^| FINDSTR /v "hash" ^| FINDSTR /v "CertUtil"') DO (
		SET "sha1[!count!]=%%h"
	)
	SET "fname[!count!]=%%~ni"
	SET /A "MSXType[!count!]=0"
	SET /A "fsize[!count!]= %%~zi / 8192"
	SET /A "maxfile=!maxfile!+1"
	SET /A "count=!count!+1"
	SET /A "step= %%~zi / 8192"
	SET /A "bank=!bank!+!step!"
	SET "fbank[!count!]=    !bank!"
)

REM -----------------------------------
REM To apply patches based on checksums
REM -----------------------------------

IF EXIST "Patched.log" (DEL "Patched.log")
SET /A "count=!count!-1"
SET "patchesDir=Patches"
CALL :APPLYPATCH ".\!patchesDir!\For Megaroms to SCC Mapper with offset Register"
CALL :APPLYPATCH ".\!patchesDir!\For Roms"

REM ------------------------------------------------------
REM Search the database for the original name of the games
REM ------------------------------------------------------

SET /A "groupLineNumber=0"
SET /A "brackets=0"
SET "content[0]="
SET "content[1]="
SET "group="
SET "processingGroups=0"

FOR /f "usebackq delims=" %%b IN ("!romDatabase!") DO (
	SET "groupLine[!groupLineNumber!]=%%b"
	SET /A "groupLineNumber+=1"
	IF "!groupLineNumber!" == "4" (
		FOR /L %%c IN (0, 1, !count!) DO (
    			SET "currentSha1=!sha1[%%c]!"
			IF "!currentSha1!"=="!groupLine[1]!" (
				IF "!nameSelectionMode!" GTR "0" (
					SET /A "nameType=0"
					FOR %%d IN (!groupLine[0]!) DO (
						SET "character=%%d"
						IF "%%d" == "-" (SET /A "nameType=1")
						IF "%%d" NEQ "-" (
							IF "!character:~0,1!" == "[" (SET /A "brackets=1")
							IF "!brackets!" == "0" (
								IF "!nameType!" == "0" (SET "content[0]=!content[0]! %%d")
								IF "!nameType!" == "1" (SET "content[1]=!content[1]! %%d")
							)
							IF "!brackets!" == "1" (
								SET "content[0]=!content[0]! %%d"
								SET "content[1]=!content[1]! %%d"
							)
							IF "!character:~1!" == "]" (SET /A "brackets=0")
						)
					)
					IF "!nameSelectionMode!"=="1" (SET /A "nameType=0")
					IF "!nameType!"=="0" (SET "name=!!content[0]!")
					IF "!nameType!"=="1" (SET "name=!!content[1]!")
					SET "fname[%%c]=!name!"
					SET /A "brackets=0"
					SET "content[0]="
					SET "content[1]="
				)
				IF "!groupLine[3]!"=="1" (
					SET /A "groupLine[2]+=32"
				)
				SET "groupLine[2]=  !groupLine[2]!"
				SET "MSXType[%%c]=!groupLine[2]:~-3!"
				ECHO !fname[%%c]!
			)
		)
		SET /A "groupLineNumber=0"
	)
)

REM ----------------------------
REM To generate the list of Roms
REM ----------------------------

IF %bank% GTR 2047 (ECHO ROMs exceeds 16384KB. Can not continue^^! && ECHO. && PAUSE && GOTO :STOP)
IF %maxfile% EQU 0 (ECHO File not found^^! && ECHO. && PAUSE && GOTO :STOP)
IF EXIST "!target!.asm" (DEL !target!.asm)

COPY ".\Sources\Menu\Data.asm" "!target!.asm"

SET /A "maxfile=!maxfile!-1"
SET /A "MSXType[!maxfile!]+=128"
rem SET "maxlist=  0"

FOR /L %%n IN (0,1,!maxfile!) DO (
	SET /A "type=MSXType[%%n]"
        FINDSTR /m /c:"Offset		equ	1	" ".\Sources\Menu\RCM Menu.asm" >nul
       	IF !errorlevel! == 0 (
		IF !sha1[%%n]! EQU d08d4e2a8d92c01551ff012a71a1f3e57fe2d09c (
			IF "!type!" GEQ "128" (SET MSXType[%%n]=161)
			IF "!type!" LSS "128" (SET MSXType[%%n]= 33)
		)
		IF !sha1[%%n]! EQU 2feff37d593683ce1c7dfac33ed3207895e01a03 (
			IF "!type!" GEQ "128" (SET MSXType[%%n]=160)
			IF "!type!" LSS "128" (SET MSXType[%%n]= 32)
		)
	)
	SET "sname=!fname[%%n]!!empty!"
	SET /A "L=    !fbank[%%n]!&255"
	SET /A "H=    !fbank[%%n]!>>8"
	SET "L=   !L!"
	SET "H=   !H!"
	ECHO 	db	!L:~-3!, !H:~-3!, !MSXType[%%n]!, "  !sname:~0,38!">> !target!.asm
	SET maxlist=  0
)
SET /A ebank=fbank[!maxfile!]+!step!
SET /A "L=    !ebank!&255"
SET /A "H=    !ebank!>>8"
SET "L=   !L!"
SET "H=   !H!"
ECHO 	db	!L:~-3!, !H:~-3!, 255, "                                        " ; Do not modify this line>> !target!.asm 

:STOP
IF EXIST "Patched.log" (DEL "Patched.log")
DEL ".\Build\Work in progress.tmp"
ENDLOCAL
@ECHO ON
GOTO :EOF

REM ------------
REM Sub-function
REM ------------

:APPLYPATCH
FOR /L %%j IN (0, 1, !count!) DO (
    	SET "currentSha1=!sha1[%%j]!"
	SET "sourceFile=!location!!fname[%%j]!.rom"
	SET "targetFile=!location!!fname[%%j]!.bin"
	FOR /R %1 %%k IN (*.txt) DO (
        	FINDSTR /m /c:"sha1=!currentSha1!" "%%k" >nul
          	IF !errorlevel! == 0 (
            		SET "patchFile=%%~dpnk.ips"
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
EXIT /B
