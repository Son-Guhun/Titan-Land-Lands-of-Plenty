library FreeCam initializer Init requires OSKeyLib

globals
    private boolean array isEnabled
    private real speed = 5
endglobals

public function Enable takes player whichPlayer, boolean flag returns nothing
    set isEnabled[GetPlayerId(whichPlayer)] = flag
endfunction

public function IsEnabled takes player whichPlayer returns boolean
    return isEnabled[GetPlayerId(whichPlayer)]
endfunction

private function onTimer takes nothing returns nothing
    local real x = 0
    local real y = 0 
    
    if not isEnabled[User.fromLocal().id] then
        return
    endif
    
    call SetCameraQuickPosition(GetCameraTargetPositionX(), GetCameraTargetPositionY())

    if OSKeys.W.isPressed() then
        set y = y + speed
    endif
        
    if OSKeys.S.isPressed() then
        set y = y - speed
    endif
    
    if OSKeys.D.isPressed() then
        set x = x + speed
    endif
    
    if OSKeys.A.isPressed() then
        set x = x - speed
    endif
    
    if x != 0 or y != 0 then
        call SetCameraPosition(GetCameraTargetPositionX() + x, GetCameraTargetPositionY() + y)
    endif
    
    if OSKeys.SPACE.isPressed() then
        if OSKeys.LCONTROL.isPressed() then
            call SetCameraField(CAMERA_FIELD_ZOFFSET, GetCameraField(CAMERA_FIELD_ZOFFSET) - speed, 1/60.)
        else
            call SetCameraField(CAMERA_FIELD_ZOFFSET, GetCameraField(CAMERA_FIELD_ZOFFSET) + speed, 1/60.)
        endif
    endif
    
    if OSKeys.NUMPAD8.isPressed() then
        set speed = speed + 1./256
    endif
    
    if OSKeys.NUMPAD2.isPressed() then
        set speed = RMaxBJ(speed - 1./256, 0)
    endif
    
    
    if OSKeys.NUMPAD6.isPressed() then
        set speed = speed + 1./16
    endif
    
    if OSKeys.NUMPAD4.isPressed() then
        set speed = RMaxBJ(speed - 1./16, 0)
    endif
endfunction

private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(), 1./60, true, function onTimer)
    
    call OSKeys.W.register()
    call OSKeys.S.register()
    call OSKeys.A.register()
    call OSKeys.D.register()
    call OSKeys.SPACE.register()
    call OSKeys.LCONTROL.register()
    call OSKeys.NUMPAD8.register()
    call OSKeys.NUMPAD2.register()
    call OSKeys.NUMPAD4.register()
    call OSKeys.NUMPAD6.register()
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