library TransportUtils requires TableStruct

static if not LIBRARY_BribesUnitEvent then
    private struct UnitData extends array

            //! runtextmacro TableStruct_NewAgentField("group", "group")
            
            method hasGroup takes nothing returns boolean
                return .groupExists()
            endmethod

            static method get takes unit whichUnit returns thistype
                return GetHandleId(whichUnit)
            endmethod
            
            method destroy takes nothing returns nothing
                if .groupExists() then
                    call DestroyGroup(.group)
                    call .groupClear()
                endif
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
    
    private function onLoad takes nothing returns nothing
        local UnitData transportData = UnitData.get(GetTransportUnit())
        
        if transportData.hasGroup() then
            call RefreshGroup(GetTransportUnit(), transportData.group)
        else
            set transportData.group = CreateGroup()
        endif
        
        call GroupAddUnit(transportData.group, GetTriggerUnit())
    endfunction
    
    function InitTrig_TransportUtils takes nothing returns nothing
        local trigger trig = CreateTrigger( )
        call TriggerRegisterAnyUnitEventBJ( trig, EVENT_PLAYER_UNIT_LOADED )
        call TriggerAddAction( trig, function onLoad )
    endfunction
endif

function ClearTransportHandleId takes integer handleId returns nothing
    static if not LIBRARY_BribesUnitEvent then
        call UnitData(handleId).destroy()
    else
        call I2R(handleId)
    endif
endfunction

function ClearTransportData takes unit whichUnit returns nothing
    call ClearTransportHandleId(GetHandleId(whichUnit))
endfunction
    
function GetTransportedUnits takes unit transport returns group
    static if not LIBRARY_BribesUnitEvent then
        local UnitData transportData = UnitData.get(transport)
        
        if transportData.hasGroup() then
            return RefreshGroup(transport, transportData.group)
        else
            return null
        endif
    else
        return udg_CargoTransportGroup[GetUnitUserData(transport)]
    endif
endfunction

endlibrary
