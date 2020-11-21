library GUISpellSystem initializer Init

function SpellIndexGetVars takes integer i returns nothing
    set udg_Spell__Ability = udg_Spell_i_Abil[udg_Spell_i_Head[i]]
    set udg_Spell__Index = i
    set udg_Spell__Caster = udg_Spell_i_Caster[i]
    set udg_Spell__CasterOwner = GetOwningPlayer(udg_Spell__Caster)
    set udg_Spell__Level = udg_Spell_i_Level[i]
    set udg_Spell__LevelMultiplier = udg_Spell__Level //Spell__LevelMultiplier is a real variable.
    set udg_Spell__Target = udg_Spell_i_Target[i]
    
    //Magic to ensure the locations never leak.
    call MoveLocation(udg_Spell__CastPoint, GetUnitX(udg_Spell__Caster), GetUnitY(udg_Spell__Caster))
    if udg_Spell__Target == null then
        call MoveLocation(udg_Spell__TargetPoint, udg_Spell_i_TargetX[i], udg_Spell_i_TargetY[i])
    else
        call MoveLocation(udg_Spell__TargetPoint, GetUnitX(udg_Spell__Target), GetUnitY(udg_Spell__Target))
    endif
    set udg_Spell__TargetGroup = udg_Spell_i_TargetGroup[i]
    set udg_Spell__Completed = udg_Spell_i_Completed[i]
    set udg_Spell__Channeling = udg_Spell_i_Channeling[i]
endfunction

function SpellSetFilters takes integer i returns nothing
    set udg_Spell_i_AllowEnemy[i]       = udg_Spell__Filter_AllowEnemy
    set udg_Spell_i_AllowAlly[i]        = udg_Spell__Filter_AllowAlly
    set udg_Spell_i_AllowDead[i]        = udg_Spell__Filter_AllowDead
    set udg_Spell_i_AllowLiving[i]      = udg_Spell__Filter_AllowLiving
    set udg_Spell_i_AllowMagicImmune[i] = udg_Spell__Filter_AllowMagicImmune
    set udg_Spell_i_AllowMechanical[i]  = udg_Spell__Filter_AllowMechanical
    set udg_Spell_i_AllowStructure[i]   = udg_Spell__Filter_AllowStructure
    set udg_Spell_i_AllowFlying[i]      = udg_Spell__Filter_AllowFlying
    set udg_Spell_i_AllowHero[i]        = udg_Spell__Filter_AllowHero
    set udg_Spell_i_AllowNonHero[i]     = udg_Spell__Filter_AllowNonHero
endfunction

function SpellIndexDestroy takes integer i returns nothing
    local integer indexOf
    local integer index
    if udg_Spell_i_RecycleList[i] >= 0 then
        return
    endif
    //If the caster is still channeling on the spell, don't destroy until it's finished:
    if not udg_Spell_i_Channeling[i] then
        set index = udg_Spell_i_Head[i]
        set udg_Spell_i_RecycleList[i] = udg_Spell_i_Recycle
        set udg_Spell_i_Recycle = i
        
        //Reset things to defaults:
        set udg_Spell_i_Time[i] = 0.00
        set udg_Spell_i_LastTime[i] = 0.00
        set udg_Spell_i_Duration[i] = 0.00
        set udg_Spell_i_Completed[i] = false
        set udg_Spell_i_Caster[i] = null
        set udg_Spell_i_Target[i] = null
        set udg_Spell_i_OnLoopStack[i] = null
        
        //Recycle any applicable target unit group.
        if udg_Spell_i_TargetGroup[i] != null then
            call GroupClear(udg_Spell_i_TargetGroup[i])
            set udg_Spell_i_GroupStack[udg_Spell_i_GroupN] = udg_Spell_i_TargetGroup[i]
            set udg_Spell_i_GroupN = udg_Spell_i_GroupN + 1
            set udg_Spell_i_TargetGroup[i] = null
        endif
        
        //Clear any user-specified data in the hashtable:
        call FlushChildHashtable(udg_Spell__Hash, i)
        //call BJDebugMsg("Destroying index: " + I2S(i))
    endif
    
    set indexOf = udg_Spell_i_StackRef[i]
    if indexOf >= 0 then
        set index = udg_Spell_i_StackN - 1
        set udg_Spell_i_StackN = index
        
        set udg_Spell_i_StackRef[udg_Spell_i_Stack[index]] = indexOf
        set udg_Spell_i_Stack[indexOf] = udg_Spell_i_Stack[index]
        if index == 0 then
            //If no more spells require the timer, pause it.
            call PauseTimer(udg_Spell_i_Timer)
        endif
        set udg_Spell_i_StackRef[i] = -1
    endif
endfunction

function SpellTriggerExecute takes integer i, trigger t returns real
    local real d = udg_Spell_i_Duration[i]
    local boolean b = false
    set udg_Spell__Duration = d
    set udg_Spell__Time = 0.00
    if t != null then
        set udg_Spell__Trigger_OnLoop = null
        set udg_Spell__Expired = d <= 0.00 //If the duration is <= 0, the spell has expired.
        call SpellIndexGetVars(i)
        if TriggerEvaluate(t) then
            call TriggerExecute(t)
        endif
        if udg_Spell__Trigger_OnLoop != null then
            set udg_Spell_i_OnLoopStack[i] = udg_Spell__Trigger_OnLoop
        endif
        //The remaining lines in this function process the duration specified by the user.
        if udg_Spell__StartDuration then
            set udg_Spell__StartDuration = false
            set udg_Spell__Duration = udg_Spell_i_Duration[udg_Spell_i_Head[i]] + udg_Spell_i_LastTime[udg_Spell_i_Head[i]]*udg_Spell__LevelMultiplier
        elseif (udg_Spell__Expired and d > 0.00) or (udg_Spell__Duration <= 0.00) then
            set udg_Spell__Duration = 0.00
            return udg_Spell__Time
            //The user manually expired the spell or the spell duration ended on its own.
        endif
        if d != udg_Spell__Duration then
            //A new duration has been assigned
            set d = udg_Spell__Duration
            set b = true
        endif
        set udg_Spell__Duration = 0.00
        if udg_Spell__Time == 0.00 then
            if udg_Spell_i_LastTime[i] == 0.00 then
                if udg_Spell_i_Time[udg_Spell_i_Head[i]] > 0.00 then
                    //The user specified a default interval to follow:
                    set udg_Spell__Time = udg_Spell_i_Time[udg_Spell_i_Head[i]]
                else
                    //Set the spell time to the minimum.
                    set udg_Spell__Time = udg_Spell__Interval
                endif
            else
                //Otherwise, set it to what it was before.
                set udg_Spell__Time = udg_Spell_i_LastTime[i]
            endif
        //else, the user is specifying a new time for the spell.
        endif
        set udg_Spell_i_LastTime[i] = udg_Spell__Time //Whatever the case, remember this time for next time.
        if b then
            //The duration was just assigned
            set udg_Spell_i_Duration[i] = d
        else
            //The duration has been ongoing
            set udg_Spell_i_Duration[i] = d - udg_Spell__Time
        endif
    endif
    return udg_Spell__Time
endfunction

//===========================================================================
// Runs every Spell__Interval seconds and handles all of the timed events.
// 
function SpellTimerLoop takes nothing returns nothing
    local integer i = udg_Spell_i_StackN
    local integer node
    local real time
    set udg_Spell__Running = true
    
    //Run stack top to bottom to avoid skipping slots when destroying.
    loop
        set i = i - 1
        exitwhen i < 0
        set node = udg_Spell_i_Stack[i]
        set time = udg_Spell_i_Time[node] - udg_Spell__Interval
        if time <= 0.00 then
            set time = SpellTriggerExecute(node, udg_Spell_i_OnLoopStack[node])
        endif
        if time <= 0.00 then
            call SpellIndexDestroy(node)
        else
            set udg_Spell_i_Time[node] = time
        endif
    endloop
    set udg_Spell__Running = false
endfunction

//===========================================================================
// This is the meat of the system as it handles the event responses.
// 
function RunSpellEvent takes nothing returns boolean
    local boolean b
    local integer aid = GetSpellAbilityId()
    local integer head = LoadInteger(udg_Spell__Hash, 0, aid)
    local integer i
    local integer id
    local trigger t
    local playerunitevent eid
    if head == 0 then
        //Nothing for this ability has been registered. Skip the sequence.
        return false
    endif
    set eid = ConvertPlayerUnitEvent(GetHandleId(GetTriggerEventId()))
    set udg_Spell__Caster = GetTriggerUnit()
    set id = GetHandleId(udg_Spell__Caster)
    set i = LoadInteger(udg_Spell__Hash, aid, id)
    if i == 0 then
        //This block will almost always happen with the OnChannel event. In the
        //case of Charge Gold and Lumber, only an OnEffect event will run.
        set i = udg_Spell_i_Recycle
        if i == 0 then
            //Create a new, unique index
            set i = udg_Spell_i_Instances + 1
            set udg_Spell_i_Instances = i
        else
            //Repurpose an existing one
            set udg_Spell_i_Recycle = udg_Spell_i_RecycleList[i]
        endif
        //call BJDebugMsg("Creating index: " + I2S(i))
        set udg_Spell_i_RecycleList[i] = -1
        set udg_Spell_i_StackRef[i] = -1
        set udg_Spell_i_Head[i] = head
        
        if eid == EVENT_PLAYER_UNIT_SPELL_CHANNEL then
            set udg_Spell_i_Channeling[i] = true
            call SaveInteger(udg_Spell__Hash, aid, id, i)
            set t = udg_Spell_i_OnChannelStack[head]
        else //eid == EVENT_PLAYER_UNIT_SPELL_EFFECT
            set t = udg_Spell_i_OnEffectStack[head]
        endif
        set udg_Spell_i_Caster[i] = udg_Spell__Caster
        set udg_Spell_i_Level[i] = GetUnitAbilityLevel(udg_Spell__Caster, aid)
        set udg_Spell_i_Target[i] = GetSpellTargetUnit()
        set udg_Spell_i_TargetX[i] = GetSpellTargetX()
        set udg_Spell_i_TargetY[i] = GetSpellTargetY()
        
        set udg_Spell_i_OnLoopStack[i] = udg_Spell_i_OnLoopStack[head]
        if udg_Spell_i_UseTG[head] then
            //Get a recycled unit group or create a new one.
            set id = udg_Spell_i_GroupN - 1
            if id >= 0 then
                set udg_Spell_i_GroupN = id
                set udg_Spell_i_TargetGroup[i] = udg_Spell_i_GroupStack[id]
            else
                set udg_Spell_i_TargetGroup[i] = CreateGroup()
            endif
        endif
    elseif eid == EVENT_PLAYER_UNIT_SPELL_CAST then
        set t = udg_Spell_i_OnCastStack[head]
    elseif eid == EVENT_PLAYER_UNIT_SPELL_EFFECT then
        set t = udg_Spell_i_OnEffectStack[head]
    elseif eid == EVENT_PLAYER_UNIT_SPELL_FINISH then
        set udg_Spell_i_Completed[i] = true
        return true
    else //eid == EVENT_PLAYER_UNIT_SPELL_ENDCAST
        set udg_Spell_i_Channeling[i] = false
        call RemoveSavedInteger(udg_Spell__Hash, aid, id)
        set t = udg_Spell_i_OnFinishStack[head]
    endif
    if SpellTriggerExecute(i, t) > 0.00 then
        //Set the spell time to the user-specified one.
        set udg_Spell_i_Time[i] = udg_Spell__Time
        if udg_Spell_i_StackRef[i] < 0 then
            //Allocate the spell index onto the loop stack.
            set aid = udg_Spell_i_StackN
            set udg_Spell_i_Stack[aid] = i
            set udg_Spell_i_StackRef[i] = aid
            set udg_Spell_i_StackN = aid + 1
            if aid == 0 then
                //If this is the first spell index using the timer, start it up:
                call TimerStart(udg_Spell_i_Timer, udg_Spell__Interval, true, function SpellTimerLoop)
            endif
        endif
    elseif (not udg_Spell_i_Channeling[i]) and (t != null or udg_Spell_i_Time[i] <= 0.00) then
        call SpellIndexDestroy(i)
    endif
    set t = null
    return true
endfunction

//This function is invoked if an event was launched recursively by another event's callback.
function RunPreSpellEvent takes nothing returns nothing
    local integer i = udg_Spell__Index
    local real time = udg_Spell__Time
    local real d = udg_Spell__Duration
    local boolean expired = udg_Spell__Expired
    if udg_Spell__Trigger_OnLoop != null then
        set udg_Spell_i_OnLoopStack[i] = udg_Spell__Trigger_OnLoop
    endif
    if RunSpellEvent() then
        set udg_Spell__Time = time
        set udg_Spell__Duration = d
        set udg_Spell__Expired = expired
        call SpellIndexGetVars(i)
    endif
endfunction

//===========================================================================
// Base function of the system: runs when an ability event does something.
// 
function SpellSystemEvent takes nothing returns boolean
    if udg_Spell__Running then
        call RunPreSpellEvent()
    else
        set udg_Spell__Running = true
        call RunSpellEvent()
        set udg_Spell__Running = false
    endif
    return false
endfunction

//===========================================================================
// Set Spell__Ability to your spell's ability
// Set Spell__Trigger_OnChannel/Cast/Effect/Finish/Loop to any trigger(s) you
// want to automatically run.
// 
// GUI-friendly: Run Spell System <gen> (ignoring conditions)
// 
function SpellSystemRegister takes nothing returns nothing
    local integer aid = udg_Spell__Ability
    local integer head = udg_Spell_i_Instances + 1
    
    if HaveSavedInteger(udg_Spell__Hash, 0, aid) or aid == 0 then
        //The system rejects duplicate or unassigned abilities.
        return
    endif
    set udg_Spell_i_Instances = head
    set udg_Spell_i_Abil[head] = aid
    
    //Preload the ability on dummy unit to help prevent first-instance lag
    call UnitAddAbility(udg_Spell_i_PreloadDummy, aid)
    
    //Save head index to the spell ability so it be referenced later.
    call SaveInteger(udg_Spell__Hash, 0, aid, head)
    
    //Set any applicable event triggers.
    set udg_Spell_i_OnChannelStack[head]= udg_Spell__Trigger_OnChannel
    set udg_Spell_i_OnCastStack[head]   = udg_Spell__Trigger_OnCast
    set udg_Spell_i_OnEffectStack[head] = udg_Spell__Trigger_OnEffect
    set udg_Spell_i_OnFinishStack[head] = udg_Spell__Trigger_OnFinish
    set udg_Spell_i_OnLoopStack[head]   = udg_Spell__Trigger_OnLoop
    set udg_Spell_i_InRangeFilter[head] = udg_Spell__Trigger_InRangeFilter
    
    //Set any customized filter variables:
    call SpellSetFilters(head)
    
    //Tell the system to automatically create target groups, if needed
    set udg_Spell_i_AutoAddTargets[head] = udg_Spell__AutoAddTargets
    set udg_Spell_i_UseTG[head] = udg_Spell__UseTargetGroup or udg_Spell__AutoAddTargets
    
    //Handle automatic buff assignment
    set udg_Spell_i_BuffAbil[head] = udg_Spell__BuffAbility
    set udg_Spell_i_BuffOrder[head] = udg_Spell__BuffOrder
    
    //Set the default time sequences if a duration is used:
    set udg_Spell_i_Time[head]     = udg_Spell__Time
    set udg_Spell_i_Duration[head] = udg_Spell__Duration
    set udg_Spell_i_LastTime[head] = udg_Spell__DurationPerLevel
    
    //Set variables back to their defaults:
    set udg_Spell__Trigger_OnChannel    = null
    set udg_Spell__Trigger_OnCast       = null
    set udg_Spell__Trigger_OnEffect     = null
    set udg_Spell__Trigger_OnFinish     = null
    set udg_Spell__Trigger_OnLoop       = null
    set udg_Spell__Trigger_InRangeFilter= null
    set udg_Spell__AutoAddTargets       = false
    set udg_Spell__UseTargetGroup       = false
    set udg_Spell__Time                 = 0.00
    set udg_Spell__Duration             = 0.00
    set udg_Spell__DurationPerLevel     = 0.00
    set udg_Spell__BuffAbility          = 0
    set udg_Spell__BuffOrder            = 0
    
    set udg_Spell__Filter_AllowEnemy        = udg_Spell_i_AllowEnemy[0]
    set udg_Spell__Filter_AllowAlly         = udg_Spell_i_AllowAlly[0]
    set udg_Spell__Filter_AllowDead         = udg_Spell_i_AllowDead[0]
    set udg_Spell__Filter_AllowMagicImmune  = udg_Spell_i_AllowMagicImmune[0]
    set udg_Spell__Filter_AllowMechanical   = udg_Spell_i_AllowMechanical[0]
    set udg_Spell__Filter_AllowStructure    = udg_Spell_i_AllowStructure[0]
    set udg_Spell__Filter_AllowFlying       = udg_Spell_i_AllowFlying[0]
    set udg_Spell__Filter_AllowHero         = udg_Spell_i_AllowHero[0]
    set udg_Spell__Filter_AllowNonHero      = udg_Spell_i_AllowNonHero[0]
    set udg_Spell__Filter_AllowLiving       = udg_Spell_i_AllowLiving[0]
endfunction

function SpellFilterCompare takes boolean is, boolean yes, boolean no returns boolean
    return (is and yes) or ((not is) and no)
endfunction

//===========================================================================
// Before calling this function, set Spell__InRangePoint to whatever point
// you need, THEN set Spell__InRange to the radius you need. The system will
// enumerate the units matching the configured filter and fill them into
// Spell_InRangeGroup.
// 
function SpellGroupUnitsInRange takes nothing returns boolean
    local integer i = udg_Spell_i_Head[udg_Spell__Index]
    local integer j = 0
    local unit u
    local real padding = 64.00
    if udg_Spell_i_AllowStructure[i] then
        //A normal unit can only have up to size 64.00 collision, but if the
        //user needs to check for structures we need a padding big enough for
        //the "fattest" ones: Tier 3 town halls.
        set padding = 197.00
    endif
    call GroupEnumUnitsInRangeOfLoc(udg_Spell__InRangeGroup, udg_Spell__InRangePoint, udg_Spell__InRange + padding, null)
    loop
        set u = FirstOfGroup(udg_Spell__InRangeGroup)
        exitwhen u == null
        call GroupRemoveUnit(udg_Spell__InRangeGroup, u)
        loop
            exitwhen udg_Spell_i_AutoAddTargets[i] and IsUnitInGroup(u, udg_Spell__TargetGroup)
            exitwhen not IsUnitInRangeLoc(u, udg_Spell__InRangePoint, udg_Spell__InRange)
            exitwhen not SpellFilterCompare(IsUnitType(u, UNIT_TYPE_DEAD), udg_Spell_i_AllowDead[i], udg_Spell_i_AllowLiving[i])
            exitwhen not SpellFilterCompare(IsUnitAlly(u, udg_Spell__CasterOwner), udg_Spell_i_AllowAlly[i], udg_Spell_i_AllowEnemy[i])
            exitwhen not SpellFilterCompare(IsUnitType(u, UNIT_TYPE_HERO) or IsUnitType(u, UNIT_TYPE_RESISTANT), udg_Spell_i_AllowHero[i], udg_Spell_i_AllowNonHero[i])
            exitwhen IsUnitType(u, UNIT_TYPE_STRUCTURE) and not udg_Spell_i_AllowStructure[i]
            exitwhen IsUnitType(u, UNIT_TYPE_FLYING) and not udg_Spell_i_AllowFlying[i]
            exitwhen IsUnitType(u, UNIT_TYPE_MECHANICAL) and not udg_Spell_i_AllowMechanical[i]
            exitwhen IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and not udg_Spell_i_AllowMagicImmune[i]
            set udg_Spell__InRangeUnit = u
            //Run the user's designated filter, if one exists.
            exitwhen udg_Spell_i_InRangeFilter[i] != null and not TriggerEvaluate(udg_Spell_i_InRangeFilter[i])
            set j = j + 1
            set udg_Spell__InRangeUnits[j] = u
            exitwhen true
        endloop
    endloop
    if j > udg_Spell__InRangeMax and udg_Spell__InRangeMax > 0 then
        //The user has defined a maximum number of units allowed in the group.
        //Remove a random unit until the total does not exceed capacity.
        loop
            set i = GetRandomInt(1, j)
            set udg_Spell__InRangeUnits[i] = udg_Spell__InRangeUnits[j]
            set j = j - 1
            exitwhen j == udg_Spell__InRangeMax
        endloop
    endif
    set udg_Spell__InRangeCount = j
    set udg_Spell__InRangeMax = 0
    set udg_Spell__InRange = 0.00
    set i = udg_Spell_i_Head[udg_Spell__Index]
    loop
        exitwhen j == 0
        set u = udg_Spell__InRangeUnits[j]
        call GroupAddUnit(udg_Spell__InRangeGroup, u)
        if udg_Spell_i_AutoAddTargets[i] then
            call GroupAddUnit(udg_Spell__TargetGroup, u)
        endif
        if udg_Spell__WakeTargets and UnitIsSleeping(u) then
            call UnitWakeUp(u)
        endif
        if udg_Spell_i_BuffAbil[i] != 0 and udg_Spell_i_BuffOrder[i] != 0 then
            //Auto-buff units added to group:
            call UnitAddAbility(udg_Spell_i_PreloadDummy, udg_Spell_i_BuffAbil[i])
            call IssueTargetOrderById(udg_Spell_i_PreloadDummy, udg_Spell_i_BuffOrder[i], u)
            call UnitRemoveAbility(udg_Spell_i_PreloadDummy, udg_Spell_i_BuffAbil[i])
        endif
        set j = j - 1
    endloop
    set u = null
    return false
endfunction

function SpellPreloadEnd takes nothing returns nothing
    local integer i = udg_Spell_i_Instances
    loop
        exitwhen i == 0
        //Remove preloaded abilities so they don't interfere with orders
        call UnitRemoveAbility(udg_Spell_i_PreloadDummy, udg_Spell_i_Abil[udg_Spell_i_Head[i]])
        set i = i - 1
    endloop
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local integer i = bj_MAX_PLAYER_SLOTS
    local player p
    local trigger t
    
    if gg_trg_Spell_System != null then
        //A JASS function call already initialized the system.
        return
    endif
    
    //This runs before map init events so the hashtable is ready before then.
    set udg_Spell__Hash = InitHashtable()
    
    //Initialize these two locations which will never get removed
    set udg_Spell__CastPoint = Location(0, 0)
    set udg_Spell__TargetPoint = Location(0, 0)
    
    //Recycle existing unit groups into the recycle stack to avoid needing to destroy any extras.
    set udg_Spell_i_GroupStack[2] = udg_Spell__TargetGroup
    set udg_Spell_i_GroupStack[3] = udg_Spell_i_TargetGroup[0]
    set udg_Spell_i_GroupStack[4] = udg_Spell_i_TargetGroup[1]
    set udg_Spell_i_GroupN = 5 //There are already five valid unit groups thanks to Variable Editor.
    
    set t = CreateTrigger()
    call TriggerRegisterVariableEvent(t, "udg_Spell__InRange", GREATER_THAN, 0.00)
    call TriggerAddCondition(t, Filter(function SpellGroupUnitsInRange))
    
    set t = CreateTrigger()
    call TriggerAddCondition(t, Filter(function SpellSystemEvent))
    loop
        set i = i - 1
        set p = Player(i)
        call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_SPELL_CHANNEL, null)
        call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_SPELL_CAST, null)
        call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_SPELL_EFFECT, null)
        call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_SPELL_FINISH, null)
        call TriggerRegisterPlayerUnitEvent(t, p, EVENT_PLAYER_UNIT_SPELL_ENDCAST, null)
        exitwhen i == 0
    endloop
    set p = null
    set t = null
    
    //Run the configuration trigger so its variables are ready before the
    //map initialization events run.
    call TriggerExecute(gg_trg_Spell_System_Config)
    call SpellSetFilters(0)
    
    //Create this trigger so it's GUI-friendly.
    set gg_trg_Spell_System = CreateTrigger()
    call TriggerAddAction(gg_trg_Spell_System, function SpellSystemRegister)
    set gg_trg_Spell_System_Config = gg_trg_Spell_System //In case the user accidentally picks this one
    
    //Create a dummy unit for preloading abilities and casting buffs.
    set udg_Spell_i_PreloadDummy = CreateUnit(udg_Spell__DummyOwner, udg_Spell__DummyType, 0, 0, 0)
    
    //Start the timer to remove its abilities:
    call TimerStart(udg_Spell_i_Timer, 0.00, false, function SpellPreloadEnd)
    call UnitRemoveAbility(udg_Spell_i_PreloadDummy, 'Amov') //Force it to never move to cast spells
endfunction

// ===============================
// New functions by Guhun:

function RegisterSpellSimple takes integer abilId, code action, boolexpr condition returns trigger
    set udg_Spell__Ability = abilId
    set udg_Spell__Trigger_OnEffect = CreateTrigger()
    
    if action != null then
        call TriggerAddAction(udg_Spell__Trigger_OnEffect, action)
    endif
    
    if condition != null then
        call TriggerAddCondition(udg_Spell__Trigger_OnEffect, condition)
    endif
    
    call TriggerExecute(gg_trg_Spell_System)
    return udg_Spell__Trigger_OnEffect
endfunction

function RegisterSpellSimpleOnCast takes integer abilId, code action, boolexpr condition returns trigger
    set udg_Spell__Ability = abilId
    set udg_Spell__Trigger_OnCast = CreateTrigger()
    
    if action != null then
        call TriggerAddAction(udg_Spell__Trigger_OnCast, action)
    endif
    
    if condition != null then
        call TriggerAddCondition(udg_Spell__Trigger_OnCast, condition)
    endif
    
    call TriggerExecute(gg_trg_Spell_System)
    return udg_Spell__Trigger_OnCast
endfunction

function RegisterSpellSimpleOnFinish takes integer abilId, code action, boolexpr condition returns trigger
    set udg_Spell__Ability = abilId
    set udg_Spell__Trigger_OnFinish = CreateTrigger()
    
    if action != null then
        call TriggerAddAction(udg_Spell__Trigger_OnFinish, action)
    endif
    
    if condition != null then
        call TriggerAddCondition(udg_Spell__Trigger_OnFinish, condition)
    endif
    
    call TriggerExecute(gg_trg_Spell_System)
    return udg_Spell__Trigger_OnFinish
endfunction

endlibrary