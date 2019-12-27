library FreeCam initializer Init

globals
    boolean array isPressed
    real speed = 5
endglobals

struct MetaKeys extends array

    static constant method operator NONE takes nothing returns integer
        return 0
    endmethod

    static constant method operator SHIFT takes nothing returns integer
        return 1
    endmethod
    
    static constant method operator CTRL takes nothing returns integer
        return 2
    endmethod
    
    static constant method operator ALT takes nothing returns integer
        return 4
    endmethod

endstruct

function onKey takes nothing returns nothing 
    set isPressed[GetHandleId(BlzGetTriggerPlayerKey())] = BlzGetTriggerPlayerIsKeyDown()
endfunction

function IsPressed takes oskeytype key returns boolean
    return isPressed[GetHandleId(key)]
endfunction

private function onTimer takes nothing returns nothing
    local real x = 0
    local real y = 0 
    
    call SetCameraQuickPosition(GetCameraTargetPositionX(), GetCameraTargetPositionY())

    if IsPressed(OSKEY_W) then
        set y = y + speed
    endif
        
    if IsPressed(OSKEY_S) then
        set y = y - speed
    endif
    
    if IsPressed(OSKEY_D) then
        set x = x + speed
    endif
    
    if IsPressed(OSKEY_A) then
        set x = x - speed
    endif
    
    if x != 0 or y != 0 then
        call SetCameraPosition(GetCameraTargetPositionX() + x, GetCameraTargetPositionY() + y)
    endif
    
    if IsPressed(OSKEY_SPACE) then
        if IsPressed(OSKEY_LCONTROL) then
            call SetCameraField(CAMERA_FIELD_ZOFFSET, GetCameraField(CAMERA_FIELD_ZOFFSET) - speed, 0)
        else
            call SetCameraField(CAMERA_FIELD_ZOFFSET, GetCameraField(CAMERA_FIELD_ZOFFSET) + speed, 0)
        endif
    endif
    
    if IsPressed(OSKEY_NUMPAD8) then
        set speed = speed + 1./256
    endif
    
    if IsPressed(OSKEY_NUMPAD2) then
        set speed = RMaxBJ(speed - 1./256, 0)
    endif
    
    
    if IsPressed(OSKEY_NUMPAD6) then
        set speed = speed + 1./16
    endif
    
    if IsPressed(OSKEY_NUMPAD4) then
        set speed = RMaxBJ(speed - 1./16, 0)
    endif
endfunction

function RegisterKeyEvent takes trigger whichTrigger, player whichPlayer, oskeytype whichKey returns nothing
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.NONE, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.NONE, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.ALT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.ALT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL + MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL + MetaKeys.ALT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL + MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL + MetaKeys.ALT, true)
endfunction

function Init takes nothing returns nothing
    local trigger trig = CreateTrigger()
    
    call RegisterKeyEvent(trig, Player(0), OSKEY_W)
    call RegisterKeyEvent(trig, Player(0), OSKEY_S)
    call RegisterKeyEvent(trig, Player(0), OSKEY_D)
    call RegisterKeyEvent(trig, Player(0), OSKEY_A)
    
    call RegisterKeyEvent(trig, Player(0), OSKEY_SPACE)
    call RegisterKeyEvent(trig, Player(0), OSKEY_LCONTROL)
    
    call RegisterKeyEvent(trig, Player(0), OSKEY_NUMPAD8)
    call RegisterKeyEvent(trig, Player(0), OSKEY_NUMPAD2)
    
    call RegisterKeyEvent(trig, Player(0), OSKEY_NUMPAD4)
    call RegisterKeyEvent(trig, Player(0), OSKEY_NUMPAD6)
    

    call TriggerAddAction(trig, function onKey)
    
    call TimerStart(CreateTimer(), 1./60, true, function onTimer)
    
    set trig = null
endfunction

endlibrary


/*
CAMERA_FIELD_ANGLE_OF_ATTACK
CAMERA_FIELD_ROTATION

BlzTriggerRegisterPlayerKeyEvent
BlzGetTriggerPlayerKey
BlzGetTriggerPlayerMetaKey
BlzGetTriggerPlayerIsKeyDown
*/