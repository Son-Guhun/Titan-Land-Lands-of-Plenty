function Trig_Pick_Up_Rider_Actions takes nothing returns nothing
    call MountSystem_MountUnit(udg_Spell__Target, udg_Spell__Caster)
endfunction

//===========================================================================
function InitTrig_Pick_Up_Rider takes nothing returns nothing
    set gg_trg_Pick_Up_Rider = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Pick_Up_Rider, function Trig_Pick_Up_Rider_Actions )
endfunction

