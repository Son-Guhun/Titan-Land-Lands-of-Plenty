scope CommandsSelectNo

private function SELECTABLE_ONLY_ABILITY takes nothing returns integer
    return 'A04U'
endfunction

private function ToEffect takes unit whichUnit returns nothing
    local DecorationEffect sfx

    if UnitHasAttachedEffect(whichUnit) then
        set sfx = UnitDetachEffect(whichUnit)
        call DecorationEffect.convertSpecialEffectNoPathing(LoP_GetOwningPlayer(whichUnit), sfx, UnitVisuals.get(whichUnit).hasColor())
        call ObjectPathing.get(whichUnit).disableAndTransfer(sfx.effect)
        call KillUnit(whichUnit)
    else
        call Unit2EffectEx(LoP_GetOwningPlayer(whichUnit), whichUnit)
        call KillUnit(whichUnit)
    endif
endfunction

globals
    private key MSGKEY_USE_F
    private key MSGKEY_NO_NEUTRAL
endglobals


private function EnumFunc takes nothing returns nothing
    local player trigP = GetTriggerPlayer()
    local unit enumUnit = GetEnumUnit()
    local player owner = LoP_GetOwningPlayer(enumUnit)
    
    if not LoP_GivesShareAccess(owner, trigP) and udg_GAME_MASTER != trigP then
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit." )
        
    elseif GetPlayerId(owner) >= bj_MAX_PLAYERS then
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, MSGKEY_NO_NEUTRAL, 0., "Neutral units cannot be unselectable." )
        
    elseif GetUnitAbilityLevel(enumUnit, SELECTABLE_ONLY_ABILITY()) > 0 then
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.INVALID, 0., "This type of unit cannot be made unselectable." )
        
    elseif not LoP_IsUnitDecoration(enumUnit) then
        if LoP_IsUnitHero(enumUnit) then
            call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.HERO, 0., "Heroes cannot be unselectable." ) 
        else
            if LoP_Command.getArguments() == "no f" then
                if GetOwningPlayer(enumUnit) == LoP.NEUTRAL_PASSIVE then
                    call SetUnitOwner(enumUnit, owner, false)  // This is required, otherwise neutral units must be enumed when a unit is made selectable.
                endif
               call GUMSMakeUnitLocust(enumUnit)
            else
                call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, MSGKEY_USE_F, 0., "You must use |cffffff00-select no f|r to make non-decorations unselectable." ) 
            endif
        endif
        
    else 
        if GetUnitAbilityLevel(enumUnit, 'Awrp') > 0 or (IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE) and GetUnitFlyHeight(enumUnit) < UnitVisuals.MIN_FLY_HEIGHT) then
            if GetOwningPlayer(enumUnit) == LoP.NEUTRAL_PASSIVE then
                call SetUnitOwner(enumUnit, owner, false)  // This is required, otherwise neutral units must be enumed when a unit is made selectable.
            endif
            call GUMSMakeUnitLocust(enumUnit)
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

