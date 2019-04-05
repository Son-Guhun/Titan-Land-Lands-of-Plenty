scope POWER
    public function INVULNERABILITY takes nothing returns unit
        return gg_unit_e00B_0405
    endfunction
    
    public function VULNERABILITY takes nothing returns unit
        return gg_unit_e00A_0411
    endfunction
    
    public function KILL takes nothing returns unit
        return gg_unit_e008_0406
    endfunction
    
    public function LEVEL takes nothing returns unit
        return gg_unit_e009_0407
    endfunction
    
    public function DELEVEL takes nothing returns unit
        return gg_unit_e00C_0408
    endfunction
    
    public function MIND takes nothing returns unit
        return gg_unit_e00D_0409
    endfunction
    
    public function REMOVE takes nothing returns unit
        return gg_unit_e007_0410
    endfunction
endscope

library LoPthree requires LoPone, LoPtwo

function LoP_RemoveUnit takes unit whichUnit returns nothing
    if not IsUnitInGroup(whichUnit, udg_System_ProtectedGroup) then
        if not LoP_IsUnitDecoration(whichUnit) then
            //call DisableTrigger(gg_trg_System_Cleanup_Removal)
            //call LoP_onRemoval(whichUnit)
            call RemoveUnit(whichUnit)  // Removing unit does not fire event immediately.
            //call EnableTrigger(gg_trg_System_Cleanup_Removal)
        else
            call DisableTrigger(gg_trg_System_Cleanup_Death)
            call LoP_onDeath(whichUnit)
            call KillUnit(whichUnit)
            call EnableTrigger(gg_trg_System_Cleanup_Death)
        endif
    endif
endfunction

function LoP_KillUnit takes unit whichUnit returns nothing
     if not IsUnitInGroup(whichUnit, udg_System_ProtectedGroup) then
        call DisableTrigger(gg_trg_System_Cleanup_Death)
        call LoP_onDeath(whichUnit)
        call KillUnit(whichUnit)
        call EnableTrigger(gg_trg_System_Cleanup_Death)
    endif   
endfunction
endlibrary

scope TitanPowers initializer onInit

private function GroupFilter takes nothing returns boolean
    if not RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) then
        call SetUnitOwner( GetFilterUnit(), udg_PowerSystem_Player, true )
    endif
    return false
endfunction

private function onOrder takes nothing returns boolean
    
    if GetIssuedOrderIdBJ() != String2OrderIdBJ("smart") then
        return false
    endif
    
    call IssueImmediateOrderBJ( GetTriggerUnit(), "stop" )
    if GetTriggerUnit() == POWER_MIND() then
        if udg_PowerSystem_allFlag then
            call GroupEnumUnitsOfPlayer(ENUM_GROUP, GetOwningPlayer(GetOrderTargetUnit()), Condition(function GroupFilter))
            set udg_PowerSystem_allFlag = false
        else
            call SetUnitOwner( GetOrderTargetUnit(), udg_PowerSystem_Player, true )
        endif
    elseif GetTriggerUnit() == POWER_INVULNERABILITY() then
            call SetUnitInvulnerable( GetOrderTargetUnit(), true )
    elseif GetTriggerUnit() == POWER_VULNERABILITY() then
            if not IsUnitInGroup(GetOrderTargetUnit(), udg_System_ProtectedGroup) then
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
    call TriggerRegisterUnitEvent( trig, POWER_MIND(), EVENT_UNIT_ISSUED_TARGET_ORDER )
    call TriggerAddCondition( trig, Condition( function onOrder ) )
endfunction

endscope

