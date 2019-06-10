library TerrainEditor initializer onInit requires TerrainTools, DeformationTools, ControlState
/*
This library is the backbone of the ingame Terrain Editor.

It uses a ControlState which disables all selections for a player and enables the triggers that allow
terrain editing.


API:
    - SetBrushSize takes player whichPlayer, integer brushSize returns nothing
    - GetBrushSize takes player whichPlayer, integer brushSize returns nothing
    
To enable terrain editing for a player:
    call TerrainEditor_controlState.activateForPlayer(your_player_here)
*/

// Height tools. Support for custom user-defined tools may be added in the future.
scope HEIGHT
    scope TOOL
        globals
            public constant integer HILL    = 1
            public constant integer PLATEAU = 2
        endglobals
    endscope
endscope

globals
    public constant boolean DEFAULT_APPLY_TEXTURE = true
    
    public constant integer DEFAULT_HEIGHT_TOOL = 0 // HEIGHT_TOOL_HILL
    public constant integer DEFAULT_TEXTURE = 'Ywmb'
endglobals

globals
    // This is the control state to be set as the active state when a user is editing terrain.
    public ControlState controlState
    
    private image array myImage
    private integer array brushSize
    private boolean array isRightButtonPressed
    private boolean array isLeftButtonPressed
    private boolean array enableCursor
    
    // Controls whether a terrain texture will be applied when clicking or moving the mouse.
    private boolean array applyTexture
    
    // Sets the tool used to change terrain height
    private integer array currentHeightTool
    
    public integer array currentTexture
endglobals



public function SetBrushSize takes player whichPlayer, integer size returns nothing
    local integer playerId = GetPlayerId(whichPlayer)
    set size = (size/2)*2 + 1  // Makes sure value is odd (convert to nearest low even, add 1)
    call DestroyImage(myImage[playerId])
    call SetImageRenderAlways(CreateImage("war3mapImported\\SelectionSquare.tga", 128*size, 128*size, 0, 0, 0, 0, 128*size/2,128*size/2,0, 1), true)
    call SetImagePosition(myImage[playerId], GetTileCenterCoordinate(GetPlayerLastMouseX(Player(0))), GetTileCenterCoordinate(GetPlayerLastMouseY(Player(0))), 0)
    set brushSize[playerId] = size
endfunction

public function GetBrushSize takes player whichPlayer returns integer
    return brushSize[GetPlayerId(whichPlayer)]
endfunction

private function onMousePress takes nothing returns boolean
    local real x = PlayerMouseEvent_GetTriggerPlayerMouseX()
    local real y = PlayerMouseEvent_GetTriggerPlayerMouseY()
    local integer radius = brushSize[GetPlayerId(PlayerEvent_GetTriggerPlayer())]/2
    local integer playerId = GetPlayerId(PlayerEvent_GetTriggerPlayer())
    local real step
    
     if PlayerMouseEvent_GetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
        set isRightButtonPressed[playerId] = true
    else
        set isLeftButtonPressed[playerId] = true
    endif
    
    if x == 0. and y == 0. then
        return false
    endif
    
    if PlayerMouseEvent_GetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
        set step =  0.125
    else
        set step = -0.125
    endif
    
    if currentHeightTool[playerId] == HEIGHT_TOOL_HILL then
            call DeformationTools_Hill(x, y, step, radius)
    endif
    
    if applyTexture[playerId] then
            call SetTerrainType(x, y, currentTexture[playerId], -1, brushSize[playerId]/2+1, TerrainTools_SHAPE_SQUARE)
    endif
    // call DeformationTools_Hill(x0, y0, step, radius)
    return false
endfunction

private function onMouseRelease takes nothing returns boolean
    if PlayerMouseEvent_GetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
        set isRightButtonPressed[GetPlayerId(PlayerEvent_GetTriggerPlayer())] = false
    else
        set isLeftButtonPressed[GetPlayerId(PlayerEvent_GetTriggerPlayer())] = false
    endif
    return false
endfunction

private function PlayerEnableCursorInEditor takes integer playerId returns boolean
    return enableCursor[playerId]
endfunction

function onMoveMouse takes nothing returns boolean
    local real x = GetTileCenterCoordinate(PlayerMouseEvent_GetTriggerPlayerMouseX())
    local real y = GetTileCenterCoordinate(PlayerMouseEvent_GetTriggerPlayerMouseY())
    local integer radius = brushSize[GetPlayerId(PlayerEvent_GetTriggerPlayer())]/2
    local integer playerId = GetPlayerId(PlayerEvent_GetTriggerPlayer())
    
    if x == 0. and y == 0. then
        if GetLocalPlayer() == Player(playerId) then
            call BlzEnableCursor(true)
        endif
        return false
    else
        if GetLocalPlayer() == Player(playerId) then
            call BlzEnableCursor(PlayerEnableCursorInEditor(playerId))
        endif
    endif
    
    if isLeftButtonPressed[playerId] then
    
        if applyTexture[playerId] then
            call SetTerrainType(x, y, currentTexture[playerId], -1, brushSize[playerId]/2+1, TerrainTools_SHAPE_SQUARE)
        endif
        
        if currentHeightTool[playerId] == HEIGHT_TOOL_HILL then
            call DeformationTools_Hill(x, y, -0.125/4, radius)
        endif
    elseif isRightButtonPressed[playerId] then
    
        if currentHeightTool[playerId] == HEIGHT_TOOL_HILL then
            call DeformationTools_Hill(x, y, 0.125/4, radius)
        endif
    endif
    
    call SetImagePosition(myImage[GetPlayerId(PlayerEvent_GetTriggerPlayer())], x, y, 0)
    return false
endfunction


private function onStateEnter takes nothing returns boolean
    local integer playerId = GetPlayerId(ControlState.getChangingPlayer())
    call SetImageRenderAlways(myImage[playerId], true)
    
    
    if GetLocalPlayer() == Player(playerId) then
        call BlzEnableCursor(PlayerEnableCursorInEditor(playerId))
    endif
    
    return false
endfunction


private function onStateExit takes nothing returns boolean
    local integer playerId = GetPlayerId(ControlState.getChangingPlayer())
    call SetImageRenderAlways(myImage[playerId], false)
    
    if GetLocalPlayer() == Player(playerId) then
        call BlzEnableCursor(true)
    endif
    
    
    return false
endfunction


private function onInit takes nothing returns nothing
    local trigger trig
    local integer i = 0
    
    loop
    exitwhen i > bj_MAX_PLAYERS
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            set myImage[i] = CreateImage("war3mapImported\\SelectionSquare.tga", 128*5, 128*5, 0, 0, 0, 0, 128*5/2,128*5/2,0, 1)
            set brushSize[i] = 5
            
            set applyTexture[i] = DEFAULT_APPLY_TEXTURE
            set currentHeightTool[i] = DEFAULT_HEIGHT_TOOL
            set currentTexture[i] = DEFAULT_TEXTURE
            set enableCursor[i] = true
        endif
        
        set i = i + 1
    endloop
    
    
    set controlState = ControlState.create()
    set controlState.selectionState = SelectionState.create()
    set controlState.dragSelectionState = DragSelectionState.create()
    set controlState.preSelectionState = PreSelectionState.create()
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onStateEnter))
    set controlState.onActivate = trig
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onStateExit))
    set controlState.onDeactivate = trig
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onMousePress))
    set controlState.trigger[EVENT_PLAYER_MOUSE_DOWN] = trig
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onMouseRelease))
    set controlState.trigger[EVENT_PLAYER_MOUSE_UP] = trig
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onMoveMouse))
    set controlState.trigger[EVENT_PLAYER_MOUSE_MOVE] = trig
    
    
    set trig = null
endfunction

endlibrary