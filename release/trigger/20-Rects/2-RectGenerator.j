/* Changelog

05/04/2019 - Changed Conditions to public. Added previx to all variables inside of Page textmacros.
             Now these can be called by users who set AUTOMATIC_ON_SPAWN to false.


*/ 
library RectGenerator initializer onInit /*
    */requires UserDefinedRects, /* Core library
    
    */optional WorldBounds /* This is used to only if AUTOMATIC_ON_SPAWN is enabled.
    
    */optional StructureTileDefinition /* This is used to safely align generators to the map grid.
    
    */optional TileDefiniton // This is used to allow terrain alignment for generators. Requires StructureTileDefinition.

// Import instructions after configuration.
//===================================================
// Simple configuration
//===================================================
globals
    // Units
    //======================
    // The rawcode of the generator unit. Only used in the Conditions function of the advanced configuration.
    public constant integer GENERATOR_ID = 'udr0'
    
    // The rawcode of the unit created by the MOVE ability. Listed here to make importing easier.
    public constant integer DUMMY_ID = 'udr1'

    // Abilities
    //======================
    // Set the constants below to the rawcodes of each appropirate GUDR ability
    public constant integer CREATE_OR_DESTROY   = 'UDR2'
    public constant integer TOGGLE_VISIBILITY   = 'UDRA'
    public constant integer MOVE                = 'UDR4'
    public constant integer MOVE_TERRAIN        = 'UDRT'

    public constant integer RETRACT_Y           = 'UDR7'
    public constant integer EXPAND_Y            = 'UDR8'
    public constant integer EXPAND_X            = 'UDR6'
    public constant integer RETRACT_X           = 'UDR5'
    
    public constant integer CHANGE_WEATHER_NEXT = 'UDR1'
    public constant integer CHANGE_WEATHER_PREV = 'UDR0'
    public constant integer TOGGLE_WEATHER      = 'UDR9'
    
    public constant integer LOCK_UNITS          = 'UDR3'
    public constant integer UNLOCK_UNITS        = 'UDRB'
    
    public constant integer PAGE_NEXT = 'UDRQ'
    public constant integer PAGE_PREV = 'UDRR'
    
    public constant integer TOGGLE_FOG = 'UDRS'
    
    // AutoRectEnvironment abilities: not needed if you are not using AutoRectEnvironment
    public constant integer FOG_STYLE_UP      = 'UDRI'
    public constant integer FOG_STYLE_DOWN    = 'UDRJ'
    
    public constant integer FOG_ZSTART_UP    = 'UDRK'
    public constant integer FOG_ZSTART_DOWN  = 'UDRL'
    
    public constant integer FOG_ZEND_UP      = 'UDRM'
    public constant integer FOG_ZEND_DOWN    = 'UDRN'
    
    public constant integer FOG_DENSITY_UP   = 'UDRO'
    public constant integer FOG_DENSITY_DOWN = 'UDRP'
    
    public constant integer FOG_RED_UP       = 'UDRC'
    public constant integer FOG_RED_DOWN     = 'UDRD'
    
    public constant integer FOG_GREEN_UP     = 'UDRG'
    public constant integer FOG_GREEN_DOWN   = 'UDRH'
    
    public constant integer FOG_BLUE_UP      = 'UDRE'
    public constant integer FOG_BLUE_DOWN    = 'UDRF'
endglobals

//===================================================
// Advanced configuration
//===================================================

// If this function returns true and AUTOMATIC_ON_SPAWN, the unit will have 'Amov' and 'Aatk' removed
// upon entering the map. Additionally, the abilities will only trigger for units when this function
// returns true upon being called with them as an argument.
public function Conditions takes unit whichUnit returns boolean
    return GetUnitTypeId(whichUnit) == GENERATOR_ID // LoP_IsUnitDecoration(whichUnit)
endfunction

globals
    // This is the maximum number of units that can be moved at a time with a GUDR (high limits may cause crashes)
    private constant integer MAXIMUM_MOVE_LIMIT = 300
    
    // If this is set to false, you will need to manually remove 'Amov' and 'Aatk' when a generator enters the map
    // You will also need to automatically set it's abilities by calling //! runtextmacro GUDR_FirstPage("ADD"," unitVar" )
    private constant boolean AUTOMATIC_ON_SPAWN = false  // true
endglobals


private function InFirstPage takes unit u returns boolean
	return GetUnitAbilityLevel(u, CREATE_OR_DESTROY) > 0
endfunction
//! textmacro GUDR_FirstPage takes FUNC, U

	call Unit$FUNC$Ability($U$, RectGenerator_CREATE_OR_DESTROY)
	call Unit$FUNC$Ability($U$, RectGenerator_TOGGLE_VISIBILITY)
	call Unit$FUNC$Ability($U$, RectGenerator_MOVE)
    static if LIBRARY_TileDefinition and LIBRARY_StructureTileDefinition then
        call Unit$FUNC$Ability($U$, RectGenerator_MOVE_TERRAIN)
    endif
	
	call Unit$FUNC$Ability($U$, RectGenerator_RETRACT_X)
	call Unit$FUNC$Ability($U$, RectGenerator_EXPAND_X)
	call Unit$FUNC$Ability($U$, RectGenerator_RETRACT_Y)
	call Unit$FUNC$Ability($U$, RectGenerator_EXPAND_Y)
	
	call Unit$FUNC$Ability($U$, RectGenerator_LOCK_UNITS)
	call Unit$FUNC$Ability($U$, RectGenerator_UNLOCK_UNITS)

//! endtextmacro

private function InSecondPage takes unit u returns boolean
	return GetUnitAbilityLevel(u, TOGGLE_WEATHER) > 0
endfunction
//! textmacro GUDR_SecondPage takes FUNC, U

	call Unit$FUNC$Ability($U$, RectGenerator_CHANGE_WEATHER_NEXT)
	call Unit$FUNC$Ability($U$, RectGenerator_CHANGE_WEATHER_PREV)
	call Unit$FUNC$Ability($U$, RectGenerator_TOGGLE_WEATHER)
	
    static if LIBRARY_AutoRectEnvironment then
        call Unit$FUNC$Ability($U$, RectGenerator_TOGGLE_FOG)
        call Unit$FUNC$Ability($U$, RectGenerator_FOG_STYLE_UP )
        call Unit$FUNC$Ability($U$, RectGenerator_FOG_STYLE_DOWN)
        call Unit$FUNC$Ability($U$, RectGenerator_FOG_ZSTART_UP )
        call Unit$FUNC$Ability($U$, RectGenerator_FOG_ZSTART_DOWN)
        call Unit$FUNC$Ability($U$, RectGenerator_FOG_ZEND_UP )
        call Unit$FUNC$Ability($U$, RectGenerator_FOG_ZEND_DOWN)
        
        if not AutoRectEnvironment_IsRectRegistered(GUDR_GetGeneratorRect($U$)) then
            call BlzUnitDisableAbility($U$, RectGenerator_FOG_STYLE_UP, true, false)
            call BlzUnitDisableAbility($U$, RectGenerator_FOG_STYLE_DOWN, true, false)
            call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZSTART_UP, true, false)
            call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZSTART_DOWN, true, false)
            call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZEND_UP, true, false)
            call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZEND_DOWN, true, false)
        endif
    endif

//! endtextmacro

//! textmacro GUDR_DisableFogAbilities takes U, BOOL
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_STYLE_UP, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_STYLE_DOWN, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZSTART_UP, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZSTART_DOWN, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZEND_UP, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_ZEND_DOWN, $BOOL$, false)


    call BlzUnitDisableAbility($U$, RectGenerator_FOG_DENSITY_UP, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_DENSITY_DOWN, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_RED_UP, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_RED_DOWN, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_GREEN_UP, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_GREEN_DOWN, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_BLUE_UP, $BOOL$, false)
    call BlzUnitDisableAbility($U$, RectGenerator_FOG_BLUE_DOWN, $BOOL$, false)
//! endtextmacro

private function InThirdPage takes unit u returns boolean
	return GetUnitAbilityLevel(u, FOG_DENSITY_UP) > 0
endfunction
//! textmacro GUDR_ThirdPage takes FUNC, U

	call Unit$FUNC$Ability($U$, RectGenerator_FOG_DENSITY_UP )
	call Unit$FUNC$Ability($U$, RectGenerator_FOG_DENSITY_DOWN)
	
	call Unit$FUNC$Ability($U$, RectGenerator_FOG_RED_UP )
	call Unit$FUNC$Ability($U$, RectGenerator_FOG_RED_DOWN)
	call Unit$FUNC$Ability($U$, RectGenerator_FOG_GREEN_UP )
	call Unit$FUNC$Ability($U$, RectGenerator_FOG_GREEN_DOWN)
	call Unit$FUNC$Ability($U$, RectGenerator_FOG_BLUE_UP )
	call Unit$FUNC$Ability($U$, RectGenerator_FOG_BLUE_DOWN)
    
    if not AutoRectEnvironment_IsRectRegistered(GUDR_GetGeneratorRect($U$)) then
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_DENSITY_UP, true, false)
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_DENSITY_DOWN, true, false)
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_RED_UP, true, false)
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_RED_DOWN, true, false)
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_GREEN_UP, true, false)
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_GREEN_DOWN, true, false)
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_BLUE_UP, true, false)
        call BlzUnitDisableAbility($U$, RectGenerator_FOG_BLUE_DOWN, true, false)
    endif

//! endtextmacro
//===================================================
// Import instructions
//===================================================
/*
To view rawcodes in the Object Editor, press Cntrl+D (View -> Display Values as Raw Data).

To import, find the all the objects listed in the Simple Configuration constants and copy them into
your map. For the MOVE ability, you must also set the unit that it creates to the correct value of
DUMMY_ID.

Then, you can just copy this trigger into your map and set all the rawcodes in the simple configuration
to the rawcodes of the copies of those objects in your map. Also, you must import the UserDefinedRects
library, if you have not done so.
                                                                                                  */
//! novjass
'                                                                                                  '
'                                         Source Code                                              '
//! endnovjass

static if LIBRARY_AutoRectEnvironment then
    private struct FogStyle extends array
        //! runtextmacro TableStruct_NewConstTableField("public","strings")
        //! runtextmacro TableStruct_NewConstTableField("private","linkedListNext")
        //! runtextmacro TableStruct_NewConstTableField("private","linkedListPrev")
        
        method next takes nothing returns integer
            return .linkedListNext[this]
        endmethod
        
        method prev takes nothing returns integer
            return .linkedListPrev[this]
        endmethod
        
        method setNext takes integer nextStyle returns nothing
            set .linkedListNext[this] = nextStyle
        endmethod
        
        method setPrev takes integer prevStyle returns nothing
            set .linkedListPrev[this] = prevStyle
        endmethod
        
        method getString takes nothing returns string
            return .strings.string[this]
        endmethod
        
        method setString takes string str returns nothing
            set .strings.string[this] = str
        endmethod
        
        
    endstruct

    //! textmacro udrAddon_LinkStyles takes PREV, NEXT
        call FogStyle($PREV$).setNext($NEXT$)
        call FogStyle($NEXT$).setPrev($PREV$)
    //! endtextmacro
endif



private function GroupLoop takes nothing returns nothing
    local unit udr = GetTriggerUnit()
    local unit enumUnit = GetEnumUnit()
    
    if GUDR_IsUnitGenerator(enumUnit) or GetOwningPlayer(enumUnit) != GetOwningPlayer(udr) then
        call GroupRemoveUnit(GUDR_GetGeneratorGroup(udr), enumUnit)
    else
        call SetUnitPosition(enumUnit, GetUnitX(enumUnit) + GetSpellTargetX() - GetUnitX(udr) , GetUnitY(enumUnit) + GetSpellTargetY() - GetUnitY(udr))
    endif
    
    set udr = null
    set enumUnit = null
endfunction

static if LIBRARY_TileDefinition then
    private function GroupLoopTerrain takes nothing returns nothing
        local unit udr = GetTriggerUnit()
        local unit enumUnit = GetEnumUnit()
        
        if GUDR_IsUnitGenerator(enumUnit) or GetOwningPlayer(enumUnit) != GetOwningPlayer(udr) then
            call GroupRemoveUnit(GUDR_GetGeneratorGroup(udr), enumUnit)
        else
            call SetUnitPosition(enumUnit, GetUnitX(enumUnit) + GetTileCenterCoordinate(GetSpellTargetX()) - GetUnitX(udr) , GetUnitY(enumUnit) + GetTileCenterCoordinate(GetSpellTargetY()) - GetUnitY(udr))
        endif
        
        set udr = null
        set enumUnit = null
    endfunction
endif

private function ColorMessage takes string color, real value returns string
    return "Fog " + color +  " set to: "+ I2S(R2I(value*100.+.5)) + "%"
endfunction


private function onCast takes nothing returns boolean
    local integer abilityId = GetSpellAbilityId()
    
    if not Conditions(GetTriggerUnit()) then
        
    elseif abilityId == PAGE_NEXT then
        static if LIBRARY_AutoRectEnvironment then
            if InFirstPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_FirstPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_SecondPage("Add","GetTriggerUnit()")
            elseif InSecondPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_SecondPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_ThirdPage("Add","GetTriggerUnit()")
            else//if InThirdPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_ThirdPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_FirstPage("Add","GetTriggerUnit()")
            endif
        else
            if InFirstPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_FirstPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_SecondPage("Add","GetTriggerUnit()")
            elseif InSecondPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_SecondPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_FirstPage("Add","GetTriggerUnit()")
            endif
        endif
        
    elseif abilityId == PAGE_PREV then
        static if LIBRARY_AutoRectEnvironment then
            if InFirstPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_FirstPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_ThirdPage("Add","GetTriggerUnit()")
            elseif InSecondPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_SecondPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_FirstPage("Add","GetTriggerUnit()")
            else//if InThirdPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_ThirdPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_SecondPage("Add","GetTriggerUnit()")
            endif
        else
            if InFirstPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_FirstPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_SecondPage("Add","GetTriggerUnit()")
            elseif InSecondPage(GetTriggerUnit()) then
                //! runtextmacro GUDR_SecondPage("Remove","GetTriggerUnit()")
                //! runtextmacro GUDR_FirstPage("Add","GetTriggerUnit()")
            endif
        endif
           
    elseif abilityId == RETRACT_Y then
        call MoveGUDR(GetTriggerUnit(), 0, -64, true)
        
    elseif abilityId == EXPAND_Y then
        call MoveGUDR(GetTriggerUnit(), 0, 64, true)
        
    elseif abilityId == EXPAND_X then
        call MoveGUDR(GetTriggerUnit(), 64, 0, true)
        
    elseif abilityId == RETRACT_X then
        call MoveGUDR(GetTriggerUnit(), -64, 0, true)
    
    elseif abilityId == MOVE then
        static if LIBRARY_StructureTileDefinition then
            if GetUnitX(GetTriggerUnit()) != Get64TileCenterCoordinate(GetUnitX(GetTriggerUnit())) then
                call SetUnitX(GetTriggerUnit(), GetUnitX(GetTriggerUnit()) + 32)
            endif
            if GetUnitY(GetTriggerUnit()) != Get64TileCenterCoordinate(GetUnitY(GetTriggerUnit())) then
                call SetUnitY(GetTriggerUnit(), GetUnitY(GetTriggerUnit()) + 32)
            endif
        endif
            
        if CountUnitsInGroup(GUDR_GetGeneratorGroup(GetTriggerUnit())) <= MAXIMUM_MOVE_LIMIT then
            call ForGroup( GUDR_GetGeneratorGroup(GetTriggerUnit()), function GroupLoop )
            call SetUnitPosition(GetTriggerUnit(), GetSpellTargetX(), GetSpellTargetY())
            call MoveGUDR(GetTriggerUnit(), 0, 0, true)
        else
            call DisplayTextToPlayer( GetOwningPlayer(GetTriggerUnit()),0,0, "Failed to move Rect Generator:\n Attached unit limit exceeded! (" + I2S(MAXIMUM_MOVE_LIMIT) + ")" )
            call SetUnitPosition(GetTriggerUnit(), GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit()))
            call MoveGUDR(GetTriggerUnit(), 0, 0, true)
        endif
        
    elseif abilityId == LOCK_UNITS then
        call GroupGUDR(GetTriggerUnit() , false)
        
    elseif abilityId == TOGGLE_VISIBILITY then
        call ToggleGUDRVisibility(GetTriggerUnit(), true, true)
        
    elseif abilityId == CHANGE_WEATHER_NEXT then
        call ChangeGUDRWeatherNew(GetTriggerUnit(), 1, 0)
    
    elseif abilityId == CHANGE_WEATHER_PREV then
        call ChangeGUDRWeatherNew(GetTriggerUnit(), -1, 0)
    
    elseif abilityId == TOGGLE_WEATHER then
        if GUDR_GeneratorHasWeather(GetTriggerUnit()) then
            call DestroyWeather(GetTriggerUnit())
        else
            call CreateWeather(GetTriggerUnit())
        endif
    
    elseif abilityId ==  CREATE_OR_DESTROY then
        if GUDR_IsUnitGenerator(GetTriggerUnit()) then
            call DestroyGUDR(GetTriggerUnit())
        else
            call CreateGUDR(GetTriggerUnit())
        endif
    
    elseif abilityId == UNLOCK_UNITS then
        call GroupGUDR(GetTriggerUnit(),  true)
    else
        static if LIBRARY_AutoRectEnvironment then
            if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog == 0 then
        
            elseif abilityId == FOG_RED_UP then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red <= .96 then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red + .05
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red = 0.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, ColorMessage("|c00ff0000Red|r", RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red))
            
            elseif abilityId == FOG_RED_DOWN then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red >= 0.01 then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red - .05
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red = 1.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, ColorMessage("|c00ff0000Red|r", RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.red))
                
            elseif abilityId == FOG_BLUE_UP then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue <= .96 then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue + .05
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue = 0.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, ColorMessage("|c000000ffBlue|r", RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue))
            
            elseif abilityId == FOG_BLUE_DOWN then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue >= 0.01 then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue - .05
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue = 1.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, ColorMessage("|c000000ffBlue|r", RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.blue))
            
            elseif abilityId == FOG_GREEN_UP then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green <= .96 then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green + .05
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green = 0.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, ColorMessage("|c0000ff00Green|r", RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green))
            
            elseif abilityId == FOG_GREEN_DOWN then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green >= 0.01 then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green - .05
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green = 1.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, ColorMessage("|c0000ff00Green|r", RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.green))
            
            elseif abilityId == FOG_DENSITY_UP then
                set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density + .00005
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, "Fog Density set to: "+ R2S(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density*100)+"%")
            
            elseif abilityId == FOG_DENSITY_DOWN then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density >= 0.00006 then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density - .00005
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density = 0. 
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, "Fog Density set to: "+ R2S(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.density*100)+"%")
            
            elseif abilityId == FOG_ZSTART_UP then
                set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart + 1000.
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0,("Fog zStart set to: "+ R2S(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart)))
            
            elseif abilityId == FOG_ZSTART_DOWN then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart >= 1200. then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart - 1000.
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart = 0.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0,("Fog zStart set to: "+ R2S(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zStart)))
            
            elseif abilityId == FOG_ZEND_UP then
                set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd + 500.
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0,("Fog zEnd set to: "+ R2S(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd)))
            
            elseif abilityId == FOG_ZEND_DOWN then
                if RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd >= 1200. then
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd = RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd - 500.
                else
                    set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd = 0.
                endif
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0,("Fog zEnd set to: "+ R2S(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.zEnd)))
            
            elseif abilityId == FOG_STYLE_UP then
                set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.style = FogStyle(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.style).next()
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, "Fog Style set to: " + FogStyle(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.style).getString())
            
            elseif abilityId == FOG_STYLE_DOWN then
                set RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.style = FogStyle(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.style).prev()
                call DisplayTextToPlayer(GetOwningPlayer(GetTriggerUnit()),0,0, "Fog Style set to: " + FogStyle(RectEnvironment.get(GUDR_GetGeneratorRect(GetTriggerUnit())).fog.style).getString())
            elseif abilityId == TOGGLE_FOG then
                if AutoRectEnvironment_IsRectRegistered(GUDR_GetGeneratorRect(GetTriggerUnit())) then
                    call AutoRectEnvironment_DeRegisterRect(GUDR_GetGeneratorRect(GetTriggerUnit()))
                    //! runtextmacro GUDR_DisableFogAbilities("GetTriggerUnit()","true")
                else
                    call AutoRectEnvironment_RegisterRect(GUDR_GetGeneratorRect(GetTriggerUnit()))
                    //! runtextmacro GUDR_DisableFogAbilities("GetTriggerUnit()","false")
                endif
            endif
        endif
        static if LIBRARY_StructureTileDefinition and LIBRARY_TileDefinition then
            if abilityId == MOVE_TERRAIN then
                if GetUnitX(GetTriggerUnit()) != GetTileCenterCoordinate(GetUnitX(GetTriggerUnit())) then
                    call SetUnitX(GetTriggerUnit(), GetUnitX(GetTriggerUnit()) - 32)
                endif
                if GetUnitY(GetTriggerUnit()) != GetTileCenterCoordinate(GetUnitY(GetTriggerUnit())) then
                    call SetUnitY(GetTriggerUnit(), GetUnitY(GetTriggerUnit()) - 32)
                endif
            
                if CountUnitsInGroup(GUDR_GetGeneratorGroup(GetTriggerUnit())) <= MAXIMUM_MOVE_LIMIT then
                    call ForGroup( GUDR_GetGeneratorGroup(GetTriggerUnit()), function GroupLoopTerrain )
                    call SetUnitPosition(GetTriggerUnit(), GetTileCenterCoordinate(GetSpellTargetX()), GetTileCenterCoordinate(GetSpellTargetY()))
                    call MoveGUDR(GetTriggerUnit(), 0, 0, true)
                else
                    call DisplayTextToPlayer( GetOwningPlayer(GetTriggerUnit()),0,0, "Failed to move Rect Generator:\n Attached unit limit exceeded! (" + I2S(MAXIMUM_MOVE_LIMIT) + ")" )
                    call SetUnitPosition(GetTriggerUnit(), GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit()))
                    call MoveGUDR(GetTriggerUnit(), 0, 0, true)
                endif
            endif
        endif
    endif
    
    return false
endfunction

private function onSpawn takes nothing returns boolean
    local unit u = GetTriggerUnit()
    
    if u == null then
        set u = GetFilterUnit()
    endif
    
    if Conditions(u) then
        //! runtextmacro GUDR_FirstPage("Add", "u")
    
        call UnitRemoveAbility(u, 'Amov')
        call UnitRemoveAbility(u, 'Aatk')
    endif
    
    set u = null
    return false
endfunction

//===========================================================================
private function onInit takes nothing returns nothing
    local trigger trig = CreateTrigger()
    local boolexpr onSpawnFilter = Condition( function onSpawn)  // No need to null this
    local integer i = 0
    
    call TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_SPELL_CAST)
    call TriggerAddCondition(trig, Condition(function onCast))
    
    static if AUTOMATIC_ON_SPAWN then
        set trig = CreateTrigger(  )
        
        static if LIBRARY_WorldBounds then
            call TriggerRegisterEnterRegion( trig, WorldBounds.worldRegion, null )
        else
            call TriggerRegisterEnterRectSimple( trig, GetPlayableMapRect() )
        endif
        
        call TriggerAddCondition( trig,  onSpawnFilter)
        
        loop
        exitwhen i >= bj_MAX_PLAYER_SLOTS
            call GroupEnumUnitsOfPlayer(ENUM_GROUP, Player(i), onSpawnFilter)
            set i = i + 1
        endloop
    endif
    
    static if LIBRARY_AutoRectEnvironment then
        call FogStyle(TerrainFog.LINEAR).setString(      "Linear")
        call FogStyle(TerrainFog.EXPONENTIAL).setString( "Exponential 1")
        call FogStyle(TerrainFog.EXPONENTIAL2).setString("Exponential 2")
        
        //! runtextmacro udrAddon_LinkStyles("TerrainFog.LINEAR", "TerrainFog.EXPONENTIAL")
        //! runtextmacro udrAddon_LinkStyles("TerrainFog.EXPONENTIAL", "TerrainFog.EXPONENTIAL2")
        //! runtextmacro udrAddon_LinkStyles("TerrainFog.EXPONENTIAL2", "TerrainFog.LINEAR")
    endif
    
    set trig = null
endfunction
endlibrary
