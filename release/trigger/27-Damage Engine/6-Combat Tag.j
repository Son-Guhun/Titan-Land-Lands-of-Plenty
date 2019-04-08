library CombatTag initializer onInit

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
    public Table PHYS_DAMAGE
    public Table SPELL_DAMAGE
    public Table HEALING
    
    private Table timerData
endglobals

private function ShowText takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer tId = GetHandleId(t)
    local unit u = timerData.unit[tId]
    local integer uId = GetUnitUserData(u)
    
    local real z_offset = 50
    
    if PHYS_DAMAGE.real[uId] > 0. then
        call CreateTextTagUnitBJ( I2S(R2I(PHYS_DAMAGE.real[uId])), u, z_offset, 13.00, PHYSICAL_RED, PHYSICAL_GREEN, PHYSICAL_BLUE, 0 )
        call SetTextTagVelocityBJ( bj_lastCreatedTextTag, 75.00, 90.00 )
        call SetTextTagPermanent( bj_lastCreatedTextTag, false )
        call SetTextTagLifespan( bj_lastCreatedTextTag, 3.50 )
        call SetTextTagFadepoint( bj_lastCreatedTextTag, 1.40 )
        set z_offset = z_offset + 50.0
        set PHYS_DAMAGE.real[uId] = 0.
    endif
    if SPELL_DAMAGE.real[uId] > 0. then
        call CreateTextTagUnitBJ( I2S(R2I(SPELL_DAMAGE.real[uId])), u, z_offset, 13.00, SPELL_RED, SPELL_GREEN, SPELL_BLUE, 0 )
        call SetTextTagVelocityBJ( bj_lastCreatedTextTag, 75.00, 90.00 )
        call SetTextTagPermanent( bj_lastCreatedTextTag, false )
        call SetTextTagLifespan( bj_lastCreatedTextTag, 3.50 )
        call SetTextTagFadepoint( bj_lastCreatedTextTag, 1.40 )
        set z_offset = z_offset + 50.0
        set SPELL_DAMAGE.real[uId] = 0.
    endif
    
    call PauseTimer(t)
    call DestroyTimer(t)
    call timerData.unit.remove(tId)
    set t = null
    set u = null
endfunction

public function Register takes unit whichUnit, real value, Table whichType returns nothing
    local integer uId = GetUnitUserData(whichUnit)
    local real amount = whichType.real[uId]
    local timer t
    
    if value <= 0. then
        return
    endif
    
    if amount <= 0. then
        set t = CreateTimer()
        call TimerStart(t, 0, false, function ShowText)
        set timerData.unit[GetHandleId(t)] = whichUnit
        set t = null
    endif
        
    set whichType.real[uId] = amount + value
endfunction

private function onInit takes nothing returns nothing
    set PHYS_DAMAGE = Table.create()
    set SPELL_DAMAGE = Table.create()
    set HEALING = Table.create()
    
    set timerData = Table.create()
endfunction

endlibrary