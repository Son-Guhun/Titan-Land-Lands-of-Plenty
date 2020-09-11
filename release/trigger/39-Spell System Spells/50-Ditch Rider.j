function Trig_Ditch_Rider_Actions takes nothing returns nothing
    call MountSystem_DitchRider(udg_Spell__Caster)
endfunction

//===========================================================================
function InitTrig_Ditch_Rider takes nothing returns nothing
    call RegisterSpellSimple('A060', function Trig_Ditch_Rider_Actions, null)
endfunction

