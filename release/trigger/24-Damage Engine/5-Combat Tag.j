library CombatTag requires TableStruct

private scope PHYSICAL
    globals
        public constant real RED   = 100.00
        public constant real GREEN = 100.00
        public constant real BLUE  = 100.00
    endglobals
endscope
private scope SPELL
    globals
        public constant real RED   = 10.00
        public constant real GREEN = 30.00
        public constant real BLUE  = 100.00
    endglobals
endscope
private scope HEAL
    globals
        public constant real RED   = 0.
        public constant real GREEN = 0.
        public constant real BLUE  = 0.
    endglobals
endscope

globals
    public constant key PHYS_DAMAGE
    public constant key SPELL_DAMAGE
    public constant key HEALING
endglobals

private struct CombatTag extends array

    private static method operator physDmgTable takes nothing returns ConstTable
        return PHYS_DAMAGE
    endmethod
    
    private static method operator spellDmgTable takes nothing returns ConstTable
        return SPELL_DAMAGE
    endmethod
    
    private static method operator healingTable takes nothing returns ConstTable
        return HEALING
    endmethod
    
    //! runtextmacro TableStruct_NewConstTableField("","timerData")


    static method showText takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer tId = GetHandleId(t)
        local unit u = timerData.unit[tId]
        local integer uId = GetUnitUserData(u)
        
        local real z_offset = 50
        
        if physDmgTable.real.has(uId) then
            call CreateTextTagUnitBJ( I2S(R2I(physDmgTable.real[uId])), u, z_offset, 13.00, PHYSICAL_RED, PHYSICAL_GREEN, PHYSICAL_BLUE, 0 )
            call SetTextTagVelocityBJ( bj_lastCreatedTextTag, 75.00, 90.00 )
            call SetTextTagPermanent( bj_lastCreatedTextTag, false )
            call SetTextTagLifespan( bj_lastCreatedTextTag, 3.50 )
            call SetTextTagFadepoint( bj_lastCreatedTextTag, 1.40 )
            set z_offset = z_offset + 50.0
            call physDmgTable.real.remove(uId)
        endif
        if spellDmgTable.real.has(uId) then
            call CreateTextTagUnitBJ( I2S(R2I(spellDmgTable.real[uId])), u, z_offset, 13.00, SPELL_RED, SPELL_GREEN, SPELL_BLUE, 0 )
            call SetTextTagVelocityBJ( bj_lastCreatedTextTag, 75.00, 90.00 )
            call SetTextTagPermanent( bj_lastCreatedTextTag, false )
            call SetTextTagLifespan( bj_lastCreatedTextTag, 3.50 )
            call SetTextTagFadepoint( bj_lastCreatedTextTag, 1.40 )
            set z_offset = z_offset + 50.0
            call spellDmgTable.real.remove(uId)
        endif
        
        call PauseTimer(t)
        call DestroyTimer(t)
        call timerData.unit.remove(tId)
        set t = null
        set u = null
    endmethod
endstruct

public function Register takes unit whichUnit, real value, ConstTable whichType returns nothing
    local integer uId = GetUnitUserData(whichUnit)
    local real amount
    local timer t
    
    if value <= 0. then
        return
    endif

    if whichType.real.has(uId) then
        set amount = whichType.real[uId]
    else
        set t = CreateTimer()
        call TimerStart(t, 0, false, function CombatTag.showText)
        set CombatTag.timerData.unit[GetHandleId(t)] = whichUnit
        set t = null
        set amount = 0
    endif
        
    set whichType.real[uId] = amount + value
endfunction

endlibrary