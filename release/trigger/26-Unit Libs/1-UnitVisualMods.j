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
private struct KEYS extends array
    implement UnitVisualValues_KEYS_Module
endstruct


// Define before creating hooks, since there's no need to hook SetUnitPosition if the unit position is the same as before.
private function RedrawUnit takes unit whichUnit returns nothing
    call SetUnitPosition(whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit))
endfunction

// hooks here
//! runtextmacro optional DefineHooks()

//==========================================
// Storing
//==========================================

// Cannot store fly high in the "begins upgrade" event, as it is already lost by then.
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

private constant function CustomUnitNameColor takes nothing returns string
    return "|cffffcc00"
endfunction

private function ConvertToCustomName takes string name returns string
    return CustomUnitNameColor() + name + "|r"
endfunction

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
        set data[GetHandleId(whichUnit)].real[KEYS.SCALE] = scaleX
    endmethod

    static method Scale takes unit whichUnit, real scale returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call SetUnitScale(whichUnit, scale, scale, scale)
        set data[GetHandleId(whichUnit)].real[KEYS.SCALE] = scale
    endmethod

    //Set Vertex Color
    static method VertexColor takes unit whichUnit, real red, real green, real blue, real trans  returns nothing
        local integer intRed   = Utils.PercentTo255(red)
        local integer intGreen = Utils.PercentTo255(green)
        local integer intBlue  = Utils.PercentTo255(blue)
        local integer intAlpha = Utils.PercentTo255(100. - trans)
        //! runtextmacro ASSERT("whichUnit != null")
        
        call SetUnitVertexColor(whichUnit, intRed, intGreen, intBlue, intAlpha)
        set data[GetHandleId(whichUnit)][KEYS.RED]   = intRed
        set data[GetHandleId(whichUnit)][KEYS.GREEN] = intGreen
        set data[GetHandleId(whichUnit)][KEYS.BLUE]  = intBlue
        set data[GetHandleId(whichUnit)][KEYS.ALPHA] = intAlpha
    endmethod

    static method VertexColorInt takes unit whichUnit, integer red, integer green, integer blue, integer alpha returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call SetUnitVertexColor(whichUnit, red, green, blue, alpha)
        set data[GetHandleId(whichUnit)][KEYS.RED]   = red
        set data[GetHandleId(whichUnit)][KEYS.GREEN] = green
        set data[GetHandleId(whichUnit)][KEYS.BLUE]  = blue
        set data[GetHandleId(whichUnit)][KEYS.ALPHA] = alpha
    endmethod

    //Set Player Color (why in hell can't this be retrieved with natives?!)
    static method Color takes unit whichUnit, integer color returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        if color <= bj_MAX_PLAYER_SLOTS and color >= 1 then
            set data[GetHandleId(whichUnit)][KEYS.COLOR] = color
            call SetUnitColor(whichUnit, ConvertPlayerColor(color-1))
        else
            call data[GetHandleId(whichUnit)].remove(KEYS.COLOR)

            //! runtextmacro GUMS_Config_ResetColorFunc()
        endif
    endmethod

    static method AnimSpeed takes unit whichUnit, real speedMultiplier returns nothing
        //! runtextmacro ASSERT("whichUnit != null")
        call SetUnitTimeScale(whichUnit, speedMultiplier)
        set data[GetHandleId(whichUnit)].real[KEYS.ASPEED] = speedMultiplier
    endmethod

    
    static method AnimTag takes unit whichUnit, string whichTag returns nothing
        local UnitVisuals unitId = GetHandleId(whichUnit)
        //! runtextmacro ASSERT("whichUnit != null")
        
        if unitId.hasAnimTag() then
            call AddUnitAnimationProperties(whichUnit, unitId.raw.getAnimTag(), false)
        else
            call AddUnitAnimationProperties(whichUnit, UnitVisuals.allTags, false)
        endif
        
        if whichTag != "" then
            call AddUnitAnimationProperties(whichUnit, whichTag, true)
            set data[unitId].string[KEYS.ATAG] = whichTag
            
        else
            call data[unitId].string.remove(KEYS.ATAG)
        endif
    endmethod
    
    implement UnitVisualModsCopy_Module
    
    static method DragSelectable takes unit whichUnit returns nothing
        local integer unitId = GetHandleId(whichUnit)
        local integer selectionType = data[unitId][KEYS.SELECT]
        //! runtextmacro ASSERT("whichUnit != null")

        if selectionType == UnitVisuals.SELECTION_DRAG then
            return //Unit is already drag-selectable, do nothing.
        endif
        
        if selectionType != UnitVisuals.SELECTION_UNSELECTABLE then //Check if unit is already unselectable.
            if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
                call UnitRemoveAbility(whichUnit,'Aloc')
                set data[unitId][KEYS.SELECT] = UnitVisuals.SELECTION_DRAG
            else
                return
            endif
        endif
        
        //This if block makes the unit drag-selectable after removing the locust ability.
        if not IsUnitHidden(whichUnit) then
            call ShowUnit(whichUnit,false)
            call ShowUnit(whichUnit,true)
        endif
    endmethod
    
    static method SelectionType takes unit whichUnit, integer selectType returns nothing
        local integer unitId = GetHandleId(whichUnit) 
        //! runtextmacro ASSERT("whichUnit != null")

        if selectType == UnitVisuals.SELECTION_UNSELECTABLE or selectType == UnitVisuals.SELECTION_LOCUST then
            if data[unitId][KEYS.SELECT] >=UnitVisuals.SELECTION_UNSELECTABLE then
                set data[unitId][KEYS.SELECT] = selectType
                return //Unit is already unselectable, do nothing.
            endif

            if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
                call UnitRemoveAbility(whichUnit,'Aloc')
                set data[unitId][KEYS.SELECT] = selectType
                call SetUnitInvulnerable(whichUnit, true)
                call BlzUnitDisableAbility(whichUnit, 'Aatk', true, true)
            endif
        elseif selectType == UnitVisuals.SELECTION_DRAG then
            call DragSelectable(whichUnit)
        endif
    endmethod
    
    static method UnSelectable takes unit whichUnit returns nothing
        call SelectionType(whichUnit, UnitVisuals.SELECTION_UNSELECTABLE)
    endmethod

    static method LocustSelectable takes unit whichUnit returns nothing
        call SelectionType(whichUnit, UnitVisuals.SELECTION_LOCUST)
    endmethod

    static method ResetName takes unit whichUnit returns nothing
        local UnitVisuals unitHandle = GetHandleId(whichUnit)
        //! runtextmacro ASSERT("whichUnit != null")
        
        if unitHandle.hasCustomName() then
            call UnitName_SetUnitName(whichUnit, unitHandle.getOriginalName())
            call data[unitHandle].string.remove(KEYS.NAME)
        endif
    endmethod
    
    static method Name takes unit whichUnit, string name returns nothing
        local UnitVisuals uId = GetHandleId(whichUnit)
        //! runtextmacro ASSERT("whichUnit != null")
        
        if name != "" then
            if not uId.hasCustomName() then
                set data[uId].string[KEYS.NAME] = UnitName_GetUnitName(whichUnit)
            endif
            call UnitName_SetUnitName(whichUnit, ConvertToCustomName(name))
        else
            call ResetName(whichUnit)
        endif
    endmethod

endstruct

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
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

endlibrary