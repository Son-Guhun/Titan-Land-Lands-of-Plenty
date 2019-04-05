function Trig_Spell_System_Filter_Decorations_Conditions takes nothing returns boolean
    if GetUnitAbilityLevel(udg_Spell__InRangeUnit , 'A0C6') != 0  then
        return false
    endif
    return true
endfunction

//===========================================================================
function InitTrig_Spell_System_Filter_Decorations takes nothing returns nothing
    set gg_trg_Spell_System_Filter_Decorations = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_Spell_System_Filter_Decorations, Condition( function Trig_Spell_System_Filter_Decorations_Conditions ) )
endfunction

