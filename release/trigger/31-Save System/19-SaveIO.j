library SaveIO initializer Init requires TableStruct, GMUI, GLHS, SaveNLoad

private struct PlayerData extends array

    //! runtextmacro TableStruct_NewStructField("loadRequests", "LinkedHashSet")

endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        local PlayerData playerId = 0


        loop
        exitwhen playerId == bj_MAX_PLAYERS
            set playerId.loadRequests = LinkedHashSet.create()
            set playerId = playerId + 1
        endloop

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
    static constant integer VERSION = 3
    //! runtextmacro TableStruct_NewPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("linesWritten", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewHandleField("player", "player")

    private method start takes nothing returns nothing
        if GetLocalPlayer() == .player then
            call PreloadGenStart()
            call PreloadGenClear()
        endif
    endmethod
    
    private method flush takes nothing returns nothing
        local string path = .folder + "\\" + I2S(.current) + ".txt"
        
        if GetLocalPlayer() == .player then
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
    
    method destroy takes nothing returns nothing
        local string filePathSize = .folder + "\\size.txt"
        local string filePathVersion = .folder + "\\version.txt"
        local string size = SaveNLoad_FormatString("SnL_IOsize", I2S(.current + 1))
        local string ver = I2S(.VERSION)
    
        call .flush()
        if GetLocalPlayer() == .player then
            call PreloadGenStart()
            call PreloadGenClear()
            call Preload(size)
            call PreloadGenEnd(filePathSize)

            //Output the major version with which the save has been made (compatibility)
            call PreloadGenStart()
            call PreloadGenClear()
            call Preload(ver)
            call PreloadGenEnd(filePathVersion)
        endif
        
        call .linesWrittenClear()
        call .currentClear()
        call .folderClear()
        call .playerClear()
    endmethod

    
endstruct

private struct SaveLoader extends array
    implement GMUIUseGenericKey

    //! runtextmacro TableStruct_NewPrimitiveField("current", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("totalFiles", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("folder", "string")
    //! runtextmacro TableStruct_NewHandleField("player", "player")

    // Reads the current file and increments the counter.
    private method read takes nothing returns nothing
        local string path = .folder + "\\" + I2S(.current) + ".txt"

        if GetLocalPlayer() == .player then
            call Preloader(path)
        endif

        set .current = .current + 1
    endmethod

    // Returns whether all files in the save folder have been read.
    private method eof takes nothing returns boolean
        return .current == .totalFiles
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
                    call saveData.destroy()
                    call playerId.loadRequests.remove(saveData)
                endif
            endif
            set playerId = playerId + 1
        endloop

    endmethod
    
    // This method does not immediately read the file. It puts it in queue for reading.
    method loadData takes nothing returns nothing
        if not PlayerData(GetPlayerId(.player)).loadRequests.contains(this) then
            call PlayerData(GetPlayerId(.player)).loadRequests.append(this)
        endif
    endmethod
    
    static method create takes player saver, integer size, string name returns thistype
        local integer this
        implement GMUI_allocate_this
        
        set .folder = name
        set .player = saver
        set .totalFiles = size
        
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        call .currentClear()
        call .folderClear()
        call .playerClear()
        call .totalFilesClear()
    endmethod

    implement InitModule
endstruct

globals
    private string array currentSave
endglobals

public function onReceiveSize takes nothing returns nothing
    call SaveLoader.create(GetTriggerPlayer(), S2I(BlzGetTriggerSyncData()), currentSave[GetPlayerId(GetTriggerPlayer())]).loadData()
endfunction

public function LoadSave takes player whichPlayer, string path returns nothing
    set currentSave[GetPlayerId(whichPlayer)] = path
    call Preloader(path+"\\size.txt")
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

private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    
    call TriggerAddAction(t, function onReceiveSize)
    call TriggerRegisterAnyPlayerSyncEvent(t, "SnL_IOsize", false)
endfunction

endlibrary