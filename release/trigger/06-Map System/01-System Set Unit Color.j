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

    // Theoretucally, we could set any trigger here, because it will never get executed (the filter always returns false)
    // But.... let's leave it this way for now
    set gg_trg_System_Set_Unit_Color = CreateTrigger(  )
    call TriggerRegisterEnterRegion( gg_trg_System_Set_Unit_Color, WorldBounds.worldRegion, Filter(function Filter_UnitSetPlayerColor) )
endfunction

endscope
