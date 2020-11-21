library MultiPatrol initializer onInit

// TODO: Still interfaces badly with the save system,  which is using a private function. When loading a unit, it relies on internal behaviour of the Patrol_RegisterPoint function.

//==================================================================================================
//  ------------------------
// ||Guhun's Patrol System || v1.3.0
//  ------------------------
// This is a JASS System that allows you to define multiple patrol points for a unit, instead of the
// default limit of 2 patrol points per unit.
//
//Notes: You can't create rects when declaring global variables.
// ==========================
// =========  API  ==========
// ==========================
//
// function Patrol_ClearUnitIdData takes integer unitHandleId returns nothing
//
// function Patrol_ClearUnitData takes unit whichUnit returns nothing
//
// function Patrol_RegisterPoint takes unit trigU, real newX, real newY returns nothing
//
//==================================================================================================
// Config
globals
    // Maximum number of patrol points a single unit can have.
    private constant integer MAX_POINTS = 128
    
    // Determines how close a unit must get to a patrol point before moving onto the next.
    private constant real RANGE = 32.
    
    // Determines the minimum distance between two consecutive patrol points.
    private constant real MINIMUM_DISTANCE = 100.
endglobals
//==================================================================================================
// Error codes for Patrol_AddPoint

scope ERROR
    globals 
        public constant integer OVERFLOW = 2
        public constant integer NULL_POINTER = 3
        public constant integer TOO_CLOSE = 1
        public constant integer NONE = 0
    endglobals
endscope
//==================================================================================================
globals
    private hashtable data = InitHashtable()
    private boolean orderBool = false
    private rect ptrlRect
    
    private constant integer INDEX_DISPLAY = 9999
endglobals

// Constants
private constant function Patrol_MinDistance takes nothing returns real
    return 100.
endfunction

private constant function Patrol_POINT_CURRENT takes nothing returns integer
    return 9996
endfunction

private constant function Patrol_POINT_TOTAL takes nothing returns integer
    return 9997
endfunction

private constant function Patrol_REGION takes nothing returns integer
    return 9998
endfunction

private constant function Patrol_TRIGGER takes nothing returns integer
    return 9999
endfunction
//==================================================================================================

// Getters and Setters

//=====================
// Points
function Patrol_GetPointX takes integer unitHandleId, integer pointNumber returns real
    return LoadReal(data, unitHandleId, pointNumber)
endfunction

function Patrol_GetPointY takes integer unitHandleId, integer pointNumber returns real
    return LoadReal(data, unitHandleId, -pointNumber)
endfunction

private function Patrol_SetPointX takes integer unitHandleId, integer pointNumber, real newX returns nothing
    call SaveReal(data, unitHandleId, pointNumber, newX)
endfunction

private function Patrol_SetPointY takes integer unitHandleId, integer pointNumber, real newY returns nothing
    call SaveReal(data, unitHandleId, -pointNumber, newY)
endfunction
//=====================
// Current Point and Total Points
function Patrol_GetCurrentPatrolPoint takes integer unitHandleId returns integer
    return LoadInteger(data , -unitHandleId , Patrol_POINT_CURRENT())
endfunction

function Patrol_GetTotalPatrolPoints takes integer unitHandleId returns integer
    return LoadInteger(data , -unitHandleId , Patrol_POINT_TOTAL())
endfunction

function Patrol_SetCurrentPatrolPoint takes integer unitHandleId, integer pointNumber returns nothing
    call SaveInteger(data , -unitHandleId , Patrol_POINT_CURRENT(), pointNumber)
endfunction

function Patrol_SetTotalPatrolPoints takes integer unitHandleId, integer newTotal returns nothing
    call SaveInteger(data , -unitHandleId , Patrol_POINT_TOTAL(), newTotal)
endfunction
//=====================
// Region and Trigger
private function Patrol_GetRegion takes integer unitHandleId returns region
    return LoadRegionHandle(data , -unitHandleId , Patrol_REGION())
endfunction

private function Patrol_GetTrigger takes integer unitHandleId returns trigger
    return LoadTriggerHandle(data , -unitHandleId , Patrol_TRIGGER())
endfunction

private function Patrol_HasTrigger takes integer unitHandleId returns boolean
    return HaveSavedHandle(data , -unitHandleId , Patrol_TRIGGER())
endfunction


private function Patrol_SetRegion takes integer unitHandleId, region newRegion returns nothing
    call SaveRegionHandle(data , -unitHandleId , Patrol_REGION(), newRegion)
endfunction

private function Patrol_SetTrigger takes integer unitHandleId, trigger newTrigger returns nothing
    call SaveTriggerHandle(data , -unitHandleId , Patrol_TRIGGER(), newTrigger)
endfunction

//=====================
// Text Tags and Special Effects for displaying patrol points
private function Patrol_SetPointEffect takes integer uId, integer point, effect spEffect returns nothing
    call SaveEffectHandle(data, uId, INDEX_DISPLAY+point, spEffect)
endfunction

private function Patrol_SetPointTag takes integer uId, integer point, texttag tag returns nothing
    call SaveTextTagHandle(data,  uId, -INDEX_DISPLAY-point, tag)
endfunction

private function Patrol_GetPointEffect takes integer uId, integer point returns effect
    return LoadEffectHandle(data, uId, INDEX_DISPLAY+point)
endfunction

private function Patrol_GetPointTag takes integer uId, integer point returns texttag
    return LoadTextTagHandle(data,  uId, -INDEX_DISPLAY-point)
endfunction

private function Patrol_RemovePointEffect takes integer uId, integer point returns nothing
    call RemoveSavedHandle(data, uId, INDEX_DISPLAY+point)
endfunction

private function Patrol_RemovePointTag takes integer uId, integer point returns nothing
    call RemoveSavedHandle(data,  uId, -INDEX_DISPLAY-point)
endfunction
//==================================================================================================

// Uitilities
private function Patrol_Distance takes real x, real y returns real
    return SquareRoot(Pow(x,2) + Pow(y,2))
endfunction

//==================================================================================================

private function Patrol_PointReached takes nothing returns boolean
    local unit trigU = GetTriggerUnit()
    local integer u_handle = GetHandleId(trigU)
    local integer currentPtrl = Patrol_GetCurrentPatrolPoint(u_handle)
    local region ptrlReg = GetTriggeringRegion()
    local real oldX
    local real oldY
    local real newX
    local real newY
    if trigU != LoadUnitHandle(data, GetHandleId(GetTriggeringTrigger()), 0) then
        set trigU = null
        set ptrlReg = null
        return false
    endif
//
    call MoveRectTo(ptrlRect , Patrol_GetPointX(u_handle, currentPtrl) , Patrol_GetPointY(u_handle, currentPtrl))
    call RegionClearRect(ptrlReg , ptrlRect)
//
    if currentPtrl == Patrol_GetTotalPatrolPoints(u_handle) then
        set currentPtrl = 1
    else
        set currentPtrl = currentPtrl + 1
    endif
    
    set oldX = GetUnitX(trigU)
    set oldY = GetUnitY(trigU)
    set newX = Patrol_GetPointX(u_handle, currentPtrl)
    set newY = Patrol_GetPointY(u_handle, currentPtrl)
            
    //TODO:System can still bug even if it's not the first point, if a unit is blocking the path
    if Patrol_Distance(newX-oldX, newY-oldY) <= MINIMUM_DISTANCE then
        set currentPtrl = currentPtrl + 1
    endif
    
    call Patrol_SetCurrentPatrolPoint(u_handle, currentPtrl)
//
    call MoveRectTo(ptrlRect , Patrol_GetPointX(u_handle, currentPtrl) , Patrol_GetPointY(u_handle, currentPtrl))
    call RegionAddRect(ptrlReg, ptrlRect)
//
    set orderBool = true
    if IssuePointOrder(trigU, "patrol",  Patrol_GetPointX(u_handle, currentPtrl) , Patrol_GetPointY(u_handle, currentPtrl)) then   
    else
        set orderBool = false
    endif
    
    set trigU = null
    set ptrlReg = null

    return true
endfunction
//==================================================================================================

// Guhun's Patrol Point System API

//===================

function Patrol_UnitIdHasPatrolPoints takes integer unitHandleId returns boolean
    return Patrol_GetCurrentPatrolPoint(unitHandleId) != 0
endfunction

function Patrol_UnitHasPatrolPoints takes unit whichUnit returns boolean
    return Patrol_UnitIdHasPatrolPoints(GetHandleId(whichUnit))
endfunction

function Patrol_DestroyIdPoints takes integer u_handle returns nothing
    local integer pnts_number = Patrol_GetTotalPatrolPoints(u_handle)
    local integer i = 1
    
    loop
    exitwhen i > pnts_number or Patrol_GetPointEffect(u_handle, i) == null
        call BlzSetSpecialEffectAlpha(Patrol_GetPointEffect(u_handle, i), 0)
        call DestroyEffect(Patrol_GetPointEffect(u_handle, i))
        call DestroyTextTag(Patrol_GetPointTag(u_handle, i))
        call Patrol_RemovePointEffect(u_handle, i)
        call Patrol_RemovePointTag(u_handle, i)
        
        set i= i+1
    endloop
endfunction

// This function accepts in-scope and out-of-scope units.
function Patrol_ClearHandleId takes integer unitHandleId returns nothing
    local trigger patrolTrig
    
    
    if Patrol_HasTrigger(unitHandleId) then
        set patrolTrig = Patrol_GetTrigger(unitHandleId)
        
        call Patrol_DestroyIdPoints(unitHandleId)
        call RemoveRegion(Patrol_GetRegion(unitHandleId))
        
        call FlushChildHashtable(data, GetHandleId(patrolTrig))
        call DestroyTrigger(patrolTrig)
        
        call FlushChildHashtable(data, unitHandleId)  // Clear patrol points
        call FlushChildHashtable(data,-unitHandleId)  // Clear other stuff
        
        set patrolTrig = null
    endif
endfunction

function Patrol_ClearUnitData takes unit whichUnit returns nothing
    call Patrol_ClearHandleId(GetHandleId(whichUnit))
endfunction

function Patrol_IsValidPatrolOrder takes integer orderId returns boolean
    if ( not ( orderId == String2OrderIdBJ("patrol"))) then
            return false
    endif
    
    // Handle recursion
    if orderBool then
        set orderBool = false
        return false
    endif
    
    return true
endfunction
/*
function Patrol_DisplayPoints takes unit whichUnit returns nothing
    local integer u_handle = GetHandleId(whichUnit)
    local integer pnts_number = Patrol_GetTotalPatrolPoints(u_handle)
    local integer i = 1
    local real x
    local real y
    local texttag tag
    local effect spEffect
    
    loop
    exitwhen i > pnts_number
        if Patrol_GetPointEffect(u_handle, i) == null then
            set x = Patrol_GetPointX(u_handle, i)
            set y = Patrol_GetPointY(u_handle, i)
        
            set tag = CreateTextTag()
            set spEffect = AddSpecialEffect("UI\\Feedback\\RallyPoint\\RallyPoint.mdl", x, y)
            call SetTextTagText(tag, I2S(i), 0.023)
            call SetTextTagPos(tag, x-32, y, 0)
            call Patrol_SetPointEffect(u_handle, i, spEffect)
            call Patrol_SetPointTag(u_handle, i, tag)
            if GetLocalPlayer() != GetOwningPlayer(whichUnit) then
                call SetTextTagVisibility(tag, false)
                call BlzSetSpecialEffectAlpha(spEffect, 0)
            endif
        endif
        
        set i = i+1
    endloop
    
    set spEffect = null
endfunction



function Patrol_DestroyPoints takes unit whichUnit returns nothing
    call Patrol_DestroyIdPoints(GetHandleId(whichUnit))
endfunction
*/
function Patrol_ResumePatrol takes unit whichUnit returns nothing
    local integer u_handle = GetHandleId(whichUnit)
    local integer currentPtrl = Patrol_GetCurrentPatrolPoint(u_handle)
    local real patrolX = Patrol_GetPointX(u_handle, currentPtrl)
    local real patrolY = Patrol_GetPointY(u_handle, currentPtrl)
    
    if not Patrol_UnitIdHasPatrolPoints(u_handle) then//currentPtrl == 0 then
        return
    endif
    
    set orderBool = true
    if Patrol_Distance(patrolX-GetUnitX(whichUnit), patrolY-GetUnitY(whichUnit)) > MINIMUM_DISTANCE then
        if not IssuePointOrder(whichUnit, "patrol", patrolX, patrolY) then
            set orderBool = false
        endif
    else
        if not IssuePointOrder(whichUnit, "move", patrolX, patrolY) then
            set orderBool = false
        endif
    endif
endfunction

function Patrol_Create takes unit whichUnit, real x0, real y0, real x, real y returns boolean
    local integer u_handle = GetHandleId(whichUnit)
    local trigger dynTrig
    local region ptrlReg
    
    if Patrol_Distance(x-x0, y-y0) > MINIMUM_DISTANCE then
        set dynTrig = CreateTrigger()
        set ptrlReg = CreateRegion()
        
        call Patrol_SetTotalPatrolPoints(u_handle, 2)
        call Patrol_SetCurrentPatrolPoint(u_handle, 2)   
        call Patrol_SetPointX(u_handle, 1, x0)
        call Patrol_SetPointY(u_handle, 1, y0)
        call Patrol_SetPointX(u_handle, 2, x)
        call Patrol_SetPointY(u_handle, 2, y)
        call Patrol_SetTrigger(u_handle, dynTrig)
        call Patrol_SetRegion(u_handle, ptrlReg)
        
        call MoveRectTo(ptrlRect, x , y)
        call RegionAddRect(ptrlReg, ptrlRect)
        
        call TriggerRegisterEnterRegion(dynTrig, ptrlReg, null )
        call TriggerAddCondition(dynTrig, Condition(function Patrol_PointReached))
        call SaveUnitHandle(data, GetHandleId(dynTrig), 0 , whichUnit)

        set dynTrig = null
        set ptrlReg = null   
    else
        return false
    endif
    return true
endfunction

function Patrol_AddPoint takes unit whichUnit, real newX, real newY returns integer
    local integer u_handle = GetHandleId(whichUnit)
    local integer pnts_number = Patrol_GetTotalPatrolPoints(u_handle)
    local real oldX
    local real oldY
    
    if pnts_number > MAX_POINTS then
        return ERROR_OVERFLOW
    
    elseif pnts_number > 0 then        
        set oldX = Patrol_GetPointX(u_handle, pnts_number)
        set oldY = Patrol_GetPointY(u_handle, pnts_number)
        
        if Patrol_Distance(newX-oldX, newY-oldY) > MINIMUM_DISTANCE then
            set pnts_number = pnts_number + 1
            call Patrol_SetTotalPatrolPoints(u_handle, pnts_number)
            call Patrol_SetPointX(u_handle, pnts_number, newX)
            call Patrol_SetPointY(u_handle, pnts_number, newY)
        else
            return ERROR_TOO_CLOSE
        endif
    else
        return ERROR_NULL_POINTER
    endif
    return ERROR_NONE
endfunction

function Patrol_RegisterPoint takes unit trigU, real newX, real newY returns nothing
    local integer errorCode = Patrol_AddPoint(trigU, newX, newY)
    
    if errorCode == ERROR_NULL_POINTER then
        if not Patrol_Create(trigU, GetUnitX(trigU), GetUnitY(trigU), newX, newY) then
            call DisplayTextToPlayer(GetOwningPlayer(trigU), 0, 0, "This patrol point is too close to the unit")
        else
            if GetUnitCurrentOrder(trigU) == 0 then
                call Patrol_ResumePatrol(trigU)
            endif
        endif
    elseif errorCode == ERROR_OVERFLOW then
        call DisplayTextToPlayer(GetOwningPlayer(trigU), 0, 0, "This unit has too many patrol points.")
    elseif errorCode == ERROR_TOO_CLOSE then
        call DisplayTextToPlayer(GetOwningPlayer(trigU), 0, 0, "This patrol point is too close to the last one")
    else
        call Patrol_ResumePatrol(trigU)
    endif
endfunction
//==================================================================================================
//  ------------------------
// ||END OF PATROL SYSTEM ||
//  
private function onInit takes nothing returns nothing
    set ptrlRect = Rect(0,0,RANGE,RANGE)
endfunction

endlibrary