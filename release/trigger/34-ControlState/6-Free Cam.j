library FreeCam initializer Init requires OSKeyLib
/*
*   v1.0.0 - by Guhun
*
*
*   This is a simple free-moving camera.
*
* Controls:
* WASD -> Move on X or Y axis.
* IJKL -> Camera rotation
* SPACEBAR -> Move on up Z axis.
* CTRL + SPACEBAR -> Move down on Z axis.
*
*
************
* Configuration
************
*/

//! novjass
'                                                                                                  '
'                                              API                                                 '

/* 
    Functions
*/
$inline$ -> "this means a function inlines, so only natives are actually called"

// Enables or disables the system for a player.
$inline$
public function Enable takes player whichPlayer, boolean flag returns nothing

// Checks whether the system is enabled for a player.
$inline$
public function IsEnabled takes player whichPlayer returns boolean
'                                                                                                  '
'                                         Source Code                                              '
//! endnovjass

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
    
    local real pitch = 0
    local real yaw = 0
    
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
            call AdjustCameraField(CAMERA_FIELD_ZOFFSET, -speed, 1/64.)
        else
            call AdjustCameraField(CAMERA_FIELD_ZOFFSET, speed, 1/64.)
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
    
    if OSKeys.I.isPressed() then
        set pitch = pitch + 1
    endif
    
    if OSKeys.K.isPressed() then
        set pitch = pitch - 1
    endif
    
    if OSKeys.L.isPressed() then
        set yaw = yaw - 1
    endif
    
    if OSKeys.J.isPressed() then
        set yaw = yaw + 1
    endif
    
    if pitch != 0 then
        call AdjustCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, pitch, 1/64.)
    endif
    
    if yaw != 0 then
        call AdjustCameraField(CAMERA_FIELD_ROTATION, yaw, 1/64.)
    endif
endfunction

private function Init takes nothing returns nothing
    call TimerStart(CreateTimer(), 1./64, true, function onTimer)
    
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
    
    call OSKeys.I.register()
    call OSKeys.K.register()
    call OSKeys.J.register()
    call OSKeys.L.register()
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