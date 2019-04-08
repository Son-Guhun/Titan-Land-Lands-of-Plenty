function Trig_CommandsR_Enable_Dmg_Tags_Conditions takes nothing returns boolean
    if GetTriggerPlayer() == udg_GAME_MASTER  then
        set ENABLE_TAGS = not ENABLE_TAGS
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Toggle_Dmg_Tags takes nothing returns nothing
    set gg_trg_CommandsR_Toggle_Dmg_Tags = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_CommandsR_Toggle_Dmg_Tags, Condition( function Trig_CommandsR_Enable_Dmg_Tags_Conditions ) )
endfunction

