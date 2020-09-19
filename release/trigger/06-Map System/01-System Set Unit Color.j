scope SystemSetUnitColor

//! runtextmacro DefineHooks()

function Filter_UnitSetPlayerColor takes nothing returns boolean
    local unit filterU = GetFilterUnit()

    if not UnitVisuals.get(filterU).hasColor() then
        call SetUnitColor(filterU, LoP_PlayerData.get(GetOwningPlayer(filterU)).getUnitColor())
    endif

    set filterU = null
    return false
endfunction

//===========================================================================
function InitTrig_System_Set_Unit_Color takes nothing returns nothing
    call TriggerRegisterEnterRegion(CreateTrigger(), WorldBounds.worldRegion, Filter(function Filter_UnitSetPlayerColor) )
endfunction

endscope
