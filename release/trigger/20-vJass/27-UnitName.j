library UnitName
/*
This library is used to add a unit's UserData to its name, which makes it possible to determine which
unit is being selected in an async manner.

It also handles a hero's proper name instead of their class name.
*/

public function ValidateName takes string name returns boolean
    return StringLength(name) > 2 and SubString(name, 0, 2) == "u#"
endfunction

public function GetActualName takes string validatedName returns string
    return SubString(validatedName, 7, StringLength(validatedName))
endfunction

private function GetFullPrefix takes string validatedName returns string
    return SubString(validatedName, 0, 7)
endfunction

public function GetUserData takes string validatedName returns integer
    return S2I(SubString(validatedName, 2, 7))
endfunction

public function SetUnitName takes unit whichUnit, string name returns nothing
    if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
        if ValidateName(GetHeroProperName(whichUnit)) then
            call BlzSetHeroProperName(whichUnit, GetFullPrefix(GetHeroProperName(whichUnit)) + name)
        else
            call BlzSetHeroProperName(whichUnit, name)
        endif
    else
        if ValidateName(GetUnitName(whichUnit)) then
            call BlzSetUnitName(whichUnit, GetFullPrefix(GetUnitName(whichUnit)) + name)
        else
            call BlzSetUnitName(whichUnit, name)
        endif
    endif
endfunction

public function Register takes unit whichUnit returns nothing
    local string userData = I2S(GetUnitUserData(whichUnit))

    if IsUnitType(whichUnit, UNIT_TYPE_HERO) then
        call BlzSetHeroProperName(whichUnit, "u#" + (SubString("00000", 0, 5 - StringLength(userData)) + userData) + GetHeroProperName(whichUnit))
    else
        call BlzSetUnitName(whichUnit, "u#" + (SubString("00000", 0, 5 - StringLength(userData)) + userData) + GetUnitName(whichUnit))
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
