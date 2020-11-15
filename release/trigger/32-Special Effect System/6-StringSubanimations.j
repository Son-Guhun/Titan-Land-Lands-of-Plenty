library StringSubanimations requires SpecialEffect, TableStruct
/*
    Converts strings (animation tags) to subanimation handles. Used to provide compatibility between
the API for units and the API for effects.

    . Unit API:
    .     native AddUnitAnimationProperties            takes unit whichUnit, string animProperties, boolean add returns nothing
    . 
    . Effect API:
    .     native BlzSpecialEffectClearSubAnimations    takes effect whichEffect returns nothing
    .     native BlzSpecialEffectRemoveSubAnimation    takes effect whichEffect, subanimtype whichSubAnim returns nothing
    .     native BlzSpecialEffectAddSubAnimation       takes effect whichEffect, subanimtype whichSubAnim returns nothing
        
    You can find a map from string to subanimation at the end of this library, inside the InitModule.
*/

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

function AddTagsStringAsSubAnimations takes SpecialEffect whichEffect, string tags, boolean add returns nothing
    local integer cutToComma = CutToCharacter(tags, " ")
    local SubAnimString current
    
    loop
        set current = StringHash(SubString(tags, 0, cutToComma))
        
        if current.isValid() then
            if add then
                call whichEffect.addSubAnimation(current.getSubAnimType())
            else
                call whichEffect.removeSubAnimation(current.getSubAnimType())
            endif
        endif
        
        exitwhen cutToComma >= StringLength(tags)
        set tags = SubString(tags, cutToComma + 1, StringLength(tags))
        set cutToComma = CutToCharacter(tags, " ")
    endloop
    call BlzPlaySpecialEffect(whichEffect.effect, ANIM_TYPE_STAND)
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