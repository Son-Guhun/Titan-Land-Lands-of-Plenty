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
            call .delete()
            
            call SetUnitPathing(.unit, true)
            call SetUnitPathing(.rider, true)
            call BlzUnitDisableAbility(.rider, 'Amov', false, false)
            
            set UnitData.get(.rider).mount = null
            set .rider = null
        endif
    endmethod
    
    method dismount takes nothing returns nothing
        // call BJDebugMsg("Dismounting")
        if .mount != null then
            // call BJDebugMsg("Mount found")
            call UnitData.get(.mount).ditchRider()
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

public function MountUnit takes unit rider, unit mount returns nothing
    local UnitData mountData = UnitData.get(mount)
    local UnitData riderData = UnitData.get(rider)
    
    if rider != null and mount != null then
        if GetUnitAbilityLevel(rider, 'Amov') == 0 then
            // Error: A unit without Amov cannot mount (since SetUnitX/Y doesn't function).
            return
        elseif rider == mount then
            // Error: Unit cannot ride itself.
            return
        elseif mountData.mount != null and rider == mountData.mount then
            // Error: Mount cannot ride its own rider.
            return
        endif
        
        if mountData.rider != null then
            if rider == mountData.rider then
                // No need to do anything in this case, rider is already riding this mount.
                return
            else
                call mountData.ditchRider()
            endif
        endif
        
        if riderData.mount != null then
            call riderData.dismount()  // case for riding own rider already handled above
        endif
        
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