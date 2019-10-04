library DecoBuilderCount requires LoPDecoBuilders
/*
This library defines functions that keep track of the number of units of a certain type, for each player.

*/

public function IncreaseCount takes unit whichUnit returns nothing
    local integer unitType = GetUnitTypeId(whichUnit)
    local integer playerNumber = GetPlayerId(GetOwningPlayer(whichUnit)) + 1
    
    if GetUnitTypeId(whichUnit) == DECO_BUILDER_SPECIAL then
        call LoPDecoBuilders_AdjustSpecialAbilities(whichUnit)
    endif

    call SaveInteger(udg_Hashtable_2, playerNumber, unitType, LoadInteger(udg_Hashtable_2, playerNumber, unitType ) + 1)
endfunction

public function ReduceCountEx takes integer playerNumber, integer unitType returns nothing
    local integer decoCount = LoadInteger(udg_Hashtable_2, playerNumber, unitType )
    if decoCount > 0 then
        debug call BJDebugMsg("Deco count reduced!")
        call SaveInteger(udg_Hashtable_2, playerNumber, unitType, decoCount - 1)
    endif
endfunction

public function ReduceCount takes unit whichUnit returns nothing
    call ReduceCountEx(GetPlayerId( GetOwningPlayer( whichUnit ) ) + 1, GetUnitTypeId(whichUnit))
endfunction

private function SwitchOwner_impl takes unit whichUnit, player ownerOld, integer decoCount returns nothing
    local integer playerNumber = GetPlayerId( GetOwningPlayer(whichUnit) ) + 1
    local integer playerNumberOld = GetPlayerId( ownerOld ) + 1
    local integer unitType =  GetUnitTypeId(whichUnit)
    
    if GetUnitTypeId(whichUnit) == DECO_BUILDER_SPECIAL then
        call LoPDecoBuilders_AdjustSpecialAbilities(whichUnit)
    endif
    
    call SaveInteger(udg_Hashtable_2, playerNumberOld, unitType, decoCount - 1)
    call SaveInteger(udg_Hashtable_2, playerNumber, unitType, LoadInteger(udg_Hashtable_2, playerNumber, unitType ) + 1)
endfunction

public function SwitchOwner takes unit whichUnit, player oldOwner returns nothing
    local integer decoCount = LoadInteger(udg_Hashtable_2, GetPlayerId(oldOwner) + 1, GetUnitTypeId(whichUnit))
    
    if decoCount > 0 then
        call SwitchOwner_impl(whichUnit, oldOwner, decoCount)
    endif
endfunction

public function GetForPlayer takes player whichPlayer, integer unitType returns integer
    return LoadInteger(udg_Hashtable_2, GetPlayerId(whichPlayer) + 1, unitType )
endfunction

/*
public function IsUnitCountedEx takes integer ownerNumber, integer unitType returns boolean
    return LoadInteger(udg_Hashtable_2, ownerNumber, unitType ) > 0
endfunction

public function IsUnitCounted takes unit whichUnit returns boolean
    return  IsUnitCountedEx(GetPlayerId(GetOwningPlayer(whichUnit)) + 1, GetUnitTypeId(whichUnit))
endfunction
*/

endlibrary