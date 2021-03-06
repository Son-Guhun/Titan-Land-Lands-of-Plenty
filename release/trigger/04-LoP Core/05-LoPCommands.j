library LoPCommands initializer onInit requires CutToComma, TableStruct, ArgumentStack, LoPStdLib, LoPPlayers, LoPTip, UserDefinedRects, UnitVisualMods, GAL, LoPWarn, CallbackTools, RGBA

globals
    constant integer ACCESS_TITAN = 1
    constant integer ACCESS_USER = 0
endglobals

// ======================================
// Argument Parsing Utils
// ======================================

// Parsers a player argument and returns the respective player id.
// "red" -> 0
// "dg" -> 10
// "light blue" -> 9
// "5" -> 5
// "999" -> 999 (invalid player numbers are returned as is)
function Arguments_ParsePlayer takes string str returns integer
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

// Parses a number argument.
// If MathParser is available, MathParser.calculate() is used.
// Otherwise R2S() is used.
function Arguments_ParseNumber takes string number returns real
    static if LIBRARY_MathParser then
        return MathParser.calculate(number)
    else
        return R2S(number)
    endif
endfunction

// Equivalent to Arguments_ParsePlayer.
function Commands_GetChatMessagePlayerNumber takes string str returns integer
    return Arguments_ParsePlayer(str)
endfunction

/* 
    Traverses a list until it finds a string or a string pair that can be converted to a player.

    If there is a match, the strings are cleared from the list (value at their index is set to ""),
and the player number is returned.
    
    If the string "all" is found, -1 is returned.
    
    If there is no match, 0 is returned.
*/
globals
    private constant integer ALL = -1
endglobals

function GetNextPlayerArgument takes ArrayList_string list returns integer
    local string lastVal
    local string curVal
    local integer number
    local integer i = 1
    
    if list.size > 0 then
        set lastVal = list[0]
        set number = Commands_GetChatMessagePlayerNumber(lastVal)
        
        if number != 0 then
            set list[0] = ""
            return number
        endif
        if lastVal == "all" then
            return ALL
        endif
        
        loop
            exitwhen i >= list.size
            set curVal = list[i]
            
            if curVal == "all" then
                set list[i] = ""
                return ALL
            endif
            set number = Commands_GetChatMessagePlayerNumber(lastVal + " " + curVal)
            if number != 0 then
                set list[i] = ""
                set list[i-1] = ""
                return number
            endif
            set number = Commands_GetChatMessagePlayerNumber(curVal)
            if number != 0 then
                set list[i] = ""
                return number
            endif

            set lastVal = list[i]
            set i = i + 1
        endloop
    endif
    
    return 0
endfunction

// Used by rgb commands.
function Commands_SetRGBAFromHex takes player whichPlayer, string args returns RGBA
    local integer pN = GetPlayerId(whichPlayer) + 1
    local integer len = StringLength(args)
    local RGBA color
    
    if len > 3 and SubString(args, 0, 1) == "#" then
        set args = SubString(args, 1, len)
        set len = len - 1
    elseif len < 2 then
        return RGBA.create(0, 0, 0, 255)
    endif
    set args = StringCase(args, false)
    
    
    set color = RGBA.newRed(AnyBase(16).decode(SubString(args,0,2)))
    
    if len >= 4 then
        set color = color.withGreen(AnyBase(16).decode(SubString(args,2,4)))
        
        if len >= 6 then
            set color = color.withBlue(AnyBase(16).decode(SubString(args,4,6)))
        
            if len >= 8 then
                set color = color.withAlpha(AnyBase(16).decode(SubString(args,6,8)))
            else
                set color = color.withAlpha(255)
            endif
        else
            set color = color.withBlue(255).withAlpha(255)
        endif
    else
        set color = color.withGreen(255).withBlue(255).withAlpha(255)
    endif

    return color
endfunction

globals
    private key INT_CONV_MSGKEY
endglobals

// Used by rgb commands.
function Commands_SetRGBAFromString takes player whichPlayer, string args, boolean forceInteger returns RGBA
    local integer pN = GetPlayerId(whichPlayer) + 1
    local integer cutToComma
    
    local real red
    local real green
    local real blue
    local real alpha
    
    if CutToCharacter(args, "#") != StringLength(args) then
        return Commands_SetRGBAFromHex(whichPlayer, args)
    endif

    set cutToComma = CutToCharacter(args," ")
    
    if cutToComma == StringLength(args) and StringLength(args) == 6 or StringLength(args) == 8 then
        return Commands_SetRGBAFromHex(whichPlayer, args)
    endif
    
    set red = Arguments_ParseNumber(SubString(args,0,cutToComma))
    
    set args = SubString( args , cutToComma+1 , StringLength(args) )
    set cutToComma = CutToCharacter(args," ")
    set green = Arguments_ParseNumber(SubString(args,0,cutToComma))

    set args = SubString(args,cutToComma+1, StringLength(args))
    set cutToComma = CutToCharacter(args," ")
    set blue = Arguments_ParseNumber(SubString(args,0,cutToComma))

    set args = SubString(args,cutToComma+1, StringLength(args))
    set cutToComma = CutToCharacter(args," ")
    set alpha = Arguments_ParseNumber(SubString(args,0,cutToComma))
    
    if not forceInteger then
        if red > 100. or green > 100. or blue > 100. or alpha > 100. then
            call LoP_WarnPlayerTimeout(whichPlayer, LoPChannels.WARNING, INT_CONV_MSGKEY, 60., "Value over 100: assuming the user meant to use integer RGB.")
        else
            set red   = LoP.UVS.utils.PercentTo255(red)
            set green = LoP.UVS.utils.PercentTo255(green)
            set blue  = LoP.UVS.utils.PercentTo255(blue)
            set alpha = LoP.UVS.utils.PercentTo255(alpha)
        endif
    endif

    return RGBA.create(R2I(red), R2I(green), R2I(blue), 255 - R2I(alpha))
endfunction

// ======================================
// Selection Utils
// ======================================

// The filter is only called for the units selected by the player.
// Enums selected units.
// - If a Controller is selected, then adds all units in the player's control group to 'whichGroup' and returns 0.
// - Otherwise calls GUDR_SwapGroup_UnitsInsideUDR.
//   - If a RectGenerator is selected, adds all units inside the Rect to 'whichGroup' and returns the generator's handle id.
//   - Otherwise adds selected units to 'whichGroup' and returns 0.
function Commands_EnumSelectedCheckForGenerator takes group whichGroup, player whichPlayer, boolexpr filter returns integer
    call GroupEnumUnitsSelected(whichGroup, whichPlayer, filter)
    
    if GetUnitTypeId(FirstOfGroup(whichGroup)) == 'h0KD' and BlzGroupGetSize(whichGroup) == 1 then
        call GroupClear(whichGroup)
        call BlzGroupAddGroupFast(udg_Player_ControlGroup[GetPlayerId(whichPlayer) + 1], whichGroup)
        return 0
    endif
    
    return GUDR_SwapGroup_UnitsInsideUDR(whichGroup, false, null)
endfunction

// ======================================
// Overflow Utils
// ======================================

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

// ======================================
// LoP_Command API
// ======================================

struct LoP_Command extends array
    
    static method fromString takes string str returns LoP_Command
        return StringHash(str)
    endmethod
    
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticPrimitiveField("disabled","boolean")

    //! runtextmacro TableStruct_NewAgentField("boolexpr","boolexpr")
    //! runtextmacro TableStruct_NewPrimitiveField("string","string")
    //! runtextmacro TableStruct_NewPrimitiveField("accessLevel","integer")
    //! runtextmacro TableStruct_NewStructField("hints","ArrayList")
    
    static method create takes string str, integer access, boolexpr expr returns LoP_Command
        local LoP_Command this = LoP_Command.fromString(str)
        if not .stringExists() then
            set .boolexpr = expr
            set .string = str
            set .accessLevel = access
        elseif .string == str then
            // Handle: Updating command.
        else
            call BJDebugMsg("Command creation error: Hash collision with (" + .string + ") when creating (" + str + ").")
        endif
        return this
    endmethod
    
    method hasHints takes nothing returns boolean
        return .hintsExists()
    endmethod
    
    method createChained takes  string str, integer access, boolexpr expr returns LoP_Command
        return 0*this + create(str, access, expr)
    endmethod
    
    method addHint takes integer hint returns thistype
        if not .hintsExists() then
            set .hints = ArrayList.create()
        endif
        call .hints.append(hint)
        return this
    endmethod
    
    method useHintsFrom takes string command returns LoP_Command
        set .hints = thistype(StringHash(command)).hints
        return this
    endmethod
        
    implement ArgumentStack
    
    static method getCommand takes nothing returns string
        return stack.string[0]
    endmethod
    
    static method getArgumentsRaw takes nothing returns string
        return stack.string[1]
    endmethod
    
    static method getArguments takes nothing returns string
        return StringTrim(getArgumentsRaw())
    endmethod
endstruct

// Must be used while GetTriggerPlayer() is defined.
public function ExecuteCommand takes string chatMsg returns boolean
    local integer cutToComma
    local string beforeSpace
    local string arguments
    local LoP_Command command
    local boolean value
    
    local integer accessLevel
    
    set cutToComma = CutToCharacter(chatMsg, " ")
    set beforeSpace = SubString(chatMsg, 0, cutToComma)
    if cutToComma < StringLength(chatMsg) then
        set arguments = SubString(chatMsg, cutToComma+1, StringLength(chatMsg))
    else
        set arguments = ""
    endif
    set command = StringHash(beforeSpace)
    
    
    if GetTriggerPlayer() == udg_GAME_MASTER then
        set accessLevel = ACCESS_TITAN
    else
        set accessLevel = ACCESS_USER
    endif
    
    
    if beforeSpace == command.string then
        if command.hasHints() then
            call LoPHints.displayFromListNonRandom(GetTriggerPlayer(), command.hints)
        endif
    
        if accessLevel >= command.accessLevel and LoP_PlayerData.get(GetTriggerPlayer()).commandsEnabled and not LoP_Command.disabled then
            debug call BJDebugMsg("Command called: " + beforeSpace)
            
            call LoP_Command.newStack()
            set LoP_Command.stack.string[0] = beforeSpace
            set LoP_Command.stack.string[1] = arguments
            call CallbackTools_EvaluateBoolexpr(command.boolexpr)
            call LoP_Command.stack.flush()
            call LoP_Command.pop()
            
        else
            call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.ERROR, "You do not have permission to use this command.")
        endif
        
        return true
    endif

    return false
endfunction

// Must be used while GetTriggerPlayer() is defined.
public function MessageHandler takes nothing returns boolean
    return ExecuteCommand(GetEventPlayerChatString())
endfunction


endlibrary