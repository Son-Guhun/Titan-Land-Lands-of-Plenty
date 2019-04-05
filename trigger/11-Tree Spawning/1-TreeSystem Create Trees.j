function Trig_Infinite_Seed_Bag_Copy_Conditions takes nothing returns boolean
    if  (GetUnitTypeId(GetTriggerUnit()) == 'u015') then
        if ( GetSpellAbilityId() == 'A00A' ) then
            return true
        endif
    endif
    return false
endfunction

function Trig_Infinite_Seed_Bag_Copy_Actions takes nothing returns nothing
    local integer playerNumber = GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1
    local integer val = udg_DecoSystem_Value[playerNumber] - 1
    local real X = GetSpellTargetX()
    local real Y = GetSpellTargetY()
    local real space = udg_TreeSystem_Space[playerNumber]
    local integer x = -val
    local integer y = -val
    loop
        exitwhen x > val
        set y = -val
        loop
            exitwhen y > val
            call SetDestructableAnimation(CreateDestructable( udg_TreeSystem_TREES[GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1], X - space*I2R(x), Y + - space*I2R(y), GetRandomDirectionDeg(), GetRandomReal(0.90, 1.10), 0 ), "birth")
            set y = y+1
        endloop
        set x = x + 1
    endloop
endfunction

//===========================================================================
function InitTrig_TreeSystem_Create_Trees takes nothing returns nothing
    set gg_trg_TreeSystem_Create_Trees = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_TreeSystem_Create_Trees, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_TreeSystem_Create_Trees, Condition( function Trig_Infinite_Seed_Bag_Copy_Conditions ) )
    call TriggerAddAction( gg_trg_TreeSystem_Create_Trees, function Trig_Infinite_Seed_Bag_Copy_Actions )
endfunction

