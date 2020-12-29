library MountSystem requires StaticLinkedSet, TableStruct
/*
=========
 Description
=========

    This library allows you to attach one unit to another, and is supposed to simulate mounting. It
doesn't have many features and is made to be as fast as possible. It also contains some safeguards
against performance issues.
    
=========
 Documentation
=========

public enum Errors:
    NULL_REF
    NONE
    NO_AMOV
    MOUNT_SELF
    MOUNT_RIDER
    OVERFLOW

Functions:
    public Errors MountUnit(unit rider, unit mount)  -> Attempts to mount a unit. Returns any relevant error codes.

    public boolean Dismount(unit rider)   -> Makes a rider dismount. Returns false if the unit does not have a mount.
    public boolean DitchRider(unit mount) -> Makes a mount ditch its rider. Returns false if the unit has no rider.

    public boolean HasRider(unit mount)

    public nothing ClearData(unit whichUnit)  -> This function accepts in-scope and out-of-scope units
*/
//==================================================================================================
//                                       Configuration
//==================================================================================================

globals

    // Maximum number of concurrently mounted units.
    public constant integer MAX_COUNT = 24
    
    // Number of times a second to update rider's position. Should be a power of 2.
    public constant real FREQUENCY = 32.
endglobals

//==================================================================================================
//                                        Source Code
//==================================================================================================

public struct Errors extends array
    static constant integer NULL_REF = -1
    static constant integer NONE = 0
    static constant integer NO_AMOV = 1
    static constant integer MOUNT_SELF = 2
    static constant integer MOUNT_RIDER = 3
    static constant integer OVERFLOW = 4
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
    
    method ditchRider takes nothing returns boolean
        if .rider != null then
            call .delete()
            
            call SetUnitPathing(.unit, true)
            call SetUnitPathing(.rider, true)
            call BlzUnitDisableAbility(.rider, 'Amov', false, false)
            
            set .riderData.mount = null
            set .rider = null
            call .riderData.mountDataClear()
            call .riderDataClear()
            return true
        endif
        return false
    endmethod
    
    method dismount takes nothing returns boolean
        if .mount != null then
            call .mountData.ditchRider()
            return true
        endif
        return false
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
                call BlzSetUnitFacingEx(rider, GetUnitFacing(mount))
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
        if UnitData.size() >= MAX_COUNT then
            // Error: Too many mounted units.
            return Errors.OVERFLOW
        elseif GetUnitAbilityLevel(rider, 'Amov') == 0 then
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
        
        call BlzUnitHideAbility(rider, 'Amov', true)  // Hide ability first to leave counter unaffected
        call BlzUnitDisableAbility(rider, 'Amov', true, false)  // Hide counter (last arg) is preserved
        call mountData.append()
        
        if mountData.getFirst() == mountData then
            call TimerStart(CreateTimer(), 1/FREQUENCY, true, function onTimer)
        endif
    else
        call BJDebugMsg("Mount system error: Null reference")
        return Errors.NULL_REF
    endif
    
    return Errors.NONE
endfunction

public function Dismount takes unit rider returns boolean
    return UnitData.get(rider).dismount()
endfunction

public function DitchRider takes unit mount returns boolean
    return UnitData.get(mount).ditchRider()
endfunction

public function HasRider takes unit mount returns boolean
    return UnitData.get(mount).rider != null
endfunction

// This function accepts in-scope and out-of-scope units.
public function ClearData takes unit whichUnit returns nothing
    call UnitData.get(whichUnit).destroy()
endfunction

endlibrary