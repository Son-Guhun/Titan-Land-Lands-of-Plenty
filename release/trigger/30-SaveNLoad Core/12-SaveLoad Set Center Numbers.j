function Trig_SaveLoad_Set_Center_New_Actions takes nothing returns nothing
    local string chatStr = SubString(GetEventPlayerChatString(), 13, StringLength(GetEventPlayerChatString()) + 1)
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer cutToComma = CutToComma(chatStr)
    local real newX = S2R(SubString(chatStr,0,cutToComma))
    local real newY = S2R(SubString(chatStr,cutToComma+1,StringLength(chatStr)))
    
    set playerId.centerX = newX
    set playerId.centerY = newY

    call DisplayTextToPlayer( GetTriggerPlayer(), 0, 0, "Save/Load Center set to: (" + R2S(newX) + " | " + R2S(newY) + ")")
endfunction

//===========================================================================
function InitTrig_SaveLoad_Set_Center_Numbers takes nothing returns nothing
    set gg_trg_SaveLoad_Set_Center_Numbers = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveLoad_Set_Center_Numbers, function Trig_SaveLoad_Set_Center_New_Actions )
endfunction

