library UnitVisualMods requires UnitVisualValues, UnitName, CutToComma, GroupTools, optional UnitVisualModsDefaults/*

    */ /*optional*/ HashtableWrapper,  /* Required to initialize a hashtable.
    
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
    private constant integer COUNTER = -1  // Used to count if the unit has had their position set by the timer loop
    private constant integer TARGET_ANGLE = -2  // Used to store the final facing angle of an immovable unit that's turning
    private constant integer AUTO_LAND = -3
    private constant integer STRUCTURE_HEIGHT = -4 // This is only saved for structures, which lose their flying heights when moving
    
    private constant integer saveFlyHeight = -5  // Used to save flying height for immovable units (to keep height after upgrading)

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
// player number (1 <= n <= bj_MAX_PLAYERS) is passed to GUMSSetUnitColor. The default behaviour is
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

globals
    private group loopGroup = CreateGroup()
endglobals

private struct data extends array
    static method operator [] takes integer i returns UnitVisualValues_data_Child
        return UnitVisualValues_data[i]
    endmethod
    
    static method flushChild takes integer i returns nothing
        call UnitVisualValues_data.flushChild(i)
    endmethod
endstruct


//==================================================================================================
//                                        Source Code
//==================================================================================================

// hooks should be below, no need to hook setunitposition if the unit position is the same as before
function GUMS_RedrawUnit takes unit whichUnit returns nothing
    call SetUnitPosition(whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit))
endfunction

// hooks here
//! runtextmacro optional DefineHooks()

function GUMS_RegisterImmovableUnit takes unit whichUnit returns nothing
    call GroupAddUnit(loopGroup, whichUnit)
endfunction

//////////////////////////////////////////////////////
constant function GUMSCustomUnitNameColor takes nothing returns string
    return "|cffffcc00"
endfunction

function GUMSConvertToCustomName takes string name returns string
    return GUMSCustomUnitNameColor() + name + "|r"
endfunction

function GUMSConvertFromCustomName takes string name returns string
    return SubString(name, 10, StringLength(name) - 2)
endfunction

function GUMS_GetUnitSelectionType takes unit whichUnit returns integer
    return data[GetHandleId(whichUnit)][SELECT]
endfunction
//==========================================
//GUMS SELECTION TYPE CONSTANTS
constant function GUMS_SELECTION_DEFAULT takes nothing returns integer
    return 0
endfunction

// Units that can only be drag-selected.
constant function GUMS_SELECTION_DRAG takes nothing returns integer
    return 1
endfunction

// Units that are unselectable and may be converted to SFX.
constant function GUMS_SELECTION_UNSELECTABLE takes nothing returns integer
    return 2
endfunction

// Units that are unselectable and should not be converted to SFX.
constant function GUMS_SELECTION_LOCUST takes nothing returns integer
    return 3
endfunction
//==========================================
constant function GUMS_MINIMUM_FLY_HEIGHT takes nothing returns real
    return 0.02
endfunction


//==========================================

//==========================================
//==========================================

//==========================================
// GUMS API
//==========================================

globals
    private boolean unitHasBeenRemoved = false
endglobals

// Clears all data stored with a unit handle ID.
function GUMSClearHandleId takes integer handleId returns nothing
    call data.flushChild(handleId)
    set unitHasBeenRemoved = true
endfunction

// Call this when a unit is removed from the game. It supports both in-scope units and units that are out of scope (aren't null, but can't really be manipulated)
function GUMSClearUnitData takes unit whichUnit returns nothing
    call GUMSClearHandleId(GetHandleId(whichUnit))
endfunction


private struct SaveFlyHeight extends array

    method operator height takes nothing returns real
        return data[this].real[saveFlyHeight]
    endmethod
    
    method operator height= takes real value returns nothing
        set data[this].real[saveFlyHeight] = value
    endmethod
    
    method clearHeight takes nothing returns nothing
        call data[this].real.remove(saveFlyHeight)
    endmethod
    
    method hasHeight takes nothing returns boolean
        return data[this].real.has(saveFlyHeight)
    endmethod
endstruct

//==========================================
// GUMS Setters

// The setters cannot be a part of the struct, since they require setting values in the unit, and the
// unit is not saved within the struct.

function GUMSSetUnitFacing takes unit whichUnit, real newAngle returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    call SetUnitFacing(whichUnit, newAngle)
    
    if GetUnitAbilityLevel(whichUnit, 'Amov') == 0 then
        call GroupAddUnit(loopGroup, whichUnit)
        set data[GetHandleId(whichUnit)].real[TARGET_ANGLE] = ModuloReal(newAngle, 360)
    endif
endfunction

function GUMSSetUnitFlyHeight takes unit whichUnit, real newHeight returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    if UnitAddAbility(whichUnit, 'Amrf' ) then
        call UnitRemoveAbility(whichUnit, 'Amrf')
    endif
    
    call SetUnitFlyHeight( whichUnit, newHeight, 0)
    set SaveFlyHeight(GetHandleId(whichUnit)).height = newHeight
    
    if GetUnitAbilityLevel(whichUnit, 'Amov') == 0 then
        call GroupAddUnit(loopGroup, whichUnit)
    endif
endfunction

function GUMS_AddStructureFlightAbility takes unit structure returns nothing
    local real facing
    //! runtextmacro ASSERT("structure != null")
    //! runtextmacro ASSERT("IsUnitType(structure, UNIT_TYPE_STRUCTURE)")

    if not data[GetHandleId(structure)].has(TARGET_ANGLE)  then
        set facing = GetUnitFacing(structure)
        call UnitAddAbility(structure, 'DEDF' )
        call GUMSSetUnitFacing(structure, facing)
    else
        call UnitAddAbility(structure, 'DEDF' )
        call SetUnitFacingTimed(structure , data[GetHandleId(structure)].real[TARGET_ANGLE], 0)
        call SetUnitAnimation(structure, "stand")
    endif
endfunction

function GUMSSetStructureFlyHeight takes unit structure, real newHeight, boolean autoLand returns nothing
    //! runtextmacro ASSERT("structure != null")
    //! runtextmacro ASSERT("IsUnitType(structure, UNIT_TYPE_STRUCTURE)")
    if GetUnitFlyHeight(structure) < GUMS_MINIMUM_FLY_HEIGHT() and newHeight < GUMS_MINIMUM_FLY_HEIGHT() then  // 0.01 seems to be the minimum flying height
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
        call GUMS_AddStructureFlightAbility(structure)  // already adds unit to loopGroup
        call IssueImmediateOrder(structure, "unroot")
        set data[GetHandleId(structure)].boolean[STRUCTURE_HEIGHT] = true
        if autoLand then
            set data[GetHandleId(structure)].boolean[AUTO_LAND] = true
        endif
    endif
endfunction

//Set Scale
function GUMSSetUnitMatrixScale takes unit whichUnit, real scaleX, real scaleY, real scaleZ returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    call SetUnitScale(whichUnit, scaleX, scaleY, scaleZ)
    set data[GetHandleId(whichUnit)].real[SCALE] = scaleX
endfunction

function GUMSSetUnitScale takes unit whichUnit, real scale returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    call SetUnitScale(whichUnit, scale, scale, scale)
    set data[GetHandleId(whichUnit)].real[SCALE] = scale
endfunction

//Set Vertex Color
function GUMSSetUnitVertexColor takes unit whichUnit, real red, real green, real blue, real trans  returns nothing
    local integer intRed = R2I(2.55 * red + 0.5)
    local integer intGreen = R2I(2.55 * green + 0.5)
    local integer intBlue = R2I(2.55 * blue + 0.5)
    local integer intAlpha = R2I(2.55 * (100. - trans) + 0.5)
    //! runtextmacro ASSERT("whichUnit != null")
    
    call SetUnitVertexColor(whichUnit, intRed, intGreen, intBlue, intAlpha)
    set data[GetHandleId(whichUnit)][RED]   = intRed
    set data[GetHandleId(whichUnit)][GREEN] = intGreen
    set data[GetHandleId(whichUnit)][BLUE]  = intBlue
    set data[GetHandleId(whichUnit)][ALPHA] = intAlpha
endfunction

function GUMSSetUnitVertexColorInt takes unit whichUnit, integer red, integer green, integer blue, integer alpha returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    call SetUnitVertexColor(whichUnit, red, green, blue, alpha)
    set data[GetHandleId(whichUnit)][RED]   = red
    set data[GetHandleId(whichUnit)][GREEN] = green
    set data[GetHandleId(whichUnit)][BLUE]  = blue
    set data[GetHandleId(whichUnit)][ALPHA] = alpha
endfunction

//Set Player Color (why in hell can't this be retrieved with natives?!)
function GUMSSetUnitColor takes unit whichUnit, integer color returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    if color <= bj_MAX_PLAYER_SLOTS and color >= 1 then
        set data[GetHandleId(whichUnit)][COLOR] = color
        call SetUnitColor(whichUnit, ConvertPlayerColor(color-1))
    else
        call data[GetHandleId(whichUnit)].remove(COLOR)

        //! runtextmacro GUMS_Config_ResetColorFunc()
    endif
endfunction

//Set Animation Speed
function GUMSSetUnitAnimSpeed takes unit whichUnit, real speedMultiplier returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    call SetUnitTimeScale(whichUnit, speedMultiplier)
    set data[GetHandleId(whichUnit)].real[ASPEED] = speedMultiplier
endfunction

//Set Animation Tag
function GUMSAddUnitAnimationTag takes unit whichUnit, string whichTag returns nothing
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
endfunction

///////////////////////////
//These functions are used to work with unit names
//
//The unit's default proper name is saved in a Hashtable so it can be reset
///////////////////////////

function GUMSUnitHasCustomName takes integer unitHandle returns boolean
    //! runtextmacro ASSERT("unitHandle != 0")
    return data[unitHandle].string.has(NAME)
endfunction

function GUMSGetDefaultName takes integer unitHandle returns string
    //! runtextmacro ASSERT("unitHandle != 0")
    return data[unitHandle].string[NAME]
endfunction

function GUMSResetUnitName takes unit whichUnit returns nothing
    local integer unitHandle = GetHandleId(whichUnit)
    //! runtextmacro ASSERT("whichUnit != null")
    
    if GUMSUnitHasCustomName(unitHandle) then
        call UnitName_SetUnitName(whichUnit, GUMSGetDefaultName(unitHandle))
        call data[unitHandle].string.remove(NAME)
    endif
endfunction

function GUMSSetUnitName takes unit whichUnit, string name returns nothing
    //! runtextmacro ASSERT("whichUnit != null")
    if name != "" then
        if not GUMSUnitHasCustomName(GetHandleId(whichUnit)) then
            set data[GetHandleId(whichUnit)].string[NAME] = UnitName_GetUnitName(whichUnit)
        endif
        call UnitName_SetUnitName(whichUnit, GUMSConvertToCustomName(name))
    else
        call GUMSResetUnitName(whichUnit)
    endif
endfunction

function GUMSGetUnitName takes unit whichUnit returns string
    //! runtextmacro ASSERT("whichUnit != null")
    return GUMSConvertFromCustomName(UnitName_GetUnitName(whichUnit))
endfunction

//==========================================
// GUMS Copying Utilities

// Does not copy:
//    -Unit selectability
//    -Unit custom name

// Copies all GUMS values from one source unit to a target unit.
function GUMSCopyValues takes unit source, unit target returns nothing
    local real fangle = GetUnitFacing(source)
    local UnitVisuals sourceId = GetHandleId(source)
    //! runtextmacro ASSERT("source != null")
    //! runtextmacro ASSERT("target != null")
    
    if IsUnitType(target, UNIT_TYPE_STRUCTURE) then
        call GUMSSetStructureFlyHeight(target, GetUnitFlyHeight(source), GetUnitAbilityLevel(source, 'DEDF') == 0)
    else
        call GUMSSetUnitFlyHeight(target, GetUnitFlyHeight(source))
    endif
    
    if sourceId.hasScale() then
        call GUMSSetUnitScale(target, data[sourceId].real[SCALE])
    endif
    if sourceId.hasVertexColor(RED) then
        call GUMSSetUnitVertexColor(target, /*
                                */  data[sourceId][RED]/2.55, /*
                                */  data[sourceId][GREEN]/2.55, /*
                                */  data[sourceId][BLUE]/2.55, /*
                                */  (255 - data[sourceId][ALPHA])/2.55)
    endif
    if sourceId.hasColor() then
        call GUMSSetUnitColor(target, data[sourceId][COLOR])
    endif
    if sourceId.hasAnimSpeed() then
        call GUMSSetUnitAnimSpeed(target, data[sourceId].real[ASPEED])
    endif
    if sourceId.hasAnimTag() then
        call GUMSAddUnitAnimationTag(target, GUMSConvertTags(UnitVisualMods_TAGS_DECOMPRESS,data[sourceId].string[ATAG]))
    endif
endfunction

// Creates a new unit and copies all the GUMS values from the old unit to the newly created one.
// bj_lastCreatedUnit is set to the newly created unit.
// If the specified newType is nonpositive, then the created unit will have the same type as the copied one
function GUMSCopyUnit takes unit whichUnit, player owner, integer newType returns unit
    local real fangle = GetUnitFacing(whichUnit)
    local unit newUnit
    //! runtextmacro ASSERT("whichUnit != null")
    
    if newType < 1 then
        set newType = GetUnitTypeId(whichUnit)
    endif
    set newUnit = CreateUnit( owner, newType, GetUnitX(whichUnit), GetUnitY(whichUnit), fangle)
    
    call GUMSCopyValues(whichUnit, newUnit)
    
    set bj_lastCreatedUnit = newUnit
    set newUnit = null
    return bj_lastCreatedUnit
endfunction

function GUMSCopyUnitSameType takes unit whichUnit, player owner returns unit
    return GUMSCopyUnit(whichUnit, owner, 0)
endfunction

//==========================================
// GUMS Unit Selectability Utilities

function GUMSMakeUnitDragSelectable takes unit whichUnit returns nothing
    local integer unitId = GetHandleId(whichUnit)
    local integer selectionType = data[unitId][SELECT]
    //! runtextmacro ASSERT("whichUnit != null")

    if selectionType == GUMS_SELECTION_DRAG() then
        return //Unit is already drag-selectable, do nothing.
    endif
    
    if selectionType != GUMS_SELECTION_UNSELECTABLE() then //Check if unit is already unselectable.
        if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
            call UnitRemoveAbility(whichUnit,'Aloc')
            set data[unitId][SELECT] = GUMS_SELECTION_DRAG()
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

    if selectType == GUMS_SELECTION_UNSELECTABLE() or selectType == GUMS_SELECTION_LOCUST() then
        if data[unitId][SELECT] >= GUMS_SELECTION_UNSELECTABLE() then
            set data[unitId][SELECT] = selectType
            return //Unit is already unselectable, do nothing.
        endif

        if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
            call UnitRemoveAbility(whichUnit,'Aloc')
            set data[unitId][SELECT] = selectType
            call SetUnitInvulnerable(whichUnit, true)
        endif
    elseif selectType == GUMS_SELECTION_DRAG() then
        call GUMSMakeUnitDragSelectable(whichUnit)
    endif
endfunction

function GUMSMakeUnitUnSelectable takes unit whichUnit returns nothing
    call GUMSSetUnitSelectionType(whichUnit, GUMS_SELECTION_UNSELECTABLE())
endfunction

function GUMSMakeUnitLocust takes unit whichUnit returns nothing
    call GUMSSetUnitSelectionType(whichUnit, GUMS_SELECTION_LOCUST())
endfunction


//////////////////////////////////////////////////////
//End of GUMS
//////////////////////////////////////////////////////

function GUMSSetUnitVertexColorString takes unit whichUnit, string args, string separator returns nothing
    local integer cutToComma
    local real cRed
    local real cGreen
    local real cBlue
    local real cAlpha
    //! runtextmacro ASSERT("whichUnit != null")
    
    set cutToComma = CutToCharacter(args, separator)
    set cRed = S2R(CutToCommaResult(args, cutToComma))
    set args = CutToCommaShorten(args, cutToComma)
    set cutToComma = CutToCharacter(args, separator)
    set cGreen = S2R(CutToCommaResult(args, cutToComma))
    set args = CutToCommaShorten(args, cutToComma)
    set cutToComma = CutToCharacter(args, separator)
    set cBlue = S2R(CutToCommaResult(args, cutToComma))
    set args = CutToCommaShorten(args, cutToComma)
    set cutToComma = CutToCharacter(args, separator)
    set cAlpha = S2R(CutToCommaResult(args, cutToComma))
    set args = CutToCommaShorten(args, cutToComma)
    
    call GUMSSetUnitVertexColor(whichUnit, cRed, cGreen, cBlue, cAlpha)
endfunction

//==================================================================================================
//                                        Initialization
//==================================================================================================
// GUMS Flying Height and Facing Timer

private struct TimerData extends array
    //! runtextmacro TableStruct_NewHandleField("unit","unit")
    //! runtextmacro TableStruct_NewPrimitiveField("owner","integer")
    //! runtextmacro TableStruct_NewPrimitiveField("isSelected","boolean")
    
    static method get takes timer t returns thistype
        return GetHandleId(t)
    endmethod
    
    method destroy takes nothing returns nothing
        call .unitClear()
        call .ownerClear()
        call .isSelectedClear()
    endmethod
endstruct

globals
    private boolean hasStructureFly = false
endglobals

private function EnableAmov takes boolean flag returns nothing
    local integer i = 0
    loop
    exitwhen i >= bj_MAX_PLAYER_SLOTS
        call SetPlayerAbilityAvailable(Player(0), 'Amov', flag)
        set i = i + 1
    endloop
endfunction

private function onTimer3 takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local TimerData tData = TimerData.get(t)
    local unit u = tData.unit
    local player owner = Player(tData.owner)
    //! runtextmacro ASSERT("u != null")
    
    call UnitRemoveAbility(u, 'DEDF')

    if hasStructureFly then
        call EnableAmov(true)
        set hasStructureFly = false
    endif
    call SetUnitOwner(u, owner, false)
    if tData.isSelected then
        if GetLocalPlayer() == owner then
            call SelectUnit(u, true)
        endif
    endif
    
    call PauseTimer(t)
    call DestroyTimer(t)
    call tData.destroy()
    
    set t = null
    set u = null
endfunction

private function onTimer2 takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local unit u = TimerData.get(t).unit
    local player owner = GetOwningPlayer(u)
    //! runtextmacro ASSERT("u != null")
    
    // Here, we make sure that units below the building don't stop it from instantly rooting (they have to move away first)
    //call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(u), GetUnitY(u), 1000., Filter(function FilterHide))
    
    // More efficient than the method used above, but units below still move out of the way: 
    call SetUnitOwner(u, Player(bj_PLAYER_NEUTRAL_VICTIM), false)
    
    call IssuePointOrder(u, "root", GetUnitX(u), GetUnitY(u))
    call TimerStart(t, 0, false, function onTimer3)
    set TimerData.get(t).owner = GetPlayerId(owner)
    set TimerData.get(t).isSelected = IsUnitSelected(u, owner)
    
    set t = null
    set u = null
endfunction

//THIS FUNCTION IS USED TO SET FLYING HEIGHT AND FACING OF IMMOBILE UNITS (NO 'Amov')
function GUMSGroupFunction takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    local integer unitId = GetHandleId(enumUnit)
    local real face
    local boolean removeReal
    local timer t
    
    //! runtextmacro ASSERT("enumUnit != null")
    
    //Check if unit is having it's facing changed and apply values accordingly
    if not data[unitId].real.has(TARGET_ANGLE) then
        set face = GetUnitFacing(enumUnit)
        set removeReal = false
    else
        set face = data[unitId].real[TARGET_ANGLE]
        set removeReal = true
    endif
    
    //Move unit to it's own position to fix flying height and facing
    if not data[unitId].has(COUNTER) then
        set data[unitId][COUNTER] = 0
        call GUMS_RedrawUnit(enumUnit)
    elseif GetUnitFacing(enumUnit) < face - 0.001 or GetUnitFacing(enumUnit) > face + 0.001 then
        call GUMS_RedrawUnit(enumUnit)
    else
        call data[unitId].remove(COUNTER)
        if removeReal then //Not sure if removing unexisting stuff can cause crashes, but might as well avoid it
            call data[unitId].real.remove(TARGET_ANGLE)
        endif
        call GUMS_RedrawUnit(enumUnit)
        
        if data[unitId].boolean.has(STRUCTURE_HEIGHT) then
            call data[unitId].boolean.remove(STRUCTURE_HEIGHT)
            if data[unitId].boolean.has(AUTO_LAND) then
                set t = CreateTimer()
                set TimerData.get(t).unit = enumUnit
                call TimerStart(t, 0, false, function onTimer2)
                call SetUnitAnimation(enumUnit, "stand")
                set t = null
                
                if not hasStructureFly then
                    call EnableAmov(false)
                    set hasStructureFly = true
                endif
            endif
            call GroupRemoveUnit(loopGroup, enumUnit)
        else
            if IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE) and GetUnitFlyHeight(enumUnit) > GUMS_MINIMUM_FLY_HEIGHT() then
                debug call BJDebugMsg(R2S(GetUnitFlyHeight(enumUnit)*1000))
                call GUMSSetStructureFlyHeight(enumUnit,GetUnitFlyHeight(enumUnit), data[unitId].boolean.has(AUTO_LAND))
            else 
                call GroupRemoveUnit(loopGroup, enumUnit)
            endif
        endif
    endif

    set enumUnit = null
endfunction


//THIS FUNCTION IS RUN ON A TIMER THAT CALLS THE FUNCTION ABOVE
function GUMSTimerFunction takes nothing returns nothing
    if unitHasBeenRemoved then
        call GroupRefresh(loopGroup)
        set unitHasBeenRemoved = true
    endif
    call ForGroup(loopGroup, function GUMSGroupFunction)
endfunction

function GUMSOnUpgradeHandler takes unit trigU returns nothing
        local SaveFlyHeight unitData = GetHandleId(trigU)
        local real height
        //! runtextmacro ASSERT("trigU != null")
        
        
        if unitData.hasHeight() and unitData.height > GUMS_MINIMUM_FLY_HEIGHT() then
            set height = unitData.height
        
            call GUMSCopyValues(trigU, trigU)

            call GUMSSetUnitFlyHeight(trigU, height)
        else
            call GUMSCopyValues(trigU, trigU)
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
        
        call TimerStart( t, 1/8., true, function GUMSTimerFunction)
    
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

//==================================================================================================
//                                       Wrappers
//==================================================================================================

function GUMS_HaveSavedScale takes unit whichUnit returns boolean
    return UnitVisuals.get(whichUnit).hasScale()
endfunction

function GUMS_HaveSavedVertexColor takes unit whichUnit, integer r1b2g3a4 returns boolean
    return UnitVisuals.get(whichUnit).hasVertexColor(r1b2g3a4)
endfunction

function GUMS_HaveSavedColor takes unit whichUnit returns boolean
    return UnitVisuals.get(whichUnit).hasColor()
endfunction

function GUMS_HaveSavedAnimSpeed takes unit whichUnit returns boolean
    return UnitVisuals.get(whichUnit).hasAnimSpeed()
endfunction

function GUMS_HaveSavedAnimationTag takes unit whichUnit returns boolean
    return UnitVisuals.get(whichUnit).hasAnimTag()
endfunction 

function GUMSGetUnitScale takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getScale()
endfunction

function GUMSGetUnitVertexColor takes unit whichUnit, integer r1g2b3a4  returns string
    return UnitVisuals.get(whichUnit).getVertexColor(r1g2b3a4)
endfunction

function GUMSGetUnitColor takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getColor()
endfunction

function GUMSGetUnitAnimSpeed takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getAnimSpeed()
endfunction

function GUMSGetUnitAnimationTag takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getAnimTag()
endfunction
endlibrary