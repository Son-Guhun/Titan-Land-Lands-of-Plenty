

scope StaffOfMimic


private function onStartEffect takes nothing returns nothing
    call CreateUnitMimic(udg_Spell__Caster, udg_Spell__Target)
endfunction

//===========================================================================
function InitTrig_Staff_of_Mimic takes nothing returns nothing
    set gg_trg_Staff_of_Mimic = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Staff_of_Mimic, function onStartEffect )
endfunction


endscope

