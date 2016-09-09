INCLUDE "components/stringtable/load.inc"

;"Status text" is text that we want to draw using the script system's text
;renderer, but isn't going to be interpreted by the script interpreter.

SECTION "Main Script Status Text Drawing WRAM", WRAM0[$CB2F]
W_MainScript_StatusLettersDrawn: ds 1

SECTION "Main Script Status Text Drawing WRAM 2", WRAM0[$C3A0]
W_MainScript_NameStagingLoc:: ds M_StringTable_Load8AreaSize + 1

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
	ld bc, $10
	add hl, bc
	pop de
	inc de
	ld a, [W_MainScript_StatusLettersDrawn]
	inc a
	ld [W_MainScript_StatusLettersDrawn], a
	pop bc
	dec b
	jp nz, .loop
	ret
    
.ret
	pop hl
	pop de
	pop bc
	ret

	;Mystery code block. Not important yet.
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
	call StringTable_LoadDenjuuName
	pop hl
	push hl
	ld a, 8
	call MainScript_DrawEmptySpaces
	pop hl
	ld de, W_StringTable_StagingLoc
	ld b, M_StringTable_Load8AreaSize
	jp Banked_MainScript_DrawStatusText
   
;BC = Argument for Draw Empty Spaces
;DE = Argument for Load Denjuu Name
;I don't know why this function exists.
;It appears to pad the loaded denjuu name with string terminators in a very
;paranoid fashion. Wtf...
MainScript_DrawPaddedDenjuuName::
	ld [W_StringTable_ROMTblIndex], a
	push bc
	push de
	ld hl, W_MainScript_NameStagingLoc
	ld b, M_StringTable_Load8AreaSize + 1
	
.clearLoop
	ld a, $E0
	ld [hli], a
	dec b
	jr nz, .clearLoop
	
	pop hl
	call StringTable_LoadDenjuuName
	pop hl
	push hl
	ld a, M_StringTable_Load8AreaSize
	call MainScript_DrawEmptySpaces
	ld hl, W_StringTable_StagingLoc
	ld de, W_MainScript_NameStagingLoc
	call Banked_StringTable_PadCopyBuffer
	ld de, W_MainScript_NameStagingLoc
	pop hl
	ld b, M_StringTable_Load8AreaSize
	jp Banked_MainScript_DrawStatusText

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