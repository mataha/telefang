INCLUDE "telefang.inc"

SECTION "Main Script Message Arg 3", WRAM0[$CA53]
W_MainScript_MessageArg3:: ds M_StringTable_Load8AreaSize

SECTION "Main Script Shop Item Window", ROM0[$2CEB]
MainScript_DrawShopWindowForItem::
    ld a, [W_CurrentBank]
    push af
    ld a, BANK(MainScriptMachine)
    rst $10
    
    call MainScript_SetupShopWindowForItem
    call MainScriptMachine
    call MainScriptMachine
    
    pop af
    rst $10
    ld a, 0
    ld [$C9CF], a
    ret

SECTION "Main Script Shop Item Window 2", ROMX[$4711], BANK[$B]
MainScript_SetupShopWindowForItem::
    push bc
    call MainScript_LoadItemNameAsArg3
    
    xor a
    ld [$C9CF], a
    ld a, $C0
    ld [W_MainScript_TileBaseIdx], a
    ld a, $E0
    ld [W_Status_NumericalTileIndex], a
    
    ld b, 0
    ld c, $BA
    ld d, 0
    call MainScript_QueueCustomWindowMessage
    
    ld a, 1
    ld [$CADA], a
    ld a, 7
    ld [W_MainScript_WindowBorderAttribs], a
    
    call MainScript_DrawEmptyShopWindow
    
    pop bc
    call MainScript_DrawQuantity
    
    ret

MainScript_LoadItemNameAsArg3::
    ld hl, StringTable_battle_items
    
    ld c, b
    ld b, 0
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    add hl, bc
    
    ld b, 8
    ld de, W_MainScript_MessageArg3
    
.copyLoop
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .copyLoop
    
    ld a, $E0
    ld [de], a
    ret

SECTION "Main Script Shop Item Window 3", ROMX[$476C], BANK[$B]
MainScript_QueueCustomWindowMessage::
    ld hl, W_MainScript_TilePtr
    ld a, 0
    ld [hli], a
    ld a, $98
    ld [hl], a
    
    ld a, d
    ld [W_MainScript_WindowLocation], a
    
    ld d, 0
    ld e, b
    ld hl, MainScript_table
    add hl, de
    add hl, de
    add hl, de
    
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld [W_MainScript_TextBank], a
    
    ld l, c
    ld h, 0
    sla l
    rl h
    add hl, de
    call MainScript_Jump2Operand
    
    call Status_ExpandNumericalTiles
    
    xor a
    ld [W_MainScript_TilesDrawn], a
    ld [W_MainScript_NumNewlines], a
    ld a, 0
    ld [W_MainScript_WaitFrames], a
    ld a, 1
    ld [W_MainScript_TextSpeed], a
    ld a, 0
    ld [W_MainScript_ContinueBtnPressed], a
    ld a, 2
    ld [$CADA], a
    ld a, 1
    ld [W_MainScript_State], a
    
    ret

SECTION "Main Script Shop Item Window 4", ROMX[$49E6], BANK[$B]
MainScript_DrawEmptyShopWindow::
    call MainScript_LoadWindowBorderTileset
    call MainScript_ClearTilesShopWindow
    
    ld de, MainScript_ShopWindowBorder
    ld b, 4
    ld a, [W_MainScript_WindowLocation]
    ld c, 0
    call MainScript_DrawWindowBorder
    ret

.mystery
    ret

SECTION "Main Script Shop Item Window 5", ROMX[$4A0F], BANK[$B]
MainScript_DrawQuantity::
    ld a, b
    ld hl, $CDBC
    add a, l
    ld l, a
    ld a, 0
    adc a, h
    ld h, a
    ld a, [hl]
    cp 100
    jr c, .decimalize
.valueCap
    ld a, 99
    
.decimalize
    call Status_DecimalizeStatValue
    
    ld a, $C7
    ld hl, $8C80
    call MainScript_DrawLetter
    
    ld a, [W_GenericRegPreserve]
    swap a
    and $F
    add a, $BB
    ld hl, $8C90
    call MainScript_DrawLetter
    
    ld a, [W_GenericRegPreserve]
    and $F
    add a, $BB
    ld hl, $8CA0
    call MainScript_DrawLetter
    
    ret

SECTION "Main Script Shop Item Window 6", ROMX[$4831], BANK[$B]
MainScript_DrawShopWindowForChiru::
    ld a, [W_Shop_PlayerTotalChiru]
    ld l, a
    ld a, [$C911]
    ld h, a
    ld d, 0
    call $4883
    call MainScript_DrawEmptyShopWindow
    call MainScriptMachine
    call MainScriptMachine
    ld a, 0
    ld [W_byte_C9CF], a
    ret

SECTION "Main Script Secondary Shop Item Window", ROM0[$2D10]
MainScript_DrawSecondaryShopWindowForChiru::
    ld a, [W_CurrentBank]
    push af
    ld a, BANK(MainScript_SetupSecondaryShopWindowForChiru)
    rst $10
    call MainScript_SetupSecondaryShopWindowForChiru
    call MainScriptMachine
    call MainScriptMachine
    call MainScriptMachine
    pop af
    rst $10
    ld a, 0
    ld [W_byte_C9CF], a
    ret

SECTION "Main Script Secondary Shop Item Window 2", ROMX[$492E], BANK[$B]
MainScript_SetupSecondaryShopWindowForChiru::
    ld a, $C0
    ld [W_MainScript_TileBaseIdx], a
    ld a, $E0
    ld [W_Status_NumericalTileIndex], a
    push bc
    push de
    call $2D03
    pop de
    pop bc
    ld a, $E6
    ld [$CA00], a
    call MainScript_QueueCustomWindowMessage
    ld a, 7
    ld [$CA65], a
    jp MainScript_MapSecondaryShopWindow
