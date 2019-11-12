library MountSystem requires StaticLinkedSet 

private struct UnitData extends array
    implement StaticLinkedSetNode

    unit rider
    unit mount
    
    method operator unit takes nothing returns unit
        return udg_UDexUnits[this]
    endmethod
    
    static method get takes unit whichUnit returns UnitData
        return GetUnitUserData(whichUnit)
    endmethod
    
    method ditchRider takes nothing returns nothing
        if .rider != null then
            set UnitData.get(.rider).mount = null
            set .rider = null
            call .delete()
        endif
    endmethod
    
    method dismount takes nothing returns nothing
        if .mount != null then
            call UnitData.get(.rider).ditchRider()
        endif
    endmethod
    

    method destroy takes nothing returns nothing
        call .dismount()
        call .ditchRider()
    endmethod
endstruct

private function onTimer takes nothing returns nothing
    local UnitData mountData = UnitData.begin()
    local unit mount
    local unit rider
    
    call BJDebugMsg(I2S(UnitData.head.next))
    if mountData.head == mountData then
        call PauseTimer(GetExpiredTimer())
        call DestroyTimer(GetExpiredTimer())
    else
        loop
            set mount = mountData.unit
            set rider = mountData.rider
            
            call SetUnitPathing(rider, false)
            call SetUnitPathing(mount, false)
            call SetUnitFacing(rider, GetUnitFacing(mount))
            call SetUnitX(rider, GetUnitX(mount))
            call SetUnitY(rider, GetUnitY(mount))
            
            //! runtextmacro StaticLinkedSet_ForNode("mountData")
        endloop
    endif
endfunction

public function MountUnit takes unit rider, unit mount returns nothing
    local UnitData mountData = UnitData.get(mount)
    
    if rider != null and mount != null then
        set UnitData.get(rider).mount = mount
        set UnitData.get(mount).rider = rider
        
        call BlzUnitDisableAbility(rider, 'Amov', true, false)
        call mountData.append()
        
        if mountData.getFirst() == mountData then
            call TimerStart(CreateTimer(), 0.03, true, function onTimer)
        endif
    endif
endfunction

public function Dismount takes unit rider returns nothing
    call UnitData.get(rider).dismount()
endfunction

public function DitchRider takes unit mount returns nothing
    call UnitData.get(mount).ditchRider()
endfunction

public function ClearData takes unit whichUnit returns nothing
    call UnitData.get(whichUnit).destroy()
endfunction

endlibrary