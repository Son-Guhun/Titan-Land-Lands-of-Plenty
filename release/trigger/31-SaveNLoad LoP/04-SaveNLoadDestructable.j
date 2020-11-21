library SaveNLoadDestructable requires WorldBounds, SaveIO, optional SaveNLoadConfig


function LoadDestructable takes string chatStr, real centerX, real centerY returns nothing
    local integer destType
    local real destX
    local real destY
    local integer cutToComma
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destType = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destX = S2R(SubString(chatStr,0,cutToComma)) + centerX
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destY = S2R(SubString(chatStr,0,cutToComma)) + centerY
    //set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    if IsPointInRegion(WorldBounds.worldRegion, destX, destY) then
        set bj_lastCreatedDestructable = CreateDestructable(destType, destX, destY, 270, 1, 0)
        //if not IsDestructableTree(bj_lastCreatedDestructable) then
          //  call RemoveDestructable(bj_lastCreatedDestructable)
        //endif
    endif
endfunction



endlibrary