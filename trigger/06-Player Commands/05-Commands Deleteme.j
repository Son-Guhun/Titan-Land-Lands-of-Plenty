function GroupEnum_RemoveOutsidePalace takes nothing returns boolean
    if not RectContainsUnit(gg_rct_Titan_Palace, GetEnumUnit()) and Commands_CheckOverflow() then
        call LoP_RemoveUnit(GetEnumUnit())
    endif
    return false
endfunction

function Trig_Commands_Deleteme_Actions takes nothing returns nothing
    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = 500
    call GroupEnumUnitsOfPlayer(ENUM_GROUP, GetTriggerPlayer(), Filter(function GroupEnum_RemoveOutsidePalace))
endfunction

//===========================================================================
function InitTrig_Commands_Deleteme takes nothing returns nothing
    set gg_trg_Commands_Deleteme = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Deleteme, function Trig_Commands_Deleteme_Actions )
endfunction

