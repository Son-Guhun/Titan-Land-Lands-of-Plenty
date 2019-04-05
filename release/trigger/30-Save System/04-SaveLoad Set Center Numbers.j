function Trig_SaveLoad_Set_Center_New_Actions takes nothing returns nothing
    local string chatStr = SubString(GetEventPlayerChatString(), 13, StringLength(GetEventPlayerChatString()) + 1)
    local integer playerNumber = GetPlayerId(GetTriggerPlayer()) + 1
    local integer cutToComma = CutToComma(chatStr)
    local real newX = S2R(SubString(chatStr,0,cutToComma))
    local real newY = S2R(SubString(chatStr,cutToComma+1,StringLength(chatStr)))
    
    set udg_load_center[playerNumber] = newX
    set udg_load_center[playerNumber + bj_MAX_PLAYERS ] = newY

    call DisplayTextToPlayer( GetTriggerPlayer(), 0, 0, "Save/Load Center set to: (" + R2S(newX) + " | " + R2S(newY) + ")")
endfunction

//===========================================================================
function InitTrig_SaveLoad_Set_Center_Numbers takes nothing returns nothing
    set gg_trg_SaveLoad_Set_Center_Numbers = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveLoad_Set_Center_Numbers, function Trig_SaveLoad_Set_Center_New_Actions )
endfunction

