function CarrionBurstCastAction takes nothing returns nothing
    local integer circleId = CreateGCOS(0, GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 200, 200, 4, Atan2(GetLocationY(udg_Spell__TargetPoint)-GetUnitY(udg_Spell__Caster),GetLocationX(udg_Spell__TargetPoint)-GetUnitX(udg_Spell__Caster)), bj_PI/4)
    local unit dummy = CreateUnit(udg_Spell__CasterOwner, 'h07Q', GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 270)//GetRecycledDummy(GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 0, 270)
    local integer i = 0

    call UnitAddAbility(dummy, 'A001')
    call UnitApplyTimedLife(dummy, 'BTLF', 2)
    call DummyDmg_SetCaster(DummyDmg_GetKey(dummy), udg_Spell__Caster)
    
    loop
    exitwhen i > 4
        call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circleId,i), GetGCOSPointY(circleId,i))
        set i = i + 1
    endloop
    
    call DestroyGCOS(circleId)
    set dummy = null
endfunction
//===========================================================================
function InitTrig_Carrion_Burst takes nothing returns nothing

    set gg_trg_Carrion_Burst = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Carrion_Burst, function CarrionBurstCastAction )

endfunction
