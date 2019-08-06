library Unit2Effect requires SpecialEffect, UnitVisualMods, UnitTypeDefaultValues

private struct SubAnimString extends array
    //! runtextmacro TableStruct_NewPrimitiveField("subanimtypeId", "integer")
    
    method getSubAnimType takes nothing returns subanimtype
        return ConvertSubAnimType(.subanimtypeId)
    endmethod
    
    method setSubAnimType takes subanimtype anim returns nothing
        set .subanimtypeId = GetHandleId(anim)
    endmethod
    
    method isValid takes nothing returns boolean
        return .subanimtypeIdExists()
    endmethod
endstruct

private struct SubAnimInteger extends array
    //! runtextmacro TableStruct_NewPrimitiveField("string", "string")
    
    method getString takes nothing returns string
        return .string
    endmethod
    
    method setString takes string str returns nothing
        set .string = str
    endmethod
    
    method isValid takes nothing returns boolean
        return .stringExists()
    endmethod
endstruct


// 

function AddTagsStringAsSubAnimations takes SpecialEffect whichEffect, string tags returns nothing
    local integer cutToComma = CutToCharacter(tags, " ")
    local SubAnimString current
    
    loop
        set current = StringHash(SubString(tags, 0, cutToComma))
        
        if current.isValid() then
            debug call BJDebugMsg(SubString(tags, 0, cutToComma)+": "+I2S(GetHandleId(current.getSubAnimType()))+" "+I2S(GetHandleId(SUBANIM_TYPE_SECOND)))
            call whichEffect.addSubAnimation(current.getSubAnimType())
        debug else
            debug call BJDebugMsg("Invalid tag: " + SubString(tags, 0, cutToComma))
        endif
        
        exitwhen cutToComma >= StringLength(tags)
        set tags = SubString(tags, cutToComma + 1, StringLength(tags))
        set cutToComma = CutToCharacter(tags, " ")
    endloop
endfunction

function SubAnimations2Tags takes LinkedHashSet subanims returns string
    local SubAnimInteger current = subanims.begin()
    local string result = ""
    
    loop
        exitwhen current == subanims.end()
        
        if current.isValid() then
            set result = result + " " + current.getString() 
        endif
        
        set current = subanims.next(current)
    endloop
    
    if StringLength(result) > 0 then
        return SubString(result, 1, StringLength(result))
    else
        return ""
    endif
endfunction

function Unit2EffectEx takes unit whichUnit, player owner returns DecorationEffect
    local UnitTypeDefaultValues unitType = GetUnitTypeId(whichUnit)
    local UnitVisuals unitData = GetHandleId(whichUnit)
    local DecorationEffect result = DecorationEffect.create(owner, unitType, GetUnitX(whichUnit), GetUnitY(whichUnit))
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
    endif
    
    if unitData.hasAnimSpeed() then
        set result.animationSpeed = unitData.raw.getAnimSpeed()
    endif
    
    if unitData.hasAnimTag() then
        debug call BJDebugMsg("Tags: " + unitData.raw.getAnimTag())
        call AddTagsStringAsSubAnimations(result, GUMSConvertTags(UnitVisualMods_TAGS_DECOMPRESS, unitData.raw.getAnimTag()))
    elseif unitType.hasAnimProps() then
        call AddTagsStringAsSubAnimations(result, unitType.animProps)
    endif
    
    if unitType.hasMaxRoll() then
        set result.roll = Deg2Rad(unitType.maxRoll+180.)
    endif
    
    call BlzPlaySpecialEffect(result.effect, ANIM_TYPE_STAND)
    return result
endfunction

function Unit2Effect takes unit whichUnit returns DecorationEffect
    return Unit2EffectEx(whichUnit, GetOwningPlayer(whichUnit))
endfunction

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



//! textmacro RegisterSubAnimation takes STRING, SUBANIMTYPE
    call SubAnimString(StringHash("$STRING$")).setSubAnimType($SUBANIMTYPE$)
    call SubAnimInteger(GetHandleId($SUBANIMTYPE$)).setString("$STRING$")
//! endtextmacro

private module InitModule

    private static method onInit takes nothing returns nothing
        //! runtextmacro RegisterSubAnimation("alternate", "SUBANIM_TYPE_ROOTED")  // I guess it's because ancients use the alternate animation set for rooted forms
        //! runtextmacro RegisterSubAnimation("slam", "SUBANIM_TYPE_SLAM")
        //! runtextmacro RegisterSubAnimation("throw", "SUBANIM_TYPE_THROW")
        //! runtextmacro RegisterSubAnimation("fast", "SUBANIM_TYPE_FAST")
        //! runtextmacro RegisterSubAnimation("spin", "SUBANIM_TYPE_SPIN")
        //! runtextmacro RegisterSubAnimation("ready", "SUBANIM_TYPE_READY")
        //! runtextmacro RegisterSubAnimation("channel", "SUBANIM_TYPE_CHANNEL")
        //! runtextmacro RegisterSubAnimation("defend", "SUBANIM_TYPE_DEFEND")
        //! runtextmacro RegisterSubAnimation("victory", "SUBANIM_TYPE_VICTORY")
        //! runtextmacro RegisterSubAnimation("flesh", "SUBANIM_TYPE_FLESH")
        //! runtextmacro RegisterSubAnimation("gold", "SUBANIM_TYPE_GOLD")
        //! runtextmacro RegisterSubAnimation("lumber", "SUBANIM_TYPE_LUMBER")
        //! runtextmacro RegisterSubAnimation("work", "SUBANIM_TYPE_WORK")
        //! runtextmacro RegisterSubAnimation("talk", "SUBANIM_TYPE_TALK")
        //! runtextmacro RegisterSubAnimation("first", "SUBANIM_TYPE_FIRST")
        //! runtextmacro RegisterSubAnimation("second", "SUBANIM_TYPE_SECOND")
        //! runtextmacro RegisterSubAnimation("third", "SUBANIM_TYPE_THIRD")
        //! runtextmacro RegisterSubAnimation("fourth", "SUBANIM_TYPE_FOURTH")
        //! runtextmacro RegisterSubAnimation("fifth", "SUBANIM_TYPE_FIFTH")
        //! runtextmacro RegisterSubAnimation("one", "SUBANIM_TYPE_ONE")
        //! runtextmacro RegisterSubAnimation("two", "SUBANIM_TYPE_TWO")
        //! runtextmacro RegisterSubAnimation("small", "SUBANIM_TYPE_SMALL")
        //! runtextmacro RegisterSubAnimation("medium", "SUBANIM_TYPE_MEDIUM")
        //! runtextmacro RegisterSubAnimation("large", "SUBANIM_TYPE_LARGE")
        //! runtextmacro RegisterSubAnimation("upgrade", "SUBANIM_TYPE_UPGRADE")
        
        // Unused subanimtypes
        /*
        SUBANIM_TYPE_ALTERNATE_EX             = ConvertSubAnimType(12)
        SUBANIM_TYPE_LOOPING            = ConvertSubAnimType(13)
        SUBANIM_TYPE_SPIKED             = ConvertSubAnimType(16)
        SUBANIM_TYPE_TURN               = ConvertSubAnimType(23)
        SUBANIM_TYPE_LEFT               = ConvertSubAnimType(24)
        SUBANIM_TYPE_RIGHT              = ConvertSubAnimType(25)
        SUBANIM_TYPE_FIRE               = ConvertSubAnimType(26)
        SUBANIM_TYPE_HIT                = ConvertSubAnimType(28)
        SUBANIM_TYPE_WOUNDED            = ConvertSubAnimType(29)
        SUBANIM_TYPE_LIGHT              = ConvertSubAnimType(30)
        SUBANIM_TYPE_MODERATE           = ConvertSubAnimType(31)
        SUBANIM_TYPE_SEVERE             = ConvertSubAnimType(32)
        SUBANIM_TYPE_CRITICAL           = ConvertSubAnimType(33)
        SUBANIM_TYPE_COMPLETE           = ConvertSubAnimType(34)
        SUBANIM_TYPE_THREE              = ConvertSubAnimType(46)
        SUBANIM_TYPE_FOUR               = ConvertSubAnimType(47)
        SUBANIM_TYPE_FIVE               = ConvertSubAnimType(48)
        SUBANIM_TYPE_DRAIN              = ConvertSubAnimType(53)
        SUBANIM_TYPE_FILL               = ConvertSubAnimType(54)
        SUBANIM_TYPE_CHAINLIGHTNING     = ConvertSubAnimType(55)
        SUBANIM_TYPE_EATTREE            = ConvertSubAnimType(56)
        SUBANIM_TYPE_PUKE               = ConvertSubAnimType(57)
        SUBANIM_TYPE_FLAIL              = ConvertSubAnimType(58)
        SUBANIM_TYPE_OFF                = ConvertSubAnimType(59)
        SUBANIM_TYPE_SWIM               = ConvertSubAnimType(60)
        SUBANIM_TYPE_ENTANGLE           = ConvertSubAnimType(61)
        SUBANIM_TYPE_BERSERK            = ConvertSubAnimType(62)
        */
    endmethod

endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

endlibrary