scope CommandsRemoveKill

/*
struct G extends array
    //! runtextmacro TableStruct_NewConstTableField("public", "allowedTypes")
endstruct
*/

function Trig_Commands_Remove_Kill_Conditions takes nothing returns boolean
    local group g = CreateGroup()
    local unit u
    local integer i
    local player trigP = GetTriggerPlayer()
    local boolean remove = LoP_Command.getCommand() == "-remove"
    local boolean GM = trigP == udg_GAME_MASTER
    
    call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)
    set i = BlzGroupGetSize(g)
    loop
        //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
        
        if GM or LoP_PlayerOwnsUnit(trigP, u) or (/*G.allowedTypes.boolean.has(GetUnitTypeId(u)) and*/ GetOwningPlayer(u) == LoP.NEUTRAL_PASSIVE) then
            if remove then
                call LoP_RemoveUnit(u)
            else
                call LoP_KillUnit(u)
            endif
        else
            call LoP_WarnPlayerTimeout(trigP, LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit!")
        endif
    endloop
    
    call DestroyGroup(g)
    set g = null
    set u = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Remove_Kill takes nothing returns nothing
    call LoP_Command.create("-kill", ACCESS_USER, Condition(function Trig_Commands_Remove_Kill_Conditions))/*
    */.addHint(LoPHints.REMOVE_UNIT_HOTKEY).addHint(LoPHints.COMMAND_DELETEME)/*
    */.createChained("-remove", ACCESS_USER, Condition(function Trig_Commands_Remove_Kill_Conditions))/*
    */.useHintsFrom("-kill")
    
    // set G.allowedTypes.boolean['nshp'] = true
    // set G.allowedTypes.boolean['nbot'] = true
endfunction

endscope
