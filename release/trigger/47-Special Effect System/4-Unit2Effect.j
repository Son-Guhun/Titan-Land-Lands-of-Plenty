library Unit2Effect requires SpecialEffect, UnitVisualMods

    function Unit2Effect takes unit whichUnit returns SpecialEffect
        local UnitVisuals unitData = GetHandleId(whichUnit)
        local DecorationEffect result = DecorationEffect.create(GetOwningPlayer(whichUnit), GetUnitTypeId(whichUnit), GetUnitX(whichUnit), GetUnitY(whichUnit))
        local real value
        
        set result.height = GetUnitFlyHeight(whichUnit)
        set result.yaw = Deg2Rad(GetUnitFacing(whichUnit))
        
        call BJDebugMsg(GUMSGetUnitScale(whichUnit))
        
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
        
        call BJDebugMsg(I2S(result.red))
        call BJDebugMsg(I2S(result.green))
        call BJDebugMsg(I2S(result.blue))
        call BJDebugMsg(I2S(result.alpha))
        
        
    
        return result
    endfunction
    
    function Effect2Unit takes DecorationEffect whichEffect returns unit
        local unit u = CreateUnit(whichEffect.getOwner(), whichEffect.unitType, whichEffect.x, whichEffect.y, Rad2Deg(whichEffect.yaw))
        
        
        call GUMSSetUnitScale(u, whichEffect.scaleX)
        call GUMSSetUnitVertexColor(u, whichEffect.red, whichEffect.green, whichEffect.blue, whichEffect.alpha)
        call GUMSSetUnitFlyHeight(u, whichEffect.height)
        call GUMSSetUnitColor(u, whichEffect.color + 1)
    
        set bj_lastCreatedUnit = u
        set u = null
        return u
    endfunction

endlibrary