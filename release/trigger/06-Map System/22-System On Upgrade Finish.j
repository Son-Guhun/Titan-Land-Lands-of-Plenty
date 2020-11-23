/*
    Perform necessary actions when a unit finishes upgrading into a new one.
*/

function Trig_System_On_Upgrade_Finish_Actions takes nothing returns nothing
    local unit trigU = GetTriggerUnit()
    local SpecialEffect sfx = 0
    
    if GetUnitTypeId(trigU) == 'e000' then
        call UnitRemoveAbility(trigU, 'ARal')
    endif
    
    if UnitHasAttachedEffect(trigU) then
        set sfx = UnitDetachEffect(trigU)
    endif
    call LoP.UVS.UpgradeHandler(trigU)
    if sfx != 0 then
        call UnitAttachEffect(trigU, sfx.copy(GetUnitTypeId(trigU)))
        call sfx.destroy()
    endif
    
    if LoP_IsUnitDecoration(trigU) then
        call DecoOnUpgrade(trigU)
    endif
    set trigU = null
endfunction

//===========================================================================
function InitTrig_System_On_Upgrade_Finish takes nothing returns nothing
    set gg_trg_System_On_Upgrade_Finish = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_System_On_Upgrade_Finish, EVENT_PLAYER_UNIT_UPGRADE_FINISH )
    call TriggerAddAction( gg_trg_System_On_Upgrade_Finish, function Trig_System_On_Upgrade_Finish_Actions )
endfunction

