library CustomStatSystem
//////////////////////////////////////////////////////
//CUSTOM STAT SYSTEM
//////////////////////////////////////////////////////

// SimError by Vexorian at wc3c.net

// Sim Error (modified)

function CSS_SimError takes string s returns nothing
    local string msg = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffcc00" + s + "|r"
    local player ForPlayer = GetTriggerPlayer()
    local sound error = CreateSoundFromLabel("InterfaceError", false, false, false, 10, 10)

    if GetLocalPlayer() == ForPlayer then
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(ForPlayer, 0.52, 0.96, 2.00, msg)
        call StartSound(error)
    endif

    set ForPlayer = null
endfunction

function CSS_SimNotification takes string s returns nothing
    local string msg = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cff32cd32" + s + "|r"
    local player ForPlayer = GetTriggerPlayer()
    local sound notify = CreateSoundFromLabel("ItemReward", false, false, false, 10, 10)

    if GetLocalPlayer() == ForPlayer then
        call ClearTextMessages()
        call DisplayTimedTextToPlayer(ForPlayer, 0.52, 0.96, 2.00, msg)
        call StartSound (notify)
    endif

    set ForPlayer = null
endfunction

// Bound Int by Magtheridon96 at hiveworkshop.com

// BoundInt

function BoundInt takes integer i, integer min, integer max returns integer
    return IMaxBJ(IMinBJ(i, max), min)
endfunction

// Bonus Handling Code

function CSS_AddBonus takes unit u, integer amount, integer bonusType returns nothing
    local integer max = udg_CSS_Power[17]
    local integer min = -udg_CSS_Power[17]
    local integer i = 16
    local integer j = LoadInteger (udg_CSS_Hashtable, GetHandleId(u), bonusType)

    if amount > max - 1 or amount < min then
        call CSS_SimError ("Value too high or too low")
        return
    endif

    if amount + j >= max or amount + j <= min then
        call CSS_SimError ("Current value at maximum or minimum")
        return
    endif

//IF NEEDED, BELOW IS FIX FOR DECORATIONS
//    if GetUnitAbilityLevel(u, 'A0C6') > 0 then
//        call CSS_SimError ("Target Unit is a Decoration")
//        return
//    endif

    set amount = amount + j
    call BoundInt (amount, min, max - 1)

    if bonusType < 0 or bonusType > 10 then
        call CSS_SimError ("CSS Error: Invalid bonus type (" + I2S(bonusType) + ")")
        return
    elseif bonusType == 8 or bonusType == 9 then

        if bonusType == 8 and amount*1. + GetUnitState(u, UNIT_STATE_MAX_LIFE) <= 0 then
            call CSS_SimError ("Unit's current max life is lower than the negative bonus amount. Unable to subtract.")
            return
        elseif bonusType == 9 and amount*1. + GetUnitState(u, UNIT_STATE_MAX_MANA) <= 0 then
            call CSS_SimError ("Unit's current max mana is lower than the negative bonus amount. Unable to subtract.")
            return
        endif

        call SaveInteger(udg_CSS_Hashtable, GetHandleId(u), bonusType, amount)

        if amount < 0 then
            set amount = max + amount
        else
            call UnitRemoveAbility(u, udg_CSS_Abilities[(bonusType + 1)*18 - 1])
        endif

        loop
            if amount >= udg_CSS_Power[i] then
                call UnitAddAbility(u, udg_CSS_Abilities[bonusType*18 + i])
                call UnitMakeAbilityPermanent(u, true, udg_CSS_Abilities[bonusType*18 + i])
                set amount = amount - udg_CSS_Power[i]
            else
                call UnitRemoveAbility(u, udg_CSS_Abilities[bonusType*18 + i])
            endif
        
            set i = i - 1
            exitwhen i < 0
        endloop

        if LoadInteger(udg_CSS_Hashtable, GetHandleId(u), bonusType) < 0 then
            call UnitAddAbility(u, udg_CSS_Abilities[(bonusType + 1)*18 - 1])
            call UnitMakeAbilityPermanent(u, true, udg_CSS_Abilities[(bonusType + 1)*18 - 1])
        endif

    else

        call SaveInteger(udg_CSS_Hashtable, GetHandleId(u), bonusType, amount)

        if amount < 0 then
            set amount = max + amount
            call UnitAddAbility(u, udg_CSS_Abilities[(bonusType + 1)*18 - 1])
            call UnitMakeAbilityPermanent(u, true, udg_CSS_Abilities[(bonusType + 1)*18 - 1])
        else
            call UnitRemoveAbility(u, udg_CSS_Abilities[(bonusType+1)*18 - 1])
        endif

        loop
            if amount >= udg_CSS_Power[i] then
                call UnitAddAbility(u, udg_CSS_Abilities[bonusType*18 + i])
                call UnitMakeAbilityPermanent(u, true, udg_CSS_Abilities[bonusType*18 + i])
                set amount = amount - udg_CSS_Power[i]
            else
                call UnitRemoveAbility(u, udg_CSS_Abilities[bonusType*18 + i])
            endif
        
            set i = i - 1
            exitwhen i < 0
        endloop

    endif
endfunction

// Clear bonus

function CSS_ClearBonus takes unit u, integer bonusType returns nothing

    if bonusType > 10 or bonusType < 0 or GetUnitTypeId (u) == 0 or IsUnitType (u, UNIT_TYPE_DEAD) then
        return
    endif

    call CSS_AddBonus (u, -LoadInteger (udg_CSS_Hashtable, GetHandleId (u), bonusType), bonusType)
endfunction

// Get current bonus

function CSS_GetBonus takes unit u, integer bonusType returns integer

    if bonusType > 10 or bonusType < 0 or GetUnitTypeId (u) == 0 or IsUnitType (u, UNIT_TYPE_DEAD) then
        return 0
    endif

    return LoadInteger (udg_CSS_Hashtable, GetHandleId (u), bonusType)
endfunction
endlibrary