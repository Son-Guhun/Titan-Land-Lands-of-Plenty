library ThirdPersonCamera
//===========================================================================
// First Person Camera System v1.1.0
//===========================
// Author: Guhun
// If you use this in your map, credits would be greatly appreciated!

// Changelog:
// 1.1.0 => Mouse movement will now only occur if the angle between the pointer and the unit is more
// than a certain minimum value. A new command has been added to allow player to change this value.

//===========================================================================
// Configuration
//===============
// Help message

// If this is returns false, then the Help Message will not be displayed when a player enters first 
// person view for the first time.
constant function Camera_HELP_FIRST_TIME takes nothing returns boolean
    return true
endfunction

// This is the Help Message displayed by the help command.
constant function Camera_HELP_MESSAGE takes nothing returns string
    return "First Person Camera Enabled!\n\nTo leave this perspective, double-click the |c00ffff00Esc|r key.\nTo fix the camera to the unit's facing, click the |c00ffff00Esc|r key.\nTo allow the camera to move independently, click the |c00ffff00Esc|r key.\n\nYou can use the |c00ffff00left|r and |c00ffff00right|r arrow keys to move the camera.\nYou can find the commands for the camera by pressing |c00ffff00F9|r."
endfunction
//===============
// Camera

// The time it takes for the camera to transition between first person and third person
function Camera_TransitionTime takes nothing returns real
    return 1.0
endfunction

// Should be 0.25 for multiplayer and 0.12 for single player
function Camera_SleepCompensator takes nothing returns real
    return 0.25
endfunction

// Command used to set camera to first person.
// If this function returns an empty string, then the commands will be disabled.
constant function Camera_FP_COMMAND takes nothing returns string
    return "-first person"
endfunction

// Command used to set camera to third person.
constant function Camera_TP_COMMAND takes nothing returns string
    return "-third person"
endfunction

// Command used to set camera to be fixed to the target unit's current facing angle.
constant function Camera_FIXED_COMMAND takes nothing returns string
    return "-fixed camera"
endfunction

// Command used to set camera to be free, allowing the user to move it while target is moving.
constant function Camera_FREE_COMMAND takes nothing returns string
    return "-free camera"
endfunction

// Command used to display the Help Message.
constant function Camera_HELP_COMMAND takes nothing returns string
    return "-help camera"
endfunction

// Command used to display the Help Message.
constant function Camera_MIN_ANGLE_COMMAND takes nothing returns string
    return "-sensitivity "
endfunction
//===============
// Dummy Units

// Unit Type of the dummy units
constant function Camera_DUMMY_TYPE takes nothing returns integer
    return 'nvil'
endfunction

// X of the point where dummy units are created.
constant function Camera_DUMMY_X takes nothing returns real
    return 0.0
endfunction

// Y of the point where dummy units are created.
constant function Camera_DUMMY_Y takes nothing returns real
    return 0.0
endfunction

// The owner of the Dummy Units. If GetEnumPlayer() is returned, each player will own his own dummy.
function Camera_Dummy_Owner takes nothing returns player
    return Player(bj_PLAYER_NEUTRAL_EXTRA)  // GetEnumPlayer()
endfunction
//===========================================================================
//===============

globals
    private hashtable data = InitHashtable()
    
    private trigger triggerMouse = CreateTrigger()
    private trigger triggerLeft = CreateTrigger()
    private trigger triggerRight = CreateTrigger()
    private trigger triggerEsc = CreateTrigger()
    private trigger triggerCleanup = CreateTrigger()
    
    private unit array focusUnits
endglobals

//===========================================================================
//===============
// Hashtable Constants (saved in child hashtable of key = PlayerId of player)

constant function Camera_ESC_KEY takes nothing returns integer
    return 0
endfunction

constant function Camera_LEFT_KEY takes nothing returns integer
    return 1
endfunction

constant function Camera_RIGHT_KEY takes nothing returns integer
    return 2
endfunction

constant function Camera_MIN_ANGLE takes nothing returns integer
    return 3
endfunction

//===========================================================================
// Utility Functions
//===============
// Setters
function Camera_SetDefaultRotator takes integer playerId, unit whichUnit returns nothing
    set focusUnits[playerId + 2*bj_MAX_PLAYERS] = whichUnit
endfunction

function Camera_SetRotator takes integer playerId, unit whichUnit returns nothing
    set focusUnits[playerId+bj_MAX_PLAYERS] = whichUnit
endfunction

function Camera_SetTarget takes integer playerId, unit whichUnit returns nothing
    set focusUnits[playerId] = whichUnit
endfunction

//===============
// Getters
function Camera_GetDefaultRotator takes integer playerId returns unit
    return focusUnits[playerId + 2*bj_MAX_PLAYERS]
endfunction

function Camera_GetRotator takes integer playerId returns unit
    return focusUnits[playerId+bj_MAX_PLAYERS]
endfunction

function Camera_GetTarget takes integer playerId returns unit
    return focusUnits[playerId]
endfunction
//===========================================================================
// API
//===============
function Camera_WasHelpSeen takes integer playerId returns boolean
    return not HaveSavedBoolean(data, playerId, -1)
endfunction

function Camera_SetHelpSeen takes integer playerId, boolean flag returns nothing
    if flag then
        call RemoveSavedBoolean(data, playerId, -1)
    else
        call SaveBoolean(data, playerId, -1, true)
    endif
endfunction

function Camera_SetFirstPerson takes player whichPlayer, unit whichUnit returns nothing
    local real sleepTime
    
    if not Camera_WasHelpSeen(GetPlayerId(whichPlayer)) then
        call DisplayTextToPlayer(whichPlayer, 0, 0, Camera_HELP_MESSAGE())
        call Camera_SetHelpSeen(GetPlayerId(whichPlayer), true)
    endif
        
    
    call SetCameraTargetControllerNoZForPlayer(whichPlayer, whichUnit, 0.00, 0, true )
    
    set sleepTime = Camera_TransitionTime() - Camera_SleepCompensator()  // Compensate for inaccuracy
    if sleepTime > 0 then
            if GetLocalPlayer() == whichPlayer then
            call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 350.00, Camera_TransitionTime() )
            call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 140.00, Camera_TransitionTime() )
            call SetCameraField(CAMERA_FIELD_ZOFFSET, ( GetUnitFlyHeight(whichUnit) + 125.00 ), Camera_TransitionTime() )
            
            call TriggerSleepAction(sleepTime)
            call StopCamera()  // Stop camera movement to avoid bugs
        else
            call TriggerSleepAction(sleepTime)
        endif
    endif
    
    call Camera_SetTarget(GetPlayerId(whichPlayer), whichUnit)
    call Camera_SetRotator(GetPlayerId(whichPlayer), Camera_GetDefaultRotator(GetPlayerId(whichPlayer)))
endfunction

function Camera_SetThirdPerson takes player whichPlayer returns nothing
    call Camera_SetTarget(GetPlayerId(whichPlayer), null)
    if GetLocalPlayer() == whichPlayer then
        call StopCamera()
        call ResetToGameCamera(Camera_TransitionTime())
    endif
endfunction

function Camera_SetFirstPersonSelected takes player p returns nothing
    local unit u
    local group g = CreateGroup()

    call GroupEnumUnitsSelected(g, p, null)
    set u = FirstOfGroup(g)
    
    call Camera_SetFirstPerson(p, u)
    
    call DestroyGroup(g)
    set g = null
    set u = null
endfunction

// Clears ALL of a player's data related to this system, including the default rotation unit and timers.
function Camera_ClearPlayerData takes player whichPlayer returns nothing
    local integer playerId = GetPlayerId(whichPlayer)

    // Flushing this will also destroy timers for arrow keys
    call FlushChildHashtable(data, playerId)  
    
    // Remove useless unit and null everything to avoid handle reference leaks
    call RemoveUnit(Camera_GetDefaultRotator(playerId))
    call Camera_SetDefaultRotator(playerId, null)
    call Camera_SetRotator(playerId, null)
    call Camera_SetTarget(playerId, null)
endfunction
//===========================================================================
// Key Event Handling: Left and Right arrows
//===============
// Utility
function Camera_IsKeyPressed takes integer playerId, integer whichKey returns boolean
    return HaveSavedBoolean(data, playerId, whichKey)
endfunction

function Camera_SetKeyPressed takes integer playerId, integer whichKey, boolean flag returns nothing
    if flag then
        call SaveBoolean(data, playerId, whichKey, true)
    else
        call RemoveSavedBoolean(data, playerId, whichKey)
    endif
endfunction

//===============
// Timer Functions
function Camera_TimerFunc2 takes nothing returns nothing
    local unit u
    local timer t = GetExpiredTimer()
    local integer playerId = LoadInteger(data, GetHandleId(t), 0)
    
    if ( Camera_IsKeyPressed(playerId, Camera_LEFT_KEY()) ) then
        set u = Camera_GetRotator(playerId)
        call SetUnitFacing(u, GetUnitFacing(u) + 10.)
        set u = null
    else
        call PauseTimer(t)
        call DestroyTimer(t)
    endif
    set t = null
endfunction

function Camera_TimerFunc_RightArrow takes nothing returns nothing
    local unit u
    local timer t = GetExpiredTimer()
    local integer playerId = LoadInteger(data, GetHandleId(t), 0)
    
    if ( Camera_IsKeyPressed(playerId, Camera_RIGHT_KEY()) ) then
        set u = Camera_GetRotator(playerId)
        call SetUnitFacing(u, GetUnitFacing(u) - 10.)
        set u = null
    else
        call FlushChildHashtable(data, GetHandleId(t))
        call PauseTimer(t)
        call DestroyTimer(t)
    endif
    set t = null
endfunction

//===============
// Trigger Actions
function SideArrowPress takes integer playerId, integer whichKey, code handlerFunc returns nothing
    local timer t
    
    if Camera_GetTarget(playerId) == null then
        return
    endif
    
    if Camera_IsKeyPressed(playerId, whichKey) then
        call Camera_SetKeyPressed(playerId, whichKey, false)
    else
        call Camera_SetKeyPressed(playerId, whichKey, true)
        
        set t = CreateTimer()
        call TimerStart(t, 0.03, true, handlerFunc)
        call SaveInteger(data, GetHandleId(t), 0, playerId)
        set t = null
    endif
endfunction

function Camera_Trig_LeftArrow_Actions takes nothing returns nothing
    call SideArrowPress(GetPlayerId(GetTriggerPlayer()), Camera_LEFT_KEY(), function Camera_TimerFunc2)
endfunction

function Camera_Trig_RightArrow_Actions takes nothing returns nothing
    call SideArrowPress(GetPlayerId(GetTriggerPlayer()), Camera_RIGHT_KEY(), function Camera_TimerFunc_RightArrow)
endfunction

//===========================================================================
// Key Event Handling: Esc
//===============
function Camera_GetEscClicks takes integer playerId returns integer
    return LoadInteger(data, playerId, Camera_ESC_KEY())
endfunction

function Camera_SetEscClicks takes integer playerId, integer value returns nothing
    call SaveInteger(data, playerId, Camera_ESC_KEY(), value)
endfunction

function Camera_ResetEscClicks takes integer playerId returns nothing
    call RemoveSavedInteger(data, playerId, Camera_ESC_KEY())
endfunction

function Camera_Trig_Esc_Actions takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pId = GetPlayerId(p)
    local integer count = Camera_GetEscClicks(pId)
    
    if count == 0 then
        if Camera_GetRotator(pId) == Camera_GetTarget(pId) then
            call Camera_SetRotator(pId, Camera_GetDefaultRotator(pId))
        else
            call Camera_SetRotator(pId, Camera_GetTarget(pId))
        endif
        
        call Camera_SetEscClicks(pId, count + 1)
        call TriggerSleepAction(.4)
        call Camera_ResetEscClicks(pId)
    elseif count == 1 then
        call Camera_SetEscClicks(pId, count + 1)
        if Camera_GetTarget(pId) != null then
            call Camera_SetThirdPerson(p)
        else
            call Camera_SetFirstPersonSelected(p) // There is a wait in this function
        endif
    endif
endfunction

//===========================================================================
// Mouse Event Handling
//===============

// Returns the minimum angle between mouse and unit for camera to turn.
// This is a per-player setting, since it may vary with screen resolution.
function Camera_GetMinAngle takes integer playerId returns real
    return LoadReal(data, playerId, Camera_MIN_ANGLE())
endfunction

// Sets the minimum angle between mouse and unit for camera to turn.
// This is a per-player setting, since it may vary with screen resolution.
function Camera_SetMinAngle takes integer playerId, real angle returns nothing
    call SaveReal(data, playerId, Camera_MIN_ANGLE(), angle)
endfunction

function Camera_AngleToMouse takes unit u, integer playerId, real x, real y returns real
    local real mouseX = BlzGetTriggerPlayerMouseX()
    local real mouseY = BlzGetTriggerPlayerMouseY()
    local real newAngle = bj_RADTODEG * Atan2(mouseY - y, mouseX - x)
    local real difference
    local real minAngle = Camera_GetMinAngle(playerId)
    
    if newAngle < 0 then
        set newAngle = 360 + newAngle  // Convert negative angles to positive, since GetUnitFacing always returns positives
    endif
    set difference = newAngle - GetUnitFacing(Camera_GetRotator(playerId))
    
    // If both mouseX and Y are 0, then the mouse is (probably) on the UI
    if (difference > minAngle or difference < -minAngle)  and (mouseX != 0 and mouseY != 0) then
        return newAngle  
    else
        return GetUnitFacing(Camera_GetRotator(playerId))
    endif
endfunction


function Trig_CameraMouse_Actions takes nothing returns nothing
    local player trigPlayer = GetTriggerPlayer()
    local integer playerId = GetPlayerId(trigPlayer)
    local unit u = Camera_GetTarget(playerId)
    
    if u != null then
        call SetUnitFacing(Camera_GetRotator(playerId),Camera_AngleToMouse(u, playerId, GetUnitX(u), GetUnitY(u)))
        set u = null
    endif
endfunction

//===========================================================================
// Commands
//===============
function Trig_Commands_First_Person_Actions takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local string chatStr = GetEventPlayerChatString()

    if chatStr == Camera_FP_COMMAND() then
        call Camera_SetFirstPersonSelected(p)
    elseif chatStr == Camera_TP_COMMAND() then
        call Camera_SetThirdPerson(p)
    elseif chatStr == Camera_FIXED_COMMAND() then
        call Camera_SetRotator(GetPlayerId(p), Camera_GetTarget(GetPlayerId(p)))
    elseif chatStr == Camera_FREE_COMMAND() then
        call Camera_SetRotator(GetPlayerId(p), Camera_GetDefaultRotator(GetPlayerId(p)))
    elseif chatStr == Camera_HELP_COMMAND() then
        call DisplayTextToPlayer(p, 0, 0, Camera_HELP_MESSAGE())
    else
        call Camera_SetMinAngle(GetPlayerId(p), S2R(SubString(chatStr, StringLength(GetEventPlayerChatStringMatched()), StringLength(chatStr))))
    endif
endfunction

//===========================================================================
// Timer Function
//===============

// This function periodically sets the local player camera to the correct position in first person
function Camera_TimerFunc takes nothing returns nothing
    local player localPlayer = GetLocalPlayer()
    local integer playerId = GetPlayerId(localPlayer)
    
    if focusUnits[playerId] != null then
        call SetCameraField(CAMERA_FIELD_ROTATION, GetUnitFacing(focusUnits[playerId+bj_MAX_PLAYERS]), 0)
        call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 350.00, 0 )
        call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 140.00, 0 )
        call SetCameraField(CAMERA_FIELD_ZOFFSET, ( GetUnitFlyHeight(focusUnits[playerId]) + 125.00 ), 0.01 )
    endif
endfunction

//===========================================================================
// Initialization
//===============
function Camera_ForForce_Init takes nothing returns nothing
    local player enumPlayer = GetEnumPlayer()
    local unit u
    if GetPlayerSlotState(enumPlayer) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(enumPlayer) == MAP_CONTROL_USER then
    
        if Camera_FP_COMMAND() != "" then
            call TriggerRegisterPlayerChatEvent(gg_trg_Camera_System, enumPlayer, Camera_FP_COMMAND(), true )
            call TriggerRegisterPlayerChatEvent(gg_trg_Camera_System, enumPlayer, Camera_TP_COMMAND(), true )
            call TriggerRegisterPlayerChatEvent(gg_trg_Camera_System, enumPlayer, Camera_FIXED_COMMAND(), true )
            call TriggerRegisterPlayerChatEvent(gg_trg_Camera_System, enumPlayer, Camera_FREE_COMMAND(), true )
            call TriggerRegisterPlayerChatEvent(gg_trg_Camera_System, enumPlayer, Camera_HELP_COMMAND(), true )
            call TriggerRegisterPlayerChatEvent(gg_trg_Camera_System, enumPlayer, Camera_MIN_ANGLE_COMMAND(), false )
        endif
        call TriggerRegisterPlayerMouseEventBJ(triggerMouse, enumPlayer, bj_MOUSEEVENTTYPE_MOVE )
        
        call TriggerRegisterPlayerEvent(triggerLeft, enumPlayer, EVENT_PLAYER_ARROW_LEFT_DOWN)
        call TriggerRegisterPlayerEvent(triggerLeft, enumPlayer, EVENT_PLAYER_ARROW_LEFT_UP)
    
        call TriggerRegisterPlayerEvent(triggerRight, enumPlayer, EVENT_PLAYER_ARROW_RIGHT_DOWN)
        call TriggerRegisterPlayerEvent(triggerRight, enumPlayer, EVENT_PLAYER_ARROW_RIGHT_UP)
        
        call TriggerRegisterPlayerEvent(triggerEsc, enumPlayer, EVENT_PLAYER_END_CINEMATIC)
        
        call TriggerRegisterPlayerEvent(triggerCleanup, enumPlayer, EVENT_PLAYER_LEAVE)
        
        set u = CreateUnit(Camera_Dummy_Owner(), Camera_DUMMY_TYPE(), Camera_DUMMY_X(), Camera_DUMMY_Y(), bj_UNIT_FACING)
        call UnitAddAbility(u, 'Aloc')
        call SetUnitInvulnerable(u, true)
        call ShowUnit(u, false)
        call SetUnitTurnSpeed(u, 3.)
        call Camera_SetDefaultRotator(GetPlayerId(enumPlayer), u)
        call Camera_SetRotator(GetPlayerId(enumPlayer), u)
        call Camera_SetMinAngle(GetPlayerId(enumPlayer), 39.0)
        
        call Camera_SetHelpSeen(GetPlayerId(enumPlayer), false)
        
        set u = null
    endif
endfunction

// Cleanup trigger
function Camera_Trig_PlayerLeaves takes nothing returns nothing
    call Camera_ClearPlayerData(GetTriggerPlayer())
endfunction

function InitTrig_Camera_System takes nothing returns nothing
    local timer t = CreateTimer()
    call TimerStart(t, 0.03, true, function Camera_TimerFunc)
    
    set data = InitHashtable()
    
    if Camera_FP_COMMAND() != "" then
        set gg_trg_Camera_System = CreateTrigger()
        call TriggerAddAction( gg_trg_Camera_System, function Trig_Commands_First_Person_Actions )
    endif

    set triggerLeft = CreateTrigger()
    set triggerRight = CreateTrigger()
    call TriggerAddAction(triggerLeft, function Camera_Trig_LeftArrow_Actions)
    call TriggerAddAction(triggerRight, function Camera_Trig_RightArrow_Actions)
    
    set triggerEsc = CreateTrigger()
    call TriggerAddAction(triggerEsc, function Camera_Trig_Esc_Actions)
    
    set triggerMouse = CreateTrigger()
    call TriggerAddAction(triggerMouse, function Trig_CameraMouse_Actions)
    
    set triggerCleanup = CreateTrigger()
    call TriggerAddAction(triggerCleanup, function Camera_Trig_PlayerLeaves)
    
    call ForForce( GetPlayersAll(), function Camera_ForForce_Init)
    
    //call CreateQuestBJ( bj_QUESTTYPE_REQ_DISCOVERED, "TRIGSTR_5472", "TRIGSTR_5473", "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp" )
endfunction
//===========================
// END OF FIRST PERSON CAMERA SYSTEM
//===========================================================================
endlibrary