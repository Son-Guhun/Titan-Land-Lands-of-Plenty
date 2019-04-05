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

function SearchSelectFilter takes nothing returns boolean
    local string str
    
    if IsUnitType(GetFilterUnit(), UNIT_TYPE_PEON) then
        //Get full unit name (Deco Builder/Modifier [Proper Name])
        set str = GetUnitName(GetFilterUnit())
        //Skip first word (Deco)
        set str = SubString(str,CutToCharacter(str," ")+1,StringLength(str))
        //Skip second word (Builder or Modifier)
        set str = SubString(str,CutToCharacter(str," ")+1,StringLength(str))
        //Use third word (the proper name that we want)
        set str = SubString(str,0,CutToCharacter(str," "))
        
        //Compare strings and Select Unit for local player only
        if StartsString(udg_System_searchStr, str) then//str == udg_System_searchStr then
            call ShowUnit(GetFilterUnit(), true)
            if GetLocalPlayer() == GetTriggerPlayer() then
                call SelectUnit(GetFilterUnit(), true)
            endif
        endif
    endif
    
    //Return false because this is a condition
    return false
endfunction

function SearchSelectMain takes nothing returns nothing
    local string str
    local string args = Commands_GetArguments()
    local integer argsLength = StringLength(args)
    
    //Check for (clear selection) tag
    if GetEventPlayerChatStringMatched() == "-seln " then
        if GetLocalPlayer() == GetTriggerPlayer() then
            call ClearSelection()
        endif
    endif
    
    if argsLength > 0 then
        //Make first letter capitalized
        set str = StringCase(SubString(args, 0, 1),true)
        
        //Make rest of the word uncapitalized and save to global variable
        set udg_System_searchStr = str + StringCase(SubString(args, 1, argsLength),false)
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, GetTriggerPlayer(), Condition(function SearchSelectFilter))
    endif
endfunction

//===========================================================================
function InitTrig_Commands_Select_Search takes nothing returns nothing
    set gg_trg_Commands_Select_Search = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Commands_Select_Search, function SearchSelectMain )
endfunction

