scope HotkeyMoveUnits

private struct Config extends array

    static constant method operator META_KEY_LEFT takes nothing returns OSKeys
        return OSKeys.LCONTROL  // Use control because Alt would ping and Shift is used for queuing actions.
    endmethod
    
    static constant method operator META_KEY_RIGHT takes nothing returns OSKeys
        return OSKeys.RCONTROL
    endmethod

endstruct

private function onMousePress takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local group g
    local group g2
    local unit u
    
    local real centerX = 0.
    local real centerY = 0.
    local boolean hasStructure = false
    
    if PlayerMouseEvent_GetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT and (Config.META_KEY_LEFT.isPressedPlayer(trigP) or Config.META_KEY_RIGHT.isPressedPlayer(trigP)) then
        set g = CreateGroup()
        set g2 = CreateGroup()
        call GroupEnumUnitsSelected(g, trigP, null)
        call BlzGroupAddGroupFast(g, g2)
        
        loop
            //! runtextmacro ForUnitInGroup("u", "g")
            if GetOwningPlayer(u) != trigP then
                call GroupRemoveUnit(g2, u)
            else
                set centerX = centerX + GetUnitX(u)
                set centerY = centerY + GetUnitY(u)
                if IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                    set hasStructure = true
                endif
            endif
        endloop
        
        if BlzGroupGetSize(g2) > 0 then
            set centerX = centerX/BlzGroupGetSize(g2)
            set centerY = centerY/BlzGroupGetSize(g2)
            
            set centerX = PlayerMouseEvent_GetTriggerPlayerMouseX() - centerX
            set centerY = PlayerMouseEvent_GetTriggerPlayerMouseY() - centerY
            
            if hasStructure then
                set centerX = 64*(R2I(centerX)/64)
                set centerY = 64*(R2I(centerY)/64)
            endif
            loop
                //! runtextmacro ForUnitInGroup("u", "g2")
                call SetUnitPosition(u, GetUnitX(u) + centerX, GetUnitY(u) + centerY)
            endloop
        endif
        
        call DestroyGroup(g)
        call DestroyGroup(g2)
        set u = null
        set g = null
        set g2 = null
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Hotkey_Move_Units takes nothing returns nothing
    local trigger trig = CreateTrigger()
    
    call Config.META_KEY_LEFT.register()
    call Config.META_KEY_RIGHT.register()
    
    
    set ControlState.default.trigger[EVENT_PLAYER_MOUSE_UP] = trig
    call TriggerAddCondition(trig, Condition(function onMousePress))
    
    set trig = null
endfunction

endscope
