scope CreatorInvincibility

private function onTimer takes nothing returns nothing
    if not UnitAlive(HERO_CREATOR()) then
        call ReviveHero(HERO_CREATOR(), GetUnitX(HERO_CREATOR()), GetUnitY(HERO_CREATOR()), false)
    endif
endfunction


//===========================================================================
function InitTrig_TheCreator_Invincibility takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function onTimer)
endfunction

endscope