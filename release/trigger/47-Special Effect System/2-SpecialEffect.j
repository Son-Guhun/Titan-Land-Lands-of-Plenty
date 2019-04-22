library SpecialEffect requires HashStruct
/* 
  Defines the basic properties of a Special effect and functions that allow you to get those properties.
*/

globals
    // If you use hooks, you might as well enable this.
    private boolean LAST_CREATED_SAFETY = false
endglobals

globals
        private hashtable hashTableHandle = InitHashtable()
endglobals  

//! runtextmacro DeclareParentHashtableWrapperModule("hashTableHandle", "true", "hT", "public")
//! runtextmacro DeclareParentHashtableWrapperStruct("hT","public")

module SpecialEffectModule
    //! runtextmacro HashStruct_SetHashtableWrapper("SpecialEffect_hT")

    //! runtextmacro HashStruct_NewPrimitiveField("x","real")
    //! runtextmacro HashStruct_NewPrimitiveField("y","real")
    //! runtextmacro HashStruct_NewPrimitiveField("height","real")
    
    //! runtextmacro HashStruct_NewNumberFieldWithDefault("scale","real","1.")
    
    //! runtextmacro HashStruct_NewPrimitiveField("roll","real")
    //! runtextmacro HashStruct_NewPrimitiveField("yaw","real")
    //! runtextmacro HashStruct_NewPrimitiveField("pitch","real")
    
    //! runtextmacro HashStruct_NewNumberFieldWithDefault("red","integer","255")
    //! runtextmacro HashStruct_NewNumberFieldWithDefault("green","integer","255")
    //! runtextmacro HashStruct_NewNumberFieldWithDefault("blue","integer","255")
    //! runtextmacro HashStruct_NewNumberFieldWithDefault("alpha","integer","255")
endmodule

module SpecialEffectGetDestroyMethods
    static method get takes effect e returns thistype
        return GetHandleId(e)
    endmethod
    
    method destroy takes nothing returns nothing
        call hT.flushChild(this)
    endmethod
endmodule

struct SpecialEffect extends array
    implement SpecialEffectModule
    implement SpecialEffectGetDestroyMethods
endstruct

// ==========================================
// X and Y setters
function SetSpecialEffectX takes effect e, real x returns nothing
    call BlzSetSpecialEffectX(e, x)
    set SpecialEffect.get(e).x = x
endfunction

function SetSpecialEffectY takes effect e, real y returns nothing
    call BlzSetSpecialEffectY(e, y)
    set SpecialEffect.get(e).y = y
endfunction

function SetSpecialEffectPosition takes effect e, real x, real y returns nothing
    call BlzSetSpecialEffectX(e, x)
    set SpecialEffect.get(e).x = x
    call BlzSetSpecialEffectY(e, y)
    set SpecialEffect.get(e).y = y
endfunction

// ==========================================

function SetSpecialEffectHeight takes effect e, real height returns nothing
    call BlzSetSpecialEffectHeight(e, height)
    set SpecialEffect.get(e).height = height
endfunction

function SetSpecialEffectScale takes effect e, real scale returns nothing
    call BlzSetSpecialEffectScale(e, scale)
    set SpecialEffect.get(e).scale = scale
endfunction

// ==========================================
// Orientation setters
function SetSpecialEffectRoll takes effect e, real value returns nothing
    call BlzSetSpecialEffectRoll(e, value)
    set SpecialEffect.get(e).roll = value
endfunction

function SetSpecialEffectYaw takes effect e, real value returns nothing
    call BlzSetSpecialEffectYaw(e, value)
    set SpecialEffect.get(e).yaw = value
endfunction

function SetSpecialEffectPitch takes effect e, real value returns nothing
    call BlzSetSpecialEffectPitch(e, value)
    set SpecialEffect.get(e).pitch = value
endfunction

function SetSpecialEffectOrientation takes effect e, real yaw, real pitch, real roll returns nothing
    call BlzSetSpecialEffectOrientation(e, yaw, pitch, roll)
    set SpecialEffect.get(e).roll = roll
    set SpecialEffect.get(e).yaw = yaw
    set SpecialEffect.get(e).pitch = pitch
endfunction

// ==========================================
// RGBA setters
function SetSpecialEffectColor takes effect e, integer red, integer green, integer blue returns nothing
    call BlzSetSpecialEffectColor(e, red, green, blue)
    set SpecialEffect.get(e).red = red
    set SpecialEffect.get(e).green = green
    set SpecialEffect.get(e).blue = blue
endfunction

function SetSpecialEffectAlpha takes effect e, integer alpha returns nothing
    call BlzSetSpecialEffectAlpha(e, alpha)
    set SpecialEffect.get(e).alpha = alpha
endfunction

// ==========================================

// Creates an effect, setting bj_lastCreatedEffect to it and returning it.
private function CreateEffect takes string model, real x, real y returns effect
    static if LAST_CREATED_SAFETY then
        local effect e = AddSpecialEffect(model, x, y)
        local SpecialEffect eData = GetHandleId(e)
        
        set eData.x = x
        set eData.y = y
        
        set bj_lastCreatedEffect = e
        set e = null
    else
        local SpecialEffect eData 
        
        set bj_lastCreatedEffect = AddSpecialEffect(model, x, y) 
        set eData = GetHandleId(bj_lastCreatedEffect)
        
        set eData.x = x
        set eData.y = y
    endif
    
    return bj_lastCreatedEffect
endfunction

/*
private function CreateEffectEx takes string model, real x, real y, real height, real roll, real yaw, real pitch, integer red, integer green, integer blue, integer alpha returns effect
    
    call BlzSetSpecialEffectColor(e, red, green, blue)
    set SpecialEffect.get(e).red = red
    set SpecialEffect.get(e).green = green
    set SpecialEffect.get(e).blue = blue
    call BlzSetSpecialEffectAlpha(e, alpha)
    set SpecialEffect.get(e).alpha = alpha
endfunction
*/

private function SelectionFilter takes nothing returns boolean
    local string model = GetAbilityEffectById(GetUnitTypeId(GetFilterUnit()), EFFECT_TYPE_SPECIAL, 0)
    local effect placeHolder = AddSpecialEffect(model, GetUnitX(GetFilterUnit()), GetUnitY(GetFilterUnit()))
    local SpecialEffect eData = GetHandleId(placeHolder)
    
    call BlzSetSpecialEffectYaw(placeHolder, Deg2Rad(270. - 45))  // => Roll along x axis
    call BlzSetSpecialEffectPitch(placeHolder, Deg2Rad(270. - 45)) // => Roll along y axiz
    call BlzSetSpecialEffectRoll(placeHolder, Deg2Rad(270.))  // => Roll along z axis (facing)
    // call BlzSetSpecialEffectScale()
    call BlzSetSpecialEffectHeight(placeHolder, -200/*GetUnitFlyHeight(GetFilterUnit())*/)
    
    call BJDebugMsg(I2S(eData.green))
    call BJDebugMsg(R2S(eData.scale))
    call SetSpecialEffectScale(placeHolder, 2.)
    call BJDebugMsg(R2S(eData.scale))
    
    
    call BJDebugMsg(model)
    return false
endfunction


private function onCommand takes nothing returns boolean
    call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Filter(function SelectionFilter))
    return false
endfunction

//===========================================================================
function InitTrig_SpecialEffect takes nothing returns nothing
    call LoP_Command.create("-testing", ACCESS_TITAN, Condition(function onCommand ))
endfunction

endlibrary
