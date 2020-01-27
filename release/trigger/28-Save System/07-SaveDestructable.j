scope SaveDestructable

private function GetSavingPlayerId takes nothing returns SaveNLoad_PlayerData
    return udg_temp_integer
endfunction

private struct PlayerData extends array
    SaveData saveData
    ArrayList_destructable destructables
    integer current
endstruct

private function SaveDestructables takes PlayerData playerId returns nothing
    local integer i = playerId.current
    local ArrayList_destructable destructables = playerId.destructables
    local integer final = IMinBJ(i + 60, destructables.size())
    local destructable dest
    local SaveData saveData = playerId.saveData

    loop
    exitwhen i == final
        set dest = destructables[i]
        if IsDestructableTree(dest) then
            call saveData.write(SaveNLoad_FormatString("SnL_dest",  I2S(GetDestructableTypeId(dest))+"|"+R2S(GetDestructableX(dest)- saveData.centerX)+"|"+R2S(GetDestructableY(dest)- saveData.centerY)+"|"))
        endif
        set i = i + 1
    endloop
    
    set playerId.current = i 
    set dest = null
endfunction

private function onTimer takes nothing returns nothing
    local PlayerData playerId = 0
    
    loop
    exitwhen playerId == bj_MAX_PLAYER_SLOTS
        if playerId.saveData != 0 then
            call SaveDestructables(playerId)
            if playerId.current == playerId.destructables.size() then
                call playerId.saveData.destroy()
                set playerId.saveData = 0
                call playerId.destructables.clear()
                call DisplayTextToPlayer( Player(playerId),0,0, "Finished Saving" )
            endif
        endif
        set playerId = playerId + 1
    endloop
endfunction

function SaveFilter takes nothing returns boolean
    call PlayerData(GetSavingPlayerId()).destructables.append(GetFilterDestructable())
    return false
endfunction

function SaveLoopActions2 takes nothing returns nothing
    local player saver = GetTriggerPlayer()
    local unit generator
    local rect rectangle
    local PlayerData playerId = GetPlayerId(saver)
    local integer tempInteger
    
    if SubString(GetEventPlayerChatString(), 0, 6) != "-dsav " then
        return
    endif
    
    set generator =  GUDR_PlayerGetSelectedGenerator(saver)
    if generator == null then
        return
    endif
    set rectangle = GUDR_GetGeneratorRect(generator)

    set tempInteger = udg_temp_integer  // store global value in local
    set udg_temp_integer = playerId
    
    if playerId.saveData != 0 then
        call DisplayTextToPlayer(playerId.saveData.player, 0., 0., "|cffff0000Warning:|r Did not finish saving previous file!")
        call playerId.saveData.destroy()
        call playerId.destructables.clear()
    endif
    
    set playerId.saveData = SaveData.create(saver, SaveNLoad_FOLDER() + SubString(GetEventPlayerChatString(), 6, 129))
    set playerId.saveData.centerX = GetUnitX(generator)
    set playerId.saveData.centerY = GetUnitY(generator)
    set playerId.saveData.extentX = GUDR_GetGeneratorExtentX(generator)
    set playerId.saveData.extentY = GUDR_GetGeneratorExtentY(generator)
    
    call EnumDestructablesInRect(rectangle, Condition(function SaveFilter), null)

    set udg_temp_integer = tempInteger  // restore global variable value
    set generator = null
    set rectangle = null
endfunction

//===========================================================================
function InitTrig_SaveDestructable takes nothing returns nothing
    local PlayerData playerId = 0
    
    set gg_trg_SaveDestructable = CreateTrigger(  )
    call TriggerAddAction( gg_trg_SaveDestructable, function SaveLoopActions2 )
    call TimerStart(CreateTimer(), 0.5, true, function onTimer)
    
    loop
    exitwhen playerId == bj_MAX_PLAYER_SLOTS
        if GetPlayerController(Player(playerId)) == MAP_CONTROL_USER then
            set playerId.destructables = ArrayList.create()
        endif
        set playerId = playerId + 1
    endloop
endfunction

endscope
