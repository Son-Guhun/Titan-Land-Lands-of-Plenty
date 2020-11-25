library AutoRectEnvironment requires RectEnvironment, GLHS, WorldBounds
// Version 1.1.0 => Now uses AnyTileDefiniton to split map into blocks of 2048x2048 instead of a region. 

globals
    private constant boolean ENABLE_SET_HOOK = false
    private constant boolean ENABLE_MOVE_HOOK = false
    private constant boolean ENABLE_REMOVE_HOOK = false
    private constant real PERIOD = 1/32.
endglobals

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

function AutoRectEnvironment_SetRect takes rect r, real minx, real miny, real maxx, real maxy returns nothing
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
    hook SetRect AutoRectEnvironment_SetRect
endif

// This function executes code specific for localplayer.
function onTimer takes nothing returns nothing
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