scope CommandsAbility

private function AddAbility takes unit whichUnit, integer rawcode returns nothing
    local ArrayList_ability abilities = UnitEnumRemoveableAbilities(whichUnit)
    
    if abilities.size() >= 4 then
    
        call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "This hero already has 4 abilities.")
    elseif not RemoveableAbility(rawcode).isHero then
    
        call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "Unit abilities can only be removed, not added.")
    else
        call UnitAddAbility(whichUnit, rawcode)
    endif
    
    call abilities.destroy()
endfunction

private function RemoveAbility takes unit whichUnit, integer rawcode returns nothing
    if UnitRemoveAbility(whichUnit, rawcode) then
        if IsAbilityAuraToggle(rawcode) then
            call UnitRemoveAbility(whichUnit, GetToggleAbilityAura(rawcode))
        endif
    endif
endfunction

private function ClearAbilities takes unit whichUnit returns nothing
    local ArrayList_ability abilities = UnitEnumRemoveableAbilities(whichUnit)
    local integer abilId
    local integer i = 0
    
    loop
    exitwhen i == abilities.end()
        set abilId = RemoveableAbility.fromAbility(abilities[i])
        call UnitRemoveAbility(whichUnit, abilId)
        if IsAbilityAuraToggle(abilId) then
            call UnitRemoveAbility(whichUnit, GetToggleAbilityAura(abilId))
        endif
        set i = abilities.next(i)
    endloop
    
    call abilities.destroy()
endfunction

private function OnCommand_GroupEnum takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local integer cutToComma = CutToCharacter(args, " ")
    local string subcommand = SubString(args, 0, cutToComma)
    
    if StringLength(args) != cutToComma then
        set args = SubString(args, cutToComma + 1, 0)
        
        if not IsAbilityRemoveable(S2ID(args)) then
            call DisplayTextToPlayer(GetTriggerPlayer(), 0., 0., "Invalid ability code.")
            return false
        endif
    else
        set args = ""
    endif
    
    
    if GetOwningPlayer(GetFilterUnit()) != GetTriggerPlayer() and GetTriggerPlayer() != udg_GAME_MASTER then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit!")
        
    elseif not LoP_IsUnitHero(GetFilterUnit()) then
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "The ability command can only be used on heroes.")
    
    else
    
        if subcommand == "a" or subcommand == "add" then
            call AddAbility(GetFilterUnit(), S2ID(args))
        elseif subcommand == "r" or subcommand == "rem" or subcommand == "remove" then
            call RemoveAbility(GetFilterUnit(), S2ID(args))
        elseif subcommand == "c" or subcommand == "clear" then
            call ClearAbilities(GetFilterUnit())
        endif
    endif
    return false
endfunction

private function OnCommand takes nothing returns boolean
    call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Filter(function OnCommand_GroupEnum ))
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Ability takes nothing returns nothing
    call LoP_Command.create("-ability", ACCESS_USER, Condition(function OnCommand ))
    call LoP_Command.create("-abil", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope
