library Unit2Effect requires DecorationSFX, StringSubanimations, UnitVisualValues, UnitTypeDefaultValues

function Unit2SpecialEffect takes unit whichUnit returns SpecialEffect
    local UnitTypeDefaultValues unitType = GetUnitTypeId(whichUnit)
    local UnitVisuals unitData = GetHandleId(whichUnit)
    local SpecialEffect result = SpecialEffect.create(unitType, GetUnitX(whichUnit), GetUnitY(whichUnit))
    local real value
    
    local integer red
    local integer green
    
    set result.height = GetUnitFlyHeight(whichUnit)
    set result.yaw = Deg2Rad(GetUnitFacing(whichUnit))
    
    if unitData.hasScale() then
        set value = unitData.raw.getScale()
        call result.setScale(value, value, value)
    elseif unitType.hasModelScale() then
        set value = unitType.modelScale
        call result.setScale(value, value, value)
    endif
    
    if unitData.hasVertexColor(UnitVisualMods_RED) then
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
        debug call BJDebugMsg("Tags: " + unitData.raw.getAnimTag())
        call AddTagsStringAsSubAnimations(result, GUMSConvertTags(UnitVisualMods_TAGS_DECOMPRESS, unitData.raw.getAnimTag()), true)
    elseif unitType.hasAnimProps() then
        call AddTagsStringAsSubAnimations(result, unitType.animProps, true)
    endif
    
    if unitType.hasMaxRoll() then
        set result.roll = Deg2Rad(unitType.maxRoll+180.)
    endif
    
    call BlzPlaySpecialEffect(result.effect, ANIM_TYPE_STAND)
    return result
endfunction

function Unit2EffectEx takes player owner, unit whichUnit returns DecorationEffect
    return DecorationEffect.convertSpecialEffect(owner, Unit2SpecialEffect(whichUnit), UnitVisuals.get(whichUnit).hasColor())
endfunction

function Unit2Effect takes unit whichUnit returns DecorationEffect
    return Unit2EffectEx(GetOwningPlayer(whichUnit), whichUnit)
endfunction

endlibrary

library Effect2Unit requires DecorationSFX, StringSubanimations, UnitVisualMods, UnitTypeDefaultValues

function Effect2Unit takes DecorationEffect whichEffect returns unit
    local unit u = CreateUnit(whichEffect.getOwner(), whichEffect.unitType, whichEffect.x, whichEffect.y, Rad2Deg(whichEffect.yaw))
    
    
    call GUMSSetUnitScale(u, whichEffect.scaleX)
    call GUMSSetUnitVertexColor(u, whichEffect.red/2.55, whichEffect.green/2.55, whichEffect.blue/2.55, 100. - whichEffect.alpha/2.55)
    call GUMSSetUnitFlyHeight(u, whichEffect.height)
    
    if whichEffect.hasCustomColor then
        call GUMSSetUnitColor(u, whichEffect.color + 1)
    endif
    
    if whichEffect.animationSpeed != 1. then
        call GUMSSetUnitAnimSpeed(u, whichEffect.animationSpeed)
    endif
    
    
    if whichEffect.hasSubAnimations() then
        call GUMSAddUnitAnimationTag(u, SubAnimations2Tags(whichEffect.subanimations))
    endif
    
    set bj_lastCreatedUnit = u
    set u = null
    return bj_lastCreatedUnit
endfunction

endlibrary