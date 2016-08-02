INCLUDE "components/stringtable/load.inc"

;"Status text" is text that we want to draw using the script system's text
;renderer, but isn't going to be interpreted by the script interpreter.

SECTION "Main Script Status Text Drawing WRAM", WRAM0[$CB2F]
W_MainScript_StatusLettersDrawn: ds 1

SECTION "Main Script Status Text Drawing", ROM0[$3A91]
MainScript_DrawStatusText::
	xor a
	ld [W_MainScript_StatusLettersDrawn], a
	
.loop
	push bc
	push de
	push hl
	ld a, [de]
	cp $E0
	jp z, .ret
	pop hl
	push hl
	call Banked_MainScript_DrawLetter
	pop hl
	jp MainScript_ADVICE_DrawStatusText
	
.secondCompositeTile
	add hl, bc
	
.firstCompositeTile
	pop de
	inc de
	ld a, [W_MainScript_StatusLettersDrawn]
	inc a
	ld [W_MainScript_StatusLettersDrawn], a
	pop bc
	dec b
	jp MainScript_ADVICE_DrawStatusText.enterSecondHalf
	
.ret
	pop hl
	pop de
	jp MainScript_ADVICE_DrawStatusText.exitFromSecondHalf
	
	di
	call YetAnotherWFB
	ld [hl], c
	ei
	ret
	
MainScript_DrawEmptySpaces_Space: db 0

;3AC3
MainScript_DrawDenjuuName::
	ld [W_StringTable_ROMTblIndex], a
	push bc
	push de
	pop hl
	call MainScript_ADVICE_DrawDenjuuName
	pop hl
	push hl
	ld a, 8
	call MainScript_DrawEmptySpaces
	pop hl
	ld de, W_StringTable_StagingLocDbl
	ld b, $16 ;likely incorrect.
	jp Banked_MainScript_DrawStatusText
		
SECTION "Main Script Status Text Drawing Advice", ROM0[$0077]
;Part of a function that replaces status text drawing with the VWF.
MainScript_ADVICE_DrawStatusText::
	ld bc, $10
	ld a, [W_MainScript_VWFOldTileMode]
	cp 1
	jp z, MainScript_DrawStatusText.secondCompositeTile
	jp MainScript_DrawStatusText.firstCompositeTile
	
.enterSecondHalf
	jp nz, MainScript_DrawStatusText.loop
	
.resetVWFAndExit
	ld a, 2
	ld [W_MainScript_VWFOldTileMode], a
	ld a, 0
	ld [W_MainScript_VWFLetterShift], a
	ret
	
.exitFromSecondHalf
	pop bc
	jr .resetVWFAndExit

SECTION "Main Script Status Text Drawing 2", ROM0[$3D5C]
MainScript_DrawEmptySpaces::
	push af
	ld de, MainScript_DrawEmptySpaces_Space
	ld b, 1
	call Banked_MainScript_DrawStatusText
	pop af
	dec a
	jr nz, MainScript_DrawEmptySpaces
	ret