library SaveIO requires TableStruct, GMUI, GLHS, Rawcode2String, optional RectGenerator

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
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("linesWritten", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewReadonlyHandleField("player", "player")
    
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
    
    private method getMetaString takes nothing returns string
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

struct SaveLoader extends array
    implement GMUIUseGenericKey

    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("version", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("centerX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("centerY", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("minX", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("minY", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("maxX", "real")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("maxY", "real")
    
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("totalFiles", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewReadonlyHandleField("player", "player")
    
    method isRectSave takes nothing returns boolean
        return this.minX != 0
    endmethod

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
    
    private method parseData takes string data returns nothing
        
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
        if PlayerData(GetPlayerId(.player)).loadRequests.contains(this) then
            call PlayerData(GetPlayerId(.player)).loadRequests.remove(this)
        endif
        implement GMUI_deallocate_this
    endmethod
    
        // This function is exectued every 0.5 seconds, and it reads the next file of a SaveData that is currently being read.
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

    implement InitModule
endstruct

// This function returns a value that is async. It will be false if the file failed to load, and ONLY for 'whichPlayer'.
public function LoadSaveEx takes boolean newVersion, player whichPlayer, string path, boolean originalPosition returns boolean
    local string tooltip = BlzGetAbilityTooltip(IO_ABILITY(), 0)
    local string pathString = "p=" + path
    
    set path = path+"\\size.txt"
    
    if GetLocalPlayer() == whichPlayer then
        call Preloader(path)
        if not newVersion then
            call BlzSendSyncData("SnL_IOsize", pathString)
        endif
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