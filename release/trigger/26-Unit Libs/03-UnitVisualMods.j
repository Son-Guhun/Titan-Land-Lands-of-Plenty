library UnitVisualMods requires UnitVisualValues, UnitName, InstantRootOrder optional UnitVisualModsDefaults/*

    */ UnitVisualModsCopy, UnitVisualModsUpgrade  /* modules for this lib package

    */ optional FuncHooks  // Hooks for attached special effects
/*
=========
 Description
=========

    This library adheres to the "Import Library Standard", and as such stores its funtions in the
UnitVisualsSetters struct. When importing this library, UVS is recommended as a short alias.

=========
 Documentation      TODO: Util functions and Upgrade module.
=========

lib UnitVisualSetters:

    Functions:
    
        nothing StructureFlyHeight(unit structure, real newHeight, boolean autoLand)
            .
            . Set flying height for a structure by ordering it to unroot. If autoLand is true, then 
            . the root ability will be removed and the strucutre will be instantly rooted using the
            . InstantRootOrder library.
        
        nothing Facing(unit whichUnit, real newAngle)
            .
            . Sets unit facing. Works for units that don't have the Amov ability by forecfully redrawing
            . those units using SetUnitPosition.

        nothing FlyHeight(unit whichUnit, real newHeight)
            .
            . Sets unit facing. Works for non-flying units by adding the Amrf ability to them. Works 
            . for units that don't have Amov by redrawing them using SetUnitPosition. Does not work
            . for structures, the StructureFlyHeight function must be used in this case.
        
        nothing MatrixScale(unit whichUnit, real scaleX, real scaleY, real scaleZ)
            .
            . Per-dimension scaling does not work for units unfortunately. This function exists in
            . order to support hooks defined in the FuncHooks library.
        
        nothing Scale(unit whichUnit, real scale)
            .
            . Set unit scale. Since only the X dimension is considered by the native function, this
            . function accepts only 1 value, which is applied on all dimensions.
        
        nothing VertexColorInt(unit whichUnit, integer red, integer green, integer blue, integer alpha)
            .
            . Works like SetUnitVertexColor.

        nothing VertexColor(unit whichUnit, real red, real green, real blue, real trans)        
            .
            . Works like SetUnitVertexColorBJ. Values are still stored as integers.
        
        nothing Color(unit whichUnit, integer color)
            .
            . Sets the unit's player color. Integer is the handle id of the player color, which
            . matches the player id of the player which has that color by default.

        nothing AnimSpeed(unit whichUnit, real speedMultiplier)
            .
            . Sets unit animation speed. Negative values are supported, though the unit actually
            . freezes at the end of the animation, instead of continually playing it (as of 1.32.9).
        
        nothing AnimTag(unit whichUnit, string whichTag)
            .
            . Set the unit's animation properties, known as animation tags in GUI. All animation tags 
            . are removed from the unit first, then the specified animation tags (separated by spaces,
            . as normal for the native) are added to the unit.


        nothing CopyValues(unit source, unit target)
            .
            . Copy visual values from one unit to another. Does not copy unit name or selection type.

        nothing Copy(unit whichUnit, player owner, integer newType)
            .
            . Creates a unit of 'newType' for the 'owner', then calls CopeValues with 'whichUnit' as
            . the source and the newly created unit as the target. Returns the newly created unit.

        nothing CopySameType(unit whichUnit, player owner)
            .
            . Calls Copy, with 'newType' being 'GetUnitTypeId(whichUnit)'.
     
     
        nothing DragSelectable(unit whichUnit)
            .
            . Makes a unit unable to be selected by clicking, only by using drag-selection.
        
        nothing SelectionType(unit whichUnit, integer selectType)
            .
            . Set a unit's selection type. Check UnitVisualValues library for the relevant constants.
        
        nothing UnSelectable(unit whichUnit returns)
            .
            . Makes the unit completely unselectable, saves '2' as it's selection type.

        nothing LocustSelectable(unit whichUnit)
            .
            . Makes the unit completely unselectable, saves '3' as it's selection type.
          

        nothing Name(unit whichUnit, string name)
            .
            . Gives a unit a custom name, which is colored. For heroes, their proper name is set.

        nothing ResetName(unit whichUnit)
            .
            . Resets a unit's name, if it had a custom one.
        



*/
//==================================================================================================
//                                       Configuration
//==================================================================================================

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


//==================================================================================================
//                                        Source Code
//==================================================================================================
private struct KEYS extends array
    implement UnitVisualValues_KEYS_Module  // Hashtable key constants
endstruct

private struct data extends array
    static if LIBRARY_HashtableWrapper and UnitVisualValues_INIT_HASHTABLE then
        static method operator [] takes integer i returns UnitVisualValues_data_Child
            return UnitVisualValues_data[i]  // Wrap UnitVisualValues hashtable
        endmethod
    else
        static method operator [] takes integer i returns Table
            return UnitVisualValues_data[i]  // Wrap UnitVisualValues hashtable
        endmethod
    endif
endstruct

private struct SaveFlyHeight extends array
    implement UnitVisualModsUpgrade_StorageStructModule  // Struct that stores unit flying height (for handling upgrades)
endstruct


// Define before creating hooks, since there's no need to hook SetUnitPosition if the unit position is the same as before.
private function RedrawUnit takes unit whichUnit returns nothing
    call SetUnitPosition(whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit))
endfunction

// hooks here
//! runtextmacro optional DefineHooks()

//==========================================

private struct Utils extends array

    static constant method operator CUSTOM_NAME_COLOR takes nothing returns string
        return "|cffffcc00"
    endmethod

    static method PercentTo255 takes real percent returns integer
        return MathRound(2.55*percent)
    endmethod
    
    static method AddStructureFlightAbility takes unit structure returns nothing
        local real facing
        //! runtextmacro ASSERT("structure != null")
        //! runtextmacro ASSERT("IsUnitType(structure, UNIT_TYPE_STRUCTURE)")

        set facing = GetUnitFacing(structure)
        call UnitAddAbility(structure, InstantRootOrder_ROOT_ABILITY )
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
                call StructureFlyHeight(whichUnit, GetUnitFlyHeight(whichUnit), GetUnitAbilityLevel(whichUnit, InstantRootOrder_ROOT_ABILITY) == 0)
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
    
    static method VertexColorInt takes unit whichUnit, integer red, integer green, integer blue, integer alpha returns nothing
        local integer uId = GetHandleId(whichUnit)
        //! runtextmacro ASSERT("whichUnit != null")
        
        call SetUnitVertexColor(whichUnit, red, green, blue, alpha)
        set data[uId][KEYS.RED]   = red
        set data[uId][KEYS.GREEN] = green
        set data[uId][KEYS.BLUE]  = blue
        set data[uId][KEYS.ALPHA] = alpha
    endmethod

    static method VertexColor takes unit whichUnit, real red, real green, real blue, real trans  returns nothing        
        call VertexColorInt(whichUnit, Utils.PercentTo255(red), Utils.PercentTo255(green), Utils.PercentTo255(blue), Utils.PercentTo255(100. - trans))
    endmethod

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
    
    implement UnitVisualModsCopy_Module  // Import copy functions
    
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
            call UnitName_SetUnitName(whichUnit, Utils.CUSTOM_NAME_COLOR + name + "|r")
        else
            call ResetName(whichUnit)
        endif
    endmethod
    
    implement UnitVisualModsUpgrade_Module  // Import upgrade handler function

endstruct


endlibrary