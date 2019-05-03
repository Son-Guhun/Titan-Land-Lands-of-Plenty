

scope StaffOfMimic


private function onStartEffect takes nothing returns nothing
    if IsValidHeroicUnit(udg_Spell__Target, GetOwningPlayer(udg_Spell__Caster)) then
        call CreateUnitMimic(udg_Spell__Caster, udg_Spell__Target)
    endif
endfunction

//===========================================================================
function InitTrig_Staff_of_Mimic takes nothing returns nothing
    set gg_trg_Staff_of_Mimic = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Staff_of_Mimic, function onStartEffect )
endfunction


endscope

