library AttachedSFX requires Unit2Effect, TableStruct

struct UnitData extends array

    //! runtextmacro TableStruct_NewStructField("attachedEffect", "SpecialEffect")
    
    method hasAttachedEffect takes nothing returns boolean
        return .attachedEffectExists()
    endmethod
    
    method clearAttachedEffect takes nothing returns nothing
        call .attachedEffectClear()
    endmethod

    static method get takes unit whichUnit returns thistype
        return GetHandleId(whichUnit)
    endmethod

endstruct

function UnitHasAttachedEffect takes unit whichUnit returns boolean
    return UnitData.get(whichUnit).hasAttachedEffect()
endfunction

function GetUnitAttachedEffect takes unit whichUnit returns SpecialEffect
    return UnitData.get(whichUnit).attachedEffect
endfunction

function UnitCreateAttachedEffect takes unit whichUnit returns SpecialEffect
    local SpecialEffect sfx = Unit2SpecialEffect(whichUnit)
    
    set UnitData.get(whichUnit).attachedEffect = sfx
    call SetUnitVertexColor(whichUnit, 0, 0, 0, 0)
    return sfx
endfunction

function UnitAttachEffect takes unit whichUnit, SpecialEffect sfx returns nothing
    set UnitData.get(whichUnit).attachedEffect = sfx
    call SetUnitVertexColor(whichUnit, 0, 0, 0, 0)
endfunction

function UnitDetachEffect takes unit whichUnit returns SpecialEffect
    local UnitData data = UnitData.get(whichUnit)
    local SpecialEffect sfx
    if data.hasAttachedEffect() then
        set sfx = data.attachedEffect
        call data.clearAttachedEffect()
        return sfx
    endif
    return 0
endfunction

public function onSetPosition takes unit whichUnit, real x, real y returns nothing
    local SpecialEffect sfx = UnitData.get(whichUnit).attachedEffect
    
    set sfx.x = GetUnitX(whichUnit)
    set sfx.y = GetUnitY(whichUnit)
endfunction

public function onSetHeight takes unit whichUnit, real height, real rate returns nothing
    local SpecialEffect sfx
    
    if UnitHasAttachedEffect(whichUnit) then
        set sfx = UnitData.get(whichUnit).attachedEffect
        set sfx.height = height
    elseif height < 0 then
        set sfx = UnitCreateAttachedEffect(whichUnit)
        set sfx.height = height
    endif
endfunction

public function onAddAnimationProperties takes unit whichUnit, string properties, boolean add returns nothing
    local SpecialEffect sfx = UnitData.get(whichUnit).attachedEffect
    
    if add then
        call AddTagsStringAsSubAnimations(sfx, properties, add)
    endif
endfunction

public function onSetColor takes unit whichUnit, playercolor color returns nothing
    local SpecialEffect sfx = UnitData.get(whichUnit).attachedEffect
    
    set sfx.color = GetHandleId(color)
endfunction

public function onSetScale takes unit whichUnit, real x, real y, real z returns nothing
    local SpecialEffect sfx = UnitData.get(whichUnit).attachedEffect

    if UnitHasAttachedEffect(whichUnit) then
        set sfx = UnitData.get(whichUnit).attachedEffect
        call sfx.setScale(x, y, z)
    elseif x!=y or x!=z then
        set sfx = UnitCreateAttachedEffect(whichUnit)
        call sfx.setScale(x, y, z)
    endif
endfunction

public function onSetVertexColor takes unit whichUnit, integer red, integer green, integer blue, integer alpha returns nothing
    local SpecialEffect sfx = UnitData.get(whichUnit).attachedEffect
    
    call sfx.setVertexColor(red, green, blue)
    set sfx.alpha = alpha
endfunction

public function onSetTimeScale takes unit whichUnit, real scale returns nothing
    local SpecialEffect sfx = UnitData.get(whichUnit).attachedEffect
    
    set sfx.animationSpeed = scale
endfunction

public function onSetFacing takes unit whichUnit, real facing returns nothing
    local SpecialEffect sfx = UnitData.get(whichUnit).attachedEffect
    
    set sfx.yaw = facing
endfunction

endlibrary