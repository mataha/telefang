INCLUDE "telefang.inc"

SECTION "Overworld New Save Init Mem", WRAM0[$C900]
W_Overworld_State:: ds 1

SECTION "Overworld Partner Species", WRAM0[$C912]
W_Overworld_PartnerSpecies:: ds 1

;Actual init code is version specific.
;Go check versions/**/components/overworld/new_save_init.asm