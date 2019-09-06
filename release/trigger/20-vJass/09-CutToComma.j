library CutToComma
//////////////////////////////////////////////////////
//CutToComma Library By Guhun v1.2
//////////////////////////////////////////////////////

function StringFind takes string str, string find returns integer
    local string currentStr = null
    local integer looping = 0
    local integer findLength = StringLength(find)
    local integer maxIndex = StringLength(str) - findLength
    loop
    exitwhen currentStr == find or looping > maxIndex
        set currentStr = SubString(str,looping,looping+findLength)
        set looping = looping + 1
    endloop
    return looping
endfunction

//// Splits a string using the given splitter and returns a GIOL list with each substring
//function StringSplit takes string whichString, string splitter returns integer
//    local integer index
//    local integer start = 0
//    local integer len = StringLength(whichString)
//    
//    local integer list = GIOL_CreateList()
//    
//    loop
//        set index = StringFind(whichString, splitter)
//        GIOL_Append(list, SubString(whichString, start, index))
//    exitwhen index == len
//        set start = index+1
//    endloop
//    
//    return list
//endfunction
function CutToComma takes string str returns integer
    local string comma
    local integer looping = 0
    local integer strLength = StringLength(str)
    set comma = SubString(str,looping,looping+1)
    loop
        exitwhen comma == "," or looping == strLength
        set looping = looping + 1
        set comma = SubString(str,looping,looping+1)
    endloop
    return looping
endfunction

function CutToCharacter takes string str, string splitter returns integer
    local string comma
    local integer looping = 0
    local integer strLength = StringLength(str)
    set comma = SubString(str,looping,looping+1)
    loop
        exitwhen comma == splitter or looping == strLength
        set looping = looping + 1
        set comma = SubString(str,looping,looping+1)
    endloop
    return looping
endfunction

function CutToCommaResult takes string str, integer cutToComma returns string
    return SubString(str, 0, cutToComma)
endfunction

function CutToCommaShorten takes string str, integer cutToComma returns string
    return SubString(str, cutToComma + 1, StringLength(str) + 1)
endfunction
endlibrary