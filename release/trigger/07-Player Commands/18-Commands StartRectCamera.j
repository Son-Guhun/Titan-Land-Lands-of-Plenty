/*
This trigger contains commands for:

-Spawning a Wandering Soul
-Spawning a Rect Generator
-Camera adjustments
*/
struct CameraValues extends array
    
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticPrimitiveField("zoom","real")
    //! runtextmacro TableStruct_NewStaticPrimitiveField("rotate","real")
    //! runtextmacro TableStruct_NewStaticPrimitiveField("roll","real")
    //! runtextmacro TableStruct_NewStaticPrimitiveField("pitch","real")
    
    //! runtextmacro TableStruct_NewStaticHandleField("timer","timer")
    
    private static method onTimer takes nothing returns nothing
        call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, .zoom, 0)
        call SetCameraField(CAMERA_FIELD_ROTATION, .rotate, 0)
        call SetCameraField(CAMERA_FIELD_ROLL, .roll, 0)
        call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, .pitch, 0)
    endmethod
    
    static method lock takes nothing returns nothing
        call TimerStart(.timer, 0.03, true, function thistype.onTimer)  // Need initialized timer: can't create a local time handle
    endmethod
    
    static method unlock takes nothing returns nothing
        call PauseTimer(.timer)
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
                if GetTriggerPlayer() == GetLocalPlayer() then
                    set CameraValues.zoom = value
                    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, value, 0 )
                endif
            elseif ( field == "rotate" ) then
                if GetTriggerPlayer() == GetLocalPlayer() then
                    set CameraValues.rotate = value
                    call SetCameraField(CAMERA_FIELD_ROTATION, value, 0 )
                endif
            elseif ( field == "roll" ) then
                if GetTriggerPlayer() == GetLocalPlayer() then
                    set CameraValues.roll = value
                    call SetCameraField(CAMERA_FIELD_ROLL, value, 0 )
                endif
            elseif ( field == "pitch" ) then
                if GetTriggerPlayer() == GetLocalPlayer() then
                    set CameraValues.pitch = value
                    call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, value, 0 )
                endif
            endif
        else
            // Lock/Unlock
            if ( field == "lock" ) then
                if GetTriggerPlayer() == GetLocalPlayer() then
                    set CameraValues.zoom = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
                    set CameraValues.rotate = GetCameraField(CAMERA_FIELD_ROTATION)*bj_RADTODEG
                    set CameraValues.roll = GetCameraField(CAMERA_FIELD_ROLL)*bj_RADTODEG
                    set CameraValues.pitch = GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)*bj_RADTODEG
                    call CameraValues.lock()
                endif
            elseif ( field == "unlock" ) then
                if GetTriggerPlayer() == GetLocalPlayer() then
                    call CameraValues.unlock()
                endif
            // Presets
            elseif ( field == "far" ) then
                if GetTriggerPlayer() == GetLocalPlayer() then
                    set CameraValues.zoom = 3000
                    call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 3000, 0 )
                endif
            endif
        endif
    endif

    return false
endfunction

//===========================================================================
function InitTrig_Commands_StartRectCamera takes nothing returns nothing
    call LoP_Command.create("-c", ACCESS_USER, Condition(function Trig_Commands_Camera))
    call LoP_Command.create("-cam", ACCESS_USER, Condition(function Trig_Commands_Camera))
    call LoP_Command.create("-camera", ACCESS_USER, Condition(function Trig_Commands_Camera))
    call LoP_Command.create("-zoom", ACCESS_USER, Condition(function Trig_Commands_Camera))
    set CameraValues.timer = CreateTimer()
endfunction

