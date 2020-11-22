library UnitVisualMods requires HashStruct, UnitVisualValues, UnitVisualModsCopy, UnitName, GroupTools, InstantRootOrder optional UnitVisualModsDefaults/*

    */ /*optional*/ HashtableWrapper, /* Required to initialize a hashtable.
    
    */ optional Table, /*  Required if a hashtable is not intialized.
    
    */ optional ConstTable  /* If present, then ConstHashTable is used instead of HashTable.
    
    */ optional FuncHooks  // Hooks for attached special effects
//////////////////////////////////////////////////////
//Guhun's Unit Modification System v1.3.1

globals
    constant boolean AUTOMATIC_ON_UPGRADE = false
endglobals

//Hashtable values:
globals    
    private constant integer SAVED_FLY_HEIGHT = -1  // Used to save flying height for units (to keep height after upgrading)

    private constant integer SCALE  = 0
    public constant integer RED    = 1
    public constant integer GREEN  = 2
    public constant integer BLUE   = 3
    public constant integer ALPHA  = 4
    private constant integer COLOR  = 5
    private constant integer ASPEED = 6
    private constant integer ATAG   = 7
    private constant integer SELECT = 8
    private constant integer NAME   = 9
endglobals

//CONSTANTS FOR STATIC TABLES (Must be negative to avoid null-point exceptions of handles and conflics with handles)
globals
    public constant integer TAGS_DECOMPRESS = -1
    public constant integer TAGS_COMPRESS   = -2
endglobals

//////////////////////////////////////////////////////
// CONFIGURATION

// This function specifies what should be done to a unit when an argument which is not a valid
// player number (1 <= n <= bj_MAX_PLAYERS) is passed to UnitVisualsSetters.Color. The default behaviour is
// to set the color of the unit to the color of the owning player.

// NOTE: Hashtable data is automatically cleared when a non-player number argument is passed.
// You can reference a whichUnit variable. Do not alter this variable.
//! textmacro GUMS_Config_ResetColorFunc
    static if LIBRARY_UnitVisualModsDefaults and UnitVisualModsDefaults_COLOR then
        call UnitVisualModsDefaults_SetColor(whichUnit, GetOwningPlayer(whichUnit))
    else
        call SetUnitColor(whichUnit, GetPlayerColor(GetOwningPlayer(whichUnit)))
    endif
    
//! endtextmacro
private struct data extends array
    static method operator [] takes integer i returns UnitVisualValues_data_Child
        return UnitVisualValues_data[i]
    endmethod
endstruct


//==================================================================================================
//                                        Source Code
//==================================================================================================

// Define before creating hooks, since there's no need to hook SetUnitPosition if the unit position is the same as before.
private function RedrawUnit takes unit whichUnit returns nothing
    call SetUnitPosition(whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit))
endfunction

// hooks here
//! runtextmacro optional DefineHooks()

//////////////////////////////////////////////////////

function GUMS_GetUnitSelectionType takes unit whichUnit returns integer
    return data[GetHandleId(whichUnit)][SELECT]
endfunction

//==========================================
// Storing
//==========================================

private struct SaveFlyHeight extends array

    method operator height takes nothing returns real
        return data[this].real[SAVED_FLY_HEIGHT]
    endmethod
    
    method operator height= takes real value returns nothing
        set data[this].real[SAVED_FLY_HEIGHT] = value
    endmethod
    
    method clearHeight takes nothing returns nothing
        call data[this].real.remove(SAVED_FLY_HEIGHT)
    endmethod
    
    method hasHeight takes nothing returns boolean
        return data[this].real.has(SAVED_FLY_HEIGHT)
    endmethod
endstruct

//==========================================
// Setters

private struct Utils extends array

    static method PercentTo255 takes real percent returns integer
        return MathRound(2.55*percent)
    endmethod
    
    static method AddStructureFlightAbility takes unit structure returns nothing
        local real facing
        //! runtextmacro ASSERT("structure != null")
        //! runtextmacro ASSERT("IsUnitType(structure, UNIT_TYPE_STRUCTURE)")

        set facing = GetUnitFacing(structure)
        call UnitAddAbility(structure, 'DEDF' )
        call BlzSetUnitFacingEx(structure, facing)
    endmethod

endstruct

struct UnitVisualsSetters extends array

    //! runtextmacro ImportLibAs("Utils", "utils")
    
    static method StructureFlyHeight takes unit structure, real newHeight, boolean autoLand returns nothing
        //! runtextmacro ASSERT("structure != null")
        //! runtextmacro ASSERT("IsUnitType(structure, UNIT_TYPE_STRUCTURE)")
        
        if GetUnitFlyHeight(structure) < UnitVisuals.MIN_FLY_HEIGHT and newHeight < UnitVisuals.MIN_FLY_HEIGHT then  // 0.01 seems to be the minimum flying height
            call SetUnitFlyHeight( structure, newHeight, 0)  // this is needed for hooked stuff
            return
        endif
     
        if UnitAddAbility(structure, 'Amrf' ) then
            call UnitRemoveAbility(structure, 'Amrf')
        endif
        
        call SetUnitFlyHeight( structure, newHeight, 0)
        set SaveFlyHeight(GetHandleId(structure)).height = newHeight
        
        if GetUnitAbilityLevel(structure,'Amov') > 0 then
            // this is an Ancient and probably already has root. Do nothing
        else
            call Utils.AddStructureFlightAbility(structure)
            call IssueImmediateOrder(structure, "unroot")
            if autoLand then
                call IssueInstantRootOrder(structure)
            endif
        endif
    endmethod
    
    static method Facing takes unit whichUnit, real newAngle returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call BlzSetUnitFacingEx(whichUnit, newAngle)
        
        if GetUnitAbilityLevel(whichUnit, 'Amov') == 0 then
            call RedrawUnit(whichUnit)
            
            if IsUnitType(whichUnit, UNIT_TYPE_STRUCTURE) and GetUnitFlyHeight(whichUnit) > UnitVisuals.MIN_FLY_HEIGHT then
                call StructureFlyHeight(whichUnit, GetUnitFlyHeight(whichUnit), GetUnitAbilityLevel(whichUnit, 'DEDF') == 0)
            endif
        endif    
    endmethod
    
    static method FlyHeight takes unit whichUnit, real newHeight returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        //! runtextmacro ASSERT("not IsUnitType(whichUnit, UNIT_TYPE_STRUCTURE)")
        
        if UnitAddAbility(whichUnit, 'Amrf' ) then
            call UnitRemoveAbility(whichUnit, 'Amrf')
        endif
        
        call SetUnitFlyHeight( whichUnit, newHeight, 0)
        set SaveFlyHeight(GetHandleId(whichUnit)).height = newHeight
        
        if GetUnitAbilityLevel(whichUnit, 'Amov') == 0 then
            call RedrawUnit(whichUnit)
        endif
    endmethod
    
    static method MatrixScale takes unit whichUnit, real scaleX, real scaleY, real scaleZ returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call SetUnitScale(whichUnit, scaleX, scaleY, scaleZ)
        set data[GetHandleId(whichUnit)].real[SCALE] = scaleX
    endmethod

    static method Scale takes unit whichUnit, real scale returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call SetUnitScale(whichUnit, scale, scale, scale)
        set data[GetHandleId(whichUnit)].real[SCALE] = scale
    endmethod

    //Set Vertex Color
    static method VertexColor takes unit whichUnit, real red, real green, real blue, real trans  returns nothing
        local integer intRed   = Utils.PercentTo255(red)
        local integer intGreen = Utils.PercentTo255(green)
        local integer intBlue  = Utils.PercentTo255(blue)
        local integer intAlpha = Utils.PercentTo255(100. - trans)
        //! runtextmacro ASSERT("whichUnit != null")
        
        call SetUnitVertexColor(whichUnit, intRed, intGreen, intBlue, intAlpha)
        set data[GetHandleId(whichUnit)][RED]   = intRed
        set data[GetHandleId(whichUnit)][GREEN] = intGreen
        set data[GetHandleId(whichUnit)][BLUE]  = intBlue
        set data[GetHandleId(whichUnit)][ALPHA] = intAlpha
    endmethod

    static method VertexColorInt takes unit whichUnit, integer red, integer green, integer blue, integer alpha returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call SetUnitVertexColor(whichUnit, red, green, blue, alpha)
        set data[GetHandleId(whichUnit)][RED]   = red
        set data[GetHandleId(whichUnit)][GREEN] = green
        set data[GetHandleId(whichUnit)][BLUE]  = blue
        set data[GetHandleId(whichUnit)][ALPHA] = alpha
    endmethod

    //Set Player Color (why in hell can't this be retrieved with natives?!)
    static method Color takes unit whichUnit, integer color returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        if color <= bj_MAX_PLAYER_SLOTS and color >= 1 then
            set data[GetHandleId(whichUnit)][COLOR] = color
            call SetUnitColor(whichUnit, ConvertPlayerColor(color-1))
        else
            call data[GetHandleId(whichUnit)].remove(COLOR)

            //! runtextmacro GUMS_Config_ResetColorFunc()
        endif
    endmethod

    static method AnimSpeed takes unit whichUnit, real speedMultiplier returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call SetUnitTimeScale(whichUnit, speedMultiplier)
        set data[GetHandleId(whichUnit)].real[ASPEED] = speedMultiplier
    endmethod

    
    static method AnimTag takes unit whichUnit, string whichTag returns nothing
        local UnitVisuals unitId = GetHandleId(whichUnit)
        //! runtextmacro ASSERT("whichUnit != null")
        
        if unitId.hasAnimTag() then
            call AddUnitAnimationProperties(whichUnit, GUMSConvertTags(TAGS_DECOMPRESS, unitId.raw.getAnimTag()), false)
        else
            call AddUnitAnimationProperties(whichUnit, UnitVisuals.allTags, false)
        endif
        
        if whichTag != "" then
            call AddUnitAnimationProperties(whichUnit, whichTag, true)
            set whichTag = GUMSConvertTags(TAGS_COMPRESS, whichTag)
            set data[unitId].string[ATAG] = whichTag
            
        else
            call data[unitId].string.remove(ATAG)
        endif
    endmethod
    
    implement UnitVisualModsCopy_Module

endstruct

///////////////////////////
//These functions are used to work with unit names
//
//The unit's default proper name is saved in a Hashtable so it can be reset
///////////////////////////

private constant function CustomUnitNameColor takes nothing returns string
    return "|cffffcc00"
endfunction

private function ConvertToCustomName takes string name returns string
    return CustomUnitNameColor() + name + "|r"
endfunction

private function ConvertFromCustomName takes string name returns string
    return SubString(name, 10, StringLength(name) - 2)
endfunction

private function GetDefaultName takes integer unitHandle returns string
    //! runtextmacro ASSERT("unitHandle != 0")
    return data[unitHandle].string[NAME]
endfunction

function GUMSUnitHasCustomName takes integer unitHandle returns boolean
    //! runtextmacro ASSERT("unitHandle != 0")
    return data[unitHandle].string.has(NAME)
endfunction

function GUMSResetUnitName takes unit whichUnit returns nothing
    local integer unitHandle = GetHandleId(whichUnit)
    //! runtextmacro ASSERT("whichUnit != null")
    
    if GUMSUnitHasCustomName(unitHandle) then
        call UnitName_SetUnitName(whichUnit, GetDefaultName(unitHandle))
        call data[unitHandle].string.remove(NAME)
    endif
endfunction

function GUMSSetUnitName takes unit whichUnit, string name returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    if name != "" then
        if not GUMSUnitHasCustomName(GetHandleId(whichUnit)) then
            set data[GetHandleId(whichUnit)].string[NAME] = UnitName_GetUnitName(whichUnit)
        endif
        call UnitName_SetUnitName(whichUnit, ConvertToCustomName(name))
    else
        call GUMSResetUnitName(whichUnit)
    endif
endfunction

function GUMSGetUnitName takes unit whichUnit returns string
    //! runtextmacro ASSERT("whichUnit != null")
    return ConvertFromCustomName(UnitName_GetUnitName(whichUnit))
endfunction

//==========================================
// GUMS Unit Selectability Utilities

function GUMSMakeUnitDragSelectable takes unit whichUnit returns nothing
    local integer unitId = GetHandleId(whichUnit)
    local integer selectionType = data[unitId][SELECT]
    //! runtextmacro ASSERT("whichUnit != null")

    if selectionType == UnitVisuals.SELECTION_DRAG then
        return //Unit is already drag-selectable, do nothing.
    endif
    
    if selectionType != UnitVisuals.SELECTION_UNSELECTABLE then //Check if unit is already unselectable.
        if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
            call UnitRemoveAbility(whichUnit,'Aloc')
            set data[unitId][SELECT] = UnitVisuals.SELECTION_DRAG
        else
            return
        endif
    endif
    
    //This if block makes the unit drag-selectable after removing the locust ability.
    if not IsUnitHidden(whichUnit) then
        call ShowUnit(whichUnit,false)
        call ShowUnit(whichUnit,true)
    endif
endfunction

function GUMSSetUnitSelectionType takes unit whichUnit, integer selectType returns nothing
    local integer unitId = GetHandleId(whichUnit) 
    //! runtextmacro ASSERT("whichUnit != null")

    if selectType == UnitVisuals.SELECTION_UNSELECTABLE or selectType == UnitVisuals.SELECTION_LOCUST then
        if data[unitId][SELECT] >=UnitVisuals.SELECTION_UNSELECTABLE then
            set data[unitId][SELECT] = selectType
            return //Unit is already unselectable, do nothing.
        endif

        if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
            call UnitRemoveAbility(whichUnit,'Aloc')
            set data[unitId][SELECT] = selectType
            call SetUnitInvulnerable(whichUnit, true)
            call BlzUnitDisableAbility(whichUnit, 'Aatk', true, true)
        endif
    elseif selectType == UnitVisuals.SELECTION_DRAG then
        call GUMSMakeUnitDragSelectable(whichUnit)
    endif
endfunction

function GUMSMakeUnitUnSelectable takes unit whichUnit returns nothing
    call GUMSSetUnitSelectionType(whichUnit, UnitVisuals.SELECTION_UNSELECTABLE)
endfunction

function GUMSMakeUnitLocust takes unit whichUnit returns nothing
    call GUMSSetUnitSelectionType(whichUnit, UnitVisuals.SELECTION_LOCUST)
endfunction


//////////////////////////////////////////////////////
//End of GUMS
//////////////////////////////////////////////////////
//==================================================================================================
//                                        Initialization
//==================================================================================================
// GUMS Flying Height and Facing Timer

function GUMSOnUpgradeHandler takes unit trigU returns nothing
        local SaveFlyHeight unitData = GetHandleId(trigU)
        local real height
        //! runtextmacro ASSERT("trigU != null")
        
        
        if unitData.hasHeight() and unitData.height > UnitVisuals.MIN_FLY_HEIGHT then
            set height = unitData.height
        
            call UnitVisualsSetters.CopyValues(trigU, trigU)

            call UnitVisualsSetters.FlyHeight(trigU, height)
        else
            call UnitVisualsSetters.CopyValues(trigU, trigU)
        endif
        
        set trigU = null
endfunction

// When a unit cancels of finishes an upgrade, reapply its Visual modifications.
private module InitModule

    static if AUTOMATIC_ON_UPGRADE then
        private static method onUpgradeHandler takes nothing returns nothing
            call GUMSOnUpgradeHandler(GetTriggerUnit())
        endmethod
    endif


    private static method onInit takes nothing returns nothing
        local trigger fixUpgrades
        local integer i
        local timer t = CreateTimer()
        
        static if AUTOMATIC_ON_UPGRADE then
            set fixUpgrades = CreateTrigger()
            call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_CANCEL )
            call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_FINISH )
            call TriggerAddAction( fixUpgrades, function thistype.onUpgradeHandler )
        endif
    
        //! runtextmacro GUMS_RegisterTag("gold", "g")
        //! runtextmacro GUMS_RegisterTag("lumber", "l")
        //! runtextmacro GUMS_RegisterTag("work", "w")
        //! runtextmacro GUMS_RegisterTag("flesh", "f")
        //! runtextmacro GUMS_RegisterTag("ready", "r")
        //! runtextmacro GUMS_RegisterTag("one", "1")
        //! runtextmacro GUMS_RegisterTag("two", "2")
        //! runtextmacro GUMS_RegisterTag("throw", "t")
        //! runtextmacro GUMS_RegisterTag("slam", "sl")
        
        //! runtextmacro GUMS_RegisterTag("large", "sl")
        //! runtextmacro GUMS_RegisterTag("medium", "sm")
        //! runtextmacro GUMS_RegisterTag("small", "ss")

        //! runtextmacro GUMS_RegisterTag("victory", "v")
        //! runtextmacro GUMS_RegisterTag("alternate", "a")
        //! runtextmacro GUMS_RegisterTag("defend", "d")
        //! runtextmacro GUMS_RegisterTag("swim", "s")
        
        //! runtextmacro GUMS_RegisterTag("spin", "sp")
        //! runtextmacro GUMS_RegisterTag("fast", "fa")
        //! runtextmacro GUMS_RegisterTag("talk", "ta")
        
        //! runtextmacro GUMS_RegisterTag("upgrade","u")
        //! runtextmacro GUMS_RegisterTag("first","n1")
        //! runtextmacro GUMS_RegisterTag("second","n2")
        //! runtextmacro GUMS_RegisterTag("third","n3")
        //! runtextmacro GUMS_RegisterTag("fourth","n4")
        //! runtextmacro GUMS_RegisterTag("fifth","n5")
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

endlibrary