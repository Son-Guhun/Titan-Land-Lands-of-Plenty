function Trig_Aura_Of_Restitution_FilterAllies takes nothing returns boolean
    local unit filterUnit = GetFilterUnit()
    if not ( IsPlayerAlly(GetOwningPlayer(filterUnit), udg_temp_player ) ) then
        return false
    endif
    if GetUnitState(filterUnit, UNIT_STATE_LIFE) >= GetUnitState(filterUnit, UNIT_STATE_MAX_LIFE)*0.98 then
        return false
    endif
    set filterUnit = null
    return true
endfunction

function Trig_Aura_Of_Restitution_ForGroup_HealUnit takes nothing returns nothing
    call SetUnitState( GetEnumUnit(), UNIT_STATE_LIFE, ( udg_temp_real + GetUnitState(GetEnumUnit(), UNIT_STATE_LIFE) ) )
endfunction

function Trig_Aura_Of_Restitution_ForGroup_HealNearbyAllies takes nothing returns nothing
    local group nearbyAlliesGroup = CreateGroup()
    local integer numberOfAllies
    local unit enumUnit = GetEnumUnit()
    local integer userData = GetUnitUserData(enumUnit)
    
    local real saveReal = udg_temp_real
    local player savePlayer = udg_temp_player
    
    //Remove unit from global group and clear damage dealt
    set udg_temp_real = udg_Abilities_AoRest_DmgDone[userData]
    call GroupRemoveUnit(udg_Abilities_AoRest_UnitGroup, enumUnit)
    set udg_Abilities_AoRest_DmgDone[userData] = 0
    
    //Check if unit has actually dealt any damage
    if udg_temp_real != 0 then
        //Enumerate group and count units in it
        set udg_temp_player = GetOwningPlayer(enumUnit)
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl", enumUnit, "origin"))
        call GroupEnumUnitsInRange(nearbyAlliesGroup, GetUnitX(enumUnit), GetUnitY(enumUnit), 500, Filter(function Trig_Aura_Of_Restitution_FilterAllies))
        set numberOfAllies = CountUnitsInGroup(nearbyAlliesGroup)
        
        //Set value of the heal amount for each unit
        set udg_temp_real = RMinBJ(( udg_temp_real * 0.50 ), ( udg_temp_real / I2R(numberOfAllies) ))
        
        call ForGroup( nearbyAlliesGroup, function Trig_Aura_Of_Restitution_ForGroup_HealUnit )
        call DestroyGroup(nearbyAlliesGroup)
    endif
        
    //Restore global variable values
    set udg_temp_real = saveReal
    set udg_temp_player = savePlayer
    
    //Null locals
    set nearbyAlliesGroup = null
endfunction

function Trig_Aura_Of_Restitution_Actions takes nothing returns nothing
    call ForGroup( udg_Abilities_AoRest_UnitGroup, function Trig_Aura_Of_Restitution_ForGroup_HealNearbyAllies )
endfunction

//===========================================================================
function InitTrig_Aura_Of_Restitution takes nothing returns nothing
    set gg_trg_Aura_Of_Restitution = CreateTrigger(  )
    call TriggerRegisterTimerEvent(gg_trg_Aura_Of_Restitution, 1., true)
    call TriggerAddAction( gg_trg_Aura_Of_Restitution, function Trig_Aura_Of_Restitution_Actions )
endfunction

