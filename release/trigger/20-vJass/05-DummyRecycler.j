library DummyRecycler /*
 
//                      DummyRecycler v1.25
//                          by Flux
//
//  A system that recycles dummy units while considering their facing angle.
//  It can be used as attachment dummies for visual effects or as dummy caster.
//
//  Why is recycling a unit important?
//      Because creating a unit is is one of the slowest function in the game
//      and there are reports that will always leave a permanent tiny bit of
//      memory (0.04 KB).
//      On average, retrieving a pending Dummy is approximately 4x faster compared
//      to creating a new one and recycling a Dummy compared to removing it is
//      approximately 1.3x faster.
//      Furthermore, if you're using a lot of "Unit has entered map" events,
//      using this system will even result to even more better performance
//      because retrieving Dummy units does not cause that event to run.


    */ requires /*
       nothing
     
    */ optional Table/*
        if not found, this system will use a hashtable. Hashtables are limited to
        255 per map.
     
    */ optional WorldBounds /*
        if not found, this system will initialize its own Map Boundaries.
//
//
//  Features:
//
//    -- Dummy Sharing
//        When a Dummy List gets low on unit count, it will borrow Dummy Units
//        from the Dummy List with the highest unit count. The transfer is not
//        instant because the shared Dummy Unit has to turn to the appropriate
//        angle of its new Dummy List before it can be recycled.
//        See BORROW_REQUEST.
//
//    -- Self-balancing recycling algorithm
//        Recycled Dummy Units will be thrown to the List having the least number
//        of Dummy Units.
//
//    -- Recycling least used
//        Allows recycling a Dummy from the Dummy List with the highest
//        unit count. It is useful when the facing angle of the Dummy Unit
//        does not matter.
//        See GetRecycledDummyAnyAngle.
//
//    -- Self-adaptation
//        When there are no free Dummy Units from a Dummy List, it will end up creating
//        a new unit instead but that unit will be permanently added as a Dummy
//        Unit to be recycled increasing the overall total Dummy Unit count.
//
//    -- Count control
//        Allows limiting the overall number of Dummy Units.
//        See MAX_DUMMY_COUNT.
//
//    -- Delayed Recycle
//        Allows recycling Dummy Units after some delay to allocate time for the
//        death animation of Special Effects to be seen.
//        See DummyAddRecycleTimer.
//
// ******************************************************************
// ***************************** API: *******************************
// ******************************************************************
//
//  function GetRecycledDummy takes real x, real y, real z, real facing returns unit
//      - Retrieve an unused Dummy Unit from the List.
//      - The equivalent of CreateUnit.
//      - To use as a Dummy Caster, follow it with PauseUnit(dummy, false).
//
//  function GetRecycledDummyAnyAngle takes real x, real y, real z returns unit
//      - Use this function if the facing angle of the Dummy doesn't matter to you.
//      - It will return a unit from the list having the highest number of unused Dummy Units.
//      - To use as a Dummy Caster, follow it with PauseUnit(dummy, false).
//
//  function RecycleDummy takes unit u returns nothing
//      - Recycle the Dummy unit for it to be used again later.
//      - The equivalent of RemoveUnit.
//
//  function DummyAddRecycleTimer takes unit u, real time returns nothing
//      - Recycle the Dummy unit after a certain time.
//      - Use this to allocate time for the the death animation of an effect attached to the
//        Dummy Unit to finish..
//      - The equivalent of UnitApplyTimedLife.
//
//  function ShowDummy takes unit u, boolean flag returns nothing
//      - Shows/hides Dummy Unit without conflicting with the Locust ability.
//
//--------------------
//      CREDITS
//--------------------
//  Bribe - for the MissileRecycler (vJASS) where I got this concept from
//       http://www.hiveworkshop.com/forums/jass-resources-412/system-missilerecycler-206086/
//        - for the optional Table
//       http://www.hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
//  Vexorian - for the Attachable and Pitch Animation Model (dummy.mdx)
//       http://www.wc3c.net/showthread.php?t=101150
//  Maker and IcemanBo - for the unit permanent 0.04 KB memory leak of units.
//       http://www.hiveworkshop.com/forums/trigger-gui-editor-tutorials-279/memory-leaks-263410/
//  Nestharus - for the data structure
//       http://www.hiveworkshop.com/forums/2809461-post7.html
//            - for the optional WorldBounds
//       http://githubusercontent.com/nestharus/JASS/master/jass/Systems/WorldBounds/script.j

// =============================================================== //
// ====================== CONFIGURATION ========================== //
// =============================================================== */

    globals
        //The rawcode of the Dummy Unit
        private constant integer DUMMY_ID = 'h07Q'
     
        //The owner of the Dummy Unit
        private constant player OWNER = Player(bj_PLAYER_NEUTRAL_VICTIM)
     
        //The number of indexed angle. The higher the value the:
        // - Lesser the turning time for the Dummy Units.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //          Recommended Value: 10 (Max difference of 18 degrees)
        private constant integer ANGLES_COUNT = 1
     
        //The number of Dummy units per ANGLES_COUNT. The higher the value the:
        // - Higher the number of units that can be recycled per angle, when
        //   no more units are in queue, the system will resort to use CreateUnit.
        // - Higher the total number of Dummy Units created at Map Initialization.
        //    Recommended Value: 3 to 5 (for less overhead in Map Loading Screen)
        private constant integer STORED_UNIT_COUNT = 10
     
        //The maximum number of Dummy units that can exist. When the system resort
        //to using CreateUnit, the unit will be permanently added to the Dummy
        //List. To avoid spamming Dummy Units and having too much free Dummy
        //Units to allocate, the maximum number of Dummy Units is capped.
        //               Recommended Value: 80 to 120
        private constant integer MAX_DUMMY_COUNT = 100
     
        //When a certain angle have less than BORROW_REQUEST units in its list,
        //it will start to borrow Dummy Units from the list with the highest
        //Dummy Unit count.
        //      Recommended Value: Half of maximum STORED_UNIT_COUNT
        private constant integer BORROW_REQUEST = 5
     
        //It will only return a Dummy if the current dummy is close
        //to it's appropriate facing angle. This is to avoid returning
        //a Dummy which is still turning to face it's list angle.
        private constant real ANGLE_TOLERANCE = 10.0
     
        //An additional option to automatically hide recycled dummy units in the
        //corner of the map camera bounds
        private constant boolean HIDE_ON_MAP_CORNER = true
    endglobals
 
    //Every time a new dummy unit is retrieved, it will apply this resets
    //If it is redundant/you dont need it, remove it.
    //! textmacro DUMMY_UNIT_RESET
    /*
        call SetUnitScale(bj_lastCreatedUnit, 1, 0, 0)
        call SetUnitVertexColor(bj_lastCreatedUnit, 255, 255, 255, 255)
        call SetUnitAnimationByIndex(bj_lastCreatedUnit, 90)
        call ShowDummy(bj_lastCreatedUnit, true)
    */
    //! endtextmacro
// =============================================================== //
// ==================== END CONFIGURATION ======================== //
// =============================================================== //
 
 
    globals
        private integer dummyCount = ANGLES_COUNT*STORED_UNIT_COUNT
        private real array angle
        private integer array count
        private integer array countHead
        private integer array countNext
        private integer array countPrev
        private integer array next
        private integer array prev
        private unit array dummy
        private integer upper
        private integer lower
        private integer lastInstance
        private constant real FACING_OFFSET = 180.0/ANGLES_COUNT
    endglobals
 
    static if HIDE_ON_MAP_CORNER and not LIBRARY_WorldBounds then
        private module BoundsInit
     
            readonly static real x
            readonly static real y
         
            private static method onInit takes nothing returns nothing
                local rect map = GetWorldBounds()
                set thistype.x = GetRectMaxX(map)
                set thistype.y = GetRectMaxY(map)
                call RemoveRect(map)
                set map = null
            endmethod
         
        endmodule
     
        private struct Bounds extends array
            implement BoundsInit
        endstruct
    endif
 
    private module M
     
        static if LIBRARY_Table then
            static Table tb
        else
            static hashtable hash = InitHashtable()
        endif
     
        private static method onInit takes nothing returns nothing
            local real add = 360.0/ANGLES_COUNT
            local real a = 0
            local integer this = ANGLES_COUNT
            local integer head = 0
            local integer cHead = JASS_MAX_ARRAY_SIZE - 1   //avoid allocation collision
            local integer i = R2I(MAX_DUMMY_COUNT/ANGLES_COUNT + 0.5)
            set upper = STORED_UNIT_COUNT
            set lower = STORED_UNIT_COUNT
            static if LIBRARY_Table then
                set tb = Table.create()
            endif
            //Initialize countHeads
            loop
                exitwhen i < 0
                set countNext[cHead] = cHead
                set countPrev[cHead] = cHead
                set countHead[i] = cHead
                set cHead = cHead - 1
                set i = i - 1
            endloop
            set cHead = countHead[STORED_UNIT_COUNT]  //All heads will be inserted here initially
            //Create the Dummy units
            loop
                exitwhen a >= 360
                //Initialize head
                set next[head] = head
                set prev[head] = head
                set count[head] = STORED_UNIT_COUNT
                set angle[head] = a
                //Insert head in the Count List
                set countNext[head] = cHead
                set countPrev[head] = countPrev[cHead]
                set countNext[countPrev[head]] = head
                set countPrev[countNext[head]] = head
                set i = 0
                loop
                    exitwhen i >= STORED_UNIT_COUNT
                    //Queued Linked List
                    set next[this] = head
                    set prev[this] = prev[head]
                    set next[prev[this]] = this
                    set prev[next[this]] = this
                    static if HIDE_ON_MAP_CORNER then
                        static if LIBRARY_WorldBounds then
                            set dummy[this] = CreateUnit(OWNER, DUMMY_ID, WorldBounds.maxX, WorldBounds.maxY, a)
                        else
                            set dummy[this] = CreateUnit(OWNER, DUMMY_ID, Bounds.x, Bounds.y, a)
                        endif
                    else
                        set dummy[this] = CreateUnit(OWNER, DUMMY_ID, 0, 0, a)
                    endif
                    // call PauseUnit(dummy[this], true)
                    static if LIBRARY_Table then
                        set tb[GetHandleId(dummy[this])] = this
                    else
                        call SaveInteger(hash, GetHandleId(dummy[this]), 0, this)
                    endif
                    set this = this + 1
                    set i = i + 1
                endloop
                set head = head + 1
                set a = a + add
            endloop
            set lastInstance = this
        endmethod
     
    endmodule
 
    private struct S extends array
        implement M
    endstruct
 
    private function GetHead takes integer facing returns integer
        if facing < 0 or facing >= 360 then
            set facing = facing - (facing/360)*360
            if facing < 0 then
                set facing = facing + 360
            endif
        endif
        return R2I((facing*ANGLES_COUNT/360.0))
    endfunction
 
    function ShowDummy takes unit u, boolean flag returns nothing
        if IsUnitHidden(u) == flag then
            call ShowUnit(u, flag)
            if flag and GetUnitTypeId(u) == DUMMY_ID then
                call UnitRemoveAbility(u, 'Aloc')
                call UnitAddAbility(u, 'Aloc')
            endif
        endif
    endfunction
 
    function GetRecycledDummy takes real x, real y, real z, real facing returns unit
        local integer head = GetHead(R2I(facing + FACING_OFFSET))
        local integer this = next[head]
        local integer cHead
     
        //If there are Dummy Units in the Queue List already facing close to the appropriate angle
        if this != head and RAbsBJ(GetUnitFacing(dummy[this]) - angle[head]) <= ANGLE_TOLERANCE then
            //Remove from the Queue List
            set next[prev[this]] = next[this]
            set prev[next[this]] = prev[this]
            //For double free protection
            set next[this] = -1
            //Unit Properties
            set bj_lastCreatedUnit = dummy[this]
            call SetUnitX(bj_lastCreatedUnit, x)
            call SetUnitY(bj_lastCreatedUnit, y)
            call SetUnitFacing(bj_lastCreatedUnit, facing)
            call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
            //! runtextmacro DUMMY_UNIT_RESET()
            //Update Count and Bounds
            set count[head] = count[head] - 1
         
            //------------------------------------------------
            //                 Unit Sharing
            //------------------------------------------------
            if count[head] < BORROW_REQUEST and count[countNext[countHead[upper]]] > count[head] then
                set count[head] = count[head] + 1
                set this = next[countNext[countHead[upper]]]
                call SetUnitFacing(dummy[this], angle[head])
                //Remove
                set next[prev[this]] = next[this]
                set prev[next[this]] = prev[this]
                //Add to the Current List
                set next[this] = head
                set prev[this] = prev[head]
                set next[prev[this]] = this
                set prev[next[this]] = this
                set head = countNext[countHead[upper]]
                set count[head] = count[head] - 1
            endif
         
            //---------------------------
            //Update Count Lists
            //---------------------------
            //Remove from the current Count List
            set countNext[countPrev[head]] = countNext[head]
            set countPrev[countNext[head]] = countPrev[head]
            //Add to the new Count List
            set cHead = countHead[count[head]]
            set countNext[head] = cHead
            set countPrev[head] = countPrev[cHead]
            set countNext[countPrev[head]] = head
            set countPrev[countNext[head]] = head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead = countHead[upper]
            if countNext[cHead] == cHead then
                set upper = upper - 1
            endif
            if count[head] < lower then
                set lower = count[head]
            endif
        else
            set bj_lastCreatedUnit = CreateUnit(OWNER, DUMMY_ID, x, y, facing)
            // call PauseUnit(bj_lastCreatedUnit, true)
            call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
            if dummyCount < MAX_DUMMY_COUNT then
                set this = lastInstance
                //For double free protection
                set next[this] = -1
                set dummy[this] = bj_lastCreatedUnit
                static if LIBRARY_Table then
                    set S.tb[GetHandleId(bj_lastCreatedUnit)] = this
                else
                    call SaveInteger(S.hash, GetHandleId(bj_lastCreatedUnit), 0, this)
                endif
                set lastInstance = lastInstance + 1
            endif
            set dummyCount = dummyCount + 1
        endif

        return bj_lastCreatedUnit
    endfunction
 
    function RecycleDummy takes unit u returns nothing
        static if LIBRARY_Table then
            local integer this = S.tb[GetHandleId(u)]
        else
            local integer this = LoadInteger(S.hash, GetHandleId(u), 0)
        endif
        local integer head
        local integer cHead
     
        //If the unit is a legit Dummy Unit
        if this > 0 and next[this] == -1 then
            //Find where to insert based on the list having the least number of units
            set head = countNext[countHead[lower]]
            set next[this] = head
            set prev[this] = prev[head]
            set next[prev[this]] = this
            set prev[next[this]] = this
            //Update Status
            call SetUnitFacing(u, angle[head])
            // call PauseUnit(u, true)
            call SetUnitOwner(u, OWNER, false)
            static if HIDE_ON_MAP_CORNER then
                static if LIBRARY_WorldBounds then
                    call SetUnitX(u, WorldBounds.maxX)
                    call SetUnitY(u, WorldBounds.maxY)
                else
                    call SetUnitX(u, Bounds.x)
                    call SetUnitY(u, Bounds.y)
                endif
            else
                call SetUnitScale(u, 0, 0, 0)
                call SetUnitVertexColor(u, 0, 0, 0, 0)
            endif
            set count[head] = count[head] + 1
         
            //---------------------------
            //    Update Count Lists
            //---------------------------
            //Remove
            set countNext[countPrev[head]] = countNext[head]
            set countPrev[countNext[head]] = countPrev[head]
            //Add to the new Count List
            set cHead = countHead[count[head]]
            set countNext[head] = cHead
            set countPrev[head] = countPrev[cHead]
            set countNext[countPrev[head]] = head
            set countPrev[countNext[head]] = head
         
            //---------------------------
            //  Update Bounds
            //---------------------------
            set cHead = countHead[lower]
            if countNext[cHead] == cHead then
                set lower = lower + 1
            endif
            if count[head] > upper then
                set upper = count[head]
            endif
        elseif this == 0 then
            call RemoveUnit(u)
        debug elseif next[this] != -1 then
            debug call BJDebugMsg("|cffffcc00[DummyRecycler]:|r Attempted to recycle a pending/free Dummy Unit.")
        endif
     
    endfunction
 
    private function Expires takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local integer id = GetHandleId(t)
        static if LIBRARY_Table then
            call RecycleDummy(S.tb.unit[id])
            call S.tb.unit.remove(id)
        else
            call RecycleDummy(LoadUnitHandle(S.hash, id, 0))
            call FlushChildHashtable(S.hash, id)
        endif
        call DestroyTimer(t)
        set t = null
    endfunction

    function DummyAddRecycleTimer takes unit u, real time returns nothing
        local timer t = CreateTimer()
        static if LIBRARY_Table then
            set S.tb.unit[GetHandleId(t)] = u
        else
            call SaveUnitHandle(S.hash, GetHandleId(t), 0, u)
        endif
        call TimerStart(t, time, false, function Expires)
        set t = null
    endfunction
 
    function GetRecycledDummyAnyAngle takes real x, real y, real z returns unit
        return GetRecycledDummy(x, y, z, angle[countNext[countHead[upper]]])
    endfunction
 
    // runtextmacro DUMMY_DEBUG_TOOLS()
 
endlibrary