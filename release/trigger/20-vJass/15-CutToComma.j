library CutToComma requires GALstring
//////////////////////////////////////////////////////
//CutToComma Library By Guhun v1.3
//////////////////////////////////////////////////////


// Returns -1 if there is no match. Starts search from given 'startIndex'.
function StringFindEx takes string str, string find, integer startIndex returns integer
    local string currentStr = null
    local integer looping = startIndex
    local integer findLength = StringLength(find)
    local integer maxIndex = StringLength(str) - findLength
    
    if findLength == 0 then
        return -1
    endif
    
    loop
        if looping > maxIndex then
            return -1
        endif
        
        set currentStr = SubString(str,looping,looping+findLength)
        exitwhen currentStr == find
        set looping = looping + 1
    endloop
    
    return looping
endfunction

// Returns -1 if there is no match.
function StringFind takes string str, string find returns integer
    return StringFindEx(str, find, 0)
endfunction

// Splits a string using the given splitter and returns an ArrayList with each substring
//
// Returns a list with a single element (the string) if the splitter does not exist in the string.
// Same as above for empty string.
// Returns an empty list for a null string.
function StringSplit takes string whichString, string splitter returns ArrayList_string
    local integer index
    local integer start = 0
    
    local ArrayList_string list = ArrayList.create()
    
    if whichString == null then
        // do nothing
    elseif whichString == "" then
        call list.append("")
    else
        loop
            set index = StringFindEx(whichString, splitter, start)
            exitwhen index == -1
            call list.append(SubString(whichString, start, index))
            set start = index + 1
        endloop
    
        call list.append(SubString(whichString, start, StringLength(whichString)))
    endif
    
    return list
endfunction

function StringSplitWS takes string whichString returns ArrayList_string
    local integer index = 0
    local integer start = 0
    local integer len = StringLength(whichString)
    local ArrayList_string list = ArrayList.create()
    local boolean inSplit = true
    
    if whichString == null then
        // do nothing
    elseif whichString == "" then
        call list.append("")
    else
        loop
            
            if inSplit then
                exitwhen index >= len
            
                if SubString(whichString, index, index+1) != " " then
                    set inSplit = false
                    set start = index
                endif
                
            elseif SubString(whichString, index, index+1) == " " or index >= len then
            
                set inSplit = true
                call list.append(SubString(whichString, start, index))
            endif
            
            set index = index + 1
        endloop
    endif
    
    return list
endfunction


// Returns the size of the string if there is no match.
// Only accepts characters (string length == 1).
function CutToCharacter takes string str, string splitter returns integer
    local string comma
    local integer looping = 0
    local integer strLength = StringLength(str)
    
    if str == null or str == "" then
        return 1
    else
        set comma = SubString(str,looping,looping+1)
        loop
            exitwhen comma == splitter or looping == strLength
            set looping = looping + 1
            set comma = SubString(str,looping,looping+1)
        endloop
        return looping
    endif
endfunction

// Returns the size of the string if there is no match.
function CutToComma takes string str returns integer
    return CutToCharacter(str, ",")
endfunction

function CutToCommaResult takes string str, integer cutToComma returns string
    return SubString(str, 0, cutToComma)
endfunction

function CutToCommaShorten takes string str, integer cutToComma returns string
    return SubString(str, cutToComma + 1, StringLength(str) + 1)
endfunction


endlibrary