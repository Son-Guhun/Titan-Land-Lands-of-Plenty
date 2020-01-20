scope CometSpell

private struct TimerData extends array
    
    //! runtextmacro TableStruct_NewAgentField("caster","unit")
    //! runtextmacro TableStruct_NewPrimitiveField("x","real")
    //! runtextmacro TableStruct_NewPrimitiveField("y","real")
    
    method flushCaster takes nothing returns nothing
        call casterClear()
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
        if not LoP_IsUnitDecoration(filterU) and IsUnitInRangeXY(filterU, Args.getReal(0), Args.getReal(1), 150) then
            call UnitDamageTarget( caster, filterU, 200., true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS )
            
            if IsUnitType(filterU, UNIT_TYPE_HERO) or IsUnitType(filterU, UNIT_TYPE_RESISTANT) then
                set udg_GDS_Duration = 3
            else
                set udg_GDS_Duration = 4
            endif
            
            call BlzEndUnitAbilityCooldown(caster, 'A02N')
            call BlzEndUnitAbilityCooldown(caster, 'A043')
            call BlzEndUnitAbilityCooldown(caster, 'A01M')
            
            set udg_GDS_Type = udg_GDS_cSTUN
            set udg_GDS_Target = filterU
            call TriggerExecute( gg_trg_GDS_Main_Modifier )
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
    
    
    call tData.flushCaster()
    call tData.flushX()
    call tData.flushY()
    call PauseTimer(t)
    call DestroyTimer(t)
    
    set t = null
endfunction

private function Conditions takes nothing returns boolean
    local timer t
    local TimerData tData
    local effect e
    
    if not udg_Spell__Completed then
        return false
    endif
    
    set t = CreateTimer()
    set tData  = GetHandleId(t)
    set e = AddSpecialEffect("Abilities\\Spells\\NightElf\\Starfall\\StarfallTarget.mdl", GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint))
    
    set tData.caster = udg_Spell__Caster
    set tData.x = GetLocationX(udg_Spell__TargetPoint)
    set tData.y = GetLocationY(udg_Spell__TargetPoint)
    call BlzSetSpecialEffectPitch(e, bj_PI/12.)
    call BlzSetSpecialEffectScale(e, 2.)
    call DestroyEffect(e)
    call TimerStart(t, .75, false, function onExpire)
    
    set t = null
    set e = null
    return false
endfunction

//===========================================================================
function InitTrig_Comet takes nothing returns nothing
    set gg_trg_Comet = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_Comet, Condition( function Conditions ) )
endfunction

endscope