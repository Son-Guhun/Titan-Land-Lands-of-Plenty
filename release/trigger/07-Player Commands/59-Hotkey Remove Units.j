scope HotkeyDeleteUnits


private struct Config extends array

    static constant method operator METAKEY takes nothing returns integer
        return MetaKeys.SHIFT  // Use control because Alt would ping and Shift is used for queuing actions.
    endmethod

endstruct

private function onKey takes nothing returns boolean
    local group g
    local unit u
    local integer i
    local player trigP = GetTriggerPlayer()
    local boolean GM = trigP == udg_GAME_MASTER
    
    if BlzGetTriggerPlayerKey() == OSKEY_BACKSPACE and BlzGetTriggerPlayerIsKeyDown() and BitAll(BlzGetTriggerPlayerMetaKey(), Config.METAKEY) then
        set g = CreateGroup()
        call GroupEnumUnitsSelected(g, GetTriggerPlayer(), null)
        set i = BlzGroupGetSize(g)
        loop
            //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
            
            if GM or LoP_PlayerOwnsUnit(trigP, u) or GetOwningPlayer(u) == LoP.NEUTRAL_PASSIVE then
                call LoP_RemoveUnit(u)
            else
                call LoP_WarnPlayerTimeout(trigP, LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit!")
            endif
        endloop

        call DestroyGroup(g)
        set g = null
        set u = null
    endif
    
    return true
endfunction

//===========================================================================
function InitTrig_Hotkey_Remove_Units takes nothing returns nothing
    call OSKeys.BACKSPACE.register()    
    
    call OSKeys.addListener(Condition(function onKey))
endfunction

endscope
