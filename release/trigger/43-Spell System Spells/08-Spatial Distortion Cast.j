scope SpatialDistortion

private struct TimerData extends array
    
    implement AgentStruct
    
    //! runtextmacro HashStruct_NewAgentField("caster","unit")
    //! runtextmacro HashStruct_NewPrimitiveField("counter","integer")
    //! runtextmacro HashStruct_NewPrimitiveField("x","real")
    //! runtextmacro HashStruct_NewPrimitiveField("y","real")
    
endstruct

private function onExpire_EnumInRange takes nothing returns nothing
    local unit filterU = GetFilterUnit()
    local unit caster = Args.s.unit[0]
    
    if not IsPlayerAlly(GetOwningPlayer(caster), GetOwningPlayer(filterU)) then
        if IsUnitInRangeXY(filterU, Args.s.real[1], Args.s.real[2], 200) then
            call UnitDamageTarget( caster, filterU, 25., true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS )
        endif
    endif
    
    set filterU = null
    set caster = null
endfunction

private function onExpire takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local TimerData tData = GetHandleId(t)
    local real x = tData.x
    local real y = tData.y
    
    call Args.newStack()
    set Args.s.unit[0] = tData.caster
    set Args.s.real[1] = x
    set Args.s.real[2] = y
    call GroupEnumUnitsInRange(ENUM_GROUP, x, y, 400, Filter(function onExpire_EnumInRange))
    call Args.s.flush()
    call Args.pop()
    
    if tData.counter >= 4 then
        call tData.destroy()
        call PauseTimer(t)
        call DestroyTimer(t)
    else
        set tData.counter = tData.counter + 1
    endif
    
    set t = null
endfunction

function Trig_Spatial_Distortion_Cast_Conditions takes nothing returns boolean
    local timer t
    local TimerData tData
     
    if ( not ( GetUnitTypeId(udg_Spell__Caster) != 'H098' ) ) then
        return false
    endif
    
    set t = CreateTimer()
    set tData  = GetHandleId(t)
    
    set tData.caster = udg_Spell__Caster
    set tData.x = GetLocationX(udg_Spell__CastPoint)
    set tData.y = GetLocationY(udg_Spell__CastPoint)
    set tData.counter = 0
    call TimerStart(t, 0.25, true, function onExpire)
    
    set t = null
    return false
endfunction

//===========================================================================
function InitTrig_Spatial_Distortion_Cast takes nothing returns nothing
    call RegisterSpellSimple('A02U', null, Condition(function Trig_Spatial_Distortion_Cast_Conditions))
endfunction

endscope