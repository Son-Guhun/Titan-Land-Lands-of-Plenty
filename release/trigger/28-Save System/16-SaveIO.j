library SaveIO requires TableStruct, GMUI, GLHS, Rawcode2String, optional RectGenerator
/*
This library requires some trigger to be listening to SnL_IOsize sync data event in order to work.

In the Save System folder, the RectSaveLoader library provides such a trigger.
*/

private struct PlayerData extends array
    implement DebugPlayerStruct

    //! runtextmacro TableStruct_NewStructField("loadRequests", "LinkedHashSet")

endstruct

// Formats a string for synced I/O, using BlzSendSyncData (delayed read).
public function FormatString takes string prefix, string data returns string
    return "\" )\ncall BlzSendSyncData(\"" + prefix + "\",\"" + data + "\")\n//"
endfunction

// Formats a string for local I/O, using BlzSetAbilityTooltip (instant read).
private function FormatStringLocal takes integer prefix, string data returns string
    return "\" )\ncall BlzSetAbilityTooltip('" + ID2S(prefix) + "',\"" + data + "\",0)\n//"
endfunction

// Formats any line of JASS code in order to insert it into a preload file
private function FormatStringEx takes string jassCode returns string
    return "\" )\n" + jassCode + "\n//"
endfunction

// Ability used to validate files (tooltip is changed).
private constant function IO_ABILITY takes nothing returns integer
    return 'Adef'
endfunction

private constant function IO_ABILITY_STR takes nothing returns string
    return "Adef"
endfunction

// String used to validate files (tooltip of IO_ABILITY is set to this string)
private constant function VALIDATION_STR takes nothing returns string
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

        set .loadingQueue = LinkedHashSet.create()
        call TimerStart(CreateTimer(), 0.5, true, function thistype.onTimer)
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
    static constant integer VERSION = 5
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("linesWritten", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewReadonlyAgentField("player", "player")
    
    //! runtextmacro TableStruct_NewPrimitiveField("centerX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("centerY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("extentX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("extentY", "real")
    
    method isRectSave takes nothing returns boolean
        return this.extentX != 0
    endmethod

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
    
    private method getMetaString takes nothing returns string
        return FormatStringLocal(IO_ABILITY(), "v" + I2S(.VERSION) + "," + I2S(.current) + "," + R2S(.centerX) + "," + R2S(.centerY) + "," + /*
                        */  R2S(.extentX) + "," + R2S(.extentY))
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
            set metaString = .getMetaString()  // Order matters for line and .flush()
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
                call Preload( "\" )
endfunction
function SomeRandomName takes nothing returns nothing //")  // Not calling PreloadEnd in a preload file greatly improves loading performance.
                call PreloadGenEnd(filePathSize)
            endif
            
            call .linesWrittenClear()
            call .currentClear()
            call .folderClear()
            call .playerClear()
            call .centerXClear()
            call .centerYClear()
            call .extentXClear()
            call .extentYClear()
            
            implement GMUI_deallocate_this
        endif
    endmethod

    
endstruct

struct SaveLoader extends array
    implement GMUIUseGenericKey

    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("version", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("originalCenterX", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("originalCenterY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("centerX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("centerY", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("extentX", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("extentY", "real")
    
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("atOriginal", "boolean")
    
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("totalFiles", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewReadonlyAgentField("player", "player")
    
    method isRectSave takes nothing returns boolean
        return this.extentX != 0
    endmethod

    // Reads the current file and increments the counter.
    private method read takes nothing returns nothing
        local string path = .folder + "\\" + I2S(.current) + ".txt"
        local string errorString = "Unable to validate file " + I2S(current) + ".txt of save. Some units may have failed to load."
        local string tooltip = BlzGetAbilityTooltip(IO_ABILITY(), 0)

        // call BJDebugMsg("Loading file: " + I2S(.current))

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
    // You can assume that calling this method will destroy the SaveLoader once all data has been synced.
    method loadData takes nothing returns nothing
        local integer playerId = GetPlayerId(.player)
        if not PlayerData(playerId).loadRequests.contains(this) then
            call PlayerData(playerId).loadRequests.append(this)
            if not .loadingQueue.contains(playerId + 1) then
                call .loadingQueue.append(playerId + 1)
            endif
        endif
    endmethod
    
    private method parseData takes string data returns nothing
        
        local integer index = CutToComma(data)
        set .version = S2I((SubString(data, 1, index)))
        set data = SubString(data, index+1, StringLength(data))
        
        set index = CutToComma(data)
        set .totalFiles = S2I((SubString(data, 0, index)))
        set data = SubString(data, index+1, StringLength(data))
        
        set index = CutToComma(data)
        set .originalCenterX = S2R((SubString(data, 0, index)))
        set .centerX = .originalCenterX
        set data = SubString(data, index+1, StringLength(data))
        
        set index = CutToComma(data)
        set .originalCenterY = S2R(SubString(data, 0, index))
        set .centerY = .originalCenterY
        set data = SubString(data, index+1, StringLength(data))
        
        if data != "" then
            set index = CutToComma(data)
            set .extentX = S2R((SubString(data, 0, index)))
            set data = SubString(data, index+1, StringLength(data))
            
            set index = CutToComma(data)
            set .extentY = S2R(SubString(data, 0, index))
            set data = SubString(data, index+1, StringLength(data))
        endif
        
    endmethod
    
    static method create takes player saver, string name, string data returns thistype
        local thistype this
        implement GMUI_allocate_this
        
        set .folder = name
        set .player = saver
        
        if SubString(data, 0, 2) == "RS" then
            set .atOriginal = false
            set data = SubString(data, 2, StringLength(data))
        else
            set .atOriginal = true
        endif
            
        if SubString(data, 0, 1) == "v" then
            call .parseData(data)
            if .extentX == 0 then
                set .atOriginal = true
            endif
        else
            set .version = 3
            set .totalFiles = S2I(data)
        endif

        if .totalFiles < 0 then  // avoids issues, but there should be a better way. Maybe destroy when calling .loadData and no files found
            set .totalFiles = 1
        endif
        
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        if PlayerData(GetPlayerId(.player)).loadRequests.contains(this) then
            call PlayerData(GetPlayerId(.player)).loadRequests.remove(this)
        endif
        
        call .currentClear()
        call .folderClear()
        call .playerClear()
        call .totalFilesClear()
        
        call .centerXClear()
        call .centerYClear()
        call .extentXClear()
        call .extentYClear()
        
        call .atOriginalClear()
        implement GMUI_deallocate_this
    endmethod
    
    static LinkedHashSet loadingQueue
    
    private static method onTimer takes nothing returns nothing
        local PlayerData playerId
        local SaveLoader saveData

        loop
            set playerId = loadingQueue.begin() - 1
            exitwhen playerId == -1
            call loadingQueue.remove(playerId + 1)
            set saveData = playerId.loadRequests.begin()
            exitwhen saveData != playerId.loadRequests.end()
            // call BJDebugMsg("A player had finished loading.")
        endloop
        
        if playerId != -1 then
            // call BJDebugMsg(I2S(playerId) + " (" + I2S(saveData.current) + "/" + I2S(saveData.totalFiles) + ")")
            call loadingQueue.append(playerId + 1)
            if not saveData.eof() then
                call saveData.read()
                if saveData.eof() then
                    // call DisplayTextToPlayer(Player(playerId), 0., 0., "Finished loading!")
                    if GetLocalPlayer() == Player(playerId) then
                        call BlzSendSyncData("SnL_IOsize", "end")
                    endif
                endif
            endif
        endif
    endmethod
    // This function is exectued periodically, and it reads the next file of a SaveLoader that is currently being read.
    /*
    private static method onTimer takes nothing returns nothing
        local PlayerData playerId = 0
        local SaveLoader saveData

        loop
        exitwhen playerId == bj_MAX_PLAYERS
            set saveData = playerId.loadRequests.begin()

            if saveData != playerId.loadRequests.end() then
                if not saveData.eof() then
                    call saveData.read()
                    if saveData.eof() then
                        call DisplayTextToPlayer(Player(playerId), 0., 0., "Finished loading!")
                        call BlzSendSyncData("SnL_IOsize", "end")
                    endif
                endif
            endif
            set playerId = playerId + 1
        endloop

    endmethod
    */

    implement InitModule
endstruct

// This function returns a value that is async. It will be false if the file failed to load, and ONLY for 'whichPlayer'.
public function LoadSaveEx takes boolean newVersion, player whichPlayer, string path, boolean originalPosition returns boolean
    local string tooltip = BlzGetAbilityTooltip(IO_ABILITY(), 0)
    local string pathString = "p=" + path
    
    set path = path+"\\size.txt"
    
    if GetLocalPlayer() == whichPlayer then
        if not newVersion then
            call BlzSendSyncData("SnL_IOsize", pathString)
        endif
        call Preloader(path)
    endif
    if newVersion then
        if BlzGetAbilityTooltip(IO_ABILITY(), 0) == tooltip then
            return GetLocalPlayer() != whichPlayer
        else
            call BlzSendSyncData("SnL_IOsize", pathString)
            if originalPosition then
                call BlzSendSyncData("SnL_IOsize", BlzGetAbilityTooltip(IO_ABILITY(), 0))
            else
                call BlzSendSyncData("SnL_IOsize", "RS" + BlzGetAbilityTooltip(IO_ABILITY(), 0))
            endif
            call BlzSetAbilityTooltip(IO_ABILITY(), tooltip, 0)
            return true
        endif
    endif
    return false
endfunction

public function GetCurrentlyLoadingSave takes player whichPlayer returns SaveLoader
    return PlayerData(GetPlayerId(whichPlayer)).loadRequests.begin()
endfunction

// This function returns a value that is async. It will be false if the file failed to load, and ONLY for 'whichPlayer'.
public function LoadSave takes player whichPlayer, string path, boolean originalPosition returns boolean
    return LoadSaveEx(true, whichPlayer, path, originalPosition)
endfunction

public function LoadSaveOld takes player whichPlayer, string path returns nothing
    call LoadSaveEx(false, whichPlayer, path, true)
endfunction

endlibrary