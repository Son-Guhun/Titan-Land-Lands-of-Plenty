

scope StaffOfMimic


private function onStartEffect takes nothing returns nothing
    if LoP_IsUnitProtected(udg_Spell__Target) then
        call DisplayTextToPlayer(udg_Spell__CasterOwner, 0, 0, "This unit's powers far exceed mortal imagination. No type of forgery can mimic their unfathomable form.")
    elseif LoP_IsUnitProtected(udg_Spell__Caster) then
        call DisplayTextToPlayer(udg_Spell__CasterOwner, 0, 0, "This unit will not lower itself in order to mimic an imperfect mortal being.")
    elseif IsUnitType(udg_Spell__Target, UNIT_TYPE_HERO) then
        call CreateUnitMimic(udg_Spell__Caster, udg_Spell__Target)
    elseif IsValidHeroicUnit(udg_Spell__Target, GetOwningPlayer(udg_Spell__Caster)) then
        call CreateUnitMimic(udg_Spell__Caster, udg_Spell__Target)
    endif
endfunction

//===========================================================================
function InitTrig_Staff_of_Mimic takes nothing returns nothing
    set gg_trg_Staff_of_Mimic = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Staff_of_Mimic, function onStartEffect )
endfunction


endscope

