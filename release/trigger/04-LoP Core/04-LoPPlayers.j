library LoPPlayers requires TableStruct, DecorationSFX, LoPNeutralUnits
/*

struct LoP_PlayerData:

    Fields:
        readonly player handle
        
        readonly string realName
        
        readonly location location
        readonly real locX
        readonly real locY
        
        readonly boolean commandsEnabled
        
    Methods:
        integer toPlayerId()
        integer toPlayerNumber()

        boolean isAtWar(player other)
        nothing setAtWar(player other, boolean enable)
        
        nothing enableCommands()
        nothing disableCommands()
        
        playercolor getUnitColor()
        nothing setUnitColor(playercolor color)
    
        Static:
            LoP_PlayerData get(player whichPlayer)
            
Functions:
    player FindFirstPlayer()
    nothing MakeTitan(player whichPlayer)
    
    boolean LoP_GivesShareAccess(player whichPlayer, player recipient)
    boolean LoP_PlayerOwnsUnit(player whichPlayer, unit whichUnit)
    
    boolean PlayerNumberIsNotExtraOrVictim(integer ID)
    boolean PlayerNumberIsNotNeutral(integer ID) 

*/

// ==============================================
// Leaver utilities

// Find the first player that is still player. Should not be called during map initialization.
function FindFirstPlayer takes nothing returns player
        local User pId = 0
        loop
            exitwhen GetPlayerSlotState(pId.handle) == PLAYER_SLOT_STATE_PLAYING
            set pId = pId + 1
        endloop
        return pId.handle
endfunction

// Makes 'whichPlayer' the new Titan.
function MakeTitan takes player whichPlayer returns nothing
        set udg_GAME_MASTER = whichPlayer
        call SetUnitOwner(HERO_COSMOSIS(), udg_GAME_MASTER, false)
        if GetOwningPlayer(HERO_CREATOR()) != LoP.NEUTRAL_PASSIVE then
            call SetUnitOwner(HERO_CREATOR(), udg_GAME_MASTER, false)
        endif
        
        call SetUnitOwner(POWER_REMOVE(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_KILL(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_DELEVEL(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_LEVEL(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_INVULNERABILITY(), udg_GAME_MASTER, false)
        call SetUnitOwner(POWER_VULNERABILITY(), udg_GAME_MASTER, false)
endfunction

// ==============================================
// Unit access utilities

function LoP_GivesShareAccess takes player whichPlayer, player recipient returns boolean
    return GetPlayerAlliance(whichPlayer, recipient, ALLIANCE_SHARED_ADVANCED_CONTROL)
endfunction


function LoP_PlayerOwnsUnit takes player whichPlayer, unit whichUnit returns boolean
    return GetPlayerAlliance(LoP_GetOwningPlayer(whichUnit), whichPlayer, ALLIANCE_SHARED_ADVANCED_CONTROL)
endfunction

// ==============================================
// Neutral utilities

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
    
    method operator handle takes nothing returns player
        return Player(this)
    endmethod
    
    //==================================
    
    method operator realName takes nothing returns string
        return udg_RealNames[.toPlayerNumber()]
    endmethod
    
    method operator location takes nothing returns location
        return udg_PLAYER_LOCATIONS[.toPlayerNumber()]
    endmethod
    
    method operator locX takes nothing returns real
        return GetLocationX(.location)
    endmethod
    
    method operator locY takes nothing returns real
        return GetLocationY(.location)
    endmethod
    
    //==================================
    
    private static boolean array atWar[24][24]
    
    method isAtWar takes player other returns boolean
        return atWar[this][GetPlayerId(other)]
    endmethod
    
    method setAtWar takes player other, boolean enable returns nothing
        set atWar[this][GetPlayerId(other)] = enable
    endmethod

    //==================================

    private static playercolor array playerColors

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
    // Enable/Disable commands

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
    
    //==================================
    // Initialization
    
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