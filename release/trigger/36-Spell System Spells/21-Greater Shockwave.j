function Trig_Greater_Shockwave_Actions takes nothing returns nothing
    local integer udg_temp_integer
    local integer circId
    local real startAngle = Atan2(GetLocationY(udg_Spell__TargetPoint)-GetUnitY(udg_Spell__Caster),GetLocationX(udg_Spell__TargetPoint)-GetUnitX(udg_Spell__Caster) )
    local unit dummy = CreateUnitAtLoc(udg_Spell__CasterOwner, 'h07Q', udg_Spell__CastPoint, 270)
    
    set circId = CreateGCOS(0, GetLocationX(udg_Spell__CastPoint), GetLocationY(udg_Spell__CastPoint), 200, 200, 16, startAngle,0)
    call UnitAddAbilityBJ( 'A02V', dummy )
    
    set udg_temp_integer = 1
    loop
        exitwhen udg_temp_integer > 2
        call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circId,udg_temp_integer), GetGCOSPointY(circId,udg_temp_integer))
        set udg_temp_integer = udg_temp_integer + 1
    endloop
    
    call IssuePointOrder(dummy, "carrionswarm", GetGCOSPointX(circId,16), GetGCOSPointY(circId,16))
    call DestroyGCOS(circId)
    call DummyDmg_SetCaster(DummyDmg_GetKey(dummy), udg_Spell__Caster)
    call UnitApplyTimedLifeBJ( 5.00, 'BTLF', dummy )
    
    set dummy = null
endfunction

//===========================================================================
function InitTrig_Greater_Shockwave takes nothing returns nothing
    set gg_trg_Greater_Shockwave = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Greater_Shockwave, function Trig_Greater_Shockwave_Actions )
endfunction

