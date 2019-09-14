library LoPthree requires LoPCleanUpDeath, LoPCleanUpRemoval

function LoP_RemoveUnit takes unit whichUnit returns nothing       // Dummy point value
    if not IsUnitInGroup(whichUnit, udg_System_ProtectedGroup) and GetUnitPointValue(whichUnit) != 37 then
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

private function MindPower takes unit target returns nothing
    local player owner = GetOwningPlayer(target)
    local LinkedHashSet_DecorationEffect decorations 
    local DecorationEffect i
    local integer color = GetHandleId(LoP_PlayerData.get(owner).getUnitColor())
    
    if udg_PowerSystem_allFlag then
            set decorations = EnumDecorationsOfPlayer(owner)
            set i = decorations.begin()
            
            loop
            exitwhen i == decorations.end()
                call i.setOwner(udg_PowerSystem_Player)
                set i = decorations.next(i)
            endloop
            call decorations.destroy()
    
            call GroupEnumUnitsOfPlayer(ENUM_GROUP, owner, Condition(function GroupFilter))
            set udg_PowerSystem_allFlag = false
        else
            call SetUnitOwner( target, udg_PowerSystem_Player, true )
    endif
endfunction

private function onOrder takes nothing returns boolean
    
    if GetIssuedOrderIdBJ() != String2OrderIdBJ("smart") then
        return false
    endif
    
    call IssueImmediateOrderBJ( GetTriggerUnit(), "stop" )
    if GetTriggerUnit() == POWER_MIND() then
        call MindPower(GetOrderTargetUnit())
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
