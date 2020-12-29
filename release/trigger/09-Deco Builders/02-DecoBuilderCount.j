library DecoBuilderCount requires LoPDecoBuilders, ConstTable
/*
=========
 Description
=========

    This library defines functions that should be called in response to events. They pertain to deco builders
and are used to keep track of the total deco builder count for each player and also to adjust Deco Modifier Special's
abilities according to the player's settings.
    
    Whenever a new deco builder enters the map, DecoBuilderCount_IncreaseCount should be called for that unit.
    Whenever a deco builder is removed from the game, DecoBuilderCount_ReduceCount should be called for that unit.
    Whenever a deco builder switches owner, DecoBuilderCount_SwitchOwner should be called for that unit.
    
    If the map is using out-of-scope unit removal (i.e. you can't get the type of the unit when responding
to a unit removal event), then the ReduceCountEx function can be used instead of ReduceCount.
    
=========
 Documentation
=========

Functions:
    public nothing IncreaseCount(unit whichUnit)

    public nothing ReduceCountEx(integer playerNumber, integer unitType)

    public nothing ReduceCount(unit whichUnit)

    public nothing SwitchOwner(unit whichUnit, player oldOwner)

    public integer GetForPlayer(player whichPlayer, integer unitType)
    
    public nothing LoPDecoBuilders_CreateMissing(player owner, real x, real y, group g, integer firstIndex, integer lastIndex, boolean reforged)
    .
    . Creates all missing deco builders in the range [firstIndex, lastIndex] for the given player, at point (x,y).
    .     group g  -> if not null, all created units will be added to it.
    .     boolean reforged  -> use constants DECO_BUILDERS_CLASSIC and DECO_BUILDERS_REFORGED for future compatibility.


*/
//==================================================================================================
//                                        Source Code
//==================================================================================================

private struct PlayerCounts extends array
    static key hashkey
    static method operator [] takes player whichPlayer returns Table
        return ConstHashTable(hashkey)[GetPlayerId(whichPlayer)]
    endmethod
endstruct

public function IncreaseCount takes unit whichUnit returns nothing
    local integer unitType = GetUnitTypeId(whichUnit)
    local player owner = GetOwningPlayer(whichUnit)
    
    if unitType == DECO_BUILDER_SPECIAL then
        call LoPDecoBuilders_AdjustSpecialAbilities(whichUnit)
    endif

    set PlayerCounts[owner][unitType] = PlayerCounts[owner][unitType] + 1
endfunction

public function ReduceCountEx takes player owner, integer unitType returns nothing
    local integer decoCount = PlayerCounts[owner][unitType]

    if decoCount > 0 then
        set PlayerCounts[owner][unitType] = decoCount - 1
    else
        call BJDebugMsg("Deco count error: count reduced below 0!")
    endif
endfunction

public function ReduceCount takes unit whichUnit returns nothing
    call ReduceCountEx(GetOwningPlayer(whichUnit), GetUnitTypeId(whichUnit))
endfunction

public function SwitchOwner takes unit whichUnit, player oldOwner returns nothing
    local integer unitType =  GetUnitTypeId(whichUnit)
    local integer decoCount = PlayerCounts[oldOwner][unitType]
    local Table ownerCounts = PlayerCounts[GetOwningPlayer(whichUnit)]
    
    if decoCount > 0 then
        if unitType == DECO_BUILDER_SPECIAL then
            call LoPDecoBuilders_AdjustSpecialAbilities(whichUnit)
        endif
        
        set PlayerCounts[oldOwner][unitType] = decoCount - 1
        set ownerCounts[unitType] = ownerCounts[unitType] + 1
    else
        call BJDebugMsg("Deco count error: switching owner went wrong")
        set ownerCounts[unitType] = ownerCounts[unitType] + 1
    endif
endfunction

public function GetForPlayer takes player whichPlayer, integer unitType returns integer
    return PlayerCounts[whichPlayer][unitType]
endfunction

//Checks the deco counter for the player. If any counter is 0, create the missing deco.
public function CreateMissing takes player owner, real x, real y, group g, integer firstIndex, integer lastIndex, boolean reforged returns nothing
    local Table playerCounts = PlayerCounts[owner]
    local integer id

    loop
    exitwhen firstIndex > lastIndex
        if reforged then
            set id = LoP_DecoBuilders.reforgedRawcodes[firstIndex]
        else
            set id = LoP_DecoBuilders.rawcodes[firstIndex]
        endif
    
        if playerCounts[id] == 0 then
            if g == null then
                call CreateUnit(owner, id, x, y, bj_UNIT_FACING)
            else
                call GroupAddUnit(g, CreateUnit(owner, id, x, y, bj_UNIT_FACING))
            endif
        endif
        
        set firstIndex = firstIndex + 1
    endloop
endfunction

endlibrary