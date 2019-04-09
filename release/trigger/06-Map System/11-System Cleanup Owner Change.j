library LoPfour requires LoPone

function DecoCount_SwitchedPlayers_impl takes unit whichUnit, player ownerOld, integer decoCount returns nothing
    local integer playerNumber = GetPlayerId( GetOwningPlayer(whichUnit) ) + 1
    local integer playerNumberOld = GetPlayerId( ownerOld ) + 1
    local integer unitType =  GetUnitTypeId(whichUnit)
    
    call SaveInteger(udg_Hashtable_2, playerNumberOld, unitType, decoCount - 1)
    call SaveInteger(udg_Hashtable_2, playerNumber, unitType, LoadInteger(udg_Hashtable_2, playerNumber, unitType ) + 1)
endfunction

function DecoCount_SwitchedPlayers takes unit whichUnit, player oldOwner returns nothing
    local integer decoCount = LoadInteger(udg_Hashtable_2, GetPlayerId(oldOwner) + 1, GetUnitTypeId(whichUnit))
    
    if decoCount > 0 then
        call DecoCount_SwitchedPlayers_impl(whichUnit, oldOwner, decoCount)
    endif
endfunction

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
        call DecoCount_SwitchedPlayers(whichUnit, ownerOld)
    endif
    
    // If ownership was changed with -neut command, no need to change colors.
    if not IsUnitInGroup(whichUnit, udg_System_NeutralUnits[ GetPlayerId(ownerOld) + 1]) then
        if unitId.hasColor() then
            call SetUnitColor(whichUnit, LoP_PlayerData.get(GetOwningPlayer(whichUnit)).getUnitColor())
        else
            call GUMSSetUnitColor(whichUnit, unitId.raw.getColor())
        endif
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

