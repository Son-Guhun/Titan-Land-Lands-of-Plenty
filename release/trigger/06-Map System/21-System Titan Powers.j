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
        call KillUnit(whichUnit)  // More efficient to not even call this at all for decorations. TODO
        call LoP_onDeath(whichUnit)
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

