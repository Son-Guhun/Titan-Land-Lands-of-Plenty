library AutoRectEnvironment requires RectEnvironment, GLHS, WorldBounds
// Version 1.1.0 => Now uses AnyTileDefiniton to split map into blocks of 2048x2048 instead of a
// region.

globals
    private constant boolean ENABLE_SET_HOOK = false
    private constant boolean ENABLE_MOVE_HOOK = false
    private constant boolean ENABLE_REMOVE_HOOK = false
endglobals

private struct Globals extends array
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticPrimitiveField("lastCameraX", "real")
    //! runtextmacro TableStruct_NewStaticPrimitiveField("lastCameraY", "real")
    //! runtextmacro TableStruct_NewStaticPrimitiveField("rectWasMoved", "boolean")
    
    //! runtextmacro TableStruct_NewStaticHandleField("lastCameraRect", "rect")
    
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
function RegisterRectImpl takes rect r returns nothing
    local real x0 = GetRectMinX(r)
    local real y0 = GetRectMinY(r)
    
    local real x = x0
    local real y
    
    local real maxX = GetRectMaxX(r)
    local real maxY = GetRectMinY(r)
    
    loop
    exitwhen x > maxX
        set y = y0
        loop
        exitwhen y > maxY
            call AutoRectBlock.get(x, y).rects.append(GetHandleId(r))
        
            set y = y + AutoRectBlock.BLOCK_SIZE
        endloop
        set x = x + AutoRectBlock.BLOCK_SIZE
    endloop

endfunction

// Removes a rect to the .rects set of all AutoRectBlocks that it encompasses.
function DeregisterRectImpl takes rect r returns nothing
    local real x0 = GetRectMinX(r)
    local real y0 = GetRectMinY(r)
    
    local real x = x0
    local real y
    
    local real maxX = GetRectMaxX(r)
    local real maxY = GetRectMinY(r)
    
    loop
    exitwhen x > maxX
        set y = y0
        loop
        exitwhen y > maxY
            call AutoRectBlock.get(x, y).rects.remove(GetHandleId(r))
        
            set y = y + AutoRectBlock.BLOCK_SIZE
        endloop
        set x = x + AutoRectBlock.BLOCK_SIZE
    endloop

endfunction

public function RegisterRect takes rect r returns nothing
    local integer rId = GetHandleId(r)
    
    if not Globals.id2.handle.has(rId) then

        set Globals.id2.rect[rId] = r
        call RegisterRectImpl(r)
    endif
endfunction

public function DeRegisterRect takes rect r returns nothing
    local integer rId = GetHandleId(r)
    
    // This rect can be different for each player. Null the handle to reduce reference counter.
    if r == Globals.lastCameraRect then
        set Globals.lastCameraRect = null  // This possibly avoids desyncs.
    endif
    
    if Globals.id2.handle.has(rId) then
        set Globals.rectWasMoved = true
        call Globals.id2.rect.remove(rId)
        call DeregisterRectImpl(r)
    endif
endfunction

public function MoveRect takes rect r, real newCenterX, real newCenterY returns nothing

    if Globals.id2.handle.has(GetHandleId(r)) then
        set Globals.rectWasMoved = true
        call RegisterRectImpl(r)
        call MoveRectTo(r, newCenterX, newCenterY)
        call DeregisterRectImpl(r)
    endif
    
endfunction

function AutoRectEnvironment_SetRect takes rect r, real minx, real miny, real maxx, real maxy returns nothing
    if Globals.id2.handle.has(GetHandleId(r)) then
        set Globals.rectWasMoved = true
        call RegisterRectImpl(r)
        call SetRect(r, minx, miny, maxx, maxy)
        call DeregisterRectImpl(r)
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


function onTimer takes nothing returns nothing
    local real x = GetCameraTargetPositionX()
    local real y = GetCameraTargetPositionY()
    local rect r
    local integer i
    
    local LinkedHashSet rectSet
    
    if Globals.lastCameraRect != null then
        if GetRectMinX(Globals.lastCameraRect) <= x and x <= GetRectMaxX(Globals.lastCameraRect) and GetRectMinY(Globals.lastCameraRect) <= y and y <= GetRectMaxY(Globals.lastCameraRect) then
            // call BJDebugMsg("In last rect.")
            call RectEnvironment.get(Globals.lastCameraRect).apply()
            return
        else
            // Do not set Globals.lastCameraRect to null, it's likely the camera will soon return to the last rect.
        endif
    endif
    
    if Globals.rectWasMoved then
        set Globals.rectWasMoved = false
    else
        if Globals.lastCameraX == x and Globals.lastCameraY == y then
            //call BJDebugMsg("Camera did not move, no rects moved: do nothing.")
            return
        endif
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
                set Globals.lastCameraRect = r
                call RectEnvironment.get(r).apply()
                exitwhen true
            endif
        
            set i = rectSet.next(i)
        endloop
        
        // No rect was found
        if i == rectSet.end() then
            call RectEnvironment(0).apply()
        endif
            
        set r = null
    else
        //call BJDebugMsg("Camera not in region.")
        call RectEnvironment(0).apply()
    endif
    
    set Globals.lastCameraX = x
    set Globals.lastCameraY = y
endfunction

globals
    private constant real PERIOD = 0.03
endglobals

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