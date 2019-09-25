function Trig_Commands_Take_Func004Func009A takes nothing returns nothing
    if ( GetOwningPlayer(GetEnumUnit()) == Player(PLAYER_NEUTRAL_PASSIVE) and IsUnitInGroup(GetEnumUnit(), udg_System_NeutralUnits[( GetConvertedPlayerId(GetTriggerPlayer()) - 1 )]) ) then
        if CheckCommandOverflow() then
            call SetUnitOwner( GetEnumUnit(), GetTriggerPlayer(), false )
            call GroupRemoveUnit(udg_System_NeutralUnits[( GetConvertedPlayerId(GetTriggerPlayer()) - 1 )], GetEnumUnit())
        endif
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit.")
    endif
endfunction

function Trig_Commands_Take_Func004Func013A takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    
    call GroupRemoveUnit(udg_System_NeutralUnits[GetPlayerId(GetTriggerPlayer())], enumUnit)
    
    if ( GetOwningPlayer(enumUnit) == Player(PLAYER_NEUTRAL_PASSIVE) ) then
        call SetUnitOwner(enumUnit, GetTriggerPlayer(), false)
    else
        call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This is not your unit.")
    endif
    
    set enumUnit = null
endfunction

function Trig_Commands_Take_Func004C takes nothing returns boolean
    if ( not ( GetEventPlayerChatString() == "-take" ) ) then
        return false
    endif
    return true
endfunction

function Trig_Commands_Take_Conditions takes nothing returns boolean
    local group g
    local string args = LoP_Command.getArguments()
    
    if ( args == "all" ) then
        call ForGroup(udg_System_NeutralUnits[( GetConvertedPlayerId(GetTriggerPlayer()) - 1 )], function Trig_Commands_Take_Func004Func013A )
    else
        set g = CreateGroup()
        call Commands_EnumSelectedCheckForGenerator(g, GetTriggerPlayer(), null)
        
        set udg_Commands_Counter = 0
        set udg_Commands_Counter_Max = 2000
        call ForGroup(g, function Trig_Commands_Take_Func004Func009A)
        
        call DestroyGroup(g)
        set g = null
    endif
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Take takes nothing returns nothing
    call LoP_Command.create("-take", ACCESS_USER, Condition(function Trig_Commands_Take_Conditions))
endfunction

