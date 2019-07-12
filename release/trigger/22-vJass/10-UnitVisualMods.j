library UnitVisualMods requires CutToComma, GroupTools, optional UnitVisualModsDefaults/*

    */ /*optional*/ HashtableWrapper,  /* Required to initialize a hashtable.
    
    */ optional Table, /*  Required if a hashtable is not intialized.
    
    */ optional ConstTable  // If present, then ConstHashTable is used instead of HashTable.
//////////////////////////////////////////////////////
//Guhun's Unit Modification System v1.3.1


//Hashtable values:

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
    private hashtable hashTable = null
    private group loopGroup = CreateGroup()
    
    private constant boolean INIT_HASHTABLE = true // DOES NOT WORK YET! NEED TO CHANGE FUNCTIONS THAT USE HASGTABLE API
    
    private string allTags = "gold lumber work flesh ready one two throw slam large medium small victory alternate morph defend swim spin fast upgrade first second third fourth fifth"
endglobals

//==================================================================================================
//                                     Hashtable Declaration
//==================================================================================================

// Never use keyword to declare the hashtable at the bottom of the library. That generates callers
// that are unnecessary.

static if LIBRARY_HashtableWrapper and INIT_HASHTABLE then
    //! runtextmacro optional DeclareParentHashtableWrapperModule("hashTable","true", "data","private")
else
    //! runtextmacro DeclareHashTableWrapperModule("data")
endif

private struct data extends array
    static if LIBRARY_HashtableWrapper and INIT_HASHTABLE then
        implement optional data_ParentHashtableWrapper
    else
        implement data_HashTableWrapper
    endif
endstruct

//==================================================================================================
//                                        Source Code
//==================================================================================================

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

//==========================================
//CONSTANTS FOR HASHTABLE ADDRESSES (Unit Handle Ids)
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



function GUMS_GetUnitSelectionType takes unit whichUnit returns integer
    return LoadInteger(hashTable, GetHandleId(whichUnit), SELECT)
endfunction
//==========================================
//GUMS SELECTION TYPE CONSTANTS
constant function GUMS_SELECTION_DEFAULT takes nothing returns integer
    return 0
endfunction

constant function GUMS_SELECTION_DRAG takes nothing returns integer
    return 1
endfunction

constant function GUMS_SELECTION_UNSELECTABLE takes nothing returns integer
    return 2
endfunction
//==========================================
constant function GUMS_MINIMUM_FLY_HEIGHT takes nothing returns real
    return 0.02
endfunction

//==========================================
// GUMS Animation Tag Utilities
//! textmacro GUMS_RegisterTag takes FULL, COMPRESSED
    set data_Child(TAGS_COMPRESS).string[StringHash("$FULL$")] = "$COMPRESSED$"
    set data_Child(TAGS_DECOMPRESS).string[StringHash("$COMPRESSED$")] = "$FULL$"
//! endtextmacro

function GUMSConvertTags takes data_Child convertType, string whichStr returns string
    local string result = ""
    local integer cutToComma = CutToCharacter(whichStr, " ")
    local integer stringHash
    
    loop
        set stringHash = StringHash((SubString(whichStr, 0, cutToComma)))
        if convertType.string.has(stringHash) then
            set result = result + convertType.string[stringHash] + " "
        else
            set result = result + whichStr + " "
            // call DisplayTextToPlayer(WHO?,0,0, whichStr + " is not a known tag. If you think this is wrong, please report it")
        endif
        
        exitwhen cutToComma >= StringLength(whichStr)
        set whichStr = SubString(whichStr, cutToComma + 1, StringLength(whichStr) + 1)
        set cutToComma = CutToCharacter(whichStr, " ")
    endloop
    return SubString(result,0,StringLength(result) - 1)
endfunction
//==========================================

//==========================================
//==========================================

//==========================================
// GUMS API
//==========================================

// Call this when a unit is removed from the game.
function GUMSClearUnitData takes unit whichUnit returns nothing
    call GroupRemoveUnit(loopGroup, whichUnit)
    call FlushChildHashtable(hashTable, GetHandleId(whichUnit))
endfunction

//==========================================
// GUMS Getters

// Contains the Raw values of each UnitVisuals struct. Returned by the .raw method operator.
private struct UnitVisualsRaw extends array
    static if not INIT_HASHTABLE  and LIBRARY_HashtableWrapper then
        private method operator values takes nothing returns Table
            return data[this]
        endmethod
    else
        private method operator values takes nothing returns data_Child
            return data[this]
        endmethod
    endif
    
    method getScale takes nothing returns real
        return (.values.real[SCALE])
    endmethod
    
    method getVertexColor takes integer r1g2b3a4 returns integer
        return (.values[r1g2b3a4])
    endmethod
    
    method getVertexRed takes nothing returns integer
        return .getVertexColor(RED)
    endmethod
    
    method getVertexGreen takes nothing returns integer
        return .getVertexColor(GREEN)
    endmethod
    
    method getVertexBlue takes nothing returns integer
        return .getVertexColor(BLUE)
    endmethod
    
    method getVertexAlpha takes nothing returns integer
        return .getVertexColor(ALPHA)
    endmethod
    
    method getColor takes nothing returns integer
        return (.values[COLOR])
    endmethod
    
    method getAnimSpeed takes nothing returns real
        return (values.real[ASPEED])
    endmethod
    
    method getAnimTag takes nothing returns string
        return .values.string[ATAG]
    endmethod
endstruct

// Contains getters for all UnitVisualMods-related data. These getters return strings, not raw values.
struct UnitVisuals extends array
    
    static if not INIT_HASHTABLE  and LIBRARY_HashtableWrapper then
        private method operator values takes nothing returns Table
            return data[this]
        endmethod
    else
        private method operator values takes nothing returns data_Child
            return data[this]
        endmethod
    endif
    
    method operator raw takes nothing returns UnitVisualsRaw
        return this
    endmethod
    
    static method get takes unit whichUnit returns UnitVisuals
        return GetHandleId(whichUnit)
    endmethod
    
    method hasScale takes nothing returns boolean
        return .values.real.has(SCALE)
    endmethod
    
    method hasVertexColor takes integer whichChannel returns boolean
        return .values.has(whichChannel)
    endmethod
    
    method hasColor takes nothing returns boolean
        return .values.has(COLOR)
    endmethod
    
    method hasAnimSpeed takes nothing returns boolean
        return .values.real.has(ASPEED)
    endmethod
    
    method hasAnimTag takes nothing returns boolean
        return .values.string.has(ATAG)
    endmethod
    
    //THESE FUNCTIONS RETRIEVE THE SAVED VALUES IN THE HASHTABLE OR RETURN "D" IF THERE IS NO SAVED VALUE
    method getScale takes nothing returns string
        if .hasScale() then
            return R2S(.values.real[SCALE])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getVertexColor takes integer r1g2b3a4 returns string
        if .hasVertexColor(r1g2b3a4) then
            return I2S(.values[r1g2b3a4])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getVertexRed takes nothing returns string
        return .getVertexColor(RED)
    endmethod
    
    method getVertexGreen takes nothing returns string
        return .getVertexColor(GREEN)
    endmethod
    
    method getVertexBlue takes nothing returns string
        return .getVertexColor(BLUE)
    endmethod
    
    method getVertexAlpha takes nothing returns string
        return .getVertexColor(ALPHA)
    endmethod
    
    method getColor takes nothing returns string
        if .hasColor() then
            return I2S(.values[COLOR])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getAnimSpeed takes nothing returns string
        if .hasAnimSpeed() then
            return R2S(values.real[ASPEED])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getAnimTag takes nothing returns string
        if .hasAnimTag() then
            return .values.string[ATAG]
        else
            return "D" //D stands for default
        endif
    endmethod
endstruct

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
    call SetUnitFacing(whichUnit, newAngle)
    
    if GetUnitAbilityLevel(whichUnit, 'Amov') == 0 then
        call GroupAddUnit(loopGroup, whichUnit)
        call SaveReal(hashTable, GetHandleId(whichUnit), TARGET_ANGLE, ModuloReal(newAngle, 360))
    endif
endfunction

function GUMSSetUnitFlyHeight takes unit whichUnit, real newHeight returns nothing
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

    if not HaveSavedReal(hashTable, GetHandleId(structure) , TARGET_ANGLE)  then
        set facing = GetUnitFacing(structure)
        call UnitAddAbility(structure, 'DEDF' )
        call GUMSSetUnitFacing(structure, facing)
    else
        call UnitAddAbility(structure, 'DEDF' )
        call SetUnitFacingTimed(structure , LoadReal(hashTable, GetHandleId(structure) , TARGET_ANGLE), 0)
        call SetUnitAnimation(structure, "stand")
    endif
endfunction

function GUMSSetStructureFlyHeight takes unit structure, real newHeight, boolean autoLand returns nothing
    if GetUnitFlyHeight(structure) < GUMS_MINIMUM_FLY_HEIGHT() and newHeight < GUMS_MINIMUM_FLY_HEIGHT() then  // 0.01 seems to be the minimum flying height
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
function GUMSSetUnitScale takes unit whichUnit, real scale returns nothing
    call SetUnitScale(whichUnit, scale, scale, scale)
    call SaveReal(hashTable, GetHandleId(whichUnit), SCALE, scale)
endfunction

//Set Vertex Color
function GUMSSetUnitVertexColor takes unit whichUnit, real red, real green, real blue, real trans  returns nothing
    local integer intRed = R2I(2.55 * red + 0.5)
    local integer intGreen = R2I(2.55 * green + 0.5)
    local integer intBlue = R2I(2.55 * blue + 0.5)
    local integer intAlpha = R2I(2.55 * (100. - trans) + 0.5)
    
    call SetUnitVertexColor(whichUnit, intRed, intGreen, intBlue, intAlpha)
    call SaveInteger(hashTable, GetHandleId(whichUnit), RED, intRed)
    call SaveInteger(hashTable, GetHandleId(whichUnit), GREEN, intGreen)
    call SaveInteger(hashTable, GetHandleId(whichUnit), BLUE, intBlue)
    call SaveInteger(hashTable, GetHandleId(whichUnit), ALPHA, intAlpha)
endfunction

//Set Player Color (why in hell can't this be retrieved with natives?!)
function GUMSSetUnitColor takes unit whichUnit, integer color returns nothing
    if color <= bj_MAX_PLAYER_SLOTS and color >= 1 then
        call SaveInteger(hashTable, GetHandleId(whichUnit), COLOR, color)
        call SetUnitColor(whichUnit, ConvertPlayerColor(color-1))
    else
        call RemoveSavedInteger(hashTable, GetHandleId(whichUnit), COLOR)

        //! runtextmacro GUMS_Config_ResetColorFunc()
    endif
endfunction

//Set Animation Speed
function GUMSSetUnitAnimSpeed takes unit whichUnit, real speedMultiplier returns nothing
    call SetUnitTimeScale(whichUnit, speedMultiplier)
    call SaveReal(hashTable, GetHandleId(whichUnit), ASPEED, speedMultiplier)
endfunction

//Set Animation Tag
function GUMSAddUnitAnimationTag takes unit whichUnit, string whichTag returns nothing
    local UnitVisuals unitId = GetHandleId(whichUnit)
    
    if unitId.hasAnimTag() then
        call AddUnitAnimationProperties(whichUnit, GUMSConvertTags(TAGS_DECOMPRESS, unitId.raw.getAnimTag()), false)
    else
        call AddUnitAnimationProperties(whichUnit, allTags, false)
    endif
    
    if whichTag != "" then
        call AddUnitAnimationProperties(whichUnit, whichTag, true)
        set whichTag = GUMSConvertTags(TAGS_COMPRESS, whichTag)
        call SaveStr(hashTable, unitId, ATAG, whichTag)
        debug call BJDebugMsg("Setting tag: " + whichTag)
        
    else
        call RemoveSavedString(hashTable, unitId, ATAG)
    endif
endfunction

///////////////////////////
//These functions are used to work with unit names
//
//The unit's default proper name is saved in a Hashtable so it can be reset
///////////////////////////

function GUMSUnitHasCustomName takes integer unitHandle returns boolean
    return HaveSavedString(hashTable, unitHandle , NAME)
endfunction

function GUMSGetDefaultName takes integer unitHandle returns string
    return LoadStr(hashTable, unitHandle, NAME)
endfunction

function GUMSResetUnitName takes unit whichUnit returns nothing
    local integer unitHandle = GetHandleId(whichUnit)
    
    if GUMSUnitHasCustomName(unitHandle) then
        if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
            call BlzSetHeroProperName(whichUnit, GUMSGetDefaultName(unitHandle))
        else
            call BlzSetUnitName(whichUnit, GUMSGetDefaultName(unitHandle))
        endif
    
        call RemoveSavedString(hashTable, unitHandle, NAME)
    endif
endfunction

function GUMSSetUnitName takes unit whichUnit, string name returns nothing
    if name != "" then
        if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
            if not GUMSUnitHasCustomName(GetHandleId(whichUnit)) then
                call SaveStr(hashTable, GetHandleId(whichUnit), NAME, GetHeroProperName(whichUnit))
            endif
            call BlzSetHeroProperName(whichUnit, GUMSConvertToCustomName(name))
        else
            if not GUMSUnitHasCustomName(GetHandleId(whichUnit)) then
                call SaveStr(hashTable, GetHandleId(whichUnit), NAME, GetUnitName(whichUnit))
            endif
            call BlzSetUnitName(whichUnit, GUMSConvertToCustomName(name))
        endif
    else
        call GUMSResetUnitName(whichUnit)
    endif
endfunction

function GUMSGetUnitName takes unit whichUnit returns string
    if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
        return GUMSConvertFromCustomName(GetHeroProperName(whichUnit))
    else
        return GUMSConvertFromCustomName(GetUnitName(whichUnit))  
    endif
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
        call GUMSAddUnitAnimationTag(target, data[sourceId].string[ATAG])
    endif
endfunction

// Creates a new unit and copies all the GUMS values from the old unit to the newly created one.
// bj_lastCreatedUnit is set to the newly created unit.
// If the specified newType is nonpositive, then the created unit will have the same type as the copied one
function GUMSCopyUnit takes unit whichUnit, player owner, integer newType returns unit
    local real fangle = GetUnitFacing(whichUnit)
    local unit newUnit
    
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

function GUMSMakeUnitUnSelectable takes unit whichUnit returns nothing
    local integer unitId = GetHandleId(whichUnit)
    local integer selectionType = LoadInteger(hashTable, unitId, SELECT)

    if selectionType == GUMS_SELECTION_UNSELECTABLE() then
        return //Unit is already unselectable, do nothing.
    endif

    if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
        call UnitRemoveAbility(whichUnit,'Aloc')
        call SaveInteger(hashTable, unitId, SELECT, GUMS_SELECTION_UNSELECTABLE())
        call SetUnitInvulnerable(whichUnit, true)
    endif
endfunction

function GUMSMakeUnitDragSelectable takes unit whichUnit returns nothing
    local integer unitId = GetHandleId(whichUnit)
    local integer selectionType = LoadInteger(hashTable, unitId, SELECT)

    if selectionType == GUMS_SELECTION_DRAG() then
        return //Unit is already drag-selectable, do nothing.
    endif
    
    if selectionType != GUMS_SELECTION_UNSELECTABLE() then //Check if unit is already unselectable.
        if UnitAddAbility(whichUnit,'Aloc') then //Do nothing is unit has locust by default.
            call UnitRemoveAbility(whichUnit,'Aloc')
            call SaveInteger(hashTable, unitId, SELECT, GUMS_SELECTION_DRAG())
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

function GUMSMakeUnitSelectable takes unit whichUnit returns nothing
    local integer unitId = GetHandleId(whichUnit)
    local integer selectionType = LoadInteger(hashTable, unitId, SELECT)
    
    if selectionType == GUMS_SELECTION_DEFAULT() then
        return //Unit has not been give a special selection type, do nothing.
    endif

    call ShowUnit(whichUnit, false) //Hide old unit.
    call GUMSCopyUnit(whichUnit, GetOwningPlayer(whichUnit), GUMS_SELECTION_DEFAULT()) //Create fresh copy that is selectable.
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
    
    static method get takes timer t returns thistype
        return GetHandleId(t)
    endmethod
    
    method destroy takes nothing returns nothing
        call .unitClear()
    endmethod
endstruct

globals
    private group hiddenGrp = CreateGroup()
endglobals

private function ForGroupUnhide takes nothing returns nothing
    // call ShowUnit(GetEnumUnit(), true)
    call BlzUnitDisableAbility(GetEnumUnit(), 'Amov', false, false)
endfunction

private function onTimer3 takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local TimerData tData = TimerData.get(t)
    local unit u = tData.unit
    
    call UnitRemoveAbility(u, 'DEDF')
    
    call ForGroup(hiddenGrp, function ForGroupUnhide)
    call GroupClear(hiddenGrp)
    
    call PauseTimer(t)
    call DestroyTimer(t)
    call tData.destroy()
    
    set t = null
    set u = null
endfunction

private function FilterHide takes nothing returns boolean
    local unit filterU = GetFilterUnit()
    if GetUnitAbilityLevel(filterU, 'Amov') > 0 then
        //call ShowUnit(filterU, false)
        call BlzUnitDisableAbility(filterU, 'Amov', true, false)
        call GroupAddUnit(hiddenGrp, filterU)
    endif
    set filterU = null
    return false
endfunction

private function onTimer2 takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local unit u = TimerData.get(t).unit
    
    // Here, we make sure that units below the building don't stop it from instantly rooting (they have to move away first)
    call GroupEnumUnitsInRange(ENUM_GROUP, GetUnitX(u), GetUnitY(u), 1000., Filter(function FilterHide))
    
    // More efficient then the method used above, but units below still move out of the way: 
    // call SetUnitOwner(u, Player(bj_PLAYER_NEUTRAL_VICTIM), false)
    
    call IssuePointOrder(u, "root", GetUnitX(u), GetUnitY(u))
    call TimerStart(t, 0, false, function onTimer3)
    
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
    
    debug call BJDebugMsg(GetUnitName(enumUnit))
    
    //Check if unit is having it's facing changed and apply values accordingly
    if not HaveSavedReal(hashTable, unitId, TARGET_ANGLE) then
        set face = GetUnitFacing(enumUnit)
        set removeReal = false
    else
        set face = LoadReal(hashTable, unitId, TARGET_ANGLE)
        set removeReal = true
    endif
    
    //Move unit to it's own position to fix flying height and facing
    if not HaveSavedInteger(hashTable, unitId, COUNTER) then
        call SaveInteger(hashTable, unitId, COUNTER, 0)
        call SetUnitPosition(enumUnit, GetUnitX(enumUnit), GetUnitY(enumUnit))
    elseif GetUnitFacing(enumUnit) < face - 0.001 or GetUnitFacing(enumUnit) > face + 0.001 then
        call SetUnitPosition(enumUnit, GetUnitX(enumUnit), GetUnitY(enumUnit))
    else
        call RemoveSavedInteger(hashTable, unitId, COUNTER)
        if removeReal then //Not sure if removing unexisting stuff can cause crashes, but might as well avoid it
            call RemoveSavedReal(hashTable, unitId, TARGET_ANGLE)
        endif
        call SetUnitPosition(enumUnit, GetUnitX(enumUnit), GetUnitY(enumUnit))
        
        if data[unitId].boolean.has(STRUCTURE_HEIGHT) then
            call data[unitId].boolean.remove(STRUCTURE_HEIGHT)
            if data[unitId].boolean.has(AUTO_LAND) then
                set t = CreateTimer()
                set TimerData.get(t).unit = enumUnit
                call TimerStart(t, 0, false, function onTimer2)
                call SetUnitAnimation(enumUnit, "stand")
                set t = null
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
    call ForGroup(loopGroup, function GUMSGroupFunction)
endfunction



// When a unit cancels of finishes an upgrade, reapply its Visual modifications.
private module InitModule


    private static method onUpgradeHandler takes nothing returns nothing
        local unit trigU = GetTriggerUnit()
        local SaveFlyHeight unitData = GetHandleId(trigU)
        local real height
        
        
        if unitData.hasHeight() and unitData.height > GUMS_MINIMUM_FLY_HEIGHT() then
            set height = unitData.height
        
            call GUMSCopyValues(trigU, trigU)

            call GUMSSetUnitFlyHeight(trigU, height)
        else
            call GUMSCopyValues(trigU, trigU)
        endif
        
        set trigU = null
    endmethod


    private static method onInit takes nothing returns nothing
        local trigger fixUpgrades = CreateTrigger()
        local integer i
        local timer t = CreateTimer()
        
        call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_CANCEL )
        call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_FINISH )
        call TriggerAddAction( fixUpgrades, function thistype.onUpgradeHandler )
        
        static if INIT_HASHTABLE /*and LIBRARY_HashtableWrapper */ then
            set hashTable = InitHashtable()
        endif
        
        call TimerStart( t, 0.1, true, function GUMSTimerFunction)
    
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
        //! runtextmacro GUMS_RegisterTag("morph", "m")
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
    return HaveSavedReal(hashTable, GetHandleId(whichUnit), SCALE)
endfunction

function GUMS_HaveSavedVertexColor takes unit whichUnit, integer r1b2g3a4 returns boolean
    return HaveSavedInteger(hashTable, GetHandleId(whichUnit), r1b2g3a4)
endfunction

function GUMS_HaveSavedColor takes unit whichUnit returns boolean
    return HaveSavedInteger(hashTable, GetHandleId(whichUnit), COLOR)
endfunction

function GUMS_HaveSavedAnimSpeed takes unit whichUnit returns boolean
    return HaveSavedReal(hashTable, GetHandleId(whichUnit), ASPEED)
endfunction

function GUMS_HaveSavedAnimationTag takes unit whichUnit returns boolean
    return HaveSavedString(hashTable, GetHandleId(whichUnit), ATAG)
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

//==================================================================================================
// Include this so it is declared even if HashtableWrapper library is not present
//! textmacro_once DeclareHashTableWrapperModule takes NAME

    module $NAME$_HashTableWrapper
        private static key table
        
        static if LIBRARY_ConstTable then
            static method operator [] takes integer index returns Table
                return ConstHashTable(table)[index]
            endmethod
            
            static method remove takes integer index returns nothing
                call ConstHashTable(table).remove(index)
            endmethod
            
            static method operator ConstHashTable takes nothing returns ConstHashTable
                return table
            endmethod
        else
            static method operator [] takes integer index returns Table
                return HashTable(table)[index]
            endmethod
            
            static method remove takes integer index returns nothing
                call HashTable(table).remove(index)
            endmethod
            
            static method operator HashTable takes nothing returns HashTable
                return table
            endmethod
        endif
    endmodule
//! endtextmacro
endlibrary