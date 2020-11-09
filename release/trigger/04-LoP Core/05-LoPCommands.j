library LoPCommands initializer onInit requires CutToComma, TableStruct, ArgumentStack, LoPPlayers, LoPTip, UserDefinedRects, UnitVisualMods, GAL, LoPWarn

globals
    constant integer ACCESS_TITAN = 1
    constant integer ACCESS_USER = 0
endglobals

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

function Arguments_ParseNumber takes string number returns real
    static if LIBRARY_MathParser then
        return MathParser.calculate(number)
    else
        return R2S(number)
    endif
endfunction

function Commands_GetChatMessagePlayerNumber takes string str returns integer
    return Arguments_ParsePlayer(str)
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

function Commands_SetRGBAFromHex takes player whichPlayer, string args returns nothing
    local integer pN = GetPlayerId(whichPlayer) + 1
    local integer len = StringLength(args)
    
    if len > 3 and SubString(args, 0, 1) == "#" then
        set args = SubString(args, 1, len)
        set len = len - 1
    elseif len < 2 then
        set udg_ColorSystem_Green[pN] = 0
        set udg_ColorSystem_Green[pN] = 0
        set udg_ColorSystem_Blue[pN] = 0
        set udg_ColorSystem_Alpha[pN] = 255
        return
    endif
    set args = StringCase(args, false)
    
    
    set udg_ColorSystem_Red[pN] = AnyBase(16).decode(SubString(args,0,2))
    
    if len >= 4 then
        set udg_ColorSystem_Green[pN] = AnyBase(16).decode(SubString(args,2,4))
        
        if len >= 6 then
            set udg_ColorSystem_Blue[pN] = AnyBase(16).decode(SubString(args,4,6))
        
            if len >= 8 then
                set udg_ColorSystem_Alpha[pN] = AnyBase(16).decode(SubString(args,6,8))
            else
                set udg_ColorSystem_Alpha[pN] = 255
            endif
        else
            set udg_ColorSystem_Blue[pN] = 0
            set udg_ColorSystem_Alpha[pN] = 255
        endif
    else
        set udg_ColorSystem_Green[pN] = 0
        set udg_ColorSystem_Blue[pN] = 0
        set udg_ColorSystem_Alpha[pN] = 255
    endif
endfunction

function Commands_SetRGBAFromString takes player whichPlayer, string args, boolean forceInteger returns nothing
    local integer pN = GetPlayerId(whichPlayer) + 1
    local integer cutToComma
    
    local real red
    local real green
    local real blue
    local real alpha
    
    if CutToCharacter(args, "#") != StringLength(args) then
        call Commands_SetRGBAFromHex(whichPlayer, args)
        return
    endif

    set cutToComma = CutToCharacter(args," ")
    
    if cutToComma == StringLength(args) and StringLength(args) == 6 or StringLength(args) == 8 then
        call Commands_SetRGBAFromHex(whichPlayer, args)
        return
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
            call LoP_WarnPlayer(whichPlayer, LoPChannels.WARNING, "Value over 100: assuming the user meant to use integer RGB.")
        else
            set red   = GUMSPercentTo255(red)
            set blue  = GUMSPercentTo255(green)
            set green = GUMSPercentTo255(blue)
            set alpha = GUMSPercentTo255(alpha)
        endif
    endif
    
    set udg_ColorSystem_Red[pN] = R2I(red)
    set udg_ColorSystem_Green[pN] = R2I(green)
    set udg_ColorSystem_Blue[pN] = R2I(blue)
    set udg_ColorSystem_Alpha[pN] = R2I(255 - alpha)
endfunction


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
        
    
    static method getCommand takes nothing returns string
        return Args.getString(0)
    endmethod
    
    static method getArguments takes nothing returns string
        return Args.getString(1)
    endmethod
endstruct

public struct Globals extends array
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticAgentField("evaluator","trigger")
endstruct

public function ExecuteCommand takes string chatMsg returns boolean
    local integer cutToComma
    local string beforeSpace
    local string arguments
    local LoP_Command command
    local triggercondition condition
    local trigger evaluator
    local boolean value
    
    local integer accessLevel
    
    if Globals.evaluator == null then  // Initialization
        set Globals.evaluator = CreateTrigger()
    endif
    
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
            call LoPHints.displayFromList(GetTriggerPlayer(), command.hints)
        endif
    
        if accessLevel >= command.accessLevel and LoP_PlayerData.get(GetTriggerPlayer()).commandsEnabled and not LoP_Command.disabled then
            set evaluator = Globals.evaluator
            debug call BJDebugMsg("Command called: " + beforeSpace)
            
            set condition = TriggerAddCondition(evaluator, command.boolexpr)
            
            call Args.setString(0, beforeSpace)
            call Args.setString(1, arguments)
            call TriggerEvaluate(evaluator)
            call Args.freeString(0)
            call Args.freeString(1)
            call TriggerRemoveCondition(evaluator, condition)
            
            set condition = null
            set evaluator = null
        else
            call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.ERROR, "You do not have permission to use this command.")
        endif
        
        return true
    endif

    return false
endfunction

public function MessageHandler takes nothing returns boolean
    return ExecuteCommand(GetEventPlayerChatString())
endfunction


endlibrary