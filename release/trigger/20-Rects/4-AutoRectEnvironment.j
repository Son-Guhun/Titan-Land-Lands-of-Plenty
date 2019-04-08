library AutoRectEnvironment requires RectEnvironment, GLHS

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
    //! runtextmacro TableStruct_NewStaticHandleField("allRects", "region")
    
    //! runtextmacro TableStruct_NewStaticStructField("rects", "LinkedHashSet")
    
    //! runtextmacro TableStruct_NewConstTableField("public","id2")
endstruct

public function RegisterRect takes rect r returns nothing
    local integer rId = GetHandleId(r)
    
    if not Globals.id2.handle.has(rId) then
        set Globals.id2.rect[rId] = r
        call RegionAddRect(Globals.allRects, r)
        call Globals.rects.append(rId)
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
        call RegionClearRect(Globals.allRects, r)
        call Globals.rects.remove(rId)
    endif
endfunction

public function MoveRect takes rect r, real newCenterX, real newCenterY returns nothing

    if Globals.id2.handle.has(GetHandleId(r)) then
        set Globals.rectWasMoved = true
        call RegionClearRect(Globals.allRects, r)
        call MoveRectTo(r, newCenterX, newCenterY)
        call RegionAddRect(Globals.allRects, r)
    endif
    
endfunction

function AutoRectEnvironment_SetRect takes rect r, real minx, real miny, real maxx, real maxy returns nothing
    if Globals.id2.handle.has(GetHandleId(r)) then
        set Globals.rectWasMoved = true
        call RegionClearRect(Globals.allRects, r)
        call SetRect(r, minx, miny, maxx, maxy)
        call RegionAddRect(Globals.allRects, r)
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
    
    if Globals.lastCameraRect != null then
        if GetRectMinX(Globals.lastCameraRect) <= x and x <= GetRectMaxX(Globals.lastCameraRect) and GetRectMinY(Globals.lastCameraRect) <= y and y <= GetRectMaxY(Globals.lastCameraRect) then
            //call BJDebugMsg("In last rect.")
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
            //call BJDebugMsg("Camera did not move, no Globals.rects moved: do nothing.")
            return
        endif
    endif
    
    if IsPointInRegion(Globals.allRects, x, y) then
        set i = Globals.rects.begin()
            loop
                exitwhen i == Globals.rects.end()
                set r = Globals.id2.rect[i]
                
                if GetRectMinX(r) <= x and x <= GetRectMaxX(r) and GetRectMinY(r) <= y and y <= GetRectMaxY(r) then
                    //call BJDebugMsg("Found rect!")
                    set Globals.lastCameraRect = r
                    call RectEnvironment.get(r).apply()
                    exitwhen true
                endif
            
                set i = Globals.rects.next(i)
            endloop
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
        local timer t = CreateTimer()
        set Globals.rects = LinkedHashSet.create()
        
        set Globals.allRects = CreateRegion()
        
        call TimerStart(t, PERIOD, true, function onTimer)
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct
endlibrary