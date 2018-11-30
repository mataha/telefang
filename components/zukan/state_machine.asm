INCLUDE "telefang.inc"

SECTION "Zukan State Machine", ROMX[$5417], BANK[$4]
Zukan_StateMachine::
    call PauseMenu_DrawClockSprites
    
    ld a, [W_SystemSubSubState]
    ld hl, .state_table
    call System_IndexWordList
    jp hl
    
.state_table
    dw Zukan_StateOverviewDrawSubScreen
    dw Zukan_StateOverviewDrawSpecies
    dw Zukan_StateOverviewDrawCursorsAndNumbers
    dw Zukan_StateOverviewInput
    dw Zukan_StateOverviewFadeOutAndDrawInner
    dw Zukan_StateFadeIn
    dw Zukan_StateInnerviewInput
    dw Zukan_StateInnerviewFadeOut
    dw Zukan_StateFadeIn
    dw Zukan_StateOverviewReturnToInput
    dw PauseMenu_SubStateSMSExit1
    dw PauseMenu_SubStateSMSExit2
    dw Zukan_StateInnerviewSwitchPage

Zukan_StateOverviewDrawSubScreen::
    ld hl, $9400
    ld b, $38
    call PauseMenu_ClearScreenTiles
    
    ld a, $F0
    ld [W_Status_NumericalTileIndex], a
    call Status_ExpandNumericalTiles
    
    ld a, 0
    ld [W_MainScript_WindowBorderAttribs], a
    
    ld a, $78
    ld [W_MainScript_TileBaseIdx], a
    call Zukan_CalculateTotals
    
    ld bc, $48
    ld a, [W_GameboyType]
    cp M_BIOS_CPU_CGB
    jr z, .load_graphic
    
.select_dmg_graphic
    ld bc, $5B
    
.load_graphic
    call Banked_LoadMaliasGraphics
    jp System_ScheduleNextSubSubState

Zukan_StateOverviewDrawSpecies::
    call Zukan_LoadSpeciesPortraitAndNameIfKnown
    
    ld a, 1
    ld [W_CGBPaletteStagedBGP], a
    jp System_ScheduleNextSubSubState
    
Zukan_StateOverviewDrawCursorsAndNumbers::
    jp Zukan_UpdateOverviewCursorsNumbersAndNextState
    
Zukan_StateOverviewInput::
    call PauseMenu_UpdateZukanOverviewCursorAnimations
    
    ld a, 1
    ld [W_OAM_SpritesReady], a
    
    ld a, [W_JPInput_TypematicBtns]
    and M_JPInput_Right
    jr z, .check_left_pressed
    
.increment_selected
    ld a, [W_Zukan_LastKnownSpecies]
    ld b, a
    ld a, [W_Zukan_SelectedSpecies]
    cp b
    jr nz, .increment_no_wraparound
    
.increment_wraparound
    ld a, $FF
    
.increment_no_wraparound
    inc a
    jr .species_changed

.check_left_pressed
    ld a, [W_JPInput_TypematicBtns]
    and M_JPInput_Left
    jr z, .check_b_pressed
    
.decrement_selected
    ld a, [W_Zukan_SelectedSpecies]
    cp 0
    jr nz, .decrement_no_wraparound
    
.decrement_wraparound
    ld a, [W_Zukan_LastKnownSpecies]
    inc a
    
.decrement_no_wraparound
    dec a
    
.species_changed
    ld [W_Zukan_SelectedSpecies], a
    
    ld a, M_Zukan_StateOverviewDrawSpecies
    ld [W_SystemSubSubState], a
    
    ld a, 2
    ld [W_Sound_NextSFXSelect], a
    
    ld hl, $9400
    ld b, $38
    call PauseMenu_ClearScreenTiles
    ret
    
.check_b_pressed
    ld a, [H_JPInput_Changed]
    and M_JPInput_B
    jr z, .check_a_pressed
    
.exit_zukan_subscreen
    ld e, $2D
    call PauseMenu_LoadMenuMap0
    
    ld a, 4
    ld [W_Sound_NextSFXSelect], a
    call PauseMenu_ClearArrowMetasprites
    
    ld a, M_Zukan_StateOverviewExit0
    ld [W_SystemSubSubState], a
    ret
    
.check_a_pressed
    ld a, [H_JPInput_Changed]
    and M_JPInput_A
    jr z, .nothing_pressed
    
.check_view_zukan_page
    ld a, [W_Zukan_SelectedSpecies]
    call Zukan_CheckEntryObtained
    jr nz, .enter_zukan_innerview
    
    ld a, [W_Zukan_SelectedSpecies]
    call Zukan_CheckSpeciesKnown
    ret z
    
.enter_zukan_innerview
    ld a, 3
    ld [W_Sound_NextSFXSelect], a
    
    ld a, 4
    call Banked_LCDC_SetupPalswapAnimation
    jp System_ScheduleNextSubSubState
    
.nothing_pressed
    ret
    
Zukan_StateOverviewFadeOutAndDrawInner::
    ld a, 1
    call Banked_LCDC_PaletteFade
    or a
    ret z
    
    call LCDC_ClearMetasprites
    
    ld bc, $E
    call Banked_LoadMaliasGraphics
    
    ld a, $F0
    ld [W_Status_NumericalTileIndex], a
    call Status_ExpandNumericalTiles
    
    ld bc, $16
    call Banked_CGBLoadBackgroundPalette
    
    ld bc, 3
    call Banked_CGBLoadObjectPalette
    
    ; Tilemap 1 in bank 1 is the Field Guide background.
    ld bc, 0
    ld e, 1
    ld a, 1
    call Banked_RLEDecompressTMAP0
    
    ld bc, 0
    ld e, 1
    ld a, 1
    call Banked_RLEDecompressAttribsTMAP0
    call PhoneConversation_OutboundConfigureScreen

    ld a, Banked_Zukan_ADVICE_DrawRightAlignedHabitatName & $FF
    call PatchUtils_AuxCodeJmp
    
    ld a, [W_Zukan_SelectedSpecies]
    ld c, 1
    ld de, $8800
    call Banked_Battle_LoadDenjuuPortrait
    
    ld a, [W_Zukan_SelectedSpecies]
    call Battle_LoadDenjuuPalettePartner
    
    ld a, [W_Zukan_SelectedSpecies]
    ld de, $9200
    call Status_LoadEvolutionIndicatorBySpeciesZukan
    
    ld a, Banked_Zukan_ADVICE_ClearMessageForSGB & $FF
    call PatchUtils_AuxCodeJmp
    
    xor a
    ld [W_MainScript_TextStyle], a
    ld a, Banked_Zukan_ADVICE_DrawDenjuuName & $FF
    call PatchUtils_AuxCodeJmp
    
    ; The Denjuu name is broken out into sprites in order to
    ; be able to center it properly on the pixel level.
    ; The original plan was to center it vertically between two
    ; tiles, but it seems like that might not be the case anymore.
    ld a, Banked_Zukan_ADVICE_InitializeNameMetaSprite & $FF
    call PatchUtils_AuxCodeJmp
    
    ld a, 1
    ld [W_Status_CalledFromContactScreen], a
    
    ld a, 4
    call Banked_LCDC_SetupPalswapAnimation
    
    ld a, $C0
    ld [W_MainScript_TileBaseIdx], a
    call Zukan_DrawSpeciesPageText
    
    ld a, 4
    ld [W_PauseMenu_SelectedCursorType], a
    
    ld de, $C0C0
    call Banked_PauseMenu_InitializeCursor
    
    ld a, $B
    ld [W_PauseMenu_SelectedCursorType], a
    
    ld de, $C0E0
    call Banked_PauseMenu_InitializeCursor
    call PauseMenu_UpdateZukanPageCursorAnimations
    
    ld a, (Banked_Zukan_ADVICE_SetupSGBScreen & $FF)
    call PatchUtils_AuxCodeJmp
    
    ld a, 1
    ld [W_OAM_SpritesReady], a
    jp System_ScheduleNextSubSubState
    nop
    nop
    nop
    nop
    nop
    nop

;yes this does fadein for both the inner view and returning to the outer view
Zukan_StateFadeIn::
    ld a, 0
    call Banked_LCDC_PaletteFade
    or a
    ret z
    jp System_ScheduleNextSubSubState
    
Zukan_StateInnerviewInput::
    call PauseMenu_UpdateZukanPageCursorAnimations
    
    ld a, [W_FrameCounter]
    and 3
    jr nz, .check_right_pressed
    
.shift_background
    ld hl, $91B0
    call Status_ShiftBackgroundTiles
    
.check_right_pressed
    ld a, [W_JPInput_TypematicBtns]
    and M_JPInput_Right
    jr z, .check_left_pressed
    
.increment_selected
    ld a, [W_Zukan_SelectedSpecies]
    ld [W_System_GenericCounter], a
    
.valid_increment_search
    ld a, [W_Zukan_LastKnownSpecies]
    ld b, a
    ld a, [W_Zukan_SelectedSpecies]
    cp b
    
    jr z, .increment_wraparound
    
.increment_no_wraparound
    inc a
    ld [W_Zukan_SelectedSpecies], a
    
    ld a, [W_Zukan_SelectedSpecies]
    call Zukan_CheckEntryObtained
    jr nz, .draw_new_species
    
    ld a, [W_Zukan_SelectedSpecies]
    call Zukan_CheckSpeciesKnown
    jr nz, .draw_new_species
    jr .valid_increment_search
    
.increment_wraparound
    ld a, $FF
    ld [W_Zukan_SelectedSpecies], a
    jr .valid_increment_search
    
.draw_new_species
    ld a, Banked_Zukan_ADVICE_StateInnerviewInputSwitchSpecies & $FF
    call PatchUtils_AuxCodeJmp
    ret

.check_left_pressed
    ld a, [W_JPInput_TypematicBtns]
    and M_JPInput_Left
    jr z, .check_button_press
    
.decrement_selected
    ld a, [W_Zukan_SelectedSpecies]
    ld [W_System_GenericCounter], a
    
.valid_decrement_search
    ld a, [W_Zukan_SelectedSpecies]
    cp 0
    jr z, .decrement_wraparound
    
    dec a
    ld [W_Zukan_SelectedSpecies], a
    
    ld a, [W_Zukan_SelectedSpecies]
    call Zukan_CheckEntryObtained
    jr nz, .draw_new_species
    
    ld a, [W_Zukan_SelectedSpecies]
    call Zukan_CheckSpeciesKnown
    jr nz, .draw_new_species
    jr .valid_decrement_search
    
.decrement_wraparound
    ld a, [W_Zukan_LastKnownSpecies]
    inc a
    ld [W_Zukan_SelectedSpecies], a
    jr .valid_decrement_search
    
.check_button_press
    ld a, [H_JPInput_Changed]
    and M_JPInput_A + M_JPInput_B
    jr z, .nothing_pressed
    
.run_button_advice
    ld a, Banked_Zukan_ADVICE_StateInnerviewInputButtonPress & $FF
    call PatchUtils_AuxCodeJmp
    ret
    
.nothing_pressed
    ret
    
Zukan_StateInnerviewFadeOut:
    ld a, 1
    call Banked_LCDC_PaletteFade
    or a
    ret z
    
    ; Added to clear the Denjuu name metasprite and SGB palettes.
    ld a, (Banked_Zukan_ADVICE_TeardownSGBScreenAndMetasprites & $FF)
    call PatchUtils_AuxCodeJmp

    ld hl, $9400
    ld b, $38
    call PauseMenu_ClearScreenTiles
    call PauseMenu_LoadMenuResources
    
    ld bc, $48
    ld a, [W_GameboyType]
    cp M_BIOS_CPU_CGB
    jr z, .load_menu_graphics
    
.select_dmg_graphic
    ld bc, $5B
    
.load_menu_graphics
    call Banked_LoadMaliasGraphics
    
    ld bc, 0
    ld e, $10
    call PauseMenu_LoadMap0
    
    ld bc, 0
    ld e, $11
    call PauseMenu_LoadMap1
    call PauseMenu_CGBLoadPalettes
    call PauseMenu_ConfigureScreen
    
    xor a
    ld [W_Status_CalledFromContactScreen], a
    
    xor a
    ld [W_CGBPaletteStagedBGP], a
    call Zukan_LoadSpeciesPortraitAndNameIfKnown
    call Zukan_UpdateOverviewCursorsNumbersAndNextState
    
    ld a, 4
    call Banked_LCDC_SetupPalswapAnimation
    ret

Zukan_StateOverviewReturnToInput:
    ld a, 0
    call Banked_LCDC_PaletteFade
    or a
    ret z
    
    ld a, M_Zukan_StateOverviewInput
    ld [W_SystemSubSubState], a
    ret

Zukan_StateInnerviewSwitchPage:
    ld a, Banked_Zukan_ADVICE_DrawRightAlignedHabitatName & $FF
    call PatchUtils_AuxCodeJmp
    
    ld a, [W_Zukan_SelectedSpecies]
    ld c, 1
    ld de, $8800
    call Banked_Battle_LoadDenjuuPortrait
    
    ld a, [W_Zukan_SelectedSpecies]
    call Battle_LoadDenjuuPalettePartner
    
    xor a
    ld [W_MainScript_TextStyle], a
    ld a, Banked_Zukan_ADVICE_DrawDenjuuName & $FF
    call PatchUtils_AuxCodeJmp
    
    ld a, [W_Zukan_SelectedSpecies]
    ld de, $9200
    call Status_LoadEvolutionIndicatorBySpeciesZukan
    
    ld a, Banked_Zukan_ADVICE_ClearMessageForSGB & $FF
    call PatchUtils_AuxCodeJmp

    ld a, $C0
    ld [W_MainScript_TileBaseIdx], a
    call Zukan_DrawSpeciesPageText
    
    ld a, 1
    ld [W_CGBPaletteStagedBGP], a
    
    ld a, Banked_Zukan_ADVICE_RefreshSGBScreen & $FF
    call PatchUtils_AuxCodeJmp
    
    ld a, M_Zukan_StateInnerviewInput
    ld [W_SystemSubSubState], a
    ret
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "Zukan State Machine Advice", ROMX[$4580], BANK[$1]
Zukan_ADVICE_InitializeNameMetaSprite::
    M_AdviceSetup

    ld a, 1
    ld [W_MetaSpriteConfig1 + M_MetaSpriteConfig_Size * 3 + M_LCDC_MetaSpriteConfig_HiAttribs], a

    ; #177 in metasprite bank 8 is MetaSprite_zukan_denjuu_name.
    ld a, $80
    ld [W_MetaSpriteConfig1 + M_MetaSpriteConfig_Size * 3 + M_LCDC_MetaSpriteConfig_Bank], a
    ld a, 177
    ld [W_MetaSpriteConfig1 + M_MetaSpriteConfig_Size * 3 + M_LCDC_MetaSpriteConfig_Index], a
    ld a, 80 + 3
    ld [W_MetaSpriteConfig1 + M_MetaSpriteConfig_Size * 3 + M_LCDC_MetaSpriteConfig_XOffset], a
    ld a, 5 * 8 - 1
    ld [W_MetaSpriteConfig1 + M_MetaSpriteConfig_Size * 3 + M_LCDC_MetaSpriteConfig_YOffset], a

    M_AdviceTeardown
    ret

;cloned from PauseMenu_ClearScreenTiles 'cause I can't bankcall it
Zukan_ADVICE_ClearScreenTiles::
    push bc
    ld c, $10
    
.loop1
    xor a
    call YetAnotherWFB
    ld [hli], a
    dec c
    jr nz, .loop1
    
    pop bc
    dec b
    jr nz, Zukan_ADVICE_ClearScreenTiles
    
    ret
    
Zukan_ADVICE_DrawRightAlignedHabitatName::
    M_AdviceSetup
    
    ld a, [W_Zukan_SelectedSpecies]
    call Zukan_ADVICE_DrawRightAlignedHabitatName_SGBTextStyle

    ld a, 7
    ld [W_MainScript_VWFNewlineWidth], a
    
    ;DrawHabitatString but inlined
    ld a, [W_Status_SelectedDenjuuSpecies]
    ld c, M_Battle_SpeciesType
    call Banked_Battle_LoadSpeciesData
    
    ld a, [W_Battle_RetrSpeciesByte]
    ld [W_StringTable_ROMTblIndex], a
    
    ld de, StringTable_denjuu_habitats
    ld bc, $9380
    ld a, BANK(MainScript_ADVICE_DrawRightAlignedHabitatName)
    ld hl, MainScript_ADVICE_DrawRightAlignedHabitatName
    rst $20 ;CallBankedFunction

    ld a, M_MainScript_UndefinedWindowWidth
    ld [W_MainScript_VWFNewlineWidth], a
    
    M_AdviceTeardown
    ret
    
Zukan_ADVICE_SetupSGBScreen::
    M_AdviceSetup
    
    ;Load SGB ATF.
    ;We don't convert colors until after the denjuu is in place, so we just want
    ;to get the status screen attributes in place.
    ld a, 5
    ld b, 0
    ld c, 0
    ld d, 0
    ld e, 0
    call Zukan_ADVICE_SetupSGBScreen_RedrawForSGB
    
    ld a, M_SGB_Pal01 << 3 + 1
    ld b, 0
    ld c, 1
    call PatchUtils_CommitStagedCGBToSGB
    
    ld a, M_SGB_Pal23 << 3 + 1
    ld b, 5
    ld c, 6
    call PatchUtils_CommitStagedCGBToSGB
    
    M_AdviceTeardown
    ret
    
Zukan_ADVICE_RefreshSGBScreen::
    M_AdviceSetup
    
    ld a, M_SGB_Pal23 << 3 + 1
    ld b, 5
    ld c, 6
    call PatchUtils_CommitStagedCGBToSGB
    
    M_AdviceTeardown
    ret
    
Zukan_ADVICE_TeardownSGBScreenAndMetasprites::
    M_AdviceSetup
    
    ;Remove the Denjuu name metasprite
    call LCDC_ClearMetasprites
    
    ;Load neutral/grayscale ATF
    ld a, 0
    ld b, 0
    ld c, 0
    ld d, 0
    ld e, 0
    call Zukan_ADVICE_TeardownSGBScreenAndMetasprites_ResetSGBTextStyle
    
    M_AdviceTeardown
    ret

Zukan_ADVICE_StateInnerviewInputButtonPress::
    M_AdviceSetup
    
.check_b_pressed
    ld a, [H_JPInput_Changed]
    and 2
    jr z, .check_a_pressed
    
.exit_inner_screen
    ld a, 0
    ld [W_MainScript_State], a
    
    ld a, 4
    ld [W_Sound_NextSFXSelect], a
    
    ld a, 4
    call Banked_LCDC_SetupPalswapAnimation
    call System_ScheduleNextSubSubState
    jr .nothing_pressed
    
.check_a_pressed
    ld a, [H_JPInput_Changed]
    and 1
    jr z, .nothing_pressed
    
    ;Check if we've drawn more than 3 lines of text.
    ;If we haven't then don't redraw the text since it's not multipage.
    ld a, [W_MainScript_NumNewlines]
    cp 3
    jr c, .nothing_pressed
    
    call Zukan_ADVICE_ClearMessageForSGB_Direct
    
    ;Evil hack: MainScriptMachine can NEVER KNOW that we're pressing A
    ld a, [H_JPInput_Changed]
    and $FE
    ld [H_JPInput_Changed], a
    
    ld a, BANK(Zukan_DrawSpeciesPageText)
    ld hl, Zukan_DrawSpeciesPageText
    call CallBankedFunction_int
    
.nothing_pressed
    M_AdviceTeardown
    ret
    nop
    nop
    nop
    nop
    nop
    
Zukan_ADVICE_StateInnerviewInputSwitchSpecies::
    M_AdviceSetup
    
    ;Clear the page indicator
    ld hl, $99D1
    call YetAnotherWFB
    xor a
    ld [hl], a
    
    ;Reset script state (so we don't accidentally draw the next page)
    ld [W_MainScript_State], a
    
    ;Everything else the original code did
    ld a, 2
    ld [W_Sound_NextSFXSelect], a
    
    ld a, M_Zukan_StateInnerviewSwitchPage
    ld [W_SystemSubSubState], a
    
    M_AdviceTeardown
    ret

SECTION "Zukan SGB Recolour Window Advice", ROMX[$5360], BANK[$1]
Zukan_ADVICE_TileLightColourReverse::
    ld d, h
    ld e, l

.drawloop
    di

.wfb
    ld a, [REG_STAT]
    and 2
    jr nz, .wfb
    ld a, [hli]
    ld c, a
    ld a, [hli]
    xor c
    cpl
    ld [de], a
    ei
    inc de
    inc de
    dec b
    jr nz, .drawloop
    ret

Zukan_ADVICE_TileLowByteBlanketFill::
    ld c, $FF

.drawloop
    di

.wfb
    ld a, [REG_STAT]
    and 2
    jr nz, .wfb
    ld a, c
    ld [hli], a
    inc hl
    ld a, c
    ld [hli], a
    ei
    inc hl
    dec b
    jr nz, .drawloop
    ret

Zukan_ADVICE_FixPaletteForSGB::
    ld hl, W_LCDC_CGBStagingBGPaletteArea

.skipHLSet
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a
    ret

Zukan_ADVICE_CheckSGB::
    ld a, [W_GameboyType]
    cp M_BIOS_CPU_CGB
    ret z
    ld a, [W_SGB_DetectSuccess]
    or a
    ret

Zukan_ADVICE_SetupSGBScreen_RedrawForSGB::
    call Banked_SGB_ConstructPaletteSetPacket
    call Zukan_ADVICE_CheckSGB
    ret z
    ld hl, $9000
    ld b, $50
    call Zukan_ADVICE_TileLightColourReverse
    call Zukan_ADVICE_FixPaletteForSGB
    ld hl, $9530
    ld b, $20
    call Zukan_ADVICE_TileLowByteBlanketFill
    ld hl, $8FE0
    ld b, 4
    call Zukan_ADVICE_TileLowByteBlanketFill
    ret

Zukan_ADVICE_TeardownSGBScreenAndMetasprites_ResetSGBTextStyle::
    call Banked_SGB_ConstructPaletteSetPacket
    call Zukan_ADVICE_CheckSGB
    ret z
    xor a
    ld [W_MainScript_TextStyle], a
    ret

Zukan_ADVICE_DrawRightAlignedHabitatName_SGBTextStyle::
    ld [W_Status_SelectedDenjuuSpecies], a
    call Zukan_ADVICE_CheckSGB
    ret z
    ld a, 3
    ld [W_MainScript_TextStyle], a
    ret

Zukan_ADVICE_ClearMessageForSGB::
    M_AdviceSetup
    call Zukan_ADVICE_ClearMessageForSGB_Direct
    M_AdviceTeardown
    ret

Zukan_ADVICE_ClearMessageForSGB_Direct::
    ld hl, $8C00
    ld b, $E0
    call Zukan_ADVICE_CheckSGB
    jr z, .notsgb
    ld de, $FF
    jr .clearloop

.notsgb
    ld d, 0
    ld e, d

.clearloop
    di

.wfb
    ld a, [REG_STAT]
    and 2
    jr nz, .wfb
    ld a, e
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
    ei
    ld e, d
    ld d, a
    dec b
    jr nz, .clearloop
    ret

Zukan_ADVICE_DrawDenjuuName::
    M_AdviceSetup
    
    ld a, [W_Zukan_SelectedSpecies]
    ld de, StringTable_denjuu_species
    ld bc, $8F00
    call MainScript_DrawCenteredName75
    
    call Zukan_ADVICE_CheckSGB
    jr z, .notsgb
    ld a, 3
    ld [W_MainScript_TextStyle], a

.notsgb
    M_AdviceTeardown
    ret
