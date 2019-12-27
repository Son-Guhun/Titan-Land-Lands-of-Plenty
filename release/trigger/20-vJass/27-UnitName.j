library UnitName
/*
This library is used to add a unit's UserData to its name, which makes it possible to determine which
unit is being selected in an async manner.
*/

public function ValidateName takes string name returns boolean
    return StringLength(name) > 2 and SubString(name, 0, 2) == "u#"
endfunction

public function GetActualName takes string validatedName returns string
    return SubString(validatedName, 7, StringLength(validatedName))
endfunction

public function GetUserData takes string validatedName returns integer
    return S2I(SubString(validatedName, 2, 7))
endfunction

public function SetUnitName takes unit whichUnit, string name returns nothing
    local string size = "00000"
    local string userData = I2S(GetUnitUserData(whichUnit))
    
    if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
        call BlzSetHeroProperName(whichUnit, "u#" + (SubString(size, 0, 5 - StringLength(userData)) + userData) + name)
    else
        call BlzSetUnitName(whichUnit, "u#" + (SubString(size, 0, 5 - StringLength(userData)) + userData) + name)
    endif
endfunction

private function NativeGetUnitName takes unit whichUnit returns string
    return GetUnitName(whichUnit)
endfunction

public function GetUnitName takes unit whichUnit returns string
    local string name
    
    if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
        set name = GetHeroProperName(whichUnit)
    else
        set name = NativeGetUnitName(whichUnit)
    endif
    
    if ValidateName(name) then
        return SubString(name, 7, StringLength(name))
    else
        return name
    endif
endfunction

/*
public function OnEnterMap takes unit whichUnit returns nothing
    if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
        call SetUnitName(whichUnit, GetHeroProperName(whichUnit))
    else
        call SetUnitName(whichUnit, NativeGetUnitName(whichUnit))
    endif
endfunction
*/

endlibrary
