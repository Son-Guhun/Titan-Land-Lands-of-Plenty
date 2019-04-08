//************************************************************************************************************
//*                                                                                                          *
//*                              CUSTOM STAT SYSTEM (CSS)                                                    *
//*                                                                                                          *
//*   Author:   Doomlord                                                                                     *
//*   Version:  1.5g                                                                                         *
//*                                                                                                          *
//*   Credits:                                                                                               *
//*   + Earth-Fury:    BonusMod binary algoritm; implementation macro.                                       *
//*   + Crigges:       A great amount of help and support.                                                   *
//*   + Geries:        Help me with the item hashtable values cleanup.                                       *
//*   + rulerofiron99: Item Socketing method referenced from [GUI]Right Click Item Recipe v1.05.             *
//*   + Vexorian:      CSS_SimError [url]http://www.wc3c.net/showthread.php?t=101260[/url]                   *
//*   + Magtheridon96: [Snippet]BoundInt [url]http://www.hiveworkshop.com/forums/2294066-post804.html[/url]  *
//*   + WaterKnight:   Help with the stack for custom Event Response.                                        *
//*   + PurgeandFire:  Pinpoint a possible desync bug with the system.                                       *
//*   + Nestharus:     Mentioning the possible negative life bug in his Bonus lib.                           *
//*                                                                                                          *
//************************************************************************************************************


//**************************************************************************************
//* INTRODUCTION:                                                                      *
//*                                                                                    *
//* 1 item - 11 passive stats with one custom script. This is Custom Stat System (CSS) *
//*                                                                                    *
//* A system that aims to get rid of mapmakers' annoyance of having to do a boring and *
//* repetitive job of creating a multitude of item passive stat abilities. At the      *
//* same time it also possesses generic bonus mod features to let you modify a unit's  *
//* stats freely and easily. It is also quite GUI friendly since everything can be     *
//* achieved solely through custom scripts.                                            *
//*                                                                                    *
//* Version 1.2 and onwards supports item socketing.                                   *
//**************************************************************************************


//**********************************************************************************************************************************
//* FEATURES:                                                                                                                      *
//*                                                                                                                                *
//* Pros:                                                                                                                          *
//* + Simple and GUI-friendly item passive stats registration.                                                                     *
//* + Has little effect on performance.                                                                                            *
//* + Quick implementation of system and system abilities through macro.                                                           *
//* + You no longer have to sit for hours creating item passive abilities for your map.                                            *
//* + Use only 1 hashtable (udg_CSS_Hashtable).                                                                                    *
//* + Pure JASS, only require JNGP for ability implementation.                                                                     *
//* + BonusMod-like features with better range for some stats.                                                                     *
//* + Bonus Range: -131072 to 131071.                                                                                              *
//* + Right Click Item Socketing.                                                                                                  *
//* + Socket event can be caught with the Event: EVENT_SOCKET_FINISH becomes equal to 1.00.                                        *
//* + In JASS: call TriggerRegisterVariableEvent(trigger, "EVENT_SOCKET_FINISH", EQUAL, 1.00).                                     *                                                                                                   *
//*                                                                                                                                *
//* Cons:                                                                                                                          *
//* + Does not include movement speed.                                                                                             *
//* + May bug if a unit somehow surpasses the bonus limit in some occasion.                                                        *
//* -> Fix: Don't allow a unit to achieve near-limit for a stat i.e keep it at a reasonable level.                                 *
//* + Limited configurability.                                                                                                     *
//* + Insufficient item tooltip, which is unavoidable because it is hard-coded.                                                    *
//**********************************************************************************************************************************


//********************************************************************************************************
//* REQUIREMENTS:                                                                                        *
//*                                                                                                      *
//* JNGP [url]http://www.hiveworkshop.com/forums/tools-560/jassnewgenpack-5d-227445[/url] (Recommended)  *
//* OR:                                                                                                  *
//* Your superhuman capability to transfer 198 abilities to your map. (Not Recommended)                  *
//********************************************************************************************************


//************************************************************************************************************************************************
//* INSTALLATION INSTRUCTION:                                                                                                                    *
//*                                                                                                                                              *
//* Step 1: Copy the custom code for bonus handling to your map header.                                                                          *
//* Step 2: Use JNGP to implement the system's abilities through macro. Instruction is included in the Implementation Macro trigger.             *
//* Step 3: Copy the whole CSS folder to your map. Don't forget to turn on "Automatically create unknown variables while pasting trigger data".  *
//* Step 4: Put the CSS trigger on top of your Item Declaration trigger.                                                                         *
//* Step 5: Register your items as examplified in the Item Declaration trigger. Remember to use Map Initialization event.                        *
//* Step 6: Set the global variables to modify your settings.                                                                                    *
//*         + udg_CSS_GemLevel: set a level identifier for your gem items. Gem Items must have a level higher than this value to function,       *
//*         + udg_CSS_Preload: set to true if you want to preload system abilities. Increase loading time but prevents first lags.               *
//*         + udg_CSS_SocketingEnabled: set to true if you want to enable the Right Click Item Socketing feature.                                *
//*         + udg_CSS_GemBonusBoolean: set to true if you want to allow wielded gems to display its bonuses.                                     *
//*         + udg_CSS_CustomSwitch: set to true if you want the item to give bonus only when it is fully socketed.                               *
//************************************************************************************************************************************************


//**************************************************************************************
//* Item Registration API                                                              *
//*                                                                                    *
//* call CSS_ItemInitialize (integer itemRawCode, integer armorBonus,                  *
//* integer attackSpeedBonus, integer damageBonus, integer agilityBonus,               *
//* integer intelligenceBonus, integer strengthBonus, integer lifeRegenBonus,          *
//* integer manaRegenBonus, integer lifeBonus, integer manaBonus,                      *
//* integer sightRangeBonus, integer socket)                                           *
//**************************************************************************************


//**************************************************************************************
//* Gem Registration API                                                               *
//*                                                                                    *
//* call CSS_GemInitialize (integer itemRawCode, integer armorBonus,                   *
//* integer attackSpeedBonus, integer damageBonus, integer agilityBonus,               *
//* integer intelligenceBonus, integer strengthBonus, integer lifeRegenBonus,          *
//* integer manaRegenBonus, integer lifeBonus, integer manaBonus,                      *
//* integer sightRangeBonus)                                                           *
//**************************************************************************************

//===========================================================================
// Only needed if you decided to use Right Click Item Socketing

// Item socket effect

constant function CSS_ItemSocketEffect takes nothing returns string
    return "Abilities\\Spells\\Items\\AIlm\\AIlmTarget.mdl"
endfunction

// Item socket effect attachment point

constant function CSS_ISEAttachPoint takes nothing returns string
    return "origin"
endfunction

// Item preload

function CSS_ItemPreload takes nothing returns nothing
    local unit u = CreateUnit(Player(15), 'Hpal', 0, 0, 0.00)
    local integer i = 0
    local integer j = LoadInteger (udg_CSS_Hashtable, -5, -5)
    local item array it

    loop
        exitwhen i > j
        set it[i] = CreateItem (LoadInteger (udg_CSS_Hashtable, -5, i), 0, 0)
        call UnitAddItem (u, it[i])
        set i = i + 1
    endloop

    set i = 0

    loop
        exitwhen i > j
        call RemoveItem (it[i])
        set it[i] = null
        set i = i + 1
    endloop

    call RemoveUnit (u)
    call FlushChildHashtable (udg_CSS_Hashtable, -5)
    set u = null
endfunction
//===========================================================================

// Fail-safe mechanism, only use in specific cases to avoid possible collision with other systems
// Refresh and update the unit's stats given by items in its inventory
// In a nutshell, do not use this unless you know what you are doing

function CSS_StatUpdate takes unit u returns nothing
    local integer i = 0
    local integer j = 0
    local integer k = GetHandleId (u)

    loop
        exitwhen j > 10
        call CSS_AddBonus (u, -LoadInteger (udg_CSS_Hashtable, k, j - 11), j)
        call SaveInteger (udg_CSS_Hashtable, k, j - 11, 0)
        set j = j + 1
    endloop

    loop
        exitwhen i > 5
        set j = 0

        loop
            exitwhen j > 10
            call CSS_AddBonus (u, LoadInteger (udg_CSS_Hashtable, GetHandleId (UnitItemInSlot (u, i)), j), j)
            call SaveInteger (udg_CSS_Hashtable, k, j - 11, LoadInteger (udg_CSS_Hashtable, k, j - 11) + LoadInteger (udg_CSS_Hashtable, GetHandleId (UnitItemInSlot (u, i)), j))
            set j = j + 1
        endloop

        set i = i + 1
    endloop
endfunction

// Item Socket Info Panel

function CSS_ItemInfoSocketPanel takes nothing returns boolean
    local group g = CreateGroup ()
    local item it
    local unit u
    local integer i
    local integer j = 0
    local player p = GetTriggerPlayer ()
    local integer k
    local string s

    if not udg_CSS_SocketingEnabled then
        call CSS_SimError ("Socketing feature is not enabled")
        call DestroyGroup (g)

        set p = null
        set g = null
        return false
    endif

    call GroupEnumUnitsSelected(g, p, null)

    if CountUnitsInGroup (g) > 1 then
        call CSS_SimError ("Invalid Selection")
        call DestroyGroup (g)

        set p = null
        set g = null
        return false
    else
        set u = FirstOfGroup (g)

        if not IsUnitOwnedByPlayer (u, p) then
            call CSS_SimError ("You must select an owned unit")
        else
            set it = UnitItemInSlot (u, S2I(SubString(GetEventPlayerChatString(), 16, StringLength(GetEventPlayerChatString()))) - 1)

            if it == null or not LoadBoolean (udg_CSS_Hashtable, GetItemTypeId (it), -4) then
                call CSS_SimError ("No item in chosen slot or chosen item is not registered with CSS")
            else

                call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + "Item Name: " + "|r" + udg_CSS_String[12] + GetItemName (it) + "|r")
                call DisplayTimedTextToPlayer (p, 0, 0, 15, "\n")

                set i = GetHandleId (it)
                set k = GetItemTypeId (it)

                loop
                    exitwhen j == LoadInteger (udg_CSS_Hashtable, k, -2)

                    set s = LoadStr (udg_CSS_Hashtable, i, -31 - j)

                    if s == null then
                        set s = "Not Socketed"
                    endif

                    call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + "Socket " + "#" + I2S (j + 1) + ": " + "|r" + udg_CSS_String[11] + s + "|r")
                    set s = ""
                    set j = j + 1
                endloop

            endif

            set it = null
        endif

        set u = null
    endif

    call DestroyGroup (g)
    set g = null
    set p = null

    return false
endfunction

// Item Info Panel

function CSS_ItemInfoPanel takes nothing returns boolean
    local group g = CreateGroup ()
    local item it
    local unit u
    local integer i
    local integer j = 0
    local player p = GetTriggerPlayer ()
    local integer k
    local integer l
    local string s1
    local string s2

    call GroupEnumUnitsSelected(g, p, null)

    if CountUnitsInGroup (g) > 1 then
        call CSS_SimError ("Invalid Selection")
        call DestroyGroup (g)

        set p = null
        set g = null
        return false
    else
        set u = FirstOfGroup (g)

        if not IsUnitOwnedByPlayer (u, p) then
            call CSS_SimError ("You must select an owned unit")
        else
            set it = UnitItemInSlot (u, S2I(SubString(GetEventPlayerChatString(), 10, StringLength(GetEventPlayerChatString()))) - 1)

            if it == null or not LoadBoolean (udg_CSS_Hashtable, GetItemTypeId (it), -4) then
                call CSS_SimError ("No item in chosen slot or chosen item is not registered with CSS")
            else

                set i = GetHandleId (it)
                set k = GetItemTypeId (it)

                if udg_CSS_SocketingEnabled then
                    call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + "Item Name: " + "|r" + udg_CSS_String[12] + GetItemName (it) + "|r")
                    call DisplayTimedTextToPlayer (p, 0, 0, 15, "\n")
                else
                    call DisplayTimedTextToPlayer (p, 0, 0, 15, "\n\n\n" + udg_CSS_String[25] + "Item Name: " + "|r" + udg_CSS_String[12] + GetItemName (it) + "|r")
                    call DisplayTimedTextToPlayer (p, 0, 0, 15, "\n")
                endif

                loop
                    exitwhen j > 10

                    if udg_CSS_SocketingEnabled then
                        set l = LoadInteger (udg_CSS_Hashtable, i, j)

                        if l > 0 then
                            set s2 = "+"
                        else
                            set s2 = ""
                        endif

                        if l - LoadInteger (udg_CSS_Hashtable, k, j) > 0 then
                            set s1 = udg_CSS_String[24] + " +" + I2S (l - LoadInteger (udg_CSS_Hashtable, k, j)) + "|r"
                        elseif l - LoadInteger (udg_CSS_Hashtable, k, j) < 0 then
                            set s1 = udg_CSS_String[24] + " -" + I2S (LoadInteger (udg_CSS_Hashtable, k, j) - l) + "|r"
                        else
                            set s1 = ""
                        endif

                        if j == 1 or j == 7 and s1 != "" then
                            set s1 = s1 + udg_CSS_String[24] + "%|r"
                        endif

                        if j == 1 or j == 7 then
                            call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + udg_CSS_String[j] + "|r" + udg_CSS_String[13+j] + s2 + I2S (LoadInteger (udg_CSS_Hashtable, k, j)) + "%|r" + s1)
                        else
                            call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + udg_CSS_String[j] + "|r" + udg_CSS_String[13+j] + s2 + I2S (LoadInteger (udg_CSS_Hashtable, k, j)) + "|r" + s1)
                        endif

                        set s1 = ""
                        set s2 = ""
                    else
                        set l = LoadInteger (udg_CSS_Hashtable, k, j)

                        if l > 0 then
                            set s2 = "+"
                        else
                            set s2 = ""
                        endif

                        if j == 1 or j == 7 then
                            call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + udg_CSS_String[j] + "|r" + udg_CSS_String[13+j] + s2 + I2S (LoadInteger (udg_CSS_Hashtable, k, j)) + "%|r")
                        else
                            call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + udg_CSS_String[j] + "|r" + udg_CSS_String[13+j] + s2 + I2S (LoadInteger (udg_CSS_Hashtable, k, j)) + "|r")
                        endif

                        set s2 = ""
                    endif

                    set j = j + 1
                endloop

                if udg_CSS_SocketingEnabled then
                    call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + "\nNumber of sockets: " + "|r" + udg_CSS_String[26] + I2S (LoadInteger (udg_CSS_Hashtable, k, -2)) + "|r")

                    if not HaveSavedInteger (udg_CSS_Hashtable, i, -2) then
                        call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + "Number of empty sockets: " + "|r" + udg_CSS_String[26] + I2S (LoadInteger (udg_CSS_Hashtable, k, -2)) + "|r")
                    else
                        call DisplayTimedTextToPlayer (p, 0, 0, 15, udg_CSS_String[25] + "Number of empty sockets: " + "|r" + udg_CSS_String[26] + I2S (LoadInteger (udg_CSS_Hashtable, i, -2)) + "|r")
                    endif
                endif

            endif

            set it = null
        endif

        set u = null
    endif

    call DestroyGroup (g)
    set g = null
    set p = null

    return false
endfunction

// Item sell event check

function CSS_ItemPawnCheck takes nothing returns boolean
    local unit u = GetTriggerUnit ()
    local integer i = GetHandleId (GetSoldItem ())
    local integer k = GetItemTypeId (GetSoldItem ())
    local trigger trig
    local integer t
    local integer j = 0
    local integer m = GetHandleId (u)

    loop
        exitwhen j > 10

        if udg_CSS_SocketingEnabled then
            call CSS_AddBonus(u, -LoadInteger (udg_CSS_Hashtable, i, j), j)
            call SaveInteger (udg_CSS_Hashtable, m, j - 11, LoadInteger (udg_CSS_Hashtable, m, j - 11) - LoadInteger (udg_CSS_Hashtable, i, j))
        else
            call CSS_AddBonus(u, -LoadInteger (udg_CSS_Hashtable, k, j), j)
            call SaveInteger (udg_CSS_Hashtable, m, j - 11, LoadInteger (udg_CSS_Hashtable, m, j - 11) - LoadInteger (udg_CSS_Hashtable, k, j))
        endif

        set j = j + 1
    endloop

    if LoadBoolean (udg_CSS_Hashtable, i, -6) then
        set trig = LoadTriggerHandle (udg_CSS_Hashtable, i, -10)
        set t = GetHandleId (trig)
        call SaveInteger (udg_CSS_Hashtable, t, 1, LoadInteger (udg_CSS_Hashtable, t, 1) + 1)

        if LoadInteger (udg_CSS_Hashtable, t, 1) == LoadInteger (udg_CSS_Hashtable, t, 0) then

            call DestroyTrigger (trig)
            call FlushChildHashtable (udg_CSS_Hashtable, t)

            if LoadTriggerHandle (udg_CSS_Hashtable, -10, -1) == trig then
                call RemoveSavedHandle (udg_CSS_Hashtable, -10, -1)
            endif

        endif

        set trig = null
        call FlushChildHashtable (udg_CSS_Hashtable, i)
    endif

    set u = null
    return false
endfunction

// Only needed if you decided to use Right Click Item Socketing

// Item socket event check

function CSS_ItemSocketCheck takes nothing returns boolean
    local item itemMain
    local item itemSocket
    local integer itemSlot
    local unit u
    local integer j = 0
    local integer i
    local integer k
    local integer l
    local integer m
    local integer n

    if GetOrderTargetItem() != null then
        set u = GetTriggerUnit()
        set itemSlot = GetIssuedOrderId() - 852002
        set itemMain = UnitItemInSlot (u, itemSlot)
        set itemSocket = GetOrderTargetItem()
        set i = GetItemTypeId (itemSocket)
        set k = GetItemTypeId (itemMain)
        set l = GetHandleId (itemMain)
        set m = GetHandleId (itemSocket)

        if not HaveSavedInteger (udg_CSS_Hashtable, l, -2) then
            call SaveInteger (udg_CSS_Hashtable, l, -2, LoadInteger (udg_CSS_Hashtable, k, -2))
        endif

        set n = LoadInteger (udg_CSS_Hashtable, l, -2)

        if itemMain != null and itemSocket != null and itemMain != itemSocket then

            if (LoadBoolean (udg_CSS_Hashtable, i, -3) and LoadBoolean (udg_CSS_Hashtable, k, -3)) or (not LoadBoolean (udg_CSS_Hashtable, i, -4) and LoadBoolean (udg_CSS_Hashtable, k, -3)) or (not LoadBoolean (udg_CSS_Hashtable, k, -4) and LoadBoolean (udg_CSS_Hashtable, i, -3)) or (not LoadBoolean (udg_CSS_Hashtable, i, -4) and not LoadBoolean (udg_CSS_Hashtable, k, -3)) or (not LoadBoolean (udg_CSS_Hashtable, k, -4) and not LoadBoolean (udg_CSS_Hashtable, i, -3)) or (LoadBoolean (udg_CSS_Hashtable, k, -7) and LoadBoolean (udg_CSS_Hashtable, i, -7)) then
                set itemSocket = null
                set itemMain = null
                set u = null
                return false
            endif

            if GetItemLevel (itemSocket) > udg_CSS_GemLevel and GetItemLevel (itemMain) < udg_CSS_GemLevel and n > 0 then

                loop
                    exitwhen j > 10
                    call SaveInteger (udg_CSS_Hashtable, l, j, LoadInteger (udg_CSS_Hashtable, l, j) + LoadInteger (udg_CSS_Hashtable, i, j))

                    if not udg_CSS_GemBonusBoolean and not udg_CSS_CustomSwitch then
                        call CSS_AddBonus(u, LoadInteger (udg_CSS_Hashtable, i, j), j)
                    endif

                    call SaveInteger (udg_CSS_Hashtable, GetHandleId (u), j - 11, LoadInteger (udg_CSS_Hashtable, GetHandleId (u), j - 11) + LoadInteger (udg_CSS_Hashtable, i, j))
                    set j = j + 1
                endloop

                call SaveStr (udg_CSS_Hashtable, l, -30 - LoadInteger (udg_CSS_Hashtable, k, -2) + n - 1, GetItemName(itemSocket))
                call CSS_SimNotification (GetItemName(itemMain) + " has been socketed with " + GetItemName(itemSocket) + " - " + I2S(n - 1) + " sockets left")
                call SaveBoolean (udg_CSS_Hashtable, m, -1, true)

                call SaveBoolean (udg_CSS_Hashtable, m, -1, false)
                call DestroyEffect (AddSpecialEffectTarget (CSS_ItemSocketEffect(), u, CSS_ISEAttachPoint ()))
                call SaveInteger (udg_CSS_Hashtable, l, -2, n - 1)

                set j = 0

                if udg_CSS_CustomSwitch and LoadInteger (udg_CSS_Hashtable, l, -2) == 0 then

                    loop
                        exitwhen j > 10
                        call CSS_AddBonus(u, LoadInteger (udg_CSS_Hashtable, l, j), j)
                        set j = j + 1
                    endloop

                endif

                set udg_CSS_Counter = udg_CSS_Counter + 1
                set udg_CSS_EventMainItemStacked[udg_CSS_Counter] = itemMain
                set udg_CSS_EventSocketItemStacked[udg_CSS_Counter] = itemSocket
                set udg_CSS_EventUnitStacked[udg_CSS_Counter] = u
                set udg_CSS_EventMainItem = itemMain
                set udg_CSS_EventSocketItem = itemSocket
                set udg_CSS_EventUnit = u
                set udg_EVENT_SOCKET_FINISH = 1
                set udg_EVENT_SOCKET_FINISH = 0
                set udg_CSS_EventMainItem = null
                set udg_CSS_EventSocketItem = null
                set udg_CSS_EventUnit = null
                set udg_CSS_EventMainItemStacked[udg_CSS_Counter] = null
                set udg_CSS_EventSocketItemStacked[udg_CSS_Counter] = null
                set udg_CSS_EventUnitStacked[udg_CSS_Counter] = null
                set udg_CSS_Counter = udg_CSS_Counter - 1

                call RemoveItem (itemSocket)

            elseif LoadInteger (udg_CSS_Hashtable, l, -2) == 0 and LoadBoolean (udg_CSS_Hashtable, k, -3) then
                call CSS_SimError ("Main item is fully socketed")
            endif
        endif

        set u = null
        set itemMain = null
        set itemSocket = null
    endif

    return false
endfunction

// Item drop event check

function CSS_ItemDropCheck takes nothing returns boolean
    local unit u = GetTriggerUnit()
    local integer i = GetHandleId (GetManipulatedItem())
    local integer k = GetItemTypeId (GetManipulatedItem())
    local integer j = 0
    local integer m = GetHandleId (u)

    if not LoadBoolean (udg_CSS_Hashtable, i, -1) then

        if not LoadBoolean (udg_CSS_Hashtable, k, -3) and LoadBoolean (udg_CSS_Hashtable, k, -5) then
            set u = null
            return false
        endif

        if udg_CSS_CustomSwitch and (not HaveSavedInteger (udg_CSS_Hashtable, i, -2) or LoadInteger (udg_CSS_Hashtable, i, -2) != 0) then
            set u = null
            return false
        endif

        loop
            exitwhen j > 10

            if udg_CSS_SocketingEnabled then
                call CSS_AddBonus(u, -LoadInteger (udg_CSS_Hashtable, i, j), j)
                call SaveInteger (udg_CSS_Hashtable, m, j - 11, LoadInteger (udg_CSS_Hashtable, m, j - 11) - LoadInteger (udg_CSS_Hashtable, i, j))
            else
                call CSS_AddBonus(u, -LoadInteger (udg_CSS_Hashtable, k, j), j)
                call SaveInteger (udg_CSS_Hashtable, m, j - 11, LoadInteger (udg_CSS_Hashtable, m, j - 11) - LoadInteger (udg_CSS_Hashtable, k, j))
            endif

            set j = j + 1
        endloop

    endif

    set u = null
    return false
endfunction

// Only needed if you decided to use Right Click Item Socketing

// Function for clearing dead/removed items' hashtable

function CSS_Event_Fire takes nothing returns boolean
    local trigger trig = GetTriggeringTrigger ()
    local integer t = GetHandleId (trig)

    call SaveInteger (udg_CSS_Hashtable, t, 1, LoadInteger (udg_CSS_Hashtable, t, 1) + 1)

    if LoadInteger (udg_CSS_Hashtable, t, 1) == LoadInteger (udg_CSS_Hashtable, t, 0) then

        call DestroyTrigger (trig)
        call FlushChildHashtable (udg_CSS_Hashtable, t)

        if LoadTriggerHandle (udg_CSS_Hashtable, -10, -1) == trig then
            call RemoveSavedHandle (udg_CSS_Hashtable, -10, -1)
        endif

    endif

    call FlushChildHashtable (udg_CSS_Hashtable, GetHandleId (GetTriggerWidget()))
    set trig = null

    return false
endfunction

// Item acquisition event check

function CSS_ItemAcquireCheck takes nothing returns boolean
    local trigger t = LoadTriggerHandle(udg_CSS_Hashtable, -10, -1)
    local integer l = GetHandleId (t)
    local unit u = GetTriggerUnit()
    local integer i = GetItemTypeId(GetManipulatedItem())
    local integer k = GetHandleId(GetManipulatedItem())
    local integer j = 0

    if not LoadBoolean (udg_CSS_Hashtable, k, -6) and LoadBoolean (udg_CSS_Hashtable, i, -4) and udg_CSS_SocketingEnabled then

        if t == null or LoadInteger (udg_CSS_Hashtable, l, 0) == 100 then
            set t = CreateTrigger ()
            set l = GetHandleId (t)
            call SaveInteger (udg_CSS_Hashtable, l, 0, 1)
            call SaveInteger (udg_CSS_Hashtable, l, 1, 0)
            call SaveTriggerHandle (udg_CSS_Hashtable, -10, -1, t)
            call TriggerAddCondition (t, Condition(function CSS_Event_Fire))
        else
            call SaveInteger (udg_CSS_Hashtable, l, 0, LoadInteger (udg_CSS_Hashtable, l, 0) + 1)
        endif

        call SaveTriggerHandle (udg_CSS_Hashtable, k, -10, t)
        call TriggerRegisterDeathEvent (t, GetManipulatedItem())
        call SaveBoolean (udg_CSS_Hashtable, k, -6, true)
    endif

    if not LoadBoolean (udg_CSS_Hashtable, i, -5) then

        loop
            exitwhen j > 10

            if not HaveSavedInteger (udg_CSS_Hashtable, k, j) then
                call SaveInteger (udg_CSS_Hashtable, k, j, LoadInteger (udg_CSS_Hashtable, i, j))
            endif

            set j = j + 1
        endloop

        if udg_CSS_CustomSwitch and (not HaveSavedInteger (udg_CSS_Hashtable, k, -2) or LoadInteger (udg_CSS_Hashtable, k, -2) != 0) then
            set t = null
            set u = null
            return false
        endif

        set j = 0

        loop
            exitwhen j > 10

            if udg_CSS_SocketingEnabled then
                call CSS_AddBonus(u, LoadInteger (udg_CSS_Hashtable, k, j), j)
                call SaveInteger (udg_CSS_Hashtable, GetHandleId (u), j - 11, LoadInteger (udg_CSS_Hashtable, GetHandleId (u), j - 11) + LoadInteger (udg_CSS_Hashtable, k, j))
            else
                call CSS_AddBonus(u, LoadInteger (udg_CSS_Hashtable, i, j), j)
                call SaveInteger (udg_CSS_Hashtable, GetHandleId (u), j - 11, LoadInteger (udg_CSS_Hashtable, GetHandleId (u), j - 11) + LoadInteger (udg_CSS_Hashtable, i, j))
            endif

            set j = j + 1
        endloop

    endif

    set t = null
    set u = null
    return false
endfunction

// Item Database Initialize

function CSS_ItemInitialize takes integer itemRawCode, integer armorBonus, integer attackSpeedBonus, integer damageBonus, integer agilityBonus, integer intelligenceBonus, integer strengthBonus, integer lifeRegenBonus, integer manaRegenBonus, integer lifeBonus, integer manaBonus, integer sightRangeBonus, integer socket returns nothing
    local integer j = LoadInteger (udg_CSS_Hashtable, -5, -5)

    call SaveInteger (udg_CSS_Hashtable, -5, j, itemRawCode)
    call SaveInteger (udg_CSS_Hashtable, -5, -5, j + 1)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 0, armorBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 1, attackSpeedBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 2, damageBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 3, agilityBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 4, intelligenceBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 5, strengthBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 6, lifeRegenBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 7, manaRegenBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 8, lifeBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 9, manaBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 10, sightRangeBonus)
    call SaveBoolean (udg_CSS_Hashtable, itemRawCode, -4, true)

    if udg_CSS_SocketingEnabled then
        call SaveInteger (udg_CSS_Hashtable, itemRawCode, -2, socket)
        call SaveBoolean (udg_CSS_Hashtable, itemRawCode, -3, true)
    endif

endfunction

// Gem Database Initialize

function CSS_GemInitialize takes integer itemRawCode, integer armorBonus, integer attackSpeedBonus, integer damageBonus, integer agilityBonus, integer intelligenceBonus, integer strengthBonus, integer lifeRegenBonus, integer manaRegenBonus, integer lifeBonus, integer manaBonus, integer sightRangeBonus returns nothing
    local integer j = LoadInteger (udg_CSS_Hashtable, -5, -5)

    call SaveInteger (udg_CSS_Hashtable, -5, j, itemRawCode)
    call SaveInteger (udg_CSS_Hashtable, -5, -5, j + 1)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 0, armorBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 1, attackSpeedBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 2, damageBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 3, agilityBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 4, intelligenceBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 5, strengthBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 6, lifeRegenBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 7, manaRegenBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 8, lifeBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 9, manaBonus)
    call SaveInteger (udg_CSS_Hashtable, itemRawCode, 10, sightRangeBonus)
    call SaveBoolean (udg_CSS_Hashtable, itemRawCode, -4, true)

    if udg_CSS_SocketingEnabled then
        call SaveBoolean (udg_CSS_Hashtable, itemRawCode, -7, true)

        if not udg_CSS_GemBonusBoolean then
            call SaveBoolean (udg_CSS_Hashtable, itemRawCode, -5, true)
        endif
    endif
endfunction

//===========================================================================
function InitTrig_CSS_Item_Functions takes nothing returns nothing
    local trigger acquireItem = CreateTrigger()
    local trigger dropItem = CreateTrigger()
    local trigger itemInfo = CreateTrigger()
    local trigger itemSocketInfo = CreateTrigger()
    local trigger socketItem
    local trigger pawnItem
    local integer j = 0

    call SaveInteger (udg_CSS_Hashtable, -5, -5, 0)

    call TriggerRegisterAnyUnitEventBJ(acquireItem, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    call TriggerAddCondition(acquireItem, Condition(function CSS_ItemAcquireCheck))
    call TriggerRegisterAnyUnitEventBJ(dropItem, EVENT_PLAYER_UNIT_DROP_ITEM)
    call TriggerAddCondition(dropItem, Condition(function CSS_ItemDropCheck))

    set udg_CSS_String[0] = "Armor Bonus: "
    set udg_CSS_String[1] = "Attack Speed Bonus: "
    set udg_CSS_String[2] = "Damage Bonus: "
    set udg_CSS_String[3] = "Agility Bonus: "
    set udg_CSS_String[4] = "Intelligence Bonus: "
    set udg_CSS_String[5] = "Strength Bonus: "
    set udg_CSS_String[6] = "Life Regen Bonus: "
    set udg_CSS_String[7] = "Mana Regen Bonus: "
    set udg_CSS_String[8] = "Life Bonus: "
    set udg_CSS_String[9] = "Mana Bonus: "
    set udg_CSS_String[10] = "Sight Range Bonus: "
 
    loop
        call TriggerRegisterPlayerChatEvent(itemInfo, Player(j), "-iteminfo", false)
        call TriggerRegisterPlayerChatEvent(itemSocketInfo, Player(j), "-itemsocketinfo", false)
        set j = j + 1
        exitwhen j > PLAYER_NEUTRAL_PASSIVE
    endloop

    call TriggerAddCondition(itemInfo, Condition(function CSS_ItemInfoPanel))
    call TriggerAddCondition(itemSocketInfo, Condition(function CSS_ItemInfoSocketPanel))

    if udg_CSS_SocketingEnabled then
        set socketItem = CreateTrigger ()
        set pawnItem = CreateTrigger ()

        call TriggerRegisterAnyUnitEventBJ(socketItem, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
        call TriggerAddCondition(socketItem, Condition(function CSS_ItemSocketCheck))
        call TriggerRegisterAnyUnitEventBJ(pawnItem, EVENT_PLAYER_UNIT_PAWN_ITEM)
        call TriggerAddCondition(pawnItem, Condition(function CSS_ItemPawnCheck))


        set socketItem = null
        set pawnItem = null
    endif

    set itemInfo = null
    set itemSocketInfo = null
    set acquireItem = null
    set dropItem = null

endfunction