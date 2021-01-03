scope DecoBuilderMovement
/*
Listens spell events and order events, when issued by a builder (UNIT_TYPE_PEON).

Handles teleporting workers if they have it enabled, and also handles switching between worker flight
and teleportation states.
*/

private struct Abils extends array

    static method operator FLY takes nothing returns integer
        return 'A0C7'
    endmethod
    
    static method operator LAND takes nothing returns integer
        return 'A0C8'
    endmethod
    
    static method operator TELE_ON takes nothing returns integer
        return 'A0C9'
    endmethod
    
    static method operator TELE_OFF takes nothing returns integer
        return 'A0CA'
    endmethod

endstruct

private function Actions takes nothing returns nothing
    local unit trigU = GetTriggerUnit()
    
    if IsUnitType(trigU, UNIT_TYPE_PEON) then
    
        if GetTriggerEventId() == EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER then

            // If unit has the ability to turn off teleportation, that means teleporation is enabled.
            if GetIssuedOrderId() == OrderId("smart") and GetUnitAbilityLevel(trigU, Abils.TELE_OFF) != 0 then
                call SetUnitPosition( trigU, GetOrderPointX(), GetOrderPointY())
            endif
            
        else
        
            if GetSpellAbilityId() == Abils.FLY then
                call SetUnitPathing(trigU, false)
                call SetUnitMoveSpeed(trigU, 522.00)
                call UnitRemoveAbility(trigU, Abils.FLY)
                call UnitAddAbility(trigU, Abils.LAND)
                
            elseif GetSpellAbilityId() == Abils.LAND then
                call SetUnitPathing(trigU, true)
                call SetUnitMoveSpeed(trigU, GetUnitDefaultMoveSpeed(trigU))
                call UnitRemoveAbility(trigU, Abils.LAND)
                call UnitAddAbility(trigU, Abils.FLY)
                
            elseif GetSpellAbilityId() == Abils.TELE_ON then
                call UnitRemoveAbility(trigU, Abils.TELE_ON)
                call UnitAddAbility(trigU, Abils.TELE_OFF)
                
            elseif GetSpellAbilityId() == Abils.TELE_OFF then
                call UnitRemoveAbility(trigU, Abils.TELE_OFF)
                call UnitAddAbility(trigU, Abils.TELE_ON)
                
            endif
            
        endif
    endif
        
    set trigU = null
endfunction

//===========================================================================
function InitTrig_DecoBuilder_Movement takes nothing returns nothing
    set gg_trg_DecoBuilder_Movement = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ(gg_trg_DecoBuilder_Movement, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerRegisterAnyUnitEventBJ(gg_trg_DecoBuilder_Movement, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    call TriggerAddAction(gg_trg_DecoBuilder_Movement, function Actions)
endfunction

endscope