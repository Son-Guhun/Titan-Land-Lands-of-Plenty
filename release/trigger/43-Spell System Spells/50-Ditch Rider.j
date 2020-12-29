function Trig_Ditch_Rider_Actions takes nothing returns nothing
    if MountSystem_DitchRider(udg_Spell__Caster) then
        call LoP.H.UnitDisableAbility(udg_Spell__Caster, 'A04S', false)
    endif
endfunction

//===========================================================================
function InitTrig_Ditch_Rider takes nothing returns nothing
    call RegisterSpellSimple('A060', function Trig_Ditch_Rider_Actions, null)
endfunction

