library Unit2Effect requires SpecialEffect, UnitVisualMods

    function Unit2Effect takes unit whichUnit returns SpecialEffect
        local UnitVisuals unitData = GetHandleId(whichUnit)
        local DecorationEffect result = DecorationEffect.create(GetOwningPlayer(whichUnit), GetUnitTypeId(whichUnit), GetUnitX(whichUnit), GetUnitY(whichUnit))
        local real value
        
        set result.height = GetUnitFlyHeight(whichUnit)
        set result.yaw = Deg2Rad(GetUnitFacing(whichUnit))
        
        if unitData.hasScale() then
            set value = unitData.raw.getScale()
            call result.setScale(value, value, value)
        endif
        
        if unitData.hasVertexColor(UnitVisualMods_RED) then
            call result.setVertexColor(unitData.raw.getVertexRed(), unitData.raw.getVertexGreen(), unitData.raw.getVertexBlue())
            set result.alpha = unitData.raw.getVertexAlpha()
        endif
        
        if unitData.hasColor() then
            set result.color = unitData.raw.getColor() - 1
        endif
        
        // Anim speed
        // Anim tag
        
        call RemoveUnit(whichUnit)
        return result
    endfunction
    
    function Effect2Unit takes DecorationEffect whichEffect returns unit
        local unit u = CreateUnit(whichEffect.getOwner(), whichEffect.unitType, whichEffect.x, whichEffect.y, Rad2Deg(whichEffect.yaw))
        
        
        call GUMSSetUnitScale(u, whichEffect.scaleX)
        call GUMSSetUnitVertexColor(u, whichEffect.red/2.55, whichEffect.green/2.55, whichEffect.blue/2.55, 100. - whichEffect.alpha/2.55)
        call GUMSSetUnitFlyHeight(u, whichEffect.height)
        call GUMSSetUnitColor(u, whichEffect.color + 1)
    
        call whichEffect.destroy()
        set bj_lastCreatedUnit = u
        set u = null
        return bj_lastCreatedUnit
    endfunction

endlibrary