library TreeSystemCreateTrees

function TreeSystemCreateTrees takes nothing returns nothing
    local integer playerNumber = GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1
    local integer val = udg_DecoSystem_Value[playerNumber] - 1
    local real X = GetSpellTargetX()
    local real Y = GetSpellTargetY()
    local real space = udg_TreeSystem_Space[playerNumber]
    local integer x = -val
    local integer y = -val
    loop
        exitwhen x > val
        set y = -val
        loop
            exitwhen y > val
            call CreateDestructable( udg_TreeSystem_TREES[GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1], X - space*I2R(x), Y + - space*I2R(y), GetRandomDirectionDeg(), GetRandomReal(0.90, 1.10), 0 )
            set y = y+1
        endloop
        set x = x + 1
    endloop
endfunction

endlibrary
