scope CommandsCount

private function PlayerName takes integer playerNumber returns string
    return "Player " + I2S(playerNumber)
    // return LoP_PlayerData(playerNumber-1).realName
endfunction

private function OnCommand takes nothing returns boolean
    local group g = CreateGroup()
    local player trigP = GetTriggerPlayer()
    local integer trigPId = GetPlayerId(trigP)
    local integer trigPCount
    local integer mostPlayerId = 0
    local integer mostCount
    local integer count
    local integer i = 1
    local ArrayList_string args = StringSplitWS(LoP_Command.getArgumentsRaw())
    local integer decorationCount
    local integer unitCount
    local integer unselectableUnitCount
    local integer unselectableDecorationCount
    local integer structureCount
    local unit u
    local integer uIndex
    
    if args.size == 0 then
        call GroupEnumUnitsOfPlayer(g, Player(0), null)
        set mostCount = BlzGroupGetSize(g)
        loop
            exitwhen i >= bj_MAX_PLAYERS
            call GroupEnumUnitsOfPlayer(g, Player(i), null)
            set count = BlzGroupGetSize(g)
            
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
        
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, "Total selectable units: |cffffff00" + I2S(BlzGroupGetSize(g)) + "|r (less than 1500 is recommended)")
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, "Player with most units: " + UserColor(mostPlayerId).hex + "(" + I2S(mostPlayerId+1) + ") " + GetPlayerName(Player(mostPlayerId)) + "|r: |cffffff00" + I2S(mostCount) + "|r")
        if trigPId != mostPlayerId then
            call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, "Your unit count: |cffffff00" + I2S(trigPCount) + "|r")
        endif
    else
        set count = 0
        loop
            set i = GetNextPlayerArgument(args)
            exitwhen not PlayerNumberIsNotNeutral(i) or count == 5
            set decorationCount = 0
            set unitCount = 0
            set unselectableUnitCount = 0
            set structureCount = 0
            
            call GroupEnumUnitsOfPlayer(g, Player(i-1), null)
            set uIndex = BlzGroupGetSize(g)
            loop
                //! runtextmacro ForUnitInGroupCountedReverse("u", "uIndex", "g")

                if LoP_IsUnitDecoration(u) then
                    set decorationCount = decorationCount + 1
                elseif IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                    set structureCount = structureCount + 1
                elseif BlzIsUnitSelectable(u) then
                    set unitCount = unitCount + 1
                else
                    set unselectableUnitCount = unselectableUnitCount + 1
                endif
            endloop
            
            set count = count + 1
            set unselectableDecorationCount = DecorationEffect.getDecorationsOfPlayer(Player(i-1)).size()
            call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, UserColor(i-1).hex + PlayerName(i) + "|r has |cffffff00" + I2S(decorationCount + structureCount + unitCount) + "|r units (|cffffff00" + I2S(unselectableUnitCount + unselectableDecorationCount) + "|r unselectable). Total: |cffffff00" + I2S(decorationCount + structureCount + unitCount + unselectableUnitCount + unselectableDecorationCount) + "|r.
  [ |cffffff00" + I2S(unitCount) + "|r characters (|cffffff00" + I2S(unselectableUnitCount) + "|r) ; |cffffff00" + I2S(decorationCount) + "|r decorations (|cffffff00" + I2S(unselectableDecorationCount) + "|r) ; |cffffff00" + I2S(structureCount) + "|r structures ]")
        endloop
        
        set u = null
    endif
    
    call DestroyGroup(g)
    call args.destroy()
    set g = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Count takes nothing returns nothing
    call LoP_Command.create("-count", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope