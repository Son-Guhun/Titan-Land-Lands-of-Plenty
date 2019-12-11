library SaveIO initializer Init requires TableStruct, GMUI, GLHS, Rawcode2String, optional RectGenerator

private struct PlayerData extends array

    //! runtextmacro TableStruct_NewStructField("loadRequests", "LinkedHashSet")

endstruct

// Formats a string for synced I/O, using BlzSendSyncData (delayed read).
public function FormatString takes string prefix, string data returns string
    return "\" )\ncall BlzSendSyncData(\"" + prefix + "\",\"" + data + "\")\n//"
endfunction

// Formats a string for local I/O, using BlzSetAbilityTooltip (instant read).
public function FormatStringLocal takes integer prefix, string data returns string
    return "\" )\ncall BlzSetAbilityTooltip('" + ID2S(prefix) + "',\"" + data + "\",0)\n//"
endfunction

// Formats a string for local I/O, using BlzSetAbilityTooltip (instant read).
public function FormatStringEx takes string jassCode returns string
    return "\" )\n" + jassCode + "\n//"
endfunction

// Ability used to validate files (tooltip is changed).
public constant function IO_ABILITY takes nothing returns integer
    return 'Adef'
endfunction

public constant function IO_ABILITY_STR takes nothing returns string
    return "Adef"
endfunction

// String used to validate files (tooltip of IO_ABILITY is set to this string)
public constant function VALIDATION_STR takes nothing returns string
    return "a"
endfunction

/*
public constant function CONDITION_STR takes nothing returns string
    return "b"
endfunction
*/

// function Save_IsPlayerLoading takes integer playerId returns boolean
//     return udg_save_load_boolean[playerId + 1 + bj_MAX_PLAYERS]
// endfunction

// function Save_SetPlayerLoading takes integer playerId, boolean flag returns nothing
//    set udg_save_load_boolean[playerId + 1 + bj_MAX_PLAYERS] = flag
// endfunction

private module InitModule
    private static method onInit takes nothing returns nothing
        local PlayerData playerId = 0


        loop
        exitwhen playerId == bj_MAX_PLAYERS
            set playerId.loadRequests = LinkedHashSet.create()
            set playerId = playerId + 1
        endloop

        call TimerStart(CreateTimer(), 0.25, true, function thistype.onTimer)
    endmethod
endmodule

// This function makes all occurences of quotation marks compatible with Preload I/O by converting them to ''.
public function CleanUpString takes string str returns string
    local string result = ""
    local string char
    local integer i = 0
    local integer length = StringLength(str)
    
    
    loop
    exitwhen i >= length
        set char = SubString(str, i, i+1)
        
        if char == "\"" then
            set char = "''"
        endif
        
        set result = result + char
    
        set i = i + 1
    endloop

    return result
endfunction

struct SaveData extends array
    implement GMUIUseGenericKey

    static constant integer MAX_LINES = 20
    static constant integer VERSION = 4
    //! runtextmacro TableStruct_NewPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("linesWritten", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewHandleField("player", "player")
    
    //! runtextmacro TableStruct_NewPrimitiveField("centerX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("centerY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("maxX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("maxY", "real")

    private method start takes nothing returns nothing
        if GetLocalPlayer() == .player then
            call PreloadGenStart()
            call PreloadGenClear()
        endif
    endmethod
    
    private method flush takes nothing returns nothing
        local string path = .folder + "\\" + I2S(.current) + ".txt"
        local string validationString = FormatStringLocal(IO_ABILITY(), VALIDATION_STR())
        
        if GetLocalPlayer() == .player then
            call Preload(validationString)
            call Preload( "\" )
endfunction
function SomeRandomName takes nothing returns nothing //")  // Not calling PreloadEnd in a preload file greatly improves loading performance.
            call PreloadGenEnd(path)
        endif
        set this.current = this.current + 1
    endmethod
    
    method write takes string str returns nothing
    
        if MAX_LINES <= .linesWritten then
            call .flush()
            call .start()
            set .linesWritten = 1
        else
            set .linesWritten = .linesWritten + 1
        endif
        
        if GetLocalPlayer() == .player then
            call Preload(str)
        endif
    endmethod
    
    static method create takes player saver, string name returns thistype
        local integer this
        implement GMUI_allocate_this
        
        set .folder = name
        set .player = saver
        
        call .start()
        
        return this
    endmethod
    
    method getMetaString takes nothing returns string
        return FormatStringLocal(IO_ABILITY(), "v" + I2S(.VERSION) + "," + I2S(.current) + "," + R2S(.centerX) + "," + R2S(.centerY) + "," + /*
                        */  R2S(.minX) + "," + R2S(.minY) + "," + R2S(.maxX) + "," + R2S(maxY))
    endmethod
    
    method destroy takes nothing returns nothing
        local string filePathSize = .folder + "\\size.txt"
        local string metaString
        /*
        local string ifStr = FormatStringEx("if BlzGetAbilityTooltip('" + IO_ABILITY_STR() + "', 0) == \"" + CONDITION_STR() + "\" then")
        local string elseStr = FormatStringEx("else")
        local string endifStr = FormatStringEx("endif")
        */

        if .folderExists() then
            call .flush()
            set metaString = .getMetaString()  // Order matters
            if GetLocalPlayer() == .player then
                call PreloadGenStart()
                call PreloadGenClear()
                /*
                call Preload(ifStr)
                call Preload(metaString)
                call Preload(elseStr)
                */
                call Preload(metaString)
                // call Preload(endifStr)
                call PreloadGenEnd(filePathSize)
            endif
            
            call .linesWrittenClear()
            call .currentClear()
            call .folderClear()
            call .playerClear()
            
            implement GMUI_deallocate_this
        endif
    endmethod

    
endstruct

private struct SaveLoader extends array
    implement GMUIUseGenericKey

    //! runtextmacro TableStruct_NewPrimitiveField("version", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("centerX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("centerY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("maxX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("maxY", "real")
    
    //! runtextmacro TableStruct_NewPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("totalFiles", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewHandleField("player", "player")

    // Reads the current file and increments the counter.
    private method read takes nothing returns nothing
        local string path = .folder + "\\" + I2S(.current) + ".txt"
        local string errorString = "Unable to validate file " + I2S(current) + ".txt of save. Some units may have failed to load."
        local string tooltip = BlzGetAbilityTooltip(IO_ABILITY(), 0)

        if GetLocalPlayer() == .player then
            call Preloader(path)
            if .version >= 4 then
                if BlzGetAbilityTooltip(IO_ABILITY(), 0) != VALIDATION_STR() then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., errorString)
                else
                    call BlzSetAbilityTooltip(IO_ABILITY(), tooltip, 0)
                endif
            endif
        endif
        
        set .current = .current + 1
    endmethod

    // Returns whether all files in the save folder have been read.
    private method eof takes nothing returns boolean
        return .current >= .totalFiles  // Using >= avoids infinite loop in case of bugged save file that has 0 or lower size
    endmethod
    
    // This method does not immediately read the file. It puts it in queue for reading.
    method loadData takes nothing returns nothing
        if not PlayerData(GetPlayerId(.player)).loadRequests.contains(this) then
            call PlayerData(GetPlayerId(.player)).loadRequests.append(this)
        endif
    endmethod
    
    method parseData takes string data returns nothing
        
        local integer index = CutToComma(data)
        set .version = S2I((SubString(data, 1, index)))
        set data = SubString(data, index+1, StringLength(data))
        
        set index = CutToComma(data)
        set .totalFiles = S2I((SubString(data, 0, index)))
        set data = SubString(data, index+1, StringLength(data))
        
        set index = CutToComma(data)
        set .centerX = S2R((SubString(data, 0, index)))
        set data = SubString(data, index+1, StringLength(data))
        
        set index = CutToComma(data)
        set .centerY = S2R(SubString(data, 0, index))
        set data = SubString(data, index+1, StringLength(data))
        
        if data != "" then
            set index = CutToComma(data)
            set .minX = S2R((SubString(data, 0, index)))
            set data = SubString(data, index+1, StringLength(data))
            
            set index = CutToComma(data)
            set .minY = S2R(SubString(data, 0, index))
            set data = SubString(data, index+1, StringLength(data))
        
            set index = CutToComma(data)
            set .maxX = S2R((SubString(data, 0, index)))
            set data = SubString(data, index+1, StringLength(data))
            
            set index = CutToComma(data)
            set .maxY = S2R(SubString(data, 0, index))
            set data = SubString(data, index+1, StringLength(data))
        endif
        
    endmethod
    
    static method create takes player saver, string name, string data returns thistype
        local thistype this
        implement GMUI_allocate_this
        
        set .folder = name
        set .player = saver
        
        if SubString(data, 0, 1) == "v" then
            call .parseData(data)
        else
            set .version = 3
            set .totalFiles = S2I(data)
        endif
        
        call BJDebugMsg(R2S(.centerX) + "," + R2S(.centerY))
        call BJDebugMsg(R2S(.minX) + "," + R2S(.minY) + "," + R2S(.maxX) + "," + R2S(.maxY))
        
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        call .currentClear()
        call .folderClear()
        call .playerClear()
        call .totalFilesClear()
    endmethod
    
        // This function is exectued every 0.5 seconds, and it reads the next file of a SaveData that is currently being read.
    private static method onTimer takes nothing returns nothing
        local PlayerData playerId = 0
        local SaveLoader saveData

        loop
        exitwhen playerId == bj_MAX_PLAYERS
            set saveData = playerId.loadRequests.begin()

            if saveData != playerId.loadRequests.end() then
                call saveData.read()
                if saveData.eof() then
                    call DisplayTextToPlayer(Player(playerId), 0., 0., "Finished loading!")
                    call saveData.destroy()
                    call playerId.loadRequests.remove(saveData)
                endif
            endif
            set playerId = playerId + 1
        endloop

    endmethod

    implement InitModule
endstruct

globals
    private string array currentSave
endglobals

private struct UnitData extends array
    //! runtextmacro TableStruct_NewStructField("saveData", "SaveLoader")
    
    method destroy takes nothing returns nothing
        if .saveDataExists() then
            call .saveDataClear()
        endif
    endmethod
    
    static method get takes unit whichUnit returns thistype
        return GetHandleId(whichUnit)
    endmethod
endstruct

function ClearSaveLoaderData takes unit whichUnit returns nothing
    call UnitData.get(whichUnit).destroy()
endfunction
        

public function onReceiveSize takes nothing returns nothing
    local unit generator
    local string syncData = BlzGetTriggerSyncData()
    local SaveLoader saveData
    
    if SubString(syncData, 0, 2) == "OG" then
        set saveData = SaveLoader.create(GetTriggerPlayer(), currentSave[GetPlayerId(GetTriggerPlayer())], SubString(syncData, 2, StringLength(syncData)))
        set generator = CreateUnit(GetTriggerPlayer(), RectGenerator_GENERATOR_ID, saveData.centerX, saveData.centerY, 270.)
    
        call UnitRemoveAbility(generator, RectGenerator_CREATE_OR_DESTROY)
        call UnitRemoveAbility(generator, RectGenerator_TOGGLE_VISIBILITY)
        call UnitRemoveAbility(generator, RectGenerator_PAGE_NEXT)
        call UnitRemoveAbility(generator, RectGenerator_PAGE_PREV)
        
        call UnitRemoveAbility(generator, RectGenerator_RETRACT_X)
        call UnitRemoveAbility(generator, RectGenerator_EXPAND_X)
        call UnitRemoveAbility(generator, RectGenerator_RETRACT_Y)
        call UnitRemoveAbility(generator, RectGenerator_EXPAND_Y)
        
        call UnitRemoveAbility(generator, RectGenerator_LOCK_UNITS)
        call UnitRemoveAbility(generator, RectGenerator_UNLOCK_UNITS)
        
        call UnitAddAbility(generator, 'A061')
        call UnitAddAbility(generator, 'A062')
        
        set UnitData.get(generator).saveData = saveData
        call CreateGUDR(generator)
        call MoveGUDR(generator, saveData.maxX - saveData.centerX, saveData.maxY - saveData.centerY, false)
        
        if GetLocalPlayer() == GetTriggerPlayer() then
            call ClearSelection()
            call SelectUnit(generator, true)
            call SetCameraPosition(GetUnitX(generator), GetUnitY(generator))
        endif
    else
        call SaveLoader.create(GetTriggerPlayer(), currentSave[GetPlayerId(GetTriggerPlayer())], syncData).loadData()
    endif
    
    // call SaveLoader.create(GetTriggerPlayer(), currentSave[GetPlayerId(GetTriggerPlayer())], BlzGetTriggerSyncData()).loadData()

    
    // Create Rect Generator with the following abilities: Move (64), Move (128), load here, load original
    // Attach this SaveLoader object to the unit
    // When load ability is cast, start loading SaveLoader
endfunction

// This function returns a value that is async. It will be false if the file failed to load, and ONLY for 'whichPlayer'.
public function LoadSaveEx takes boolean newVersion, player whichPlayer, string path, boolean originalPosition returns boolean
    local string tooltip = BlzGetAbilityTooltip(IO_ABILITY(), 0)
    set currentSave[GetPlayerId(whichPlayer)] = path
    set path = path+"\\size.txt"
    if GetLocalPlayer() == whichPlayer then
        call Preloader(path)
    endif
    if newVersion then
        if BlzGetAbilityTooltip(IO_ABILITY(), 0) == tooltip then
            return GetLocalPlayer() != whichPlayer
        else
            if originalPosition then
                call BlzSendSyncData("SnL_IOsize", BlzGetAbilityTooltip(IO_ABILITY(), 0))
            else
                call BlzSendSyncData("SnL_IOsize", "OG" + BlzGetAbilityTooltip(IO_ABILITY(), 0))
            endif
            call BlzSetAbilityTooltip(IO_ABILITY(), tooltip, 0)
            return true
        endif
    endif
    return false
endfunction

// This function returns a value that is async. It will be false if the file failed to load, and ONLY for 'whichPlayer'.
public function LoadSave takes player whichPlayer, string path, boolean originalPosition returns boolean
    return LoadSaveEx(true, whichPlayer, path, originalPosition)
endfunction

public function LoadSaveOld takes player whichPlayer, string path returns nothing
    call LoadSaveEx(false, whichPlayer, path, true)
endfunction

function TriggerRegisterAnyPlayerSyncEvent takes trigger whichTrigger, string prefix, boolean fromServer returns nothing
    local integer i = 0
    local player slot
    
    loop
    exitwhen i == bj_MAX_PLAYERS
        set slot = Player(i)
        if GetPlayerController(slot) == MAP_CONTROL_USER then
            call BlzTriggerRegisterPlayerSyncEvent(whichTrigger, slot, prefix, fromServer)
        endif
        
        set i = i + 1
    endloop
endfunction

private function onAbility takes nothing returns nothing
    if GetSpellAbilityId() == 'A061' then
        call UnitData.get(GetTriggerUnit()).saveData.loadData()
        call KillUnit(GetTriggerUnit())
    endif
endfunction

private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    
    call TriggerAddAction(t, function onReceiveSize)
    call TriggerRegisterAnyPlayerSyncEvent(t, "SnL_IOsize", false)
    
    set t = CreateTrigger()
    call TriggerAddAction(t, function onAbility)
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
endfunction

endlibrary