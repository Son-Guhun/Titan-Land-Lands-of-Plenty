/*
This trigger contains commands for:

-Spawning a Wandering Soul
-Spawning a Rect Generator
-Camera adjustments
*/
struct CameraValues extends array
    
    static real zoom = 0
    static real rotate = 0
    static real roll = 0
    static real pitch = 0
    static real zoffset = 0
    static boolean locked = false
    
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticHandleField("timer","timer")
    
    private static method onTimer takes nothing returns nothing
        if .locked then
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, .zoom, 0)
            call SetCameraField(CAMERA_FIELD_ROTATION, .rotate, 0)
            call SetCameraField(CAMERA_FIELD_ROLL, .roll, 0)
            call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, .pitch, 0)
        endif
    endmethod
    
    static method startTimer takes nothing returns nothing
        call TimerStart(.timer, 0.03, true, function thistype.onTimer)
    endmethod
    
    static method lock takes nothing returns nothing
        set .locked = true
    endmethod
    
    static method unlock takes nothing returns nothing
        set .locked = false
    endmethod
endstruct

function Trig_Commands_Camera takes nothing returns boolean
    local string command = LoP_Command.getCommand()
    local string args = LoP_Command.getArguments()
    local integer cutToComma
    local string field
    local real value
    
    if command == "-zoom" then
        set value = S2R(args)
        if GetTriggerPlayer() == GetLocalPlayer() then
            set CameraValues.zoom = value
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, value, 0 )
        endif
    else  // general camera commands
        set cutToComma = CutToCharacter(args, " ")
        set field = SubString(args, 0, cutToComma)
        if cutToComma < StringLength(args) then
            set value = S2R(SubString(args, cutToComma+1, StringLength(args)))
            
            // Local player blocks inside because we don't want to create strings in local blocks!!!
            if ( field == "zoom" ) then
                if GetLocalPlayer() == GetTriggerPlayer()  then
                    set CameraValues.zoom = value
                    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, value, 0 )
                endif
            elseif ( field == "rotate" ) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set CameraValues.rotate = value
                    call SetCameraField(CAMERA_FIELD_ROTATION, value, 0 )
                endif
            elseif ( field == "roll" ) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set CameraValues.roll = value
                    call SetCameraField(CAMERA_FIELD_ROLL, value, 0 )
                endif
            elseif ( field == "pitch" ) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set CameraValues.pitch = value
                    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, value, 0 )
                endif
            elseif ( field == "zoffset" ) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set CameraValues.zoffset = value
                    call SetCameraField(CAMERA_FIELD_ZOFFSET, value, 0 )
                endif
            elseif (field == "smoothness") then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call CameraSetSmoothingFactor(value)
                endif
            endif
        else
            // Lock/Unlock
            if ( field == "lock" ) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set CameraValues.zoom = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
                    set CameraValues.rotate = GetCameraField(CAMERA_FIELD_ROTATION)*bj_RADTODEG
                    set CameraValues.roll = GetCameraField(CAMERA_FIELD_ROLL)*bj_RADTODEG
                    set CameraValues.pitch = GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)*bj_RADTODEG
                    set CameraValues.zoffset = GetCameraField(CAMERA_FIELD_ZOFFSET)
                    call CameraValues.lock()
                endif
            elseif ( field == "unlock" ) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call CameraValues.unlock()
                endif
            // Presets
            elseif ( field == "far" ) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set CameraValues.zoom = 3000
                    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 3000, 0 )
                endif
            endif
        endif
    endif

    return false
endfunction

//===========================================================================
function InitTrig_Commands_Camera takes nothing returns nothing
    call LoP_Command.create("-c", ACCESS_USER, Condition(function Trig_Commands_Camera))
    call LoP_Command.create("-cam", ACCESS_USER, Condition(function Trig_Commands_Camera))
    call LoP_Command.create("-camera", ACCESS_USER, Condition(function Trig_Commands_Camera))
    call LoP_Command.create("-zoom", ACCESS_USER, Condition(function Trig_Commands_Camera))
    set CameraValues.timer = CreateTimer()
    call CameraValues.startTimer()
endfunction

