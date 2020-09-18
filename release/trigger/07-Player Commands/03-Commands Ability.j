library LoPCommandsAbility requires CustomizableAbilityList, LoPWarn

globals
    private key MSGKEY_MAXABILS
    private key MSGKEY_UNITABIL
endglobals

private function MAX_ABILITIES takes nothing returns integer
    return 7
endfunction

public function AddAbility takes unit whichUnit, integer rawcode returns nothing
    local ArrayList_ability abilities = UnitEnumRemoveableAbilities(whichUnit)
    
    if abilities.size() >= MAX_ABILITIES() then
    
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, MSGKEY_MAXABILS, 5., "This hero already has " + I2S(MAX_ABILITIES()) + " abilities.")
    elseif not RemoveableAbility(rawcode).isHero then
    
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, MSGKEY_UNITABIL, 5., "Unit abilities can only be removed, not added.")
    else
        call UnitAddAbility(whichUnit, rawcode)
    endif
    
    call abilities.destroy()
endfunction

public function RemoveAbility takes unit whichUnit, integer rawcode returns nothing
    if UnitRemoveAbility(whichUnit, rawcode) then
        if IsAbilityAuraToggle(rawcode) then
            call UnitRemoveAbility(whichUnit, GetToggleAbilityAura(rawcode))
        endif
    endif
endfunction

public function ClearAbilities takes unit whichUnit returns nothing
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

endlibrary

scope CommandsAbility



private function OnCommand_GroupEnum takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local integer cutToComma = CutToCharacter(args, " ")
    local string subcommand = SubString(args, 0, cutToComma)
    
    if LoP_IsUnitProtected(GetFilterUnit()) then
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.ERROR, "This hero's abilities cannot be altered.")
        return false
    endif
    
    if StringLength(args) != cutToComma then
        set args = SubString(args, cutToComma + 1, 0)
        
        if not IsAbilityRemoveable(S2ID(args)) then
            call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.ERROR, "Invalid ability code.")
            return false
        endif
    else
        set args = ""
    endif
    
    
    if GetOwningPlayer(GetFilterUnit()) != GetTriggerPlayer() and GetTriggerPlayer() != udg_GAME_MASTER then
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit!")
        
    elseif not LoP_IsUnitHero(GetFilterUnit()) then
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.HERO, 0., "The ability command can only be used on heroes.")
    
    else
    
        if subcommand == "a" or subcommand == "add" then
            call LoPCommandsAbility_AddAbility(GetFilterUnit(), S2ID(args))
        elseif subcommand == "r" or subcommand == "rem" or subcommand == "remove" then
            call LoPCommandsAbility_RemoveAbility(GetFilterUnit(), S2ID(args))
        elseif subcommand == "c" or subcommand == "clear" then
            call LoPCommandsAbility_ClearAbilities(GetFilterUnit())
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
