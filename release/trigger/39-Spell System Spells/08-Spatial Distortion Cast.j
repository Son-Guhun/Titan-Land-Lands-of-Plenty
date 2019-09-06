scope SpatialDistortion

private struct TimerData extends array
    
    //! runtextmacro TableStruct_NewHandleField("caster","unit")
    //! runtextmacro TableStruct_NewPrimitiveField("counter","integer")
    //! runtextmacro TableStruct_NewPrimitiveField("x","real")
    //! runtextmacro TableStruct_NewPrimitiveField("y","real")
    
    method flushCaster takes nothing returns nothing
        call casterClear()
    endmethod
    method flushCounter takes nothing returns nothing
        call counterClear()
    endmethod
    method flushX takes nothing returns nothing
        call xClear()
    endmethod
    method flushY takes nothing returns nothing
        call yClear()
    endmethod
endstruct

private function onExpire_EnumInRange takes nothing returns nothing
    local unit filterU = GetFilterUnit()
    local unit caster = Args.getUnit(0)
    
    if not IsPlayerAlly(GetOwningPlayer(caster), GetOwningPlayer(filterU)) then
        if IsUnitInRangeXY(filterU, Args.getReal(0), Args.getReal(1), 200) then
            call UnitDamageTarget( caster, filterU, 20., true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS )
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
    
    call Args.setUnit(0, tData.caster)
    call Args.setReal(0, x)
    call Args.setReal(1, y)
    call GroupEnumUnitsInRange(ENUM_GROUP, x, y, 400, Filter(function onExpire_EnumInRange))
    call Args.freeReal(0)
    call Args.freeReal(1)
    call Args.freeUnit(0)
    
    if tData.counter >= 4 then
        call tData.flushCaster()
        call tData.flushCounter()
        call tData.flushX()
        call tData.flushY()
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
    call TimerStart(t, 0.2, true, function onExpire)
    
    set t = null
    return false
endfunction

//===========================================================================
function InitTrig_Spatial_Distortion_Cast takes nothing returns nothing
    set gg_trg_Spatial_Distortion_Cast = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_Spatial_Distortion_Cast, Condition( function Trig_Spatial_Distortion_Cast_Conditions ) )
endfunction

endscope