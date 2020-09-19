library DestructableLib initializer Initialization
//* ============================================================================ *
//* Made by PitzerMike                                                           *
//*                                                                              *
//* I made this to detect if a destructable is a tree or not. It works not only  *
//* for the standard trees but also for custom destructables created with the    *
//* object editor. It uses a footie as a dummy with the goul's harvest ability.  *
//* The dummy ids can be changed though. I also added the IsDestructableDead     *
//* function for completeness.                                                   *
//* ============================================================================ *

globals
    private constant integer DUMMY_UNIT_ID = 'hfoo' // footman
    private constant integer HARVEST_ID    = 'Ahrl' // ghouls harvest
    
    private unit dummy = null
endglobals

// Added by Guhun to avoid creating a player variable in globals block
private constant function OWNING_PLAYER takes nothing returns player
    return Player(PLAYER_NEUTRAL_PASSIVE)
endfunction

function IsDestructableDead takes destructable dest returns boolean
    return GetDestructableLife(dest) <= 0.405
endfunction

function IsDestructableTree takes destructable dest returns boolean
    local boolean result = false
    if (dest != null) then
        call PauseUnit(dummy, false)
        set result = IssueTargetOrder(dummy, "harvest", dest)
        call PauseUnit(dummy, true) // stops order
    endif
    return result
endfunction

private function Initialization takes nothing returns nothing
    set dummy = CreateUnit(OWNING_PLAYER(), DUMMY_UNIT_ID, 0.0, 0.0, 0.0)
    call ShowUnit(dummy, false) // cannot enumerate
    call UnitAddAbility(dummy, HARVEST_ID)
    call UnitAddAbility(dummy, 'Aloc') // unselectable, invulnerable
    call PauseUnit(dummy, true)
endfunction
endlibrary