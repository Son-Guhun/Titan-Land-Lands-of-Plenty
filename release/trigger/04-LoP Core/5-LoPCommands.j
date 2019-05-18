library LoPCommands initializer onInit requires CutToComma, TableStruct, ArgumentStack, LoPPlayers

globals
    constant integer ACCESS_TITAN = 1
    constant integer ACCESS_USER = 0
endglobals
// Save string. MUST MATCH.





struct LoP_Command extends array
    
    static method fromString takes string str returns LoP_Command
        return StringHash(str)
    endmethod

    //! runtextmacro TableStruct_NewHandleField("boolexpr","boolexpr")
    //! runtextmacro TableStruct_NewPrimitiveField("string","string")
    //! runtextmacro TableStruct_NewPrimitiveField("accessLevel","integer")
    
    static method create takes string str, integer access, boolexpr expr returns LoP_Command
        local LoP_Command this = LoP_Command.fromString(str)
        if not .stringExists() then
            set .boolexpr = expr
            set .string = str
            set .accessLevel = access
        elseif .string == str then
            // Updating command.
        else
            // Hash collision
        endif
        return this
    endmethod
    
    static method getCommand takes nothing returns string
        return Args.getString(0)
    endmethod
    
    static method getArguments takes nothing returns string
        return Args.getString(1)
    endmethod
endstruct

public struct Globals extends array
    private static key static_members_key

    //! runtextmacro TableStruct_NewStaticHandleField("trigger","trigger")
    //! runtextmacro TableStruct_NewStaticHandleField("evaluator","trigger")
endstruct



private function onChatMessage takes nothing returns boolean
    local string chatMsg
    local integer cutToComma
    local string beforeSpace
    local string arguments
    local LoP_Command command
    local triggercondition condition
    local trigger evaluator
    
    local integer accessLevel
    
    if not LoP_PlayerData.get(GetTriggerPlayer()).commandsEnabled then
        return false
    endif
    
    set chatMsg = GetEventPlayerChatString()
    set cutToComma = CutToCharacter(chatMsg, " ")
    set beforeSpace = SubString(chatMsg, 0, cutToComma)
    if cutToComma < StringLength(chatMsg) then
        set arguments = SubString(chatMsg, cutToComma+1, StringLength(chatMsg))
    else
        set arguments = ""
    endif
    set command = StringHash(beforeSpace)
    
    
    if GetTriggerPlayer() == udg_GAME_MASTER then
        set accessLevel = 1
    else
        set accessLevel = 0
    endif
    
    
    debug call BJDebugMsg("Command called")
    if beforeSpace == command.string and accessLevel >= command.accessLevel then
        set evaluator = Globals.evaluator
        debug call BJDebugMsg(beforeSpace)
        
        set condition = TriggerAddCondition(evaluator, command.boolexpr)
        
        call Args.setString(0, beforeSpace)
        call Args.setString(1, arguments)
        call TriggerEvaluate(evaluator)
        call Args.freeString(0)
        call Args.freeString(1)
        call TriggerRemoveCondition(evaluator, condition)
        
        set condition = null
        set evaluator = null
    endif

    return false
endfunction




function onInit takes nothing returns nothing
    local integer playerId = 0
    local trigger trig = CreateTrigger()
    
    set Globals.trigger = trig
    set Globals.evaluator = CreateTrigger()
    
    loop
    exitwhen playerId == bj_MAX_PLAYERS
        if GetPlayerSlotState(Player(playerId)) == PLAYER_SLOT_STATE_PLAYING then
            call TriggerRegisterPlayerChatEvent(trig, Player(playerId), "'", false)
            call TriggerRegisterPlayerChatEvent(trig, Player(playerId), "-", false)
        endif
        set playerId = playerId + 1
    endloop
    call TriggerAddCondition(trig, Condition(function onChatMessage))

    set trig = null
endfunction




endlibrary