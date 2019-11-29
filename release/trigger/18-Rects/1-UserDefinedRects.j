library UserDefinedRects initializer onInit /*
    */requires /*
        */GroupTools /* Used to refresh the GUDR groups.
        
    */optional RectEnvironment // Does not require Hooks to be enabled. Uses the library's SetRect.
    
//////////////////////////////////////////////////////
//Guhun's User Defined Rect System v1.2.0


// TODO: check if bj_groupRandomCurrentPick is being used somewhere in LoP. If not, make this system use a differnt global.

//! novjass
'                                                                                                  '
'                                              API                                                 '

// If the first unit of the group is a GUDR, adds all units inside of the rect to 'whichGroup'.
function GUDR_SwapGroup_UnitsInsideUDR takes group whichGroup, boolean includeGenerator, boolexpr filter returns integer
endfunction

//Returns the Handle Id of an active UDR generator selected by a player
//Additionally, the global bj_groupRandomCurrentPick will be set to the selected generator
function GUDR_PlayerGetSelectedGeneratorId takes player whichPlayer returns integer
endfunction


function ChangeGUDRWeatherNew takes unit whichUnit, integer changeWeather, integer finalWeather returns integer
    integer changeWeather => //! 
    integer finalWeather => //! If this value is between 1 and 21, then this will be the weather value of the GUDR.
endfunction

// Adds all units inside of the rect to the GUDR group.
function GroupGUDR takes unit whichUnit,  boolean unlock  returns boolean
    
endfunction

function ToggleGUDRVisibility takes unit whichUnit, boolean switch, boolean show returns boolean
    unit whichUnit => //!The GUDR generator.
    boolean switch => //!If true, the current visibility of the GUDR will be reversed.
    boolean show => //!If switch is false, the visibility will be set to this value.
endfunction

function MoveGUDR takes unit centerUnit, real offsetX, real offsetY, boolean expand returns boolean
    unit centerUnit => //!The GUDR generator.
    real offsetX
    real offsetY
    boolean expand => //!If true, the region's current borders will be expanded by the offsets.
                      //!If false, the region's borders will be set to the specified offets. (center +- offset)
endfunction

// Creates a generator's GUDR.
function CreateGUDR takes unit centerUnit returns boolean
endfunction

// Destroys a generator's GUDR.
function DestroyGUDR takes unit centerUnit returns nothing
endfunction

// Destroys a unit's GUDR if it is a generator. Creates a new GUDR for the unit if it isn't.
function CreateDestroyGUDRWrapper takes unit whichUnit returns boolean
endfunction
'                                                                                                  '
'                                         Source Code                                              '
//! endnovjass

globals
    private hashtable hashTable = InitHashtable()
    private weathereffect array weatherEffects
endglobals

static if LIBRARY_GMUI then
    globals
        private constant key RECYCLE_KEY
    endglobals
else
    globals
        private integer array instances
    endglobals
endif

//=============================
//CONSTANTS THAT RETURN THE INTEGER ADDRESS OF A GUDR MEMBER IN THE HASHTABLE
//! textmacro GUDR_INDEX takes NAME, NUMBER
    static constant method operator $NAME$ takes nothing returns integer
        return $NUMBER$
    endmethod
//! endtextmacro

private struct Indices extends array
    //! runtextmacro GUDR_INDEX("RECT", "0")
    //! runtextmacro GUDR_INDEX("LIGHT_T", "1")
    //! runtextmacro GUDR_INDEX("LIGHT_B", "2")
    //! runtextmacro GUDR_INDEX("LIGHT_L", "3")
    //! runtextmacro GUDR_INDEX("LIGHT_R", "4")
    //! runtextmacro GUDR_INDEX("WEATHER", "5")
    //! runtextmacro GUDR_INDEX("GROUP", "6")
    //! runtextmacro GUDR_INDEX("HIDDEN", "7")
    //! runtextmacro GUDR_INDEX("WEATHER_TYPE", "8")
    //! runtextmacro GUDR_INDEX("OFFSET_X", "9")
    //! runtextmacro GUDR_INDEX("OFFSET_Y", "10")
endstruct

//! runtextmacro DeclareParentHashtableWrapperModule("hashTable", "true", "hT", "private")
//! runtextmacro DeclareParentHashtableWrapperStruct("hT","private")

private struct UserDefinedRect extends array
    // //! runtextmacro HashStruct_SetHashtableWrapper("hashTable")

    //! runtextmacro HashStruct_NewPrimitiveFieldEx("hT", "offsetX","real","Indices.OFFSET_X")
    //! runtextmacro HashStruct_NewPrimitiveFieldEx("hT", "offsetY","real","Indices.OFFSET_Y")
endstruct
//=============================
//FUNCTIONS THAT RETURN BOOLEANS
function GUDR_IsUnitIdGenerator takes integer unitHandle returns boolean
    return HaveSavedHandle(hashTable, unitHandle, Indices.RECT) 
endfunction

function GUDR_IsUnitGenerator takes unit whichUnit returns boolean
    return GUDR_IsUnitIdGenerator(GetHandleId(whichUnit))
endfunction

function GUDR_IsGeneratorIdHidden takes integer generatorId returns boolean
    return LoadBoolean(hashTable, generatorId, Indices.HIDDEN)
endfunction

function GUDR_IsGeneratorHidden takes unit generator returns boolean
    return GUDR_IsGeneratorIdHidden(GetHandleId(generator))
endfunction

function GUDR_GeneratorIdHasGroup takes integer generatorId returns boolean
    return HaveSavedHandle(hashTable, generatorId, Indices.GROUP)
endfunction

function GUDR_GeneratorHasGroup takes unit generator returns boolean
    return GUDR_GeneratorIdHasGroup(GetHandleId(generator))
endfunction

function GUDR_GeneratorIdHasWeather takes integer generatorId returns boolean
    return HaveSavedInteger(hashTable, generatorId, Indices.WEATHER)
endfunction

function GUDR_GeneratorHasWeather takes unit generator returns boolean
    return GUDR_GeneratorIdHasWeather(GetHandleId(generator))
endfunction
//=============================
//FUNCTIONS TO GET GUDR MEMBERS

//Handle Id as parameter
function GUDR_GetGeneratorIdRect takes integer generatorId returns rect
    return LoadRectHandle(hashTable, generatorId, Indices.RECT)
endfunction

function GUDR_GetGeneratorIdWeatherEffect takes integer generatorId returns weathereffect
    return weatherEffects[LoadInteger(hashTable, generatorId, Indices.WEATHER)]
endfunction

function GUDR_GetGeneratorIdGroup takes integer generatorId returns group
    return LoadGroupHandle(hashTable, generatorId, Indices.GROUP)
endfunction

function GUDR_GetGeneratorIdWeatherType takes integer generatorId returns integer
    return LoadInteger(hashTable, generatorId, Indices.WEATHER_TYPE)
endfunction

//Unit as parameter

function GUDR_GetGeneratorRect takes unit generator returns rect
    return GUDR_GetGeneratorIdRect(GetHandleId(generator))
endfunction

function GUDR_GetGeneratorWeatherEffect takes unit generator returns weathereffect
    return GUDR_GetGeneratorIdWeatherEffect(GetHandleId(generator))
endfunction

function GUDR_GetGeneratorGroup takes unit generator returns group
    return GUDR_GetGeneratorIdGroup(GetHandleId(generator))
endfunction

function GUDR_GetGeneratorWeatherType takes unit generator returns integer
    return GUDR_GetGeneratorIdWeatherType(GetHandleId(generator))
endfunction

function GUDR_ConvertWeatherType takes integer weatherType returns integer
    return LoadInteger(hashTable, 0, weatherType)
endfunction

private function GetGeneratorIdLightning takes integer genId, integer i returns lightning
    return LoadLightningHandle(hashTable, genId, i)
endfunction

//=============================

function GUDR_SwapGroup_UnitsInsideUDR takes group whichGroup, boolean includeGenerator, boolexpr filter returns integer
    local integer genId
    local unit firstOfGroup
    
    set firstOfGroup = FirstOfGroup(whichGroup)
    set genId = GetHandleId(firstOfGroup)
    
    if GUDR_IsUnitIdGenerator(genId) then
        set bj_groupRandomCurrentPick = firstOfGroup
        
        call GroupClear(whichGroup)
        call GroupEnumUnitsInRect(whichGroup, GUDR_GetGeneratorIdRect(genId), filter)
        
        if not includeGenerator then
            call GroupRemoveUnit(whichGroup, firstOfGroup)
        endif
    else
        set genId = 0
    endif
    
    set firstOfGroup = null
    return genId
endfunction

//Returns the Handle Id of an active UDR generator selected by a player
//Additionally, the global bj_groupRandomCurrentPick will be set to the selected generator
function GUDR_PlayerGetSelectedGeneratorId takes player whichPlayer returns integer
    local unit firstOfGroup
    local integer unitId
    local group slctGrp = CreateGroup()
    
    call GroupEnumUnitsSelected(slctGrp, whichPlayer, null)
    set firstOfGroup = FirstOfGroup(slctGrp)
    set unitId = GetHandleId(firstOfGroup)
    
    call DestroyGroup(slctGrp)
    set slctGrp = null
    
    if GUDR_IsUnitIdGenerator(unitId) then
        set bj_groupRandomCurrentPick = firstOfGroup
        set firstOfGroup = null
        return unitId
    endif
    
    set firstOfGroup = null
    return 0
endfunction


function ChangeGUDRWeatherNew takes unit whichUnit, integer changeWeather, integer finalWeather returns integer
    local integer curWeather
    local integer unitId = GetHandleId(whichUnit)
    local integer weatherId
    
    if not GUDR_IsUnitIdGenerator(unitId) then
        return 0
    endif

    if finalWeather < 1 or finalWeather > 21 then
        set curWeather = GUDR_GetGeneratorIdWeatherType(unitId)
        set finalWeather = curWeather + changeWeather
    endif
        

    if finalWeather > 21 then
        loop
        exitwhen finalWeather <= 21
                set finalWeather = finalWeather - 21
        endloop
    elseif finalWeather < 1 then
        loop
        exitwhen finalWeather >= 1
                set finalWeather = finalWeather + 21
        endloop
    endif
    
    call SaveInteger(hashTable, unitId, Indices.WEATHER_TYPE, finalWeather)
    
    // Update Weather, if it exists.
    set weatherId = LoadInteger(hashTable, unitId, 5)
    if weatherId > 0 then
        call EnableWeatherEffect(weatherEffects[weatherId],false) //BUG: If weather effect is not disabled before destruction, it's sound effect will remain
        call RemoveWeatherEffect(weatherEffects[weatherId])
        set weatherEffects[weatherId] = AddWeatherEffect(GUDR_GetGeneratorIdRect(unitId), GUDR_ConvertWeatherType(finalWeather))
        call EnableWeatherEffect(weatherEffects[weatherId], true)
    endif
    
    return finalWeather
endfunction

function GroupGUDRFilter takes nothing returns boolean
    local unit filterUnit = GetFilterUnit()
    
    if GUDR_IsUnitGenerator(filterUnit) or GetOwningPlayer(filterUnit) != bj_forceRandomCurrentPick then
        set filterUnit = null
        return false
    endif
    
    call SetUnitPathing( filterUnit, false )
    set filterUnit = null
    return true
endfunction

function GroupGUDR takes unit whichUnit,  boolean unlock  returns boolean
    local integer unitId = GetHandleId(whichUnit)
    local group g
    local unit firstUnit
    local player storeGlobal = bj_forceRandomCurrentPick
    
    if not GUDR_IsUnitIdGenerator(unitId) then
        return false
    endif
    
    set g = GUDR_GetGeneratorIdGroup(unitId)
    
    //Save the GURD's owner in the Hashtable for use in the EnumFilter function
    set firstUnit = FirstOfGroup(g)
    
    //This loop clears the group and restores pathing and unpauses
    loop
    exitwhen BlzGroupGetSize(g) == 0
        if firstUnit != null then
            call SetUnitPathing(firstUnit,true)
            call GroupRemoveUnit(g, firstUnit)
        else
            call GroupRefresh(g)
        endif
        set firstUnit = FirstOfGroup(g)
    endloop
    
    //We only want to add new units to the group if the user doesn't want to unlock it
    if not unlock then 
        set bj_forceRandomCurrentPick = GetOwningPlayer(whichUnit)
        call GroupEnumUnitsInRect(g, GUDR_GetGeneratorIdRect(unitId), Condition(function GroupGUDRFilter))
        set bj_forceRandomCurrentPick = storeGlobal
    endif
    
    set g = null
    set firstUnit = null
    return true
endfunction


function CreateWeather takes unit whichUnit returns boolean
    local integer instance
    local integer genId = GetHandleId(whichUnit)
    
    if not GUDR_IsUnitIdGenerator(genId) then
        return false
    endif
    
    static if not LIBRARY_GMUI then
        set instance = instances[0]
        if instances[instances[0]] == 0 then
            set instances[0] = instances[0] + 1
        else
            set instances[0] = instances[instances[0]]
            set instances[instance] = 0
        endif
    else
        set instance = GMUI_GetIndex(RECYCLE_KEY)
    endif
    
    call SaveInteger(hashTable, GetHandleId(whichUnit), Indices.WEATHER, instance)
    set weatherEffects[instance] = AddWeatherEffect(GUDR_GetGeneratorIdRect(genId), /*
                                                  */GUDR_ConvertWeatherType(GUDR_GetGeneratorIdWeatherType(genId)))
    call EnableWeatherEffect(weatherEffects[instance], true)
    
    return true
endfunction

function DestroyWeather takes unit whichUnit returns boolean
    local integer instance = LoadInteger(hashTable, GetHandleId(whichUnit), Indices.WEATHER)
    
    if instance < 1 then
        return false  // False for effect not destroyed, unit did not have weather attached.
    endif
    
    call EnableWeatherEffect(weatherEffects[instance],false)  // BUG: If weather effect is not disabled before destruction, it's sound effect will remain
    call RemoveWeatherEffect(weatherEffects[instance])
    set weatherEffects[instance] = null  // Null to free handles for other systems
    call RemoveSavedInteger(hashTable, GetHandleId(whichUnit), Indices.WEATHER)
    
    
    static if not LIBRARY_GMUI then
        set instances[instance] = instances[0]
        set instances[0] = instance
    else
        call GMUI_RecycleIndex(RECYCLE_KEY, instance)
    endif
    
    return true  // True for effect destroyed.
endfunction

function ToggleGUDRVisibility takes unit whichUnit, boolean toggle, boolean show returns boolean
    local real alpha
    local integer unitId = GetHandleId(whichUnit)
    
    if not GUDR_IsUnitIdGenerator(unitId) then
        return false
    endif
    
    if toggle then //If user wants to switch the current value, change the value of show to opposite of current value
        set show = not LoadBoolean(hashTable, unitId, Indices.HIDDEN)
    endif
    
    call SaveBoolean(hashTable, unitId, Indices.HIDDEN, show)//Save current show/hide boolean
    
    //Convert Boolean to Real T/F = 1/0
    if show then
        set alpha = 1 //Show > Alpha = 100%
    else
        set alpha = 0 //Hide > Alpha = 0%
    endif
    //End of Conversion

    //After it has been decided if the GUDR should be shown or hidden, apply the choice
    call SetUnitVertexColor(whichUnit, 255, 255, 255, 255*R2I(alpha))
    call SetLightningColor(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_T),1,1,1,alpha)
    call SetLightningColor(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_B),1,1,1,alpha)
    call SetLightningColor(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_L),1,1,1,alpha)
    call SetLightningColor(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_R),1,1,1,alpha)
    return true
endfunction

function MoveGUDR takes unit centerUnit, real offsetX, real offsetY, boolean expand returns boolean
    local UserDefinedRect unitId = GetHandleId(centerUnit)
    local real centerX = GetUnitX(centerUnit)
    local real centerY = GetUnitY(centerUnit)
    local rect userDefRect
    local integer weatherId
    
    local real minX
    local real maxX
    local real minY
    local real maxY
    
    if not GUDR_IsUnitIdGenerator(unitId) then
        return false
    endif
    
    set userDefRect = GUDR_GetGeneratorIdRect(unitId)
    
    //If user wants to expand or contract the current region, Load the current value of its borders
    if expand then
        set offsetX = RMaxBJ(offsetX + unitId.offsetX, 32)
        set offsetY = RMaxBJ(offsetY + unitId.offsetY, 32)
    else
        set offsetX = RMaxBJ(offsetX, 32)
        set offsetY = RMaxBJ(offsetY, 32)
    endif
    set unitId.offsetX = offsetX
    set unitId.offsetY = offsetY
    
    //Set the values of the borders based on the offsets
    set minX = centerX - offsetX
    set maxX = centerX + offsetX
    set minY = centerY - offsetY
    set maxY = centerY + offsetY
    
    //Update Rect
    static if LIBRARY_AutoRectEnvironment then
        call AutoRectEnvironment_SetRect(userDefRect, minX, minY, maxX, maxY)
    else
        call SetRect(userDefRect, minX, minY, maxX, maxY)
    endif
    
    set minX = GetRectMinX(userDefRect)
    set maxX = GetRectMaxX(userDefRect)
    set minY = GetRectMinY(userDefRect)
    set maxY = GetRectMaxY(userDefRect)
    
    //Update Lightnings
    call MoveLightning(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_T), false, minX,maxY,maxX,maxY)
    call MoveLightning(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_B), false, minX,minY,maxX,minY)
    call MoveLightning(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_L), false, minX,minY,minX,maxY)
    call MoveLightning(LoadLightningHandle(hashTable, unitId, Indices.LIGHT_R), false, maxX,minY,maxX,maxY)
    
    // Update Weather Effect
    set weatherId = LoadInteger(hashTable, unitId, 5)
    if weatherId > 0 then
        call EnableWeatherEffect(weatherEffects[weatherId], false) //BUG: If weather effect is not disabled before destruction, it's sound effect will remain
        call RemoveWeatherEffect(weatherEffects[weatherId])
        set weatherEffects[weatherId] = AddWeatherEffect(userDefRect, /*
                                                       */GUDR_ConvertWeatherType(GUDR_GetGeneratorIdWeatherType(unitId)))
        call EnableWeatherEffect(weatherEffects[weatherId], true)
    endif
    
    set userDefRect = null
    return true
endfunction


function CreateGUDR takes unit centerUnit returns boolean
    local UserDefinedRect unitId = GetHandleId(centerUnit)
    local real centerX = GetUnitX(centerUnit)
    local real centerY = GetUnitY(centerUnit)
    local rect userDefRect 
    
    static if LIBRARY_AutoRectEnvironment then
        local TerrainFog fog
    endif
    
    if GUDR_IsUnitIdGenerator(unitId) then
        return false
    endif
    
    set userDefRect = Rect(centerX-32, centerY-32, centerX+32, centerY+32) 
    
    static if LIBRARY_AutoRectEnvironment then
        set fog = TerrainFog.create()
        set RectEnvironment.get(userDefRect).fog = fog
        set fog.style = TerrainFog.EXPONENTIAL
    endif
    
    call SaveRectHandle(hashTable, unitId, Indices.RECT, userDefRect)
    call SaveLightningHandle(hashTable, unitId, Indices.LIGHT_T, AddLightning("DRAM", false, centerX-32, centerY+32, centerX+32, centerY+32))
    call SaveLightningHandle(hashTable, unitId, Indices.LIGHT_B, AddLightning("DRAM", false, centerX-32, centerY-32, centerX+32, centerY-32))
    call SaveLightningHandle(hashTable, unitId, Indices.LIGHT_L, AddLightning("DRAM", false, centerX-32, centerY-32, centerX-32, centerY+32))
    call SaveLightningHandle(hashTable, unitId, Indices.LIGHT_R, AddLightning("DRAM", false, centerX+32, centerY-32, centerX+32, centerY+32))
    call SaveGroupHandle(hashTable, unitId, Indices.GROUP, CreateGroup())
    call SaveBoolean(hashTable, unitId, Indices.HIDDEN, true) //Save show/hide boolean as true, because nothing is being hidden
    call SaveInteger(hashTable, unitId, Indices.WEATHER_TYPE, 1) //Save 1 as it is the value of 'RAhr'
    
    set unitId.offsetX = 32
    set unitId.offsetY = 32
    
    set userDefRect = null
    return true
endfunction

function DestroyGUDR takes unit centerUnit returns nothing
    local integer unitId = GetHandleId(centerUnit)
    local rect udr = GUDR_GetGeneratorIdRect(unitId)
    
    static if LIBRARY_AutoRectEnvironment then
        local TerrainFog fog = RectEnvironment.get(udr).fog
    endif
    
    if udr == null then
        return
    endif
    
    static if LIBRARY_AutoRectEnvironment then
        call AutoRectEnvironment_DeRegisterRect(udr)
        
        if fog > 0 then
            call fog.destroy()
        endif
    endif

    call DestroyWeather(centerUnit)
    call GroupGUDR(centerUnit, true)
    call DestroyLightning(GetGeneratorIdLightning(unitId, Indices.LIGHT_T))
    call DestroyLightning(GetGeneratorIdLightning(unitId, Indices.LIGHT_B))
    call DestroyLightning(GetGeneratorIdLightning(unitId, Indices.LIGHT_L))
    call DestroyLightning(GetGeneratorIdLightning(unitId, Indices.LIGHT_R))
    call RemoveRect(udr)
    call DestroyGroup(GUDR_GetGeneratorIdGroup(unitId))
    
    call FlushChildHashtable(hashTable, unitId)

    set udr = null
endfunction

private function onInit takes nothing returns nothing
    static if not LIBRARY_GMUI then
        set instances[0] = 1
    endif
    
    call SaveInteger(hashTable, 0, 1,  'RAhr')
    call SaveInteger(hashTable, 0, 2,  'RAlr')
    call SaveInteger(hashTable, 0, 3,  'MEds')
    call SaveInteger(hashTable, 0, 4,  'FDbh')
    call SaveInteger(hashTable, 0, 5,  'FDbl')
    call SaveInteger(hashTable, 0, 6,  'FDgh')
    call SaveInteger(hashTable, 0, 7,  'FDgl')
    call SaveInteger(hashTable, 0, 8,  'FDrh')
    call SaveInteger(hashTable, 0, 9,  'FDrl')
    call SaveInteger(hashTable, 0, 10, 'FDwh')
    call SaveInteger(hashTable, 0, 11, 'FDwl')
    call SaveInteger(hashTable, 0, 12, 'RLhr')
    call SaveInteger(hashTable, 0, 13, 'RLlr')
    call SaveInteger(hashTable, 0, 14, 'SNbs')
    call SaveInteger(hashTable, 0, 15, 'SNhs')
    call SaveInteger(hashTable, 0, 16, 'SNls')
    call SaveInteger(hashTable, 0, 17, 'WOcw')
    call SaveInteger(hashTable, 0, 18, 'WOlw')
    call SaveInteger(hashTable, 0, 19, 'LRaa')
    call SaveInteger(hashTable, 0, 20, 'LRma')
    call SaveInteger(hashTable, 0, 21, 'WNcw')
endfunction

//////////////////////////////////////////////////////
//END OF GUDR
//////////////////////////////////////////////////////
endlibrary
