library SpecialEffect requires TableStruct, AnyTileDefinition, GLHS, HashStruct

globals
        private hashtable hashTableHandle = InitHashtable()
endglobals  

//! runtextmacro DeclareParentHashtableWrapperModule("hashTableHandle", "true", "hT", "public")
//! runtextmacro DeclareParentHashtableWrapperStruct("hT","public")

function GetUnitTypeIdModel takes integer unitTypeId returns string 
    return GetAbilityEffectById(unitTypeId, EFFECT_TYPE_SPECIAL, 1)
endfunction

struct SpecialEffect extends array
    //! runtextmacro HashStruct_SetHashtableWrapper("SpecialEffect_hT")

    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("unitType","integer")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("effect","effect")
    
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("height_impl","real")
    
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("yaw_impl","real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("pitch_impl","real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("roll_impl","real")
    
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("color_impl","integer")

    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("scaleX","real","1.")
    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("scaleY","real","1.")
    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("scaleZ","real","1.")

    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("red","integer","255")
    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("green","integer","255")
    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("blue","integer","255")
    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("alpha_impl","integer", "255")
    
    //! runtextmacro HashStruct_NewReadonlyNumberFieldWithDefault("animationSpeed_impl","real","1.")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("animation_impl","integer")
    
    // Ideally this should return a list that, when modified, modfies the SFX as well. For now, don't remove elements from this list.
    //! runtextmacro HashStruct_NewReadonlyStructField("subanimations","LinkedHashSet")
    
    method operator x takes nothing returns real
        return BlzGetLocalSpecialEffectX(.effect)
    endmethod
    
    method operator x= takes real value returns nothing
        // change block
        call BlzSetSpecialEffectX(.effect, value)
    endmethod
    
    method operator y takes nothing returns real
        return BlzGetLocalSpecialEffectY(.effect)
    endmethod
    
    method operator y= takes real value returns nothing
        // change block
        call BlzSetSpecialEffectY(.effect, value)
    endmethod
    
    method operator height takes nothing returns real
        return .height_impl
    endmethod
    
    method operator height= takes real value returns nothing
        set .height_impl = value
        call BlzSetSpecialEffectHeight(.effect, value)
    endmethod
    
    method operator yaw takes nothing returns real
        return .yaw_impl
    endmethod
    
    method operator yaw= takes real value returns nothing
        set .yaw_impl = value
        call BlzSetSpecialEffectYaw(.effect, value)
    endmethod
    
    method operator pitch takes nothing returns real
        return .pitch_impl
    endmethod
    
    method operator pitch= takes real value returns nothing
        set .pitch_impl = value
        call BlzSetSpecialEffectPitch(.effect, value)
    endmethod
    
    method operator roll takes nothing returns real
        return .roll_impl
    endmethod
    
    method operator roll= takes real value returns nothing
        set .roll_impl = value
        call BlzSetSpecialEffectRoll(.effect, value)
    endmethod
    
    method setOrientation takes real yaw, real pitch, real roll returns nothing
        set .yaw_impl = yaw
        set .pitch_impl = pitch
        set .roll_impl = roll
        call BlzSetSpecialEffectOrientation(.effect, yaw, pitch, roll)
    endmethod
    
    method operator color takes nothing returns integer
        return .color_impl
    endmethod
    
    method operator color= takes integer value returns nothing
        set .color_impl = value
        call BlzSetSpecialEffectColorByPlayer(.effect, Player(value))
    endmethod
    
    method setScale takes real scaleX, real scaleY, real scaleZ returns nothing
        set .scaleX = scaleX
        set .scaleY = scaleY
        set .scaleZ = scaleZ
        call BlzSetSpecialEffectMatrixScale(.effect, scaleX, scaleY, scaleZ)
    endmethod
    
    method setVertexColor takes integer red, integer green, integer blue returns nothing
        set .red = red
        set .green = green
        set .blue = blue
        call BlzSetSpecialEffectColor(.effect, red, green, blue)
    endmethod
    
    method operator alpha takes nothing returns integer
        return .alpha_impl
    endmethod
    
    method operator alpha= takes integer alpha returns nothing
        set .alpha_impl = alpha
        call BlzSetSpecialEffectAlpha(.effect, alpha)
    endmethod
    
    method operator animationSpeed takes nothing returns real
        return .animationSpeed_impl
    endmethod
    
    method operator animationSpeed= takes real value returns nothing
        set .animationSpeed_impl = value
        call BlzSetSpecialEffectTimeScale(.effect, value)
    endmethod
    
    method hasSubAnimations takes nothing returns boolean
        return .subanimations_exists()
    endmethod
    
    method addSubAnimation takes subanimtype anim returns nothing
        local integer animId = GetHandleId(anim)
        
        if not .subanimations_exists() then
            set .subanimations = LinkedHashSet.create()
        endif
        
        if not .subanimations.contains(animId) then
            call BJDebugMsg("Adding subanimation: " + I2S(animId))
            call .subanimations.append(animId)
            call BlzSpecialEffectAddSubAnimation(.effect, anim)
        endif
    endmethod    
    
    method removeSubAnimation takes subanimtype anim returns nothing
        local integer animId = GetHandleId(anim)
        
        if .subanimations_exists() then
            if .subanimations.contains(animId) then
                call .subanimations.remove(animId)
                call BlzSpecialEffectRemoveSubAnimation(.effect, anim)
                
                if .subanimations.begin() == .subanimations.end() then
                    call .subanimations.destroy()
                    call .subanimations_clear()
                endif
            endif
        endif
    endmethod
    
    method clearSubAnimations takes nothing returns nothing
        if .subanimations_exists() then
            call BlzSpecialEffectClearSubAnimations(.effect)
            call .subanimations.destroy()
            call .subanimations_clear()
        endif
    endmethod
    
    
    static method create takes integer unitType, real x, real y returns SpecialEffect
        local effect e = AddSpecialEffect(GetUnitTypeIdModel(unitType), x, y)
        local SpecialEffect this = GetHandleId(e)
        
        set this.unitType= unitType
        set this.effect = e
        //call DecorationEffectBlock.get(x, y).effects.append(this)
        
        set e = null
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        local effect e = .effect
        
        call DestroyEffect(e)
        call BlzPlaySpecialEffect(e, ANIM_TYPE_STAND)
        call BlzSetSpecialEffectZ(e, 9999.)
        call SpecialEffect_hT.flushChild(this)
        
        set e = null
    endmethod

endstruct

endlibrary