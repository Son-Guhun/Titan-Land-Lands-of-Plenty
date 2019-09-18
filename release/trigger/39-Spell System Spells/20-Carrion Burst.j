function CarrionBurstCastAction takes nothing returns nothing
    local integer circleId = CreateGCOS(0, GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 200, 200, 4, Atan2(GetLocationY(udg_Spell__TargetPoint)-GetUnitY(udg_Spell__Caster),GetLocationX(udg_Spell__TargetPoint)-GetUnitX(udg_Spell__Caster)), bj_PI/4)
    local unit dummy = DummyDmg_CreateDummyAt(udg_Spell__Caster, 0, GetLocationX(udg_Spell__TargetPoint), GetLocationY(udg_Spell__TargetPoint), 2.)
    local integer i = 0

    call DummyDmg_AddAbility(dummy, 'A001')
    
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
