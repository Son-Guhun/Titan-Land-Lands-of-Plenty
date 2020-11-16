library MountSystem requires StaticLinkedSet, TableStruct

public struct Errors extends array
    static constant integer NONE = 0
    static constant integer NO_AMOV = 1
    static constant integer MOUNT_SELF = 2
    static constant integer MOUNT_RIDER = 3
endstruct

private struct UnitData extends array
    implement StaticLinkedSetNode

    unit rider
    unit mount
    //! runtextmacro TableStruct_NewStructField("riderData", "UnitData")
    //! runtextmacro TableStruct_NewStructField("mountData", "UnitData")
    
    method operator unit takes nothing returns unit
        return udg_UDexUnits[this]
    endmethod
    
    static method get takes unit whichUnit returns UnitData
        return GetUnitUserData(whichUnit)
    endmethod
    
    method ditchRider takes nothing returns nothing
        if .rider != null then
            call .delete()
            
            call SetUnitPathing(.unit, true)
            call SetUnitPathing(.rider, true)
            call BlzUnitDisableAbility(.rider, 'Amov', false, false)
            
            set .riderData.mount = null
            set .rider = null
            call .riderData.mountDataClear()
            call .riderDataClear()
        endif
    endmethod
    
    method dismount takes nothing returns nothing
        // call BJDebugMsg("Dismounting")
        if .mount != null then
            // call BJDebugMsg("Mount found")
            call .mountData.ditchRider()
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
    
    // call BJDebugMsg(I2S(UnitData.head.next))
    if mountData.head == mountData then
        call PauseTimer(GetExpiredTimer())
        call DestroyTimer(GetExpiredTimer())
    else
        loop
            set mount = mountData.unit
            set rider = mountData.rider
            
            call SetUnitPathing(rider, false)
            call SetUnitPathing(mount, false)
            if GetUnitCurrentOrder(rider) == 0 then
                call SetUnitFacing(rider, GetUnitFacing(mount))
            endif
            call SetUnitX(rider, GetUnitX(mount))
            call SetUnitY(rider, GetUnitY(mount))
            
            //! runtextmacro StaticLinkedSet_ForNode("mountData")
        endloop
    endif
endfunction

public function MountUnit takes unit rider, unit mount returns integer
    local UnitData mountData = UnitData.get(mount)
    local UnitData riderData = UnitData.get(rider)
    
    if rider != null and mount != null then
        if GetUnitAbilityLevel(rider, 'Amov') == 0 then
            // Error: A unit without Amov cannot mount (since SetUnitX/Y doesn't function).
            return Errors.NO_AMOV
        elseif rider == mount then
            // Error: Unit cannot ride itself.
            return Errors.MOUNT_SELF
        elseif mountData.mount != null and rider == mountData.mount then
            // Error: Mount cannot ride its own rider.
            return Errors.MOUNT_RIDER
        endif
        
        if mountData.rider != null then
            if rider == mountData.rider then
                // No need to do anything in this case, rider is already riding this mount.
                return Errors.NONE
            else
                call mountData.ditchRider()
            endif
        endif
        
        if riderData.mount != null then
            call riderData.dismount()  // case for riding own rider already handled above
        endif
        
        set UnitData.get(rider).mount = mount
        set UnitData.get(rider).mountData = GetUnitUserData(mount)
        set UnitData.get(mount).rider = rider
        set UnitData.get(mount).riderData = GetUnitUserData(rider)
        
        call BlzUnitDisableAbility(rider, 'Amov', true, false)
        call mountData.append()
        
        if mountData.getFirst() == mountData then
            call TimerStart(CreateTimer(), 1/32., true, function onTimer)
        endif
    endif
    return Errors.NONE
endfunction

public function Dismount takes unit rider returns nothing
    call UnitData.get(rider).dismount()
endfunction

public function DitchRider takes unit mount returns nothing
    call UnitData.get(mount).ditchRider()
endfunction

// This function accepts in-scope and out-of-scope units.
public function ClearData takes unit whichUnit returns nothing
    call UnitData.get(whichUnit).destroy()
endfunction

endlibrary