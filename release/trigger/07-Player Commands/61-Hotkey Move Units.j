scope HotkeyMoveUnits
/*
========
Description
========

    Scripts the teleporation of units when a player releases a mouse button while holding a certain
metakey combination. The button and key combination can be configured below.

    Creates a trigger at map initialization and sets it as the response to EVENT_PLAYER_MOUSE_UP of
the default ControlState.

========
Cofiguration
========
*/
private struct Config extends array

    static constant method operator METAKEY takes nothing returns integer
        return MetaKeys.CTRL + MetaKeys.SHIFT  // Use control because Alt would ping and Shift is used for queuing actions.
    endmethod
    
    static constant method operator MOUSE_BUTTON takes nothing returns mousebuttontype
        return MOUSE_BUTTON_TYPE_LEFT
    endmethod
    
endstruct

// ========================
// Source Code
// ========================


// We need to use FuncHooks since units will be moved around.
//! runtextmacro DefineHooks()

private function onMousePress takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local group g
    local group g2
    local unit u
    
    local real centerX = 0.
    local real centerY = 0.
    local boolean hasStructure = false
    
    if PlayerMouseEvent_GetTriggerPlayerMouseX() == 0. and PlayerMouseEvent_GetTriggerPlayerMouseY() == 0. then
        // do nothing
    else
        if not IsPlayerMouseOnButton(trigP) and PlayerMouseEvent_GetTriggerPlayerMouseButton() == Config.MOUSE_BUTTON and Config.METAKEY == OSKeys.getPressedMetaKeys(trigP) then
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
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Hotkey_Move_Units takes nothing returns nothing
    local trigger trig = CreateTrigger()
    
    call OSKeys.registerMetaKey(Config.METAKEY)
    
    set ControlState.default.trigger[EVENT_PLAYER_MOUSE_UP] = trig
    call TriggerAddCondition(trig, Condition(function onMousePress))
    
    set trig = null
endfunction

endscope
