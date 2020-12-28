library AutoRectEnvironment requires RectEnvironment, GLHS, WorldBounds
// Version 1.1.0 => Now uses AnyTileDefiniton to split map into blocks of 2048x2048 instead of a region. 
/*
=========
 Description
=========

    This library is used to automatically apply a rect's RectEnvironment when the local player's camera
target is inside of the Rect. In order for a rect to be affected by this system, it must be registered
first. When two rects overlap, the last one registered or moved has the lower priority.

    This library functions by splitting the map into square blocks with sides 2048. Each block has a list
of registered rects which intersect it. 32 times per second (can be configured), the system will determine
which block the current camera target is located in, and then iterate over all rects which intersect that block.
If it finds a rect which contains the current camera target, then iteration stops and the RectEnvironment
is applied.

    When moving or setting a rect, you must use this library functions instead of the natives, so that
the map blocks it intersects are also updated. This library also provides hooks for this purpose, which
can be found in the configuration section.
    
=========
 Documentation
=========
    
    public boolean IsRectRegistered(rect r)
    public nothing RegisterRect(rect r)
    public nothing DeRegisterRect(rect r)
    
    . In order for this system to function, these functions must be called instead of the natives:
    .
    .   public nothing MoveRect(rect r, real x, real y)
    .   public nothing SetRect(rect r, real x, real y)
    .
    . Alternatively, you can enable hooks in this library's configratuion section.

*/
//==================================================================================================
//                                      Configuration
//==================================================================================================

globals
    private constant boolean ENABLE_SET_HOOK = false     // Hooks this library's SetRect to the native of the same name.
    private constant boolean ENABLE_MOVE_HOOK = false    // Hooks this library's SetRect to the native of the same name.
    private constant boolean ENABLE_REMOVE_HOOK = false  // Hooks DeRegisterRect to RemoveRect.
    
    private constant real PERIOD = 1/32.  // Set the frequency at which this system checks the camera position.
endglobals

//==================================================================================================
//                                        Source Code
//==================================================================================================

private struct Globals extends array

    static boolean rectWasMoved = false // this is a localplayer value
    
    //! runtextmacro TableStruct_NewConstTableField("public","id2")
endstruct

private struct AutoRectBlock extends array

    static constant integer BLOCK_SIZE = 2048

    //! runtextmacro TableStruct_NewStructField("rects", "LinkedHashSet")
    
    static method get takes real x, real y returns AutoRectBlock
        return GetCustomTileId(.BLOCK_SIZE, x, y)
    endmethod
    
endstruct

    
// Adds a rect to the .rects set of all AutoRectBlocks that it encompasses.
private function AppendRectToBlocks takes rect r returns nothing
    //! runtextmacro TilesInRectLoopDeclare("block", "AutoRectBlock.BLOCK_SIZE", "GetRectMinX(r)", "GetRectMinY(r)", "GetRectMaxX(r)", "GetRectMaxY(r)")
    
    loop
        call AutoRectBlock(block).rects.append(GetHandleId(r))

        //! runtextmacro TilesInRectLoop("block", "AutoRectBlock.BLOCK_SIZE")
    endloop
endfunction

// Removes a rect to the .rects set of all AutoRectBlocks that it encompasses.
private function RemoveRectFromBlocks takes rect r returns nothing
    //! runtextmacro TilesInRectLoopDeclare("block", "AutoRectBlock.BLOCK_SIZE", "GetRectMinX(r)", "GetRectMinY(r)", "GetRectMaxX(r)", "GetRectMaxY(r)")
    
    loop
        call AutoRectBlock(block).rects.remove(GetHandleId(r))

        //! runtextmacro TilesInRectLoop("block", "AutoRectBlock.BLOCK_SIZE")
    endloop
endfunction

private function IsRectIdRegistered takes integer rectId returns boolean
    return Globals.id2.handle.has(rectId)
endfunction

public function IsRectRegistered takes rect r returns boolean
    return IsRectIdRegistered(GetHandleId(r))
endfunction

public function RegisterRect takes rect r returns nothing
    local integer rId = GetHandleId(r)
    
    if r != null and not IsRectIdRegistered(rId) then

        set Globals.rectWasMoved = true
        set Globals.id2.rect[rId] = r
        call AppendRectToBlocks(r)
    endif
endfunction

public function DeRegisterRect takes rect r returns nothing
    local integer rId = GetHandleId(r)
    
    if r != null and IsRectIdRegistered(rId) then
    
        set Globals.rectWasMoved = true
        call Globals.id2.rect.remove(rId)
        call RemoveRectFromBlocks(r)
    endif
endfunction

public function MoveRect takes rect r, real newCenterX, real newCenterY returns nothing

    if IsRectRegistered(r) then
        set Globals.rectWasMoved = true
        call RemoveRectFromBlocks(r)
        call MoveRectTo(r, newCenterX, newCenterY)
        call AppendRectToBlocks(r)
    else
        call MoveRectTo(r, newCenterX, newCenterY)
    endif
    
endfunction

public function SetRect takes rect r, real minx, real miny, real maxx, real maxy returns nothing
    if IsRectRegistered(r) then
        set Globals.rectWasMoved = true
        call RemoveRectFromBlocks(r)
        call SetRect(r, minx, miny, maxx, maxy)
        call AppendRectToBlocks(r)
    else
        call SetRect(r, minx, miny, maxx, maxy)
    endif
endfunction

static if ENABLE_MOVE_HOOK then
    hook MoveRectTo MoveRect
endif
static if ENABLE_REMOVE_HOOK then
    hook RemoveRect DeRegisterRect
endif
static if ENABLE_SET_HOOK then
    hook SetRect SetRect
endif

// This function executes code specific for localplayer.
private function onTimer takes nothing returns nothing
    local real x = GetCameraTargetPositionX()
    local real y = GetCameraTargetPositionY()
    local rect r
    local integer i
    
    local LinkedHashSet rectSet
    
    if Globals.rectWasMoved then
        set Globals.rectWasMoved = false
    endif
    
    set rectSet = AutoRectBlock.get(x, y).rects
    if not rectSet.isEmpty() then
        // call BJDebugMsg(I2S(AutoRectBlock.get(x, y)))
        set i = rectSet.begin()
        loop
            exitwhen i == rectSet.end()
            set r = Globals.id2.rect[i]
            
            if GetRectMinX(r) <= x and x <= GetRectMaxX(r) and GetRectMinY(r) <= y and y <= GetRectMaxY(r) then
                // call BJDebugMsg("Found rect!")
                call RectEnvironment.get(r).apply()
                exitwhen true
            endif
        
            set i = rectSet.next(i)
        endloop
        
        // No rect was found
        if i == rectSet.end() then
            call RectEnvironment.default.apply()
        endif
            
        set r = null
    else
        //call BJDebugMsg("Camera in block with no rects.")
        call RectEnvironment.default.apply()
    endif
endfunction

private module InitModule
    private static method onInit takes nothing returns nothing
        local integer lastId
        local integer i = 0
        
        local timer t = CreateTimer()
        
        call InitCustomTiles(AutoRectBlock.BLOCK_SIZE)
        set lastId = AutoRectBlock.get(WorldBounds.maxX, WorldBounds.maxY)
        loop
        exitwhen i > lastId
            set AutoRectBlock(i).rects = LinkedHashSet.create()
            set i = i + 1
        endloop
        
        call TimerStart(t, PERIOD, true, function onTimer)
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct
endlibrary