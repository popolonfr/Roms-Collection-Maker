
; Multi-ROM Menu v1.1 for SCC mapper by Popolon-fr
;
; Thanks to GDX for their contribution

; Main-ROM entries

BASRVN		equ	0002Bh
DISSCR		equ	00041h
ENASCR		equ	00044h
ENASLT		equ	00024h
FILVRM		equ	00056h
INITXT		equ	0006Ch				; Initialize the screen 0
INIT32		equ	0006Fh				; Initialize the screen 1
GTSTCK		equ	000D5h
GTTRIG		equ	000D8h
LDIRVM		equ	0005Ch
MSXVER		equ	0002Dh
RSLREG		equ	00138h
VDP_DR		equ	00006h
VDP_DW		equ	00007h
WRSLT		equ	00014h
WRTVDP		equ	00047h 
WRTVRM		equ	0004Dh

; System variables

BAKCLR		equ	0F3EAh				; Background color (screen 1)
BDRCLR		equ	0F3EBh				; Border color
FORCLR		equ	0F3E9h				; Text color
LINL40		equ	0F3AEh				; Width
TXTATR		equ	0F3B9h				; Character attributs table 
NEWKEY		equ	0FBE5h
EXPTBL		equ	0FCC1h
RG9SAV		equ	0FFE8h				; Current value of the register 9
VOICAQ		equ	0F975h				; Data voice 1 (used as buffer here)

; Hooks

H_STKE	equ	0FEDAh

; Program variables


RamBottom	equ	0E000h
PrgInRam	equ	RamBottom+10h			; Address of the program in RAM
CurrTopName	equ	PrgInRam+(MainPrgEnd-RomSel)	; Address of the first name of the list to display
VramPos		equ	CurrTopName+2			; Vram address to display the list
SettingBits	equ	VramPos+2			; Setting bits after the selected ROM
SegMum		equ	SettingBits+1			; First segment number of the selected ROM
NextSegMum	equ	SegMum+1			; Segment number after the selected ROM
RomSlot		equ	NextSegMum+1			; Slot number
CurrAdr		equ	RomSlot+1			; Data address of the selected ROM
RomSize		equ	CurrAdr+2			; Rom size in number of the segment
WidthName	equ	40
LineData	equ	42

Offset		equ	1				; 0 Without offset register
							; 1 Offset register (Flash Rom SCC Cartridge popolon-fr)
							; 2 Offset register (MFR SCC+ SD)
	if	Offset==1
OffsetReg	equ	03FF0h
	elif	Offset==2
OffsetReg	equ	07FFDh
	endif

	org	04000h

; Rom header

	db	41h,42h
	dw	Start
	ds	12,0

; Menu program

Start:
	push	af
	push	bc
	push	de
	push	hl

	ld	hl,BankSel
	ld	de,VOICAQ
	ld	bc,RamPrgEnd-BankSel
	ldir						; Copy the segments selection routine

	ld	hl,RomSel
	ld	de,PrgInRam
	ld	bc,MainPrgEnd-RomSel
	ldir						; Copy the Rom pages selection routine

	call	RSLREG
	rrca
	rrca
	and	3
	ld	c,a
	ld	b,0
	ld	hl,EXPTBL
	add	hl,bc
	ld	a,(hl)
	and	80h
	or	c
	ld	c,a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	0Ch
	or	c
	ld	(RomSlot),a				; Get the ROM slot number

	ld	hl,09000h
	ld	e,1
	call	WRSLT					; Select the segment 1 on the page 6000h-7FFFh

	ld	a,1
	ld	(07000h),a

	ld	a,1
	ld	(BAKCLR),a				; (Useless in screen 0)
	ld	(BDRCLR),a
	ld	a,15
	ld	(FORCLR),a				; Text color
	ld	a,WidthName
	ld	(LINL40),a				; Width 40
	call	INITXT					; Screen 0

;-- Tests if one Game only to execute it directly

	ld	hl,RomList+45				; Point to the second MSX generation value
	cp	255
	jp	z,RomExec				; Jump if MSX generation value of the second line is 255

	ld	hl,RomList+3				; Point to the first MSX generation value
	ld	de,42
NextMSXgen:
	ld	a,(hl)
	and	3					; Reset unused bits of the MSX generation value
	add	hl,de
	ld	b,a
	ld	a,(MSXVER)
	and	3					; Reset unused bits of MSXVER
	cp	b
	jr	c,NextMSXgen				; Jump if MSXVER < A

	add	hl,de
	cp	255
	jp	z,RomExec				; Jump if MSX generation value of the next line is 255
;--
	ld	hl,(TXTATR)
	ld	de,WidthName*0
	add	hl,de
	ex	hl,de					; Set the position at the line 0
	ld	hl,Title
	ld	bc,WidthName
	call	LDIRVM					; Print the title

	ld	hl,EmptyLine
	ld	a,(MSXVER)
	or	a
	jr	z,CurrFreq				; Jump if MSX1

	ld	a,(RG9SAV)
	and	2
	ld	hl,F1_50Hz
	jr	z,CurrFreq				; Jump if 60hz mode
	ld	hl,F1_60Hz
CurrFreq:
	call	PrintFreqOpt				; Print the 50/60hz option

	ld	hl,RomList
	ld	(CurrTopName),hl

MainLoop:
	ld	hl,(TXTATR)
	ld	de,WidthName*4				; Set the list position at the line 4
	add	hl,de
	ld	(VramPos),hl

	halt
	call	PrintList				; Print the Roms list

; Keyboard tests

	ld	a,(NEWKEY+8)				; Row 8
	and	40h
	call	z,MoveDown				; Call if Down key is pressed

	ld	a,(NEWKEY+8)				; Row 8
	and	20h
	call	z,MoveUp				; Call if Up key is pressed

	ld	a,(NEWKEY+8)				; Row 8
	and	1
	jr	z,RomExec				; Jump if Space key is pressed

	ld	a,(NEWKEY+6)				; Row 6
	and	20h
	call	z,FreqToggle				; Call if F1 key is pressed

; Joystick tests

	ld	a,1
	call	GTSTCK					; Test the joystick 1
	cp	1
	call	z,MoveUp				; Jump if Up is pressed

	ld	a,1
	call	GTSTCK					; Test the joystick 1
	cp	5
	call	z,MoveDown				; Jump if Down is pressed

	ld	a,1
	call	GTTRIG					; Test the button 1 of the joystick 1
	or	a
	jr	nz,RomExec				; Jump if button 1 of the joystick 1 is pressed

	ld	a,3
	call	GTTRIG					; Test the button 2 of the joystick 1
	or	a
	call	nz,FreqTogglJ				; Jump if button 2 of the joystick 1 is pressed

	jr	MainLoop

FreqTogglJ:
	ld	a,3
	call	GTTRIG					; Test the button 1 of the joystick 1
	or	a
	jr	nz,FreqTogglJ				; Jump if button 2 of the joystick 1 is pressed

	ld	a,1
	call	GTSTCK					; Test the joystick 1
	cp	3
	ret	nz					; Back if Left of the joystick 1 is not pressed

FreqToggle:
	ld	a,(MSXVER)
	or	a
	ret	z					; Back if MSX1

	ld	a,(NEWKEY+6)
	and	20h
	jr	z,FreqToggle				; Jump if F1 key is pressed

	ld	c,9
	ld	a,(RG9SAV)
	xor	2
	ld	b,a
	call	WRTVDP					; Toggle 50/60 Hz mode

	ld	a,(RG9SAV)
	and	2
	ld	hl,F1_50Hz
	jr	z,PrintFreqOpt				; Jump if 60hz mode
	ld	hl,F1_60Hz

PrintFreqOpt:
	push	hl
	ld	hl,(TXTATR)
	ld	de,WidthName*2
	add	hl,de
	ex	hl,de					; Set the position at the line 2
	pop	hl
	ld	bc,WidthName
	jp	LDIRVM					; Print the 50/60hz option

RomExec:
	ld	a,(SegMum)
	ld	(RamBottom+15),a			; Temporary SegMum
	ld	(VOICAQ+(RamPrgEnd-BankSel)),a
	ld	c,a
	ld	a,(NextSegMum)
	sub	c					; Calculate the Rom size
	ld	(RomSize),a

	pop	hl
	pop	de
	pop	bc
	pop	af
	jp	PrgInRam				; Go to the Rom execution program in RAM (RomSel)

MoveDown:
	ld	hl,(CurrAdr)
	inc	hl
	ld	a,(hl)					; Get the MSX generation data
	and	3
	ld	b,a					; Store MSX generation value in B
	bit	7,(hl)
	jr	z,NextName				; Jump if last Rom bit is reset
	ld	a,(MSXVER)
	and	3					; Reset unused bits of MSX generation
	cp	b
	ret	c					; Last line?

CONT:
	ld	de,LineData
	add	hl,de
	ld	a,(hl)					; Get the nMSX generation data
	cp	255
	ret	z

NextName:
	ld	hl,(CurrTopName)
	ld	de,LineData
	add	hl,de
	ld	(CurrTopName),hl			; Set the new current name position
	ret

MoveUp:
	ld	hl,(CurrTopName)
	ld	de,LineData*5
	add	hl,de
	ld	a,(hl)
	or	a
	ret	z					; Back if next ROM segment is 0 (No ROM) 

PrevName:
	ld	hl,(CurrTopName)
	ld	de,LineData
	or	a
	sbc	hl,de
	ld	(CurrTopName),hl			; Set the new current name position
	ret

PrintList:
	ld	b,20					; 20 lines to display
	ld	hl,(CurrTopName)			; HL = Current Top name address

PrintListLP:
	push	bc
	inc	hl					; Points the MSX generation
PrnCond:
	ld	a,(hl)
	and	3					; to keep the bits 0-1
	ld	c,a
	ld	a,(MSXVER)
	cp	c
	jr	nc,PrintOK				; Call if A >= c

	ld	de,LineData
	add	hl,de					; Go to the next name

	jr	PrnCond
PrintOK:
	ld	e,(hl)					; Get the settings bits (Mirror and Boot)
	dec	hl					; Points the Segment number
	pop	bc
	push	bc
	ld	a,20-6
	cp	b
	jr	nz,SkipSegMum
	ld	a,e
	ld	(SettingBits),a				; Store the settings bits at the cursor
	ld	a,(hl)					; Get the Segment number at the cursor
	ld	(SegMum),a				; Store the Segment number at the cursor
	ld	(CurrAdr),hl
	ld	de,LineData
	add	hl,de
	ld	a,(hl)					; Get the next Segment number
	ld	(NextSegMum),a				; Store the next Segment number
	ld	hl,(CurrAdr)
SkipSegMum:
	ld	de,LineData-WidthName
	add	hl,de					; Points the current name
	ld	de,(VramPos)
	ld	bc,WidthName
	push	hl
	call	LDIRVM					; Print a name

	ld	hl,(VramPos)
	ld	de,WidthName
	add	hl,de
	ld	(VramPos),hl				; Go to the line

	pop	hl
	ld	de,WidthName
	add	hl,de					; Go to the next name

	pop	bc
	djnz	PrintListLP

	ld	hl,(TXTATR)
	ld	de,WidthName*10
	add	hl,de
	ld	a,'>'
	call	WRTVRM					; Print the selection cursor to line 10

	halt
	halt
	halt
	halt
	ret

PrintName:
	pop	hl
	inc	hl
	ld	bc,WidthName*4
	call	LDIRVM					; Print the current name
	pop	hl
	ret

RomSel:
	push	bc
	push	de

	ld	a,(BASRVN+1)
	bit	4,a
	jr	nz,NoScreen1				; Jump if initial screen mode is screen 0
	ld	a,1
	push	hl
	call	INIT32
	pop	hl
NoScreen1:
	ld	a,(RomSize)
	cp	5
	jp	z,PrgInRam+(Rom2pages1_2_3-RomSel)	; Jump if Romsize == 40K (jr Rom2pages1_2_3)
	cp	6
	jp	z,PrgInRam+(Rom2pages1_2_3-RomSel)	; Jump if Romsize == 48K (jr Rom2pages1_2_3)
	cp	4
	jp	nc,PrgInRam+(Rom2pages1_2-RomSel)	; Jump if Romsize >= 32K (jr Rom2pages1_2)

PlainRom8to16K:

; Initialise the Rom mapper segments and pages for 4/8/16kB Roms

	ld	a,(RamBottom+15)
	ld	(05000h),a				; Select the segment 0 on the page 4000h-5FFFh

	ld	a,(04003h)
	bit	7,a
	jp	nz,PrgInRam+(Rom2page2-RomSel)		; Jump if INIT address > 7FFFh
	ld	a,(04009h)
	bit	7,a
	jp	nz,PrgInRam+(Rom2page2-RomSel)		; Jump if TEXT address > 7FFFh
	ld	a,(04003h)
	bit	6,a
	jp	z,PrgInRam+(Rom2page0-RomSel)		; Jump if INIT address < 4000h

Rom2page1:
	ld	a,(RamBottom+15)
	ld	(05000h),a				; Select the segment 0 on the page 4000h-5FFFh
	inc	a
	ld	(07000h),a				; Select the segment 1 on the page 6000h-7FFFh
	ld	e,1
	ld	hl,09000h
	call	WRSLT					; Select the empty segment on the page 8000h-9FFFh
	ld	e,1
	ld	hl,0B000h
	call	WRSLT					; Select the empty segment on the page A000h-BFFFh
	pop	de
	pop	bc
	ld	hl,(04002h)
	jp	PrgInRam+(ExeByJump-RomSel)		; Execute the selected Rom with INIT address between 4000h and 7FFFh

; 32kB Rom execution on page 4000h

Rom2pages1_2:
	ld	a,(RamBottom+15)

	if	Offset==2
	ld	e,0
	ld	a,(RomSlot)
	ld	hl,OffsetReg+1
	call	WRSLT					; Sets up the offset segment
	endif

	if	Offset==1
	ld	e,a
	ld	a,(RomSlot)
	ld	hl,OffsetReg
	call	WRSLT					; Sets up the offset segment
	xor	a
	endif

	ld	(05000h),a				; Select the segment 0 on the page 4000h-5FFFh
	inc	a
	ld	(07000h),a				; Select the segment 1 on the page 6000h-7FFFh
	ld	e,a
	ld	a,(RomSlot)
	inc	e
	ld	hl,09000h
	call	WRSLT					; Select the segment 2 on the page 8000h-9FFFh
	ld	a,(RomSlot)
	inc	e
	ld	hl,0B000h
	call	WRSLT					; Select the segment 3 on the page A000h-BFFFh
	pop	af

	ld	hl,(4002h)
	push	hl
	bit	7,h
	jr	z,NoUPTO8000

	ld	a,(EXPTBL)
	ld	h,040h
	call	ENASLT					; Select the Main-ROM on the page 4000h-7fffh
	ld	a,(RomSlot)
	ld	h,080h
	call	ENASLT					; Select the ROM on the page 8000h-Bfffh
NoUPTO8000:
	pop	hl
	pop	de
	pop	bc
	jp	PrgInRam+(ExeByJump-RomSel)		; Execute the selected Rom with INIT address between 4000h and 7FFFh

; 32Kb Rom execution on page 8000h

Rom2page2:
	ld	a,1
	ld	(05000h),a				; Select the empty segment on the page 4000h-5FFFh
	ld	(07000h),a				; Select the empty segment on the page 6000h-7FFFh

	push	hl
	ld	a,(RamBottom+15)
	ld	e,a
	ld	a,(RomSlot)
	ld	hl,09000h
	call	WRSLT					; Select the segment 0 on the page 8000h-9FFFh
	ld	a,(RomSlot)
	inc	e
	ld	hl,0B000h
	call	WRSLT					; Select the segment 1 on the page A000h-BFFFh
	pop	hl
	pop	de
	pop	bc
	jp	PrgInRam+(ExeByRet-RomSel)		; Back to Rom scaning

; 16Kb Rom execution on page 0000h

Rom2page0:
	ld	a,1
	ld	(05000h),a				; Select the empty segment on the page 4000h-5FFFh
	ld	(07000h),a				; Select the empty segment on the page 6000h-7FFFh

	push	hl
	ld	a,(RamBottom+15)
	ld	e,a
	ld	a,(RomSlot)
	ld	hl,09000h
	call	WRSLT					; Select the segment 0 on the page 8000h-9FFFh
	ld	a,(RomSlot)
	inc	e
	ld	hl,0B000h
	call	WRSLT					; Select the segment 1 on the page A000h-BFFFh
	pop	hl
	pop	de
	pop	bc
	jp	PrgInRam+(ExeByRet-RomSel)		; Back to Rom scaning

; 48Kb Rom execution

Rom2pages1_2_3:
	ld	a,(RamBottom+15)
	ld	(05000h),a				; Select the segment 2 on the page 4000h-5FFFh
	ld	a,(04000h)
	cp	41h
	jp	nz,PrgInRam+(PutOnpages1_2_3-RomSel)	; Jump to PutOnpages1_2_3 if no header on the first segment
	ld	a,(04001h)
	cp	42h
	jp	z,PrgInRam+(Rom2pages1_2-RomSel)	; Jump to Rom2pages1_2 if Header on the first segment

PutOnpages1_2_3:
	ld	a,(RamBottom+15)
	add	a,4
	ld	(05000h),a				; Select the segment 4 on the page 4000h-5FFFh
	inc	a
	ld	(07000h),a				; Select the segment 5 on the page 6000h-7FFFh

	ld	hl,4000h
	ld	de,8000h
	ld	bc,4000h
	ldir

	sub	2
	ld	(07000h),a				; Select the segment 3 on the page 6000h-7FFFh
	dec	a
	ld	(05000h),a				; Select the segment 2 on the page 4000h-5FFFh

	ld	a,(RamBottom+15)
	ld	e,a
	ld	a,(RomSlot)
	ld	hl,09000h
	call	WRSLT					; Select the segment 0 on the page 8000h-9FFFh
	ld	a,(RomSlot)
	inc	e
	ld	hl,0B000h
	call	WRSLT					; Select the segment 1 on the page A000h-BFFFh

	pop	de
	pop	bc
	ld	hl,(4002h)
;	jp	(hl)					; Execute the selected Rom with INIT address between 4000h and 7FFFh

ExeByJump:
	ld	a,(SettingBits)
	and	020h					; Boot type
	jp	nz,0					; Bios reboot
	jp	(hl)					; Execute the selected Rom

ExeByRet:
	ld	a,(SettingBits)
	and	020h					; Boot type
	ret	nz					; Back to Rom scaning
	rst	0					; Bios reboot

MainPrgEnd:

; These routines have a fixed size and are placed in the music buffer area of channel.
; A patched Megarom calls its routines to change memory pages.

BankSel:

Bk5000:							; F975h Bank 0 8KB
	push	af
	push	hl
	if	Offset==0
	ld	hl,VOICAQ+(RamPrgEnd-BankSel)
	add	a,(hl)
	endif
	ld	(05000h),a
	pop	hl
	pop	af
	ret
	if	Offset
	ds	4,0
	endif
Bk7000:							; F981h Bank 1 8KB
	push	af
	push	hl
	if	Offset==0
	ld	hl,VOICAQ+(RamPrgEnd-BankSel)
	add	a,(hl)
	endif
	ld	(07000h),a
	pop	hl
	pop	af
	ret
	if	Offset
	ds	4,0
	endif
Bk9000:							; F98Dh Bank 2 8KB
	push	af
	push	hl
	if	Offset==0
	ld	hl,VOICAQ+(RamPrgEnd-BankSel)
	add	a,(hl)
	endif
	ld	(09000h),a
	pop	hl
	pop	af
	ret
	if	Offset
	ds	4,0
	endif
BkB000:							; F999h Bank 3 8KB
	push	af
	push	hl
	if	Offset==0
	ld	hl,VOICAQ+(RamPrgEnd-BankSel)
	add	a,(hl)
	endif
	ld	(0B000h),a
	pop	hl
	pop	af
	ret
	if	Offset
	ds	4,0
	endif
AD6000:							; F9A5h Bank 0 16KB
	push	af
	add	a,a
	if	Offset==0
	ld	hl,VOICAQ+(RamPrgEnd-BankSel)
	add	a,(hl)
	endif
	ld	(05000h),a
	inc	a
	ld	(07000h),a
	pop	af
	ret
	if	Offset
	ds	4,0
	endif
AD7000:							; F9B4h Bank 1 16KB
	push	af
	add	a,a
	if	Offset==0
	ld	hl,VOICAQ+(RamPrgEnd-BankSel)
	add	a,(hl)
	endif
	ld	(09000h),a
	inc	a
	ld	(0B000h),a
	pop	af
	ret
	if	Offset
	ds	4,0
	endif
RamPrgEnd:

Title:
	include	".\RCM Title.asm"
EmptyLine:
	db	"                                        "
F1_50Hz:
	db	"    Push [F1] key to select 50Hz mode   "
F1_60Hz:
	db	"    Push [F1] key to select 60Hz mode   "

; RomList format is: ROM segment, MSX generation, "Rom name"

RomList:
	ds	LineData*6,0
	include	".\Build\EditThisList.asm"
	ds	LineData*13,0

EndList:
	ds	02000h-(EndList-04000h),255

; Empty header on the segment 1 to run the Roms that contains a Basic program

	ds	10h,0

; Fill the rest of segment 1 with 255

	ds	01FF0h,255
