library SaveIO requires TableStruct, GMUI, GLHS, Rawcode2String, PlayerUtils, optional RectGenerator
/*
This library requires some trigger to be listening to SnL_IOsize sync data event in order to work.

In the Save System folder, the RectSaveLoader library provides such a trigger.

Functions:

    async boolean SaveIO_LoadSave(player whichPlayer, string path, boolean originalPosition)
    .
    . This function returns a value that is async:
    .   It will return true for any player that is not 'whichPlayer'.
    .   It will return false for 'whichPlayer' if the file failed to be read.

    nothing SaveIO_LoadSaveOld(player whichPlayer, string path)
    .
    . This function is used in LoP to load old save formats.
    
    
    string SaveIO_CleanUpString(string str)
    .
    . This function makes all occurences of quotation marks compatible with Preload I/O by converting them to '' (two single quotes).


. This struct is used to save strings to a file.
.
struct SaveWriter:

    Constants:
            integer MAX_LINES
            integer VERSION
    
    Fields:
        integer current
        integer linesWritten
        string folder
        player player
        
        real centerX
        real centerY
        real extentX
        real extentY

    Methods:
    
        boolean isRectSave()
        
        nothing write(string str)
        
        nothing destroy()  -> destroys this instance and flushes data to size.txt file.
        
        Constructors:
            thistype create(player saver, string name)


. This struct is used to read a file that has been saved using SaveWriter.
.
struct SaveLoader extends array

    Fields:
        integer version
        real originalCenterX
        real originalCenterY
        
        real centerX
        real centerY
        real extentX
        real extentY
        
        boolean atOriginal
        
        integer current
        integer totalFiles
        string folder
        player player

    
    Methods:
        boolean isRectSave()
        
        . This method does not immediately read the file. It puts it in queue for reading.
        . You can assume that calling this method will destroy the SaveLoader once all data has been synced.
        .
        nothing loadData()
        
        nothing destroy()
        
        
        Constructors:
            thistype create(player saver, string name, string data)
    
endstruct

*/

private struct PlayerData extends array
    implement DebugPlayerStruct

    //! runtextmacro TableStruct_NewStructField("loadRequests", "LinkedHashSet")

endstruct

// Formats a string for sending sync data using BlzSendSyncData.
public function FormatString takes string prefix, string data returns string
    return prefix + "|" + data
endfunction

// Formats a string for local I/O, using BlzSetAbilityTooltip (instant read).
private function FormatStringLocal takes integer prefix, string data returns string
    return "\" )\ncall BlzSetAbilityIcon('" + ID2S(prefix) + "',\"" + data + "\")\n//"
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


private module InitModule
    private static method onInit takes nothing returns nothing
        local PlayerData playerId = 0
        local integer i


        loop
        exitwhen playerId == bj_MAX_PLAYERS
            set playerId.loadRequests = LinkedHashSet.create()
            set playerId = playerId + 1
        endloop
        
        set abilities[1] = 'Sca6'
        set abilities[2] = 'Sca1'
        set abilities[3] = 'Sca4'
        set abilities[4] = 'Sca5'
        set abilities[5] = 'Sca2'
        set abilities[6] = 'Sca3'
        set abilities[7] = 'Amnz'
        set abilities[8] = 'Amnx'
        set abilities[9] = 'Awan'
        set abilities[10] = 'Abdl'
        set abilities[11] = 'Abds'
        set abilities[12] = 'Abdt'
        set abilities[13] = 'Achd'
        set abilities[14] = 'Agld'
        set abilities[15] = 'Amin'
        set abilities[16] = 'Apiv'
        set abilities[17] = 'Argd'
        set abilities[18] = 'Argl'
        set abilities[19] = 'Arlm'
        set abilities[20] = 'Arng'
        
        set i = 0
        loop
        exitwhen abilities[i] == 0
            call BlzSetAbilityIcon(abilities[i], "__")
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


struct SaveWriter extends array
    implement ExtendsTable

    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("current", "integer")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("linesWritten", "integer")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("folder", "string")
    //! runtextmacro HashStruct_NewReadonlyHandleField("player", "player")
    
    //! runtextmacro HashStruct_NewPrimitiveField("centerX", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("centerY", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("extentX", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("extentY", "real")
    
    //! runtextmacro HashStruct_NewStructField("buffer", "Table")
    
    method isValid takes nothing returns boolean
        return .folder_exists()
    endmethod
    
    method isRectSave takes nothing returns boolean
        return this.extentX != 0
    endmethod

    static constant integer MAX_LINES = 20
    static constant integer VERSION = 7

    private method flush takes nothing returns nothing
        local string path = .folder + "\\" + I2S(.current) + ".txt"
        local integer i = 1
        local integer totalLines = .linesWritten
        local Table buffer = .buffer
        
        if GetLocalPlayer() == .player then
            call PreloadGenStart()
            call PreloadGenClear()
            
            loop
                exitwhen i > totalLines
                call Preload(buffer.string[i])
                set i = i + 1
            endloop
        
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
            set .linesWritten = 1
        else
            set .linesWritten = .linesWritten + 1
        endif
        
        set .buffer.string[.linesWritten] = FormatStringLocal(abilities[.linesWritten], str)
    endmethod
    
    
    static method create takes player saver, string name returns thistype
        local integer this = Table.create()
        
        set .folder = name
        set .player = saver
        set .buffer = Table.create()
        
        return this
    endmethod
    
    
    private method getMetaString takes nothing returns string
        return FormatStringLocal(IO_ABILITY(), "v" + I2S(.VERSION) + "," + I2S(.current) + "," + R2S(.centerX) + "," + R2S(.centerY) + "," + /*
                        */  R2S(.extentX) + "," + R2S(.extentY))
    endmethod
    
    
    method destroy takes nothing returns nothing
        local string filePathSize = .folder + "\\size.txt"
        local string metaString

        if .isValid() then
            call .flush()
            set metaString = .getMetaString()  // Order matters for line and .flush()
            if GetLocalPlayer() == .player then
                call PreloadGenStart()
                call PreloadGenClear()
                call Preload(metaString)
                call Preload( "\" )
endfunction
function SomeRandomName takes nothing returns nothing //")  // Not calling PreloadEnd in a preload file greatly improves loading performance.
                call PreloadGenEnd(filePathSize)
            endif
            
            call .buffer.destroy()
            
            call .tab.destroy()
        endif
    endmethod

    
endstruct

globals
    integer array abilities
endglobals

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
    
    static method handlerV6 takes string errorString returns nothing
        local integer i = 1
        local integer index
        local string icon
        local integer abil
        local boolean end = false
        
        loop
            set abil = abilities[i]
            exitwhen abil == 0
            set icon = BlzGetAbilityIcon(abil)
            if icon == "__" then
                set end = true
            else
                set index = CutToCharacter(icon, "|")
                call BlzSendSyncData(SubString(icon, 0, index) + "", SubString(icon, index + 1, StringLength(icon))+"")
                call BlzSetAbilityIcon(abil, "__")
                if end then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., errorString)
                endif
            endif
            set i = i + 1
        endloop
        
        if i == 1 then
            call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., errorString)
        endif
    endmethod

    // Reads the current file and increments the counter.
    private method read takes nothing returns nothing
        local string path = .folder + "\\" + I2S(.current) + ".txt"
        local string errorString = "Unable to validate file " + I2S(.current) + ".txt of save. Some units may have failed to load."
        local string tooltip = BlzGetAbilityTooltip(IO_ABILITY(), 0)

        if GetLocalPlayer() == .player then
            call Preloader(path)
            if .version >= 6 then
                call thistype.handlerV6(errorString)
            elseif .version >= 4 then
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

        if .totalFiles < 1 then  // avoids issues, but there should be a better way. Maybe destroy when calling .loadData and no files found
            call DisplayTextToPlayer(saver, 0., 0., "Save metadata could not be read (probably Reforged bug). Attempting to load with workaround.")
            set .totalFiles = 300
            set .centerX = 0
            set .centerY = 0
            set .extentX = 0
            set .version = 3
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
    
    // This function is exectued periodically, and it reads the next file of a SaveLoader that is currently being read.
    private static method onTimer takes nothing returns nothing
        local PlayerData playerId
        local SaveLoader saveData

        loop
            set playerId = loadingQueue.begin() - 1
            exitwhen playerId == -1
            call loadingQueue.remove(playerId + 1)
            set saveData = playerId.loadRequests.begin()
            exitwhen saveData != playerId.loadRequests.end()
        endloop
        
        if playerId != -1 then
            call loadingQueue.append(playerId + 1)
            if not saveData.eof() then
                call saveData.read()

                if saveData.eof() then
                    if User.fromLocal() == playerId then
                        call BlzSendSyncData("SnL_IOsize", "end")
                        call BlzFrameSetVisible(loadBar, false)
                    endif
                elseif User.fromLocal() == playerId then
                    call BlzFrameSetText(loadBarText, I2S(saveData.current)+"/"+I2S(saveData.totalFiles))
                    call BlzFrameSetValue(loadBar, 100.*I2R(saveData.current)/saveData.totalFiles)
                    call BlzFrameSetVisible(loadBar, true)
                endif
            endif
        endif
    endmethod

    implement InitModule
endstruct

/*
    new -> should hold the header string. If it is equal to original, that means the file could not be read.

    Returns true if the current local player is different from whichPlayer.
    
    Returns true for whichPlayer if new != original.
    Returns false for whichPlayer if new == original.
*/
private function SendIOSyncHeader takes player whichPlayer, boolean originalPosition, string pathString, string new, string original returns boolean
        if new == original then
            return GetLocalPlayer() != whichPlayer
        else
            call BlzSendSyncData("SnL_IOsize", pathString)
            if originalPosition then
                call BlzSendSyncData("SnL_IOsize", new)
            else
                call BlzSendSyncData("SnL_IOsize", "RS" + new)
            endif
            return true
        endif
endfunction

// This function returns a value that is async. It will be false if the file failed to load, and ONLY for 'whichPlayer'.
public function LoadSaveEx takes boolean newVersion, player whichPlayer, string path, boolean originalPosition returns boolean
    local string icon = BlzGetAbilityIcon(IO_ABILITY())
    local string tooltip = BlzGetAbilityTooltip(IO_ABILITY(), 0)
    local string pathString = "p=" + path
    local boolean ret = false
    
    set path = path+"\\size.txt"
    
    if GetLocalPlayer() == whichPlayer then
        if not newVersion then
            call BlzSendSyncData("SnL_IOsize", pathString)
        endif
        call Preloader(path)
    endif
    if newVersion then
        if SendIOSyncHeader(whichPlayer, originalPosition, pathString, BlzGetAbilityIcon(IO_ABILITY()), icon) then
            set ret = true
        elseif SendIOSyncHeader(whichPlayer, originalPosition, pathString, BlzGetAbilityTooltip(IO_ABILITY(), 0), tooltip) then
            set ret = true
        endif
    endif
    
    call BlzSetAbilityIcon(IO_ABILITY(), icon)
    call BlzSetAbilityTooltip(IO_ABILITY(), tooltip, 0)
    return ret
endfunction

public function GetCurrentlyLoadingSave takes player whichPlayer returns SaveLoader
    return PlayerData(GetPlayerId(whichPlayer)).loadRequests.begin()
endfunction

// This function returns a value that is async:
    // It will return true for any player that is not 'whichPlayer'
    // It will return false for 'whichPlayer' if the file failed to load.
public function LoadSave takes player whichPlayer, string path, boolean originalPosition returns boolean
    return LoadSaveEx(true, whichPlayer, path, originalPosition)
endfunction

public function LoadSaveOld takes player whichPlayer, string path returns nothing
    call LoadSaveEx(false, whichPlayer, path, true)
endfunction

endlibrary