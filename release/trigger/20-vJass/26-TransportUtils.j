// TODO: Clear Data on removal!
library TransportUtils requires TableStruct

private struct UnitData extends array

    //! runtextmacro TableStruct_NewHandleField("group", "group")
    
    method hasGroup takes nothing returns boolean
        return .groupExists()
    endmethod

    static method get takes unit whichUnit returns thistype
        return GetHandleId(whichUnit)
    endmethod
endstruct

private function RefreshGroup takes unit transport, group transportGrp returns group
    local group tempGrp = CreateGroup()
    local integer i = 0
    local integer size = BlzGroupGetSize(transportGrp)
    local unit u
    
    loop
        exitwhen i >= size
        set u = BlzGroupUnitAt(transportGrp, i)
        if u != null and IsUnitInTransport(u, transport) then
            call GroupAddUnit(tempGrp, u)
        else
        endif
        set i = i + 1
    endloop
    
    call GroupClear(transportGrp)
    call BlzGroupAddGroupFast(tempGrp, transportGrp)
    call DestroyGroup(tempGrp)
    set u = null
    set tempGrp = null
    return transportGrp
endfunction
    
function GetTransportedUnits takes unit transport returns group
    local UnitData transportData = UnitData.get(transport)
    
    if transportData.hasGroup() then
        return RefreshGroup(transport, transportData.group)
    else
        return null
    endif
endfunction

private function onLoad takes nothing returns nothing
    local UnitData transportData = UnitData.get(GetTransportUnit())
    
    if transportData.hasGroup() then
        call RefreshGroup(GetTransportUnit(), transportData.group)
    else
        set transportData.group = CreateGroup()
    endif
    
    call GroupAddUnit(transportData.group, GetTriggerUnit())
endfunction

//===========================================================================
function InitTrig_TransportUtils takes nothing returns nothing
    local trigger trig = CreateTrigger( )
    call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_LOADED )
    call TriggerAddAction( trig, function onLoad )
endfunction
endlibrary
