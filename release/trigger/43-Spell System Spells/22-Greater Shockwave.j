scope SpellGreaterShockwave

private function onEffect takes nothing returns nothing
    local integer udg_temp_integer
    local integer circId
    local real startAngle = Atan2(GetLocationY(udg_Spell__TargetPoint)-GetUnitY(udg_Spell__Caster),GetLocationX(udg_Spell__TargetPoint)-GetUnitX(udg_Spell__Caster) )
    local unit dummy = DummyDmg_CreateDummy(udg_Spell__Caster, 0, 5.)
    
    set circId = CreateGCOS(0, GetLocationX(udg_Spell__CastPoint), GetLocationY(udg_Spell__CastPoint), 200, 200, 16, startAngle,0)
    call DummyDmg_AddAbility(dummy, 'A02V')
    
    set udg_temp_integer = 1
    loop
        exitwhen udg_temp_integer > 2
        call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circId,udg_temp_integer), GetGCOSPointY(circId,udg_temp_integer))
        set udg_temp_integer = udg_temp_integer + 1
    endloop
    
    call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circId,16), GetGCOSPointY(circId,16))
    call DestroyGCOS(circId)
    
    set dummy = null
endfunction

//===========================================================================
function InitTrig_Greater_Shockwave takes nothing returns nothing
    call RegisterSpellSimple('A02R', function onEffect, null)
endfunction

endscope
