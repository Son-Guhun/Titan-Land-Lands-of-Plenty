scope CommandsSelectNo

private function SELECTABLE_ONLY_ABILITY takes nothing returns integer
    return 'A04U'
endfunction

private function ToEffect takes unit whichUnit returns nothing
    local DecorationEffect sfx

    if UnitHasAttachedEffect(whichUnit) then
        set sfx = UnitDetachEffect(whichUnit)
        call DecorationEffect.convertSpecialEffect(LoP_GetOwningPlayer(whichUnit), sfx, UnitVisuals.get(whichUnit).hasColor())
        call KillUnit(whichUnit)
    else
        call Unit2EffectEx(LoP_GetOwningPlayer(whichUnit), whichUnit)
        call KillUnit(whichUnit)
    endif
endfunction

private function EnumFunc takes nothing returns nothing
    local player trigP = GetTriggerPlayer()
    local unit enumUnit = GetEnumUnit()
    
    if not LoP_PlayerOwnsUnit(trigP, enumUnit) and udg_GAME_MASTER != trigP then
        call DisplayTextToPlayer(trigP, 0, 0, "This is not your unit." )
        
    elseif GetUnitAbilityLevel(enumUnit, SELECTABLE_ONLY_ABILITY()) > 0 then
        call DisplayTextToPlayer(trigP, 0, 0, "This type of unit cannot be made unselectable." )
        
    elseif not LoP_IsUnitDecoration(enumUnit) then
        if LoP_IsUnitHero(enumUnit) then
            call DisplayTextToPlayer(trigP, 0, 0, "Heroes cannot be unselectable." ) 
        else
            if LoP_Command.getArguments() == "no f" then
               call PauseUnit(enumUnit, true)
               call SetUnitOwner(enumUnit, trigP, false)  // This is required, otherwise neutral units must be enumed when a unit is made unselectable.
               call GUMSMakeUnitLocust(enumUnit)
            else
                call DisplayTextToPlayer(trigP, 0, 0, "You must use |cffffff00-select no f|r to make non-decorations unselectable." ) 
            endif
        endif
        
    else 
        if GetUnitAbilityLevel(enumUnit, 'Awrp') > 0 or (IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE) and GetUnitFlyHeight(enumUnit) < GUMS_MINIMUM_FLY_HEIGHT()) then
            call GUMSMakeUnitUnSelectable(enumUnit)
        else
            if CheckCommandOverflow() then
                call ToEffect(enumUnit)
            endif
        endif
    endif
    
    set enumUnit = null
endfunction

private function onCommand takes nothing returns boolean
    local group g

    if LoP_Command.getArguments() == "no" or LoP_Command.getArguments() == "no f" then
        set g = CreateGroup()
        
        call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
        call BlzGroupRemoveGroupFast(udg_System_ProtectedGroup, g)
        set udg_Commands_Counter = 0
        set udg_Commands_Counter_Max = 500
        call ForGroup( g, function EnumFunc )
        
        call DestroyGroup(g)
        set g = null
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Select_No takes nothing returns nothing
    call LoP_Command.create("-select", ACCESS_USER, Condition(function onCommand))
endfunction

endscope

