function StartsString takes string str, string subStr returns boolean
    local integer strSize = StringLength(str)
    local integer subStrSize = StringLength(subStr)
    local integer i = 0
    
    //If it's an empty string, return false as a convention
    if strSize == 0 or subStrSize == 0 then
        return false
    endif
    
    //Compare letter by letter until mismatch or end of string
    loop
    exitwhen i >= strSize or i >= subStrSize
        if SubString(str, i, i+1) != SubString(subStr, i, i+1) then
            return false //return false for mismatch
        else
        endif
        set i = i + 1
    endloop
    
    //No mismatches found, so return true
    return true
endfunction

function HasString takes string str, string subStr returns boolean
    local integer strSize = StringLength(str)
    local integer subStrSize = StringLength(subStr)
    local integer i = 0
    local integer j = 0
    
    // If it's an empty string, return false as a convention
    if strSize == 0 or subStrSize == 0 then
        return false
    endif
    
    // Compare letter by letter until we iterate over either string
    loop
    exitwhen i >= strSize or j >= subStrSize
        if SubString(str, i, i+1) != SubString(subStr, j, j+1) then
            set j = 0  // Reset substring comparison
        else
            set j = j + 1
        endif
        set i = i + 1
    endloop
    
    // If we itared over the whole subStr, there is a match inside of str
    return j>= subStrSize 
endfunction

function GetThirdName takes string str returns string
    //Skip first word (Deco)
    set str = SubString(str,CutToCharacter(str," ")+1,StringLength(str))
    //Skip second word (Builder or Modifier)
    set str = SubString(str,CutToCharacter(str," ")+1,StringLength(str))
    //Use third word (the proper name that we want)
    return SubString(str,0,CutToCharacter(str," "))
endfunction

function SearchSelectFilter takes nothing returns boolean
    local string str
    
    if IsUnitType(GetFilterUnit(), UNIT_TYPE_PEON) and (LoP_IsUnitDecoBuilder(GetFilterUnit()) or LoP_IsUnitDecoration(GetFilterUnit())) then
        //Get full unit name (Deco Builder/Modifier [Proper Name])
        set str = GetThirdName(GetUnitName(GetFilterUnit()))
        
        //Compare strings and Select Unit for local player only
        if StartsString(udg_System_searchStr, StringCase(str,true)) then
            call ShowUnit(GetFilterUnit(), true)
            if GetLocalPlayer() == GetTriggerPlayer() then
                call SelectUnit(GetFilterUnit(), true)
            endif
        endif
    endif
    
    //Return false because this is a condition
    return false
endfunction

function SelcHandler takes player whichPlayer, string name returns nothing
    local integer i = 0
    local unit deco
    local integer pId = GetPlayerId(whichPlayer)
    set name = StringCase(name, true)

    loop
        exitwhen i == LoP_DecoBuilders.AdvDecoLastIndex
        
        if LoadInteger(udg_Hashtable_2, pId+1, LoP_DecoBuilders.rawcodes[i]) == 0 and  StartsString(StringCase(GetThirdName(GetObjectName(LoP_DecoBuilders.rawcodes[i])), true), name) then
            
            set deco = CreateUnitAtLoc(whichPlayer, LoP_DecoBuilders.rawcodes[i], udg_PLAYER_LOCATIONS[pId+1], 270.)
            set LoP_UnitData.get(deco).hideOnDeselect = true
            if User.fromLocal().id == pId then
                call SelectUnit(deco, true)
            endif
        endif
        set i = i + 1
    endloop
    
    set deco = null
endfunction

function SearchSelectMain takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local integer argsLength = StringLength(args)
    
    //Check for (clear selection) tag
    if LoP_Command.getCommand() == "-seln" then
        if GetLocalPlayer() == GetTriggerPlayer() then
            call ForceUICancel()
            call ClearSelection()
        endif
    endif
    
    if argsLength > 0 then
        // Capitalize (all strings will be capitalized when compared)
        set udg_System_searchStr = StringCase(args, true)
        
        // Handle special cases
        if udg_System_searchStr == "RECT" then
            set udg_System_searchStr = "GENERATOR"  // -sele rect will select rect generator
        endif
        
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, GetTriggerPlayer(), Condition(function SearchSelectFilter))
    endif
    
    if LoP_Command.getCommand() == "-selc" then
        call SelcHandler(GetTriggerPlayer(), args)
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Select_Search takes nothing returns nothing
    call LoP_Command.create("-seln", ACCESS_USER, Condition(function SearchSelectMain ))
    call LoP_Command.create("-sele", ACCESS_USER, Condition(function SearchSelectMain ))
    call LoP_Command.create("-selc", ACCESS_USER, Condition(function SearchSelectMain ))
endfunction

