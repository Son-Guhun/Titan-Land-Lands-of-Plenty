scope TitanPowers initializer onInit
/*
    Perform an action when a Titan Power is issued a "smart" order targeting a unit.
*/

private function onOrder takes nothing returns boolean
    
    if GetIssuedOrderIdBJ() != String2OrderIdBJ("smart") then
        return false
    endif
    
    call IssueImmediateOrderBJ(GetTriggerUnit(), "stop")  // prevent Power from leaving its position.
    
    if GetTriggerUnit() == POWER_INVULNERABILITY() then
        call SetUnitInvulnerable( GetOrderTargetUnit(), true )
    elseif GetTriggerUnit() == POWER_VULNERABILITY() then
        if not IsUnitInGroup(GetOrderTargetUnit(), udg_System_ProtectedGroup) or GetOrderTargetUnit() == HERO_COSMOSIS() or GetOrderTargetUnit() == HERO_CREATOR() then
            call SetUnitInvulnerable( GetOrderTargetUnit(), false )
        endif
    elseif GetTriggerUnit() == POWER_DELEVEL() then
        call UnitStripHeroLevel(GetOrderTargetUnit(), 1)
    elseif GetTriggerUnit() == POWER_LEVEL() then
        call SetHeroLevel(GetOrderTargetUnit(), GetHeroLevel(GetOrderTargetUnit()) + 1, false)
    elseif GetTriggerUnit() == POWER_KILL() then
        call LoP_KillUnit(GetOrderTargetUnit())
    elseif GetTriggerUnit() == POWER_REMOVE() then
        call LoP_RemoveUnit(GetOrderTargetUnit())
    endif
    
    return false
endfunction

//===========================================================================
private function onInit takes nothing returns nothing
    local trigger trig = CreateTrigger(  )
    call TriggerRegisterUnitEvent( trig, POWER_REMOVE(), EVENT_UNIT_ISSUED_TARGET_ORDER )
    call TriggerRegisterUnitEvent( trig, POWER_KILL(), EVENT_UNIT_ISSUED_TARGET_ORDER )
    call TriggerRegisterUnitEvent( trig, POWER_DELEVEL(), EVENT_UNIT_ISSUED_TARGET_ORDER )
    call TriggerRegisterUnitEvent( trig, POWER_LEVEL(), EVENT_UNIT_ISSUED_TARGET_ORDER )
    call TriggerRegisterUnitEvent( trig, POWER_INVULNERABILITY(), EVENT_UNIT_ISSUED_TARGET_ORDER )
    call TriggerRegisterUnitEvent( trig, POWER_VULNERABILITY(), EVENT_UNIT_ISSUED_TARGET_ORDER )
    call TriggerAddCondition( trig, Condition( function onOrder ) )
endfunction

endscope

