function Trig_Pick_Up_Rider_Actions takes nothing returns nothing
    if LoP_PlayerOwnsUnit(udg_Spell__CasterOwner, udg_Spell__Target) then
        call MountSystem_MountUnit(udg_Spell__Target, udg_Spell__Caster)
    endif
endfunction

//===========================================================================
function InitTrig_Pick_Up_Rider takes nothing returns nothing
    set gg_trg_Pick_Up_Rider = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Pick_Up_Rider, function Trig_Pick_Up_Rider_Actions )
endfunction

