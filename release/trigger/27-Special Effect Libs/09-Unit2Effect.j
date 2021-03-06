library Unit2Effect requires DecorationSFX, StringSubanimations, UnitVisualValues, UnitTypeDefaultValues

function Unit2SpecialEffect takes unit whichUnit returns SpecialEffect
    local UnitTypeDefaultValues unitType = GetUnitTypeId(whichUnit)
    local UnitVisuals unitData = GetHandleId(whichUnit)
    local SpecialEffect result
    local real value
    
    local integer red
    local integer green
    
    if BlzGetUnitSkin(whichUnit) == GetUnitTypeId(whichUnit) then
        set result = SpecialEffect.create(unitType, GetUnitX(whichUnit), GetUnitY(whichUnit))
    else
        set result = SpecialEffect.createWithSkin(unitType, BlzGetUnitSkin(whichUnit), GetUnitX(whichUnit), GetUnitY(whichUnit))
    endif
    
    set result.height = GetUnitFlyHeight(whichUnit)
    set result.yaw = Deg2Rad(GetUnitFacing(whichUnit))
    
    if unitData.hasScale() then
        set value = unitData.raw.getScale()
        call result.setScale(value, value, value)
    elseif unitType.hasModelScale() then
        set value = unitType.modelScale
        call result.setScale(value, value, value)
    endif
    
    if unitData.hasVertexColor() then
        call result.setVertexColor(unitData.raw.getVertexRed(), unitData.raw.getVertexGreen(), unitData.raw.getVertexBlue())
        set result.alpha = unitData.raw.getVertexAlpha()
    else
        if unitType.hasRed() then
            set red = unitType.red
        else
            set red = 255
        endif
        if unitType.hasGreen() then
            set green = unitType.green
        else
            set green = 255
        endif
        if unitType.hasBlue() then
            call result.setVertexColor(red, green, unitType.blue)
        else
            if green != 255 and red != 255 then
                call result.setVertexColor(red, green, 255)
            endif
        endif
    endif
    
    if unitData.hasColor() then
        set result.color = unitData.raw.getColor() - 1
    else
        set result.color = DecorationSFX_GetPlayerColor(GetOwningPlayer(whichUnit))
    endif
    
    if unitData.hasAnimSpeed() then
        set result.animationSpeed = unitData.raw.getAnimSpeed()
    endif
    
    if unitData.hasAnimTag() then
        call AddTagsStringAsSubAnimations(result, unitData.raw.getAnimTag(), true)
    elseif unitType.hasAnimProps() then
        call AddTagsStringAsSubAnimations(result, unitType.animProps, true)
    endif
    
    if unitType.hasMaxRoll() then
        set result.roll = Deg2Rad(unitType.maxRoll+180.)
    endif
    
    return result
endfunction

function Unit2EffectEx takes player owner, unit whichUnit returns DecorationEffect
    local SpecialEffect sfx = Unit2SpecialEffect(whichUnit)
    
    call ObjectPathing.get(whichUnit).disableAndTransfer(sfx.effect)
    
    return DecorationEffect.convertSpecialEffectNoPathing(owner, sfx, UnitVisuals.get(whichUnit).hasColor())
endfunction

function Unit2Effect takes unit whichUnit returns DecorationEffect
    return Unit2EffectEx(GetOwningPlayer(whichUnit), whichUnit)
endfunction

endlibrary

library Effect2Unit requires DecorationSFX, StringSubanimations, UnitVisualMods, UnitTypeDefaultValues

function Effect2Unit takes DecorationEffect whichEffect returns unit
    local unit u
    
    set DefaultPathingMaps_dontApplyPathMap = true
    set u = CreateUnit(whichEffect.getOwner(), whichEffect.unitType, whichEffect.x, whichEffect.y, Rad2Deg(whichEffect.yaw))
    
    if u != null then
        call BlzSetUnitSkin(u, whichEffect.skin)
        call UnitVisualsSetters.Scale(u, whichEffect.scaleX)
        call UnitVisualsSetters.VertexColor(u, whichEffect.red/2.55, whichEffect.green/2.55, whichEffect.blue/2.55, 100. - whichEffect.alpha/2.55)
        call UnitVisualsSetters.FlyHeight(u, whichEffect.height)
        
        if whichEffect.hasCustomColor then
            call UnitVisualsSetters.Color(u, whichEffect.color + 1)
        endif
        
        if whichEffect.animationSpeed != 1. then
            call UnitVisualsSetters.AnimSpeed(u, whichEffect.animationSpeed)
        endif
        
        
        if whichEffect.hasSubAnimations() then
            call UnitVisualsSetters.AnimTag(u, SubAnimations2Tags(whichEffect.subanimations))
        endif
        
        call ObjectPathing(whichEffect).disableAndTransfer(u)
    else
         set DefaultPathingMaps_dontApplyPathMap = false
    endif
    
    set bj_lastCreatedUnit = u
    set u = null
    return bj_lastCreatedUnit
endfunction

endlibrary