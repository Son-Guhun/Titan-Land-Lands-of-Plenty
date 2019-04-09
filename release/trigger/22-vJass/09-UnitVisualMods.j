library UnitVisualMods initializer onInit requires CutToComma, /*

    */ /*optional*/ HashtableWrapper,  /* Required to initialize a hashtable.
    
    */ optional Table, /*  Required if a hashtable is not intialized.
    
    */ optional ConstTable  // If present, then ConstHashTable is used instead of HashTable.
//////////////////////////////////////////////////////
//Guhun's Unit Modification System v1.31


//Hashtable values:
// -2  -> Intended angle for the unit to reach in the GroupFunction
// -1  -> temporary integer to count how many times a  unit has been looped through in the GroupFunction

//////////////////////////////////////////////////////
// CONFIGURATION

// This function specifies what should be done to a unit when an argument which is not a valid
// player number (1 <= n <= bj_MAX_PLAYERS) is passed to GUMSSetUnitColor. The default behaviour is
// to set the color of the unit to the color of the owning player.

// NOTE: Hashtable data is automatically cleared when a non-player number argument is passed.
// You can reference a whichUnit variable. Do not alter this variable.
//! textmacro GUMS_Config_ResetColorFunc
    // DEFAULT
    //call SetUnitColor(whichUnit, GetPlayerColor(GetOwningPlayer(whichUnit)))
    
    // LOP
    call SetUnitColor(whichUnit, I2PC[udg_System_PlayerColor[GetPlayerId(GetOwningPlayer(whichUnit))+1]])
//! endtextmacro


globals
    private playercolor array I2PC  // can't save playercolor to hashtables
    private hashtable hashTable = null
    private group loopGroup = CreateGroup()
    
    private constant boolean INIT_HASHTABLE = true // DOES NOT WORK YET! NEED TO CHANGE FUNCTIONS THAT USE HASGTABLE API
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

struct TerrainType2Id extends array
    private static constant integer KEY = -2
    
    static method operator[] takes integer key returns integer
        return data[KEY][key]
    endmethod
    
    static method operator[]= takes integer key, integer value returns nothing
        set data[KEY][key] = value
    endmethod

endstruct

//==================================================================================================
//                                        Source Code
//==================================================================================================

function GUMS_I2PlayerColor takes integer i returns playercolor
    return I2PC[i]
endfunction

function GUMS_AddStructureFlightAbility takes unit structure returns nothing
    local real facing

    if not HaveSavedReal(hashTable, GetHandleId(structure) , -2)  then
        set facing = GetUnitFacing(structure)
        call SaveReal(hashTable, GetHandleId(structure), -2, facing)
        call UnitAddAbility(structure, 'DEDF' )
        call SetUnitFacingTimed(structure, facing, 0 )
        call GroupAddUnit(loopGroup, structure)
    else
        call UnitAddAbility(structure, 'DEDF' )
        call SetUnitFacingTimed(structure , LoadReal(hashTable, GetHandleId(structure) , -2), 0)
    endif
endfunction

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
//CONSTANT FUNCTIONS FOR HASHTABLE ADDRESSES
globals
    private constant integer SCALE  = 0
    private constant integer RED    = 1
    private constant integer GREEN  = 2
    private constant integer BLUE   = 3
    private constant integer ALPHA  = 4
    private constant integer COLOR  = 5
    private constant integer ASPEED = 6
    private constant integer ATAG   = 7
    private constant integer SELECT = 8
    private constant integer NAME   = 9

endglobals

function GUMS_GetUnitSelectionType takes unit whichUnit returns integer
    return LoadInteger(hashTable, GetHandleId(whichUnit), SELECT)
endfunction

function GUMS_GetTerrainTileIndex takes integer terrainType returns integer
    return TerrainType2Id[terrainType]
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

//==========================================
// GUMS Animation Tag Utilities
function GUMSTagDict takes string whichStr returns string
    set whichStr = StringCase(whichStr, false)
    
    if whichStr == "gold" then
        return "g"
    endif
    if whichStr == "g" then
        return "gold"
    endif
    
    if whichStr == "lumber" then
        return "l"
    endif
    if whichStr == "l" then
        return "lumber"
    endif
    
    if whichStr == "alternate" then
        return "a"
    endif
    if whichStr == "a" then
        return "alternate"
    endif
    
    if whichStr == "swim" then
        return "s"
    endif
    if whichStr == "s" then
        return "swim"
    endif
    
    if whichStr == "upgrade" then
        return "u"
    endif
    if whichStr == "u" then
        return "upgrade"
    endif
    
    if whichStr == "defend" then
        return "d"
    endif
    if whichStr == "d" then
        return "defend"
    endif
    
    if whichStr == "work" then
        return "w"
    endif
    if whichStr == "w" then
        return "work"
    endif
    
    if whichStr == "first" then
        return "n1"
    endif
    if whichStr == "second" then
        return "n2"
    endif
    if whichStr == "third" then
        return "n3"
    endif
    if whichStr == "fourth" then
        return "n4"
    endif
    if whichStr == "fifth" then
        return "n5"
    endif
    
    if whichStr == "n1" then
        return "first"
    endif
    if whichStr == "n2" then
        return "second"
    endif
    if whichStr == "n3" then
        return "third"
    endif
    if whichStr == "n4" then
        return "fourth"
    endif
    if whichStr == "n5" then
        return "fifth"
    endif
    
    return whichStr
endfunction

function GUMSConvertTags takes string whichStr returns string
    local string result = ""
    local integer cutToComma = -1
    loop
    exitwhen cutToComma == 0
        //call BJDebugMsg("Here:" + whichStr + "hello")
        set cutToComma = CutToCharacter(whichStr, " ")
        set result = result + GUMSTagDict(SubString(whichStr, 0, cutToComma)) + " "
        set whichStr = SubString(whichStr, cutToComma + 1, StringLength(whichStr) + 1)
    endloop
    return SubString(result,0,StringLength(result) - 1)
endfunction
//==========================================

//==========================================
// GUMS Flying Height and Facing Timer

//THIS FUNCTION IS USED TO SET FLYING HEIGHT AND FACING OF IMMOBILE UNITS (NO 'Amov')
function GUMSGroupFunction takes nothing returns nothing
    local unit enumUnit = GetEnumUnit()
    local integer unitId = GetHandleId(enumUnit)
    local real face
    local boolean removeReal
    
    debug call BJDebugMsg(GetUnitName(enumUnit))
    
    //Check if unit is having it's facing changed and apply values accordingly
    if not HaveSavedReal(hashTable, unitId, -2) then
        set face = GetUnitFacing(enumUnit)
        set removeReal = false
    else
        set face = LoadReal(hashTable, unitId, -2)
        set removeReal = true
    endif
    
    //Move unit to it's own position to fix flying height and facing
    if not HaveSavedInteger(hashTable, unitId, -1) then
        call SaveInteger(hashTable, unitId, -1, 0)
        call SetUnitPosition(enumUnit, GetUnitX(enumUnit), GetUnitY(enumUnit))
    elseif GetUnitFacing(enumUnit) < face - 0.001 or GetUnitFacing(enumUnit) > face + 0.001 then
        call SetUnitPosition(enumUnit, GetUnitX(enumUnit), GetUnitY(enumUnit))
    else
        call RemoveSavedInteger(hashTable, unitId, -1)
        if removeReal then //Not sure if removing unexisting stuff can cause crashes, but might as well avoid it
            call RemoveSavedReal(hashTable, unitId, -2)
        endif
        call GroupRemoveUnit(loopGroup, enumUnit)
        call SetUnitPosition(enumUnit, GetUnitX(enumUnit), GetUnitY(enumUnit))
    endif

    set enumUnit = null
endfunction

//THIS FUNCTION IS RUN ON A TIMER THAT CALLS THE FUNCTION ABOVE
function GUMSTimerFunction takes nothing returns nothing
    call ForGroup(loopGroup, function GUMSGroupFunction)
endfunction
//==========================================

//==========================================
// GUMS API
//==========================================

function GUMSClearUnitData takes unit whichUnit returns nothing
    call GroupRemoveUnit(loopGroup, whichUnit)
    call FlushChildHashtable(hashTable, GetHandleId(whichUnit))
endfunction

//==========================================
// GUMS Setters

//Set Scale
function GUMSSetUnitScale takes unit whichUnit, real scale returns nothing
    call SetUnitScale(whichUnit, scale, scale, scale)
    call SaveReal(hashTable, GetHandleId(whichUnit), SCALE, scale)
endfunction

//Set Vertex Color
function GUMSSetUnitVertexColor takes unit whichUnit, real red, real green, real blue, real trans  returns nothing
    local integer intRed = R2I(2.55 * red)
    local integer intGreen = R2I(2.55 * green)
    local integer intBlue = R2I(2.55 * blue)
    local integer intAlpha = R2I(2.55 * (100. - trans))
    
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
        call SetUnitColor(whichUnit, I2PC[color])
    else
        call RemoveSavedInteger(hashTable, GetHandleId(whichUnit), COLOR)
        //! novjass
        call GUMS_Config_ResetColorFunc(whichUnit)
        //! endnovjass
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
    local integer unitId = GetHandleId(whichUnit)
    local string oldTag = GUMSConvertTags(LoadStr(hashTable, unitId, ATAG))
    call RemoveSavedString(hashTable, unitId, ATAG)
    call AddUnitAnimationProperties(whichUnit, oldTag, false)
    if whichTag != "" then
        
        call AddUnitAnimationProperties(whichUnit, whichTag, true)
        set whichTag = GUMSConvertTags(whichTag)
        //call BJDebugMsg(whichTag)
        call SaveStr(hashTable, unitId, ATAG, whichTag)
    endif
endfunction

//==========================================
// GUMS Getters

struct UnitVisuals extends array
    
    static if LIBRARY_ConstTable and INIT_HASHTABLE then
        private method operator values takes nothing returns data_Child
            return data[this]
        endmethod
    else
        private method operator values takes nothing returns Table
            return data[this]
        endmethod
    endif
    
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
            return "D"
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
            return "D"
        endif
    endmethod
    
    method getAnimSpeed takes nothing returns string
        if .hasAnimSpeed() then
            return R2S(values.real[ASPEED])
        else
            return "D"
        endif
    endmethod
    
    method getAnimTag takes nothing returns string
        if .hasAnimTag() then
            return .values.string[ATAG]
        else
            return "D"
        endif
    endmethod
endstruct

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

//THESE FUNCTIONS RETRIEVE THE SAVED VALUES IN THE HASHTABLE OR RETURN "D" IF THERE IS NO SAVED VALUE
//GET Scale
function GUMSGetUnitScale takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getScale()
endfunction

//GET Vertex Color
function GUMSGetUnitVertexColor takes unit whichUnit, integer r1g2b3a4  returns string
    return UnitVisuals.get(whichUnit).getVertexColor(r1g2b3a4)
endfunction

//GET Player Color (why in hell can't this be retrieved with natives?!)
function GUMSGetUnitColor takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getColor()
endfunction

//GET Animation Speed
function GUMSGetUnitAnimSpeed takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getAnimSpeed()
endfunction

//GET Animation Tag
function GUMSGetUnitAnimationTag takes unit whichUnit returns string
    return UnitVisuals.get(whichUnit).getAnimTag()
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
    
    if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
        call BlzSetHeroProperName(whichUnit, GUMSGetDefaultName(unitHandle))
    else
        call BlzSetUnitName(whichUnit, GUMSGetDefaultName(unitHandle))
    endif
    
    call RemoveSavedString(hashTable, unitHandle, NAME)
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
    if UnitAddAbility(newUnit, 'Amrf') then
        call UnitRemoveAbility(newUnit, 'Amrf')
    endif
    call SetUnitFlyHeight(newUnit, GetUnitFlyHeight(whichUnit), 0)
    //Fix Flying (TLLOP SPECIFIC)
    if GetUnitAbilityLevel(newUnit, 'Amov') == 0 then
        if IsUnitType(newUnit, UNIT_TYPE_STRUCTURE) then
            if GetUnitFlyHeight(whichUnit) > 0.5 then
                call SaveReal(hashTable, GetHandleId(newUnit), -2, fangle)
                call UnitAddAbility(newUnit,'DEDF')
                call IssueImmediateOrder(newUnit, "unroot")
                call SetUnitFacingTimed(newUnit, fangle, 0)
            endif
        endif   
        call GroupAddUnit(loopGroup, newUnit)
    endif
    //EndofFix
    //FIX Flying (ANY MAP)
//    if GetUnitAbilityLevel(newUnit, 'Amov') == 0 then
//        call GroupAddUnit(loopGroup, newUnit)
//    endif
    //EndofFix
        if GUMSGetUnitScale(whichUnit) != "D" then
        call GUMSSetUnitScale(newUnit, S2R(GUMSGetUnitScale(whichUnit)))
    endif
    if GUMSGetUnitVertexColor(whichUnit,1) != "D" then
        call GUMSSetUnitVertexColor(newUnit, S2I(GUMSGetUnitVertexColor(whichUnit,1))/2.55,S2I(GUMSGetUnitVertexColor(whichUnit,2))/2.55, S2I(GUMSGetUnitVertexColor(whichUnit,3))/2.55, (255 - S2I(GUMSGetUnitVertexColor(whichUnit,4)))/2.55)
    endif
    if GUMSGetUnitColor(whichUnit) != "D" then
        call GUMSSetUnitColor(newUnit, S2I(GUMSGetUnitColor(whichUnit)))
    endif
    if GUMSGetUnitAnimSpeed(whichUnit) != "D" then
        call GUMSSetUnitAnimSpeed(newUnit, S2R(GUMSGetUnitAnimSpeed(whichUnit)))
    endif
    if GUMSGetUnitAnimationTag(whichUnit) != "D" then
        call GUMSAddUnitAnimationTag(newUnit, GUMSConvertTags(GUMSGetUnitAnimationTag(whichUnit)))
    endif
    
    set bj_lastCreatedUnit = newUnit
    set newUnit = null
    return bj_lastCreatedUnit
endfunction

function GUMSCopyUnitSameType takes unit whichUnit, player owner returns unit
    return GUMSCopyUnit(whichUnit, owner, 0)
endfunction

// Copies all GUMS values from one source unit to a target unit.
function GUMSCopyValues takes unit source, unit target returns nothing
    local real fangle = GetUnitFacing(source)
    local UnitVisuals sourceId = GetHandleId(source)
    
    if UnitAddAbility(target, 'Amrf') then
        call UnitRemoveAbility(target, 'Amrf')
    endif
    //Fix Flying (TLLOP SPECIFIC)
    if GetUnitAbilityLevel(target, 'Amov') == 0 then
        if IsUnitType(target, UNIT_TYPE_STRUCTURE) then
            if GetUnitFlyHeight(source) > 0.5 then
            call SaveReal(hashTable, GetHandleId(target), -2, fangle)
                if UnitAddAbility(target,'DEDF') then
                    
                endif
                call IssueImmediateOrder(target, "unroot")
                call SetUnitFacingTimed(target, fangle, 0)
            endif
        endif   
        call GroupAddUnit(loopGroup, target)
    endif
    //EndofFix
    //FIX Flying (ANY MAP)
//    if GetUnitAbilityLevel(bj_lastCreatedUnit, 'Amov') == 0 then
//        call GroupAddUnit(loopGroup, bj_lastCreatedUnit)
//    endif
    //EndofFix
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

function GUMSSetUnitFacing takes unit whichUnit, real newAngle returns nothing
    call SetUnitFacing(whichUnit, newAngle)
    if GetUnitAbilityLevel(whichUnit, 'Amov') == 0 then
        // call SetUnitPosition(whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit))
        call GroupAddUnit(loopGroup, whichUnit)
        call SaveReal(hashTable, GetHandleId(whichUnit), -2, ModuloReal(newAngle, 360))
    endif
endfunction

function GUMSSetUnitFlyHeight takes unit whichUnit, real newHeight returns nothing
    if UnitAddAbility(whichUnit, 'Amrf' ) then
        call UnitRemoveAbility(whichUnit, 'Amrf')
    endif
    call SetUnitFlyHeight( whichUnit, newHeight, 0)
    if GetUnitAbilityLevel(whichUnit, 'Amov') == 0 then
        // call SetUnitPosition( whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit) )
        call GroupAddUnit(loopGroup, whichUnit)
    endif
endfunction

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

// When a unit cancels of finishes an upgrade, reapply its Visual modifications.
function GUMS_FixUpgrades takes nothing returns nothing
    call GUMSCopyValues(GetTriggerUnit(), GetTriggerUnit())
endfunction


private function onInit takes nothing returns nothing
    local trigger fixUpgrades = CreateTrigger()
    local integer i
    local timer t = CreateTimer()
    
    call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_CANCEL )
    call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_FINISH )
    call TriggerAddAction( fixUpgrades, function GUMS_FixUpgrades )
    
    static if INIT_HASHTABLE /*and LIBRARY_HashtableWrapper */ then
        set hashTable = InitHashtable()
    endif
    
    set i = 1
    loop
        exitwhen i >  bj_MAX_PLAYER_SLOTS
        set I2PC[i] = GetPlayerColor(Player(i-1))
        set i = i + 1
    endloop
    
    call TimerStart( t, 0.1, true, function GUMSTimerFunction)
    
    set i = 0
    loop
        exitwhen i > 15
        set TerrainType2Id[udg_TileSystem_TILES[i]] = i
        set i = i + 1
    endloop
endfunction

//==================================================================================================
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