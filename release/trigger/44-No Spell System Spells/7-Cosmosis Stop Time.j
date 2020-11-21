scope CosmosisStopTime

private function PlayTickTockSound takes nothing returns nothing
    call StartSound(gg_snd_StopTimeTicTac)
endfunction

private function PauseAllUnits takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()

    call SetUnitTimeScalePercent(enumUnit, 0.00 )
    call PauseUnit(enumUnit, true)
    
    set enumUnit = null
endfunction

private function UnpauseAllUnits takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    
    if UnitVisuals.get(enumUnit).hasAnimSpeed() then
        call SetUnitTimeScalePercent(enumUnit, UnitVisuals.get(enumUnit).raw.getAnimSpeed())
    else
        call SetUnitTimeScalePercent(enumUnit, 100.00 )
    endif
    call PauseUnit(enumUnit, false)
    
    set enumUnit = null
endfunction

private struct G extends array
    static key static_members_key
    //! runtextmacro TableStruct_NewStaticHandleField("pausedUnits", "group")
    //! runtextmacro TableStruct_NewStaticHandleField("tickTimer", "timer")
endstruct

private function Actions takes nothing returns nothing    
    
    if GetIssuedOrderId() == OrderId("immolation") then
        if BlzGroupGetSize(G.pausedUnits) == 0 then
            call GroupEnumUnitsInRect(G.pausedUnits, WorldBounds.world, null)
            call GroupRemoveUnit(G.pausedUnits, HERO_COSMOSIS())
            call GroupRemoveUnit(G.pausedUnits, HERO_CREATOR())
            
            call ForGroup(G.pausedUnits, function PauseAllUnits )
            call TimerStart(G.tickTimer, 1., true, function PlayTickTockSound)
        endif
    elseif  GetIssuedOrderId() == OrderId("unimmolation") then
        if BlzGroupGetSize(G.pausedUnits) > 0 then
    
            call ForGroup( G.pausedUnits, function UnpauseAllUnits )
            call PauseTimer(G.tickTimer)
            call GroupClear(G.pausedUnits)
        endif
    endif
endfunction

//===========================================================================
function InitTrig_Cosmosis_Stop_Time takes nothing returns nothing
    set gg_trg_Cosmosis_Stop_Time = CreateTrigger(  )
    call TriggerRegisterUnitEvent( gg_trg_Cosmosis_Stop_Time, HERO_COSMOSIS(), EVENT_UNIT_ISSUED_ORDER )
    call TriggerAddAction( gg_trg_Cosmosis_Stop_Time, function Actions )
    set G.pausedUnits = CreateGroup()
    set G.tickTimer = CreateTimer()
endfunction

endscope