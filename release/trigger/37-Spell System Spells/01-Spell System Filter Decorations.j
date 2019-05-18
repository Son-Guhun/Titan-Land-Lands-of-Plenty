/*
This trigger is used by spells that pick a group of units in range, using the Spell System's API. 

It simply filters decoration units, preventing them from being added to the unit goup.
*/

function Trig_Spell_System_Filter_Decorations_Conditions takes nothing returns boolean
    return not LoP_IsUnitDecoration(udg_Spell__InRangeUnit)
endfunction

//===========================================================================
function InitTrig_Spell_System_Filter_Decorations takes nothing returns nothing
    set gg_trg_Spell_System_Filter_Decorations = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_Spell_System_Filter_Decorations, Condition( function Trig_Spell_System_Filter_Decorations_Conditions ) )
endfunction

