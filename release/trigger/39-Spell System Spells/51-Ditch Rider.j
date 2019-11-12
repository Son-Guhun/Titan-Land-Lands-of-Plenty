function Trig_Ditch_Rider_Actions takes nothing returns nothing
    call MountSystem_DitchRider(udg_Spell__Caster)
endfunction

//===========================================================================
function InitTrig_Ditch_Rider takes nothing returns nothing
    set gg_trg_Ditch_Rider = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Ditch_Rider, function Trig_Ditch_Rider_Actions )
endfunction

