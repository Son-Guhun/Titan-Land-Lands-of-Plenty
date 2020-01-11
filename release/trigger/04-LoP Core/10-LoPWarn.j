library LoPWarn initializer Init requires Timeline, Table


private struct PlayerData extends array

    //! runtextmacro TableStruct_NewStructField("messages", "Table")

    method next takes nothing returns integer
        return this + 1
    endmethod
endstruct

function LoP_WarnPlayerId takes PlayerData pId, real timeout, string message returns nothing
    local integer msgId = StringHash(message)

    if pId.messages.real.has(msgId) and Timeline.game.elapsed <= pId.messages.real[msgId] then
        return
    endif
    
    set pId.messages.real[msgId] = Timeline.game.elapsed + timeout
    call DisplayTextToPlayer(Player(pId), 0., 0., message)
endfunction

function LoP_WarnPlayer takes player whichPlayer, real timeout, string message returns nothing
    call LoP_WarnPlayerId(GetPlayerId(whichPlayer), timeout, message)
endfunction

private function Init takes nothing returns nothing
    local PlayerData pId = 0
    
    loop
        set pId.messages = Table.create()
        set pId = pId.next()
    endloop
endfunction


endlibrary