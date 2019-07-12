library LoPfour requires LoPCleanUpDeath, LoPNeutralUnits

function LoP_onChangeOwner takes unit whichUnit, player ownerOld returns nothing
    local player owner = GetOwningPlayer( whichUnit )
    local UnitVisuals unitId = GetHandleId(whichUnit)
    
    if not LoP_IsUnitDecoration(whichUnit) then
    
        if ( Limit_IsUnitLimited(whichUnit) ) then
        
            if Limit_IsPlayerLimited(ownerOld) then
                call Limit_UnregisterUnitEx(whichUnit, ownerOld)
            endif
            
            if Limit_IsPlayerLimited(owner) then
                call Limit_RegisterUnit(whichUnit)
            endif
        endif
        
        // DECO BUILDER DECREASE AND INCREASE COUNT
        call DecoBuilderCount_SwitchOwner(whichUnit, ownerOld)
    endif
    
    // If ownership was changed with -neut command, no need to change colors.
    if not IsUnitInGroup(whichUnit, LoP_GetPlayerNeutralUnits(ownerOld)) then
        if unitId.hasColor() then
            call GUMSSetUnitColor(whichUnit, unitId.raw.getColor())
        else
            call SetUnitColor(whichUnit, LoP_PlayerData.get(GetOwningPlayer(whichUnit)).getUnitColor())
        endif
        call LoP_ClearNeutralData(whichUnit)
    endif
endfunction

endlibrary

function Trig_System_Cleanup_Owner_Change_Actions takes nothing returns nothing 
    call LoP_onChangeOwner(GetTriggerUnit(), GetChangingUnitPrevOwner())
endfunction

//===========================================================================
function InitTrig_System_Cleanup_Owner_Change takes nothing returns nothing
    set gg_trg_System_Cleanup_Owner_Change = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_System_Cleanup_Owner_Change, EVENT_PLAYER_UNIT_CHANGE_OWNER )
    call TriggerAddAction( gg_trg_System_Cleanup_Owner_Change, function Trig_System_Cleanup_Owner_Change_Actions )
endfunction

