scope SystemDeselect

function onDeselect takes nothing returns boolean
    local unit trigU = GetTriggerUnit()
    
    if GetOwningPlayer(trigU) == GetTriggerPlayer() and LoP_UnitData.get(trigU).hideOnDeselect then
        call ShowUnit(trigU, false)
    endif
    
    set trigU = null
    return false
endfunction

//===========================================================================
function InitTrig_System_Deselect takes nothing returns nothing
    set gg_trg_System_Deselect = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_System_Deselect, Condition(function onDeselect))
endfunction

endscope

