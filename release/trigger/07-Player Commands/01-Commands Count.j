scope CommandsCount

private function OnCommand takes nothing returns boolean
    local group g = CreateGroup()
    local player trigP = GetTriggerPlayer()
    local integer trigPId = GetPlayerId(trigP)
    local integer trigPCount
    local integer mostPlayerId = 0
    local integer mostCount
    local integer count
    local integer i = 1
    
    call GroupEnumUnitsOfPlayer(g, Player(0), null)
    set mostCount = BlzGroupGetSize(g)
    // set totalCount = mostCount
    loop
        exitwhen i >= bj_MAX_PLAYERS
        call GroupEnumUnitsOfPlayer(g, Player(i), null)
        set count = BlzGroupGetSize(g)
        // set totalCount = totalCount + count
        
        if count > mostCount then
            set mostCount = count
            set mostPlayerId = i
        endif
        if trigPId == i then
            set trigPCount = count
        endif
        set i = i + 1
    endloop
    
    call GroupEnumUnitsInRect(g, WorldBounds.world, null)
    
    call DisplayTextToPlayer(trigP, 0, 0, "Total unselectable units (Recommended: less than 1500): " + I2S(BlzGroupGetSize(g)))
    call DisplayTextToPlayer(trigP, 0, 0, "Player with most units: (" + I2S(mostPlayerId) + ") " + GetPlayerName(Player(mostPlayerId)) + ": " + I2S(mostCount))
    if trigPId != mostPlayerId then
        call DisplayTextToPlayer(trigP, 0, 0, "Your unit count: " + I2S(trigPCount))
    endif
    
    call DestroyGroup(g)
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Count takes nothing returns nothing
    call LoP_Command.create("-count", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope