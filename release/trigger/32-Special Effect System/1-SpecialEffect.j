library SpecialEffect requires AnyTileDefinition, GLHS, HashStruct

globals
        private hashtable hashTableHandle = InitHashtable()
endglobals  

//! runtextmacro DeclareParentHashtableWrapperModule("hashTableHandle", "true", "hT", "public")
//! runtextmacro DeclareParentHashtableWrapperStruct("hT","public")

globals
    constant boolean IS_SLK = true
endglobals
function GetUnitTypeIdModel takes integer unitTypeId returns string 
    static if IS_SLK then
        return GetAbilityEffectById(unitTypeId, EFFECT_TYPE_SPECIAL, 1)
    else
        local string str = GetAbilityEffectById(unitTypeId, EFFECT_TYPE_SPECIAL, 1)
        return SubString(str, CutToComma(str)+1, StringLength(str))
    endif
endfunction

module InitModule
    private static method onInit takes nothing returns nothing
        set .loc = Location(0., 0.)
    endmethod
endmodule

struct SpecialEffect extends array
    private static location loc
    implement InitModule

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
        implement assertNotNull
        
        return BlzGetLocalSpecialEffectX(.effect)
    endmethod
    
    method operator x= takes real value returns nothing
        implement assertNotNull
        
        call BlzSetSpecialEffectX(.effect, value)
        call BlzSetSpecialEffectHeight(.effect, .height_impl)
    endmethod
    
    method operator y takes nothing returns real
        implement assertNotNull
        
        return BlzGetLocalSpecialEffectY(.effect)
    endmethod
    
    method operator y= takes real value returns nothing
        implement assertNotNull
        
        call BlzSetSpecialEffectY(.effect, value)
        call BlzSetSpecialEffectHeight(.effect, .height_impl)
    endmethod
    
    method operator height takes nothing returns real
        implement assertNotNull
        
        return .height_impl
    endmethod
    
    method operator height= takes real value returns nothing
        implement assertNotNull
        
        set .height_impl = value
        call MoveLocation(.loc, .x, .y)
        // call BlzSetSpecialEffectHeight(.effect, value)
        call BlzSetSpecialEffectZ(.effect, GetLocationZ(.loc) + value)
    endmethod
    
    method operator yaw takes nothing returns real
        implement assertNotNull
        
        return .yaw_impl
    endmethod
    
    method operator pitch takes nothing returns real
        implement assertNotNull
        
        return .pitch_impl
    endmethod
    
    method operator roll takes nothing returns real
        implement assertNotNull
        
        return .roll_impl
    endmethod
    
    method operator yaw= takes real value returns nothing
        implement assertNotNull
        
        set .yaw_impl = value
        // call BlzSetSpecialEffectYaw(.effect, value)
        call BlzSetSpecialEffectOrientation(.effect, value, .pitch, .roll)
        call BlzSetSpecialEffectMatrixScale(.effect, .scaleX, .scaleY, .scaleZ)
    endmethod
    
    method operator pitch= takes real value returns nothing
        implement assertNotNull
        
        set .pitch_impl = value
        //call BlzSetSpecialEffectPitch(.effect, value)
        call BlzSetSpecialEffectOrientation(.effect, .yaw, value, .roll)
        call BlzSetSpecialEffectMatrixScale(.effect, .scaleX, .scaleY, .scaleZ)
    endmethod
    
    method operator roll= takes real value returns nothing
        implement assertNotNull
        
        set .roll_impl = value
        //call BlzSetSpecialEffectRoll(.effect, value)
        call BlzSetSpecialEffectOrientation(.effect, .yaw, .pitch, value)
        call BlzSetSpecialEffectMatrixScale(.effect, .scaleX, .scaleY, .scaleZ)
    endmethod
    
    method setOrientation takes real yaw, real pitch, real roll returns nothing
        implement assertNotNull
        
        set .yaw_impl = yaw
        set .pitch_impl = pitch
        set .roll_impl = roll
        call BlzSetSpecialEffectOrientation(.effect, yaw, pitch, roll)
        call BlzSetSpecialEffectMatrixScale(.effect, .scaleX, .scaleY, .scaleZ)
    endmethod
    
    method operator color takes nothing returns integer
        implement assertNotNull
        
        return .color_impl
    endmethod
    
    method operator color= takes integer value returns nothing
        implement assertNotNull
        
        if 0 <= value and bj_MAX_PLAYER_SLOTS > value then
            set .color_impl = value
            call BlzSetSpecialEffectColorByPlayer(.effect, Player(value))
        endif
    endmethod
    
    method setScale takes real scaleX, real scaleY, real scaleZ returns nothing
        implement assertNotNull
        
        set .scaleX = scaleX
        set .scaleY = scaleY
        set .scaleZ = scaleZ
        
        // call BlzResetSpecialEffectMatrix(.effect)
        call BlzSetSpecialEffectOrientation(.effect, .yaw, .pitch, .roll)
        call BlzSetSpecialEffectMatrixScale(.effect, scaleX, scaleY, scaleZ)
    endmethod
    
    method setVertexColor takes integer red, integer green, integer blue returns nothing
        implement assertNotNull
        
        set .red = red
        set .green = green
        set .blue = blue
        call BlzSetSpecialEffectColor(.effect, red, green, blue)
    endmethod
    
    method operator alpha takes nothing returns integer
        implement assertNotNull
        
        return .alpha_impl
    endmethod
    
    method operator alpha= takes integer alpha returns nothing
        implement assertNotNull
        
        set .alpha_impl = alpha
        call BlzSetSpecialEffectAlpha(.effect, alpha)
    endmethod
    
    method operator animationSpeed takes nothing returns real
        implement assertNotNull
        
        return .animationSpeed_impl
    endmethod
    
    method operator animationSpeed= takes real value returns nothing
        implement assertNotNull
        
        set .animationSpeed_impl = value
        call BlzSetSpecialEffectTimeScale(.effect, value)
    endmethod
    
    method hasSubAnimations takes nothing returns boolean
        implement assertNotNull
        
        return .subanimations_exists()
    endmethod
    
    method addSubAnimation takes subanimtype anim returns nothing
        local integer animId = GetHandleId(anim)
        implement assertNotNull
        
        if not .subanimations_exists() then
            set .subanimations = LinkedHashSet.create()
        endif
        
        if not .subanimations.contains(animId) then
            debug call BJDebugMsg("Adding subanimation: " + I2S(animId))
            call .subanimations.append(animId)
            call BlzSpecialEffectAddSubAnimation(.effect, anim)
        endif
    endmethod    
    
    method removeSubAnimation takes subanimtype anim returns nothing
        local integer animId = GetHandleId(anim)
        implement assertNotNull
        
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
        implement assertNotNull
        
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
        
        call BlzPlaySpecialEffect(e, ANIM_TYPE_STAND)
        set e = null
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        local effect e = .effect
        implement assertNotNull
        
        call .clearSubAnimations()
        
        call DestroyEffect(e)
        call BlzPlaySpecialEffect(e, ANIM_TYPE_STAND)
        call BlzSetSpecialEffectZ(e, 9999.)
        call SpecialEffect_hT.flushChild(this)
        
        set e = null
    endmethod
    
    method copy takes integer newType returns SpecialEffect
        local SpecialEffect result = SpecialEffect.create(newType, this.x, this.y)
        local LinkedHashSet subanims
        local integer subanim
        implement assertNotNull
        
        set result.height = this.height
        call result.setOrientation(this.yaw, this.pitch, this.roll)
        call result.setScale(this.scaleX, this.scaleY, this.scaleZ)
        set result.color = this.color
        call result.setVertexColor(this.red, this.green, this.blue)
        set result.alpha = this.alpha
        set result.animationSpeed = this.animationSpeed
        
        if this.hasSubAnimations() then
            set subanims = this.subanimations
            set subanim = subanims.begin()
            loop
                exitwhen subanim == subanims.end()
                call result.addSubAnimation(ConvertSubAnimType(subanim))
                set subanim = subanims.next(subanim)
            endloop
            call BlzPlaySpecialEffect(result.effect, ANIM_TYPE_STAND)
        endif
        return result
    endmethod

endstruct

endlibrary