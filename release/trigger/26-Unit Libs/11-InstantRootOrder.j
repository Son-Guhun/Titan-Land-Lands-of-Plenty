library InstantRootOrder requires AgentStruct
/*
=========
 Description
=========

    This library defines the IssueInstantRootOrder function. It issues a root order to a unit after a
0-second timer. Assuming the root ability used follows the specifications provided in CONFIGURATION,
then the unit will instantly be rooted in-game.

    The function also handles cases in which units exist below the rooting structure. For this to
function, the following properties are assumed to be zero for the structure:

            - Pathing - Placement Requires        (requirePlace)
            - Pathing - Placement Prevented By    (preventPlace)
    
    How it works:
        - The structure owner is changed to neutral extra. Thus the structure is not prevented from
    rooting if there are units below it. As such, neutral extra should not own any units in the map.
        - The 'Amov' ability is disabled for all players using SetPlayerAbilityAvailable, so that
    units won't move out of the way when the root order is issued.
        - After another 0-second timer, the structure is already rooted, since the duration of the
    ability is zero. When this happens, the root ability is removed, the structure is returned to the
    owner, and Amov is enabled for all players again.

=========
 Documentation
=========
    
    Functions:
        nothing IssueInstantRootOrder(unit u)

*/
//==================================================================================================
//                                       Configuration
//==================================================================================================

globals
    // The ability to be used for root/unroot orders:
    //     - Must have 'Duration - Hero (HeroDur1)' and 'Duration - Unit (Dur1)' set to 0.00
    public constant integer ROOT_ABILITY = 'DEDF'
endglobals

//==================================================================================================
//                                        Source Code
//==================================================================================================

private function EnableAmov takes boolean flag returns nothing
    local integer i = 0
    loop
    exitwhen i >= bj_MAX_PLAYER_SLOTS
        call SetPlayerAbilityAvailable(Player(0), 'Amov', flag)
        set i = i + 1
    endloop
endfunction

private struct TimerData extends array

    implement AgentStruct

    //! runtextmacro HashStruct_NewAgentField("unit","unit")
    //! runtextmacro HashStruct_NewPrimitiveField("owner","integer")
    //! runtextmacro HashStruct_NewPrimitiveField("isSelected","boolean")
    
    private static boolean isAmovDisabled = false
    
    /*
        Performs cleanup after unit has finished rooting.
        
    */
    private static method doCleanup takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local TimerData tData = TimerData.get(t)
        local unit u = tData.unit
        local player owner = Player(tData.owner)
        //! runtextmacro ASSERT("u != null")
        
        call UnitRemoveAbility(u, ROOT_ABILITY)

        if isAmovDisabled then
            call EnableAmov(true)
            set isAmovDisabled = false
        endif
        call SetUnitOwner(u, owner, false)
        if tData.isSelected then
            if GetLocalPlayer() == owner then
                call SelectUnit(u, true)
            endif
        endif
        
        call PauseTimer(t)
        call DestroyTimer(t)
        call tData.destroy()
        
        set t = null
        set u = null
    endmethod

    /*
        Issue a root order while taking into account that units may be below the structure and thus stop it from rooting.
        
        This assumes that the following fields are empty for all structures:
            - Pathing - Placement Requires        (requirePlace)
            - Pathing - Placement Prevented By    (preventPlace)
    */
    static method issueRootOrder takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local unit u = TimerData.get(t).unit
        local player owner = GetOwningPlayer(u)
        //! runtextmacro ASSERT("u != null")
        
        if not isAmovDisabled then  // Only disable if it hasn't already been disabled in this frame.
            call EnableAmov(false)  // Disabled Amov so that units won't move out of the way.
            set isAmovDisabled = true
        endif
        call SetUnitOwner(u, Player(bj_PLAYER_NEUTRAL_VICTIM), false)  // Change owner so that structure can root even if there are units belonging to the player below it
        
        call IssuePointOrder(u, "root", GetUnitX(u), GetUnitY(u))
        call TimerStart(t, 0, false, function TimerData.doCleanup)
        set TimerData.get(t).owner = GetPlayerId(owner)
        set TimerData.get(t).isSelected = IsUnitSelected(u, owner)
        
        set t = null
        set u = null
    endmethod
endstruct

function IssueInstantRootOrder takes unit u returns nothing
        local timer t = CreateTimer()
        
        set TimerData.get(t).unit = u
        call TimerStart(t, 0, false, function TimerData.issueRootOrder)
        call SetUnitAnimation(u, "stand")
        
        set t = null
endfunction


endlibrary