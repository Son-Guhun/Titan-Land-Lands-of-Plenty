library LoPPlayers requires TableStruct, DecorationSFX, LoPNeutralUnits

function LoP_SendSysMsg takes player whichPlayer, string msg returns nothing
    call DisplayTextToPlayer(whichPlayer, 0., 0., "|cffffcc00[SYS]:|r " + msg)
endfunction

function FindFirstPlayer takes nothing returns player
        local User pId = 0
        loop
            exitwhen GetPlayerSlotState(pId.handle) == PLAYER_SLOT_STATE_PLAYING
            set pId = pId + 1
        endloop
        return pId.handle
endfunction

function MakeTitan takes player whichPlayer returns nothing
        set udg_GAME_MASTER = whichPlayer
        call SetUnitOwner(HERO_COSMOSIS(), udg_GAME_MASTER, false)
        if GetOwningPlayer(HERO_CREATOR()) != Player(PLAYER_NEUTRAL_PASSIVE) then
            call SetUnitOwner(HERO_CREATOR(), udg_GAME_MASTER, false)
        endif
        
        call SetUnitOwner(POWER_REMOVE(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_KILL(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_DELEVEL(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_LEVEL(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_INVULNERABILITY(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_VULNERABILITY(), udg_GAME_MASTER, false)
endfunction

function LoP_PlayerOwnsUnit takes player whichPlayer, unit whichUnit returns boolean
    return GetPlayerAlliance(LoP_GetOwningPlayer(whichUnit), whichPlayer, ALLIANCE_SHARED_ADVANCED_CONTROL)
endfunction

function PlayerNumberIsNotExtraOrVictim takes integer ID returns boolean
    return (ID <= bj_MAX_PLAYERS or ID == PLAYER_NEUTRAL_AGGRESSIVE+1 or ID == PLAYER_NEUTRAL_PASSIVE+1) and (ID >= 1)
endfunction

function PlayerNumberIsNotNeutral takes integer ID returns boolean
    return ID <= bj_MAX_PLAYERS and ID > 0
endfunction


struct LoP_PlayerData extends array
    
    static method get takes player whichPlayer returns LoP_PlayerData
        return GetPlayerId(whichPlayer)
    endmethod
    
    method toPlayerId takes nothing returns integer
        return this
    endmethod
    
    // Player number is the value used by GUI and also by user commands in the map. It is also used as an index in some systems.
    method toPlayerNumber takes nothing returns integer
        return this+1
    endmethod
    
    //==================================
    
    method operator realName takes nothing returns string
        return udg_RealNames[.toPlayerNumber()]
    endmethod
    
    //==================================
    
    static boolean array atWar[24][24]
    
    method isAtWar takes player other returns boolean
        return atWar[this][GetPlayerId(other)]
    endmethod
    
    method setAtWar takes player other, boolean enable returns nothing
        set atWar[this][GetPlayerId(other)] = enable
    endmethod

    static playercolor array playerColors

    // Why use an array and not ConvertPlayerColor? Because ConvertPlayerColor can crash.
    // Would make finding any bugs caused by this really hard, since it could happen anywhere.
    method getUnitColor takes nothing returns playercolor
        return playerColors[this]  
    endmethod
    
    method setUnitColor takes playercolor color returns nothing
        set playerColors[this] = color
        call DecorationSFX_SetPlayerColor(Player(this), GetHandleId(color))
    endmethod
    
    //! runtextmacro TableStruct_NewPrimitiveField("rotationStep","integer")
    
    //==================================
    // Enable/Disable function (to be called by the Save System when loading)
    
    
    // Should add a timer to check if player finished loading, because they might not type -load end
    
    // Alternative: create seperate command trigger for each player. Disable it or destroy it when they leave the game.
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("commandsEnabled_internal","boolean")
    method enableCommands takes nothing returns nothing
        call commandsEnabled_internalClear()
    endmethod
    method disableCommands takes nothing returns nothing
        set commandsEnabled_internal = true
    endmethod
    method operator commandsEnabled takes nothing returns boolean
        return not commandsEnabled_internalExists()
    endmethod
    
    private static method onInit takes nothing returns nothing
        local LoP_PlayerData playerData = 0
        
        
        loop
        exitwhen playerData == bj_MAX_PLAYERS
            call playerData.setUnitColor(ConvertPlayerColor(playerData))
            
            if GetPlayerController(Player(playerData)) == MAP_CONTROL_USER then
                set playerData.rotationStep = 90
            endif
        
            set playerData = playerData + 1
        endloop
        loop
        exitwhen playerData == bj_MAX_PLAYER_SLOTS
            call playerData.setUnitColor(ConvertPlayerColor(playerData))
            
            set playerData = playerData + 1
        endloop
        
    endmethod
endstruct



endlibrary