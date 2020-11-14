scope SystemLevelUpHeroes
/*
    Set hero level to 10 upon creation.

*/

private function onRegisterUnit takes nothing returns boolean
    local unit hero = udg_UDexUnits[udg_UDex]
    local string properName
    local string name

    if IsUnitType(hero, UNIT_TYPE_HERO) == true then
    
        if GetHeroLevel(hero) < 10 then
            call SetHeroLevel(hero, 10, false)
        endif
        
        set properName = UnitName_GetUnitName(hero)
        if StringLength(properName) > 4 and SubString(properName, 0, 3) == "_HD" then
            call UnitName_SetUnitName(hero, SubString(properName, 4, StringLength(properName)))
        endif
        
        set name = GetUnitName(hero)
        if StringLength(name) > 4 and SubString(name, 0, 3) == "_HD" then
            call BlzSetUnitName(hero, SubString(name, 4, StringLength(name)))
        endif
        
    endif
    
    set hero = null
    return false
endfunction

//===========================================================================
function InitTrig_System_Level_Up_Heroes takes nothing returns nothing
    set gg_trg_System_Level_Up_Heroes = CreateTrigger(  )
    call TriggerRegisterVariableEvent( gg_trg_System_Level_Up_Heroes, "udg_UnitIndexEvent", EQUAL, 1.00 )
    call TriggerAddCondition(gg_trg_System_Level_Up_Heroes, Condition(function onRegisterUnit))
endfunction

endscope

