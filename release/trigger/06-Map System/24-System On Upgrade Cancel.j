/*
    Perform necessary actions when a unit cancels an upgrade.
    
    Should be unnecessary as long as all units upgrade instantly (thus upgrades can't be cancelled).
*/
function Trig_System_On_Upgrade_Cancel_Actions takes nothing returns nothing
    local unit trigU = GetTriggerUnit()
    local SpecialEffect sfx = 0
    
    if not UnitHasAttachedEffect(trigU) then
        set sfx = UnitDetachEffect(trigU)
    endif
    call GUMSOnUpgradeHandler(trigU)
    if sfx != 0 then
        call UnitAttachEffect(trigU, sfx)
    endif
        
    set trigU = null
endfunction

//===========================================================================
function InitTrig_System_On_Upgrade_Cancel takes nothing returns nothing
    set gg_trg_System_On_Upgrade_Cancel = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_System_On_Upgrade_Cancel, EVENT_PLAYER_UNIT_UPGRADE_CANCEL )
    call TriggerAddAction( gg_trg_System_On_Upgrade_Cancel, function Trig_System_On_Upgrade_Cancel_Actions )
endfunction

