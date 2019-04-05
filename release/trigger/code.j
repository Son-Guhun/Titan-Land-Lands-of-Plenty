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
// =============================================================== //

////The rawcode of the Dummy Unit
//constant function Dummy_Rawcode takes nothing returns integer
//    return 'h07Q'
//endfunction
//
////The owner of the Dummy Unit
//constant function Dummy_Owner takes nothing returns player
//    return Player(14)
//endfunction
//
////The number of indexed angle. The higher the value the:
//// - Lesser the turning time for the Dummy Units.
//// - Higher the total number of Dummy Units created at Map Initialization.
////          Recommended Value: 10 (Max difference of 18 degrees)
//constant function Dummy_Angles takes nothing returns integer
//    return 10
//endfunction
//
////The number of Dummy units per Dummy_Angle. The higher the value the:
//// - Higher the number of units that can be recycled per angle, when 
////   no more units are in queue, the system will resort to use CreateUnit.
//// - Higher the total number of Dummy Units created at Map Initialization.
////    Recommended Value: 3 to 5 (for less overhead in Map Loading Screen)
//constant function Dummy_StoredUnits takes nothing returns integer
//    return 3
//endfunction
//
////The maximum number of Dummy units that can exist. When the system resort
////to using CreateUnit, the unit will be permanently added to the Dummy
////List. To avoid spamming Dummy Units and having too much free Dummy
////Units to allocate, the maximum number of Dummy Units is capped.
////               Recommended Value: 80 to 120
//constant function Dummy_MaxCount takes nothing returns integer
//    return 100
//endfunction
//
////When a certain angle have less than BORROW_REQUEST units in its list,
////it will start to borrow Dummy Units from the list with the highest
////Dummy Unit count.
////      Recommended Value: Half of maximum Dummy_StoredUnits
//constant function Dummy_BorrowRequest takes nothing returns integer
//    return 5
//endfunction
//
////It will only return a Dummy if the current dummy is close
////to it's appropriate facing angle. This is to avoid returning
////a Dummy which is still turning to face it's list angle.
//constant function Dummy_AngleTolerance takes nothing returns real
//    return 10.0
//endfunction
//
////An additional option to automatically hide recycled dummy units in the
////corner of the map camera bounds
//constant function Dummy_HideOnMapCorner takes nothing returns boolean
//    return true
//endfunction
//
//// =============================================================== //
//// ==================== END CONFIGURATION ======================== //
//// =============================================================== //
//
//function Dummy_GetHead takes integer facing returns integer
//    if facing < 0 or facing >= 360 then
//        set facing = facing - (facing/360)*360
//        if facing < 0 then
//            set facing = facing + 360
//        endif
//    endif
//    return R2I((facing*Dummy_Angles()/360.0))
//endfunction
//
//function ShowDummy takes unit u, boolean flag returns nothing
//    if IsUnitHidden(u) == flag then
//        call ShowUnit(u, flag)
//        if flag and GetUnitTypeId(u) == Dummy_Rawcode() then
//            call UnitRemoveAbility(u, 'Aloc')
//            call UnitAddAbility(u, 'Aloc')
//        endif
//    endif
//endfunction
//
//function GetRecycledDummy takes real x, real y, real z, real facing returns unit
//    local integer head = Dummy_GetHead(R2I(facing + 180.0/Dummy_Angles()))
//    local integer this = udg_Dummy_Next[head]
//    local integer countHead
//    
//    
//    //If there are Dummy Units in the Queue List already facing the appropriate angle
//    if this != head and RAbsBJ(GetUnitFacing(udg_Dummy_Unit[this]) - udg_Dummy_Angle[head]) <= Dummy_AngleTolerance() then
//        //Remove from the Queue List
//        set udg_Dummy_Next[udg_Dummy_Prev[this]] = udg_Dummy_Next[this]
//        set udg_Dummy_Prev[udg_Dummy_Next[this]] = udg_Dummy_Prev[this]
//        //For double free protection
//        set udg_Dummy_Next[this] = -1
//        //Unit Properties
//        set bj_lastCreatedUnit = udg_Dummy_Unit[this]
//        call SetUnitX(bj_lastCreatedUnit, x)
//        call SetUnitY(bj_lastCreatedUnit, y)
//        call SetUnitFacing(bj_lastCreatedUnit, facing)
//        call SetUnitVertexColor(bj_lastCreatedUnit, 255, 255, 255, 255)
//        call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
//        call ShowDummy(bj_lastCreatedUnit, true)
//        //------------------------------------------------
//        //       Comment out resets you don't need
//        //------------------------------------------------
//        call SetUnitScale(bj_lastCreatedUnit, 1, 0, 0)
//        call SetUnitAnimationByIndex(bj_lastCreatedUnit, 90)
//        //Update Count and Bounds
//        set udg_Dummy_Count[head] = udg_Dummy_Count[head] - 1
//        
//        //------------------------------------------------
//        //                 Unit Sharing
//        //------------------------------------------------
//        if udg_Dummy_Count[head] < Dummy_BorrowRequest() and udg_Dummy_Count[udg_Dummy_CountNext[udg_Dummy_CountHead[udg_Dummy_Upper]]] > udg_Dummy_Count[head] then
//            set udg_Dummy_Count[head] = udg_Dummy_Count[head] + 1
//            //Take an instance from the UpperBound list
//            set this = udg_Dummy_Next[udg_Dummy_CountNext[udg_Dummy_CountHead[udg_Dummy_Upper]]]
//            call SetUnitFacing(udg_Dummy_Unit[this], udg_Dummy_Angle[head])
//            //Remove
//            set udg_Dummy_Next[udg_Dummy_Prev[this]] = udg_Dummy_Next[this]
//            set udg_Dummy_Prev[udg_Dummy_Next[this]] = udg_Dummy_Prev[this]
//            //Add to the Current List
//            set udg_Dummy_Next[this] = head
//            set udg_Dummy_Prev[this] = udg_Dummy_Prev[head]
//            set udg_Dummy_Next[udg_Dummy_Prev[this]] = this
//            set udg_Dummy_Prev[udg_Dummy_Next[this]] = this
//            set head = udg_Dummy_CountNext[udg_Dummy_CountHead[udg_Dummy_Upper]]
//            set udg_Dummy_Count[head] = udg_Dummy_Count[head] - 1
//        endif
//        //---------------------------
//        //Update Count Lists
//        //---------------------------
//        //Remove from the current Count List
//        set udg_Dummy_CountNext[udg_Dummy_CountPrev[head]] = udg_Dummy_CountNext[head]
//        set udg_Dummy_CountPrev[udg_Dummy_CountNext[head]] = udg_Dummy_CountPrev[head]
//        //Add to the new Count List
//        set countHead = udg_Dummy_CountHead[udg_Dummy_Count[head]]
//        set udg_Dummy_CountNext[head] = countHead
//        set udg_Dummy_CountPrev[head] = udg_Dummy_CountPrev[countHead]
//        set udg_Dummy_CountNext[udg_Dummy_CountPrev[head]] = head
//        set udg_Dummy_CountPrev[udg_Dummy_CountNext[head]] = head
//        
//        //---------------------------
//        //  Update Bounds
//        //---------------------------
//        set countHead = udg_Dummy_CountHead[udg_Dummy_Upper]
//        if udg_Dummy_CountNext[countHead] == countHead then
//            set udg_Dummy_Upper = udg_Dummy_Upper - 1
//        endif
//        if udg_Dummy_Count[head] < udg_Dummy_Lower  then
//            set udg_Dummy_Lower = udg_Dummy_Count[head]
//        endif
//    else
//        set bj_lastCreatedUnit = CreateUnit(Dummy_Owner(), Dummy_Rawcode(), x, y, facing)
//        call PauseUnit(bj_lastCreatedUnit, true)
//        call SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
//        if udg_Dummy_UnitCount < Dummy_MaxCount() then
//            set this = udg_Dummy_LastInstance
//            set udg_Dummy_Next[this] = -1
//            set udg_Dummy_Unit[this] = bj_lastCreatedUnit
//            call SaveInteger(udg_Dummy_Hashtable, GetHandleId(bj_lastCreatedUnit), 0, this)
//            set udg_Dummy_LastInstance = udg_Dummy_LastInstance + 1
//        endif
//        set udg_Dummy_UnitCount = udg_Dummy_UnitCount + 1
//    endif
//
//    return bj_lastCreatedUnit
//endfunction
//
//function GetRecycledDummyAnyAngle takes real x, real y, real z returns unit
//    return GetRecycledDummy(x, y, z, udg_Dummy_Angle[udg_Dummy_CountNext[udg_Dummy_CountHead[udg_Dummy_Upper]]])
//endfunction
//
//
//function RecycleDummy takes unit u returns nothing
//    local integer this = LoadInteger(udg_Dummy_Hashtable, GetHandleId(u), 0)
//    local integer head
//    local integer countHead
//    
//    //If the unit is a legit Dummy Unit
//    if this > 0 and udg_Dummy_Next[this] == -1 then
//        //Find where to insert based on the list having the least number of units
//        set head = udg_Dummy_CountNext[udg_Dummy_CountHead[udg_Dummy_Lower]]
//        set udg_Dummy_Next[this] = head
//        set udg_Dummy_Prev[this] = udg_Dummy_Prev[head]
//        set udg_Dummy_Next[udg_Dummy_Prev[this]] = this
//        set udg_Dummy_Prev[udg_Dummy_Next[this]] = this
//        //Update Status
//        call SetUnitFacing(u, udg_Dummy_Angle[head])
//        call PauseUnit(u, true)
//        call SetUnitOwner(u, Dummy_Owner(), false)
//        if Dummy_HideOnMapCorner() then
//            call SetUnitX(u, udg_Dummy_X)
//            call SetUnitY(u, udg_Dummy_Y)
//        else
//            call SetUnitVertexColor(u, 0, 0, 0, 0)
//        endif
//        set udg_Dummy_Count[head] = udg_Dummy_Count[head] + 1
//        
//        //---------------------------
//        //    Update Count Lists
//        //---------------------------
//        //Remove
//        set udg_Dummy_CountNext[udg_Dummy_CountPrev[head]] = udg_Dummy_CountNext[head]
//        set udg_Dummy_CountPrev[udg_Dummy_CountNext[head]] = udg_Dummy_CountPrev[head]
//        //Add to the new Count List
//        set countHead = udg_Dummy_CountHead[udg_Dummy_Count[head]]
//        set udg_Dummy_CountNext[head] = countHead
//        set udg_Dummy_CountPrev[head] = udg_Dummy_CountPrev[countHead]
//        set udg_Dummy_CountNext[udg_Dummy_CountPrev[head]] = head
//        set udg_Dummy_CountPrev[udg_Dummy_CountNext[head]] = head
//        
//        //---------------------------
//        //  Update Bounds
//        //---------------------------
//        set countHead = udg_Dummy_CountHead[udg_Dummy_Lower]
//        if udg_Dummy_CountNext[countHead] == countHead then
//            set udg_Dummy_Lower = udg_Dummy_Lower + 1
//        endif
//        if udg_Dummy_Count[head] > udg_Dummy_Upper then
//            set udg_Dummy_Upper = udg_Dummy_Count[head]
//        endif
//    elseif this == 0 then
//        //User tries to recycle an invalid unit, remove the unit instead
//        call RemoveUnit(u)
//    endif
//    
//endfunction
//
//function Dummy_TimerExpires takes nothing returns nothing
//    local timer t = GetExpiredTimer()
//    local integer id = GetHandleId(t)
//    call RecycleDummy(LoadUnitHandle(udg_Dummy_Hashtable, id, 0))
//    call FlushChildHashtable(udg_Dummy_Hashtable, id)
//    call DestroyTimer(t)
//    set t = null
//endfunction
//
//function DummyAddRecycleTimer takes unit u, real time returns nothing
//    local timer t = CreateTimer()
//    call SaveUnitHandle(udg_Dummy_Hashtable, GetHandleId(t), 0, u)
//    call TimerStart(t, time, false, function Dummy_TimerExpires)
//    set t = null
//endfunction
//
//////////////////////////////////////////////////////
//END OF DUMMY RECYCLER
//////////////////////////////////////////////////////



