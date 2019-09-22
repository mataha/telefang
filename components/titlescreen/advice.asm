INCLUDE "telefang.inc"

SECTION "Title Screen SGB Advice", ROMX[$7F50], BANK[$2]
TitleScreen_ADVICE_LoadSGBFiles::
    call AttractMode_ADVICE_CheckSGB
    ret z
    
    ;Load our ATF
    ld a, 2
    ld b, 1
    ld c, 2
    ld d, 3
    ld e, 4
    call Banked_SGB_ConstructPaletteSetPacket
    ret
    
TitleScreen_ADVICE_RecolorVersionBand::
    call AttractMode_ADVICE_CheckSGB
    jp z, System_ScheduleNextSubState
    
    ;Replace the version band sprite tiles
    ld bc, $5f
    call Banked_LoadMaliasGraphics
    
    ;The version band on the titlescreen is designed to consume all four colors.
    ;On SGB, we need all four of our palettes to have a black value, which also
    ;changes the version band's color to black. Since I'm too lazy to add a
    ;separate set of resources for the same tilemap, let's instead just OR that
    ;particular tile with our own value
    ld hl, $9902
    
.wfbLoopNewTile
    ld a, [REG_STAT]
    and 2
    jr nz, .wfbLoopNewTile
    
    ld a, $FF
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    
    ld hl, $990E
    
.wfbLoopNewTile2
    ld a, [REG_STAT]
    and 2
    jr nz, .wfbLoopNewTile2
    
    ld a, $FF
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    
    jp System_ScheduleNextSubState
    
TitleScreen_ADVICE_UnloadSGBFiles::
    ;Load a neutral ATF
    ld a, 0
    ld b, 0
    ld c, 0
    ld d, 0
    ld e, 0
    call Banked_SGB_ConstructPaletteSetPacket
    jp System_ScheduleNextSubState