INCLUDE "telefang.inc"

SECTION "Overworld Acre Transition Common Preparation", ROMX[$5917], BANK[$E]
Overworld_AcreTransition_CommonPrep::
	push af
	ld a, [$C906]
	ld [$C90F], a
	pop bc
	ld a, $B
	ld hl, $61FD
	call CallBankedFunction_int
	ld a, $F
	ld [$C915], a
	ld [$C916], a
	ld a, 0
	ld [$C980], a
	ld a, 1
	ld [$C98E], a
	call $2793
	ld a, $C
	ld hl, $2B98
	call CallBankedFunction_int
	call $2B72
	ld a, [$CAFE]
	or a
	ret nz
	call $3435
	ret
