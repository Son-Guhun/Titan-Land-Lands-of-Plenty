function Trig_TerrainSystem_Cast_Ability_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'u02E' ) ) then
        return false
    endif
    return true
endfunction

function Trig_TerrainSystem_Cast_Ability_Actions takes nothing returns nothing
    local integer index = 0
    local integer trigAbility = GetSpellAbilityId()
    local real x = GetSpellTargetX()
    local real y = GetSpellTargetY()
    local player owner = GetOwningPlayer(GetTriggerUnit())
    local integer playerNumber = GetPlayerId(owner) + 1
    
    if GetSpellAbilityId() == 'A0BR' then
        call SetTerrainType( x, y, TerrainTools_GetTexture(4), -1, udg_DecoSystem_Value[playerNumber], 0 )
        call SetBlight(owner, x, y, ( 128.00 * ( I2R(udg_DecoSystem_Value[playerNumber]) - 1 ) ), true)
    elseif GetSpellAbilityId() == 'A002' then
        call SetBlight(owner, x, y, ( 128.00 * ( I2R(udg_DecoSystem_Value[playerNumber]) - 1 ) ), false)
    else
        loop
            exitwhen index > 15
            if trigAbility == udg_TileSystem_ABILITIES[index] then
                call SetTerrainType(x, y, TerrainTools_GetTexture(index), udg_TileSystem_Var[playerNumber], udg_DecoSystem_Value[playerNumber], 0 )
                exitwhen true
            endif
            set index = index + 1
        endloop
    endif
endfunction

//===========================================================================
function InitTrig_TerrainSystem_Cast_Ability takes nothing returns nothing
    set udg_TileSystem_ABILITIES[0] = 'A0BH'
    set udg_TileSystem_ABILITIES[1] = 'A0BK'
    set udg_TileSystem_ABILITIES[2] = 'A0BE'
    set udg_TileSystem_ABILITIES[3] = 'A0BI'
    set udg_TileSystem_ABILITIES[4] = 'A0BF'
    set udg_TileSystem_ABILITIES[5] = 'A0BM'
    set udg_TileSystem_ABILITIES[6] = 'A0BO'
    set udg_TileSystem_ABILITIES[7] = 'A0BN'
    set udg_TileSystem_ABILITIES[8] = 'A0BJ'
    set udg_TileSystem_ABILITIES[9] = 'A0BL'
    set udg_TileSystem_ABILITIES[10] = 'A0BP'
    set udg_TileSystem_ABILITIES[11] = 'A0BQ'
    set udg_TileSystem_ABILITIES[12] = 'A0BT'
    set udg_TileSystem_ABILITIES[13] = 'A0BS'
    set udg_TileSystem_ABILITIES[14] = 'A0BU'
    set udg_TileSystem_ABILITIES[15] = 'A0BG'


    set gg_trg_TerrainSystem_Cast_Ability = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_TerrainSystem_Cast_Ability, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_TerrainSystem_Cast_Ability, Condition( function Trig_TerrainSystem_Cast_Ability_Conditions ) )
    call TriggerAddAction( gg_trg_TerrainSystem_Cast_Ability, function Trig_TerrainSystem_Cast_Ability_Actions )
endfunction

