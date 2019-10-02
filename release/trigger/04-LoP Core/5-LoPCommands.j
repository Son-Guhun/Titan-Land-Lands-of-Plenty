library LoPCommands initializer onInit requires CutToComma, TableStruct, ArgumentStack, LoPPlayers, UserDefinedRects

globals
    constant integer ACCESS_TITAN = 1
    constant integer ACCESS_USER = 0
endglobals
// Save string. MUST MATCH.

/*
 Old Commands API
*/
function Commands_GetArguments takes nothing returns string
    return SubString(GetEventPlayerChatString(), StringLength(GetEventPlayerChatStringMatched()), StringLength(GetEventPlayerChatString()))
endfunction

function Commands_StartsWithCommand takes nothing returns boolean
    return SubString(GetEventPlayerChatString(), 0, StringLength(GetEventPlayerChatStringMatched())) == GetEventPlayerChatStringMatched()
endfunction

// The filter is only called for the units selected by the player.
function Commands_EnumSelectedCheckForGenerator takes group whichGroup, player whichPlayer, boolexpr filter returns integer
    call GroupEnumUnitsSelected(whichGroup, whichPlayer, filter)
    
    if GetUnitTypeId(FirstOfGroup(whichGroup)) == 'h0KD' and BlzGroupGetSize(whichGroup) == 1 then
        call GroupClear(whichGroup)
        call BlzGroupAddGroupFast(udg_Player_ControlGroup[GetPlayerId(whichPlayer) + 1], whichGroup)
        return 0
    endif
    
    return GUDR_SwapGroup_UnitsInsideUDR(whichGroup, false, null)
endfunction

function Commands_GetChatMessagePlayerNumber takes string str returns integer
    local integer s2i = S2I(str)
    local integer strHash
    if  s2i == 0 then//and str != "0" then
        set strHash = StringHash(str)
        if HaveSavedInteger(udg_Hashtable_1, 0, strHash) then
            return LoadInteger(udg_Hashtable_1, 0, strHash)
        endif
    endif
    return s2i
endfunction

/*
 Command Overflow check
*/
function CheckCommandOverflow takes nothing returns boolean
    if udg_Commands_Counter < udg_Commands_Counter_Max then
        set udg_Commands_Counter = ( udg_Commands_Counter + 1 )
        return true
    elseif udg_Commands_Counter == udg_Commands_Counter_Max then
        call DisplayTextToPlayer( GetTriggerPlayer(), 0, 0, "Command Overflow! Execution stopped.\n Run the command again until it is finished.")
        set udg_Commands_Counter = ( udg_Commands_Counter + 1 )
    endif
    return false
endfunction

function Commands_SetMaximumExecutions takes integer max returns nothing
    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = max
endfunction

function Commands_CheckOverflow takes nothing returns boolean
    return CheckCommandOverflow()
endfunction


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
            // Handle: Updating command.
        else
            // Handle: Hash collision.
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
        if GetPlayerController(Player(playerId)) == MAP_CONTROL_USER then
            call TriggerRegisterPlayerChatEvent(trig, Player(playerId), "'", false)
            call TriggerRegisterPlayerChatEvent(trig, Player(playerId), "-", false)
        endif
        set playerId = playerId + 1
    endloop
    call TriggerAddCondition(trig, Condition(function onChatMessage))

    set trig = null
endfunction




endlibrary