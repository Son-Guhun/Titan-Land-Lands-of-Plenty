scope DecoModAbils

    private function PlayerNumber takes unit whichUnit returns integer
        return GetPlayerId(GetOwningPlayer(whichUnit)) + 1
    endfunction

    public function Trig_DecoSystem_Cast_Ability_Conditions takes nothing returns boolean
        local unit trigU = GetSpellTargetUnit()
        local integer spellId = GetSpellAbilityId()
        local integer playerNumber = GetConvertedPlayerId(GetOwningPlayer(GetTriggerUnit()))
    
        // Performance: check if unit is Special Deco
        if not ( GetUnitTypeId(trigU) == 'u015' ) then
            set trigU = null
            return false
        endif
        
        if ( udg_temp_ability == 'A0C0' ) then
            call GUMSSetUnitScale(trigU, udg_DecoSystem_Scale[PlayerNumber(trigU)]/100)
        elseif ( udg_temp_ability == 'A04A' ) then
            call GUMSSetUnitFlyHeight(trigU, udg_DecoSystem_Height[PlayerNumber(trigU)])
        elseif ( udg_temp_ability == 'A0C4' ) then
            call GUMSSetUnitFacing(trigU, udg_DecoSystem_Facing[PlayerNumber(trigU)])
        elseif ( udg_temp_ability == 'A0C3' ) then
            call GUMSSetUnitVertexColor(trigU, udg_ColorSystem_Red[playerNumber], udg_ColorSystem_Green[playerNumber], udg_ColorSystem_Blue[playerNumber], udg_ColorSystem_Alpha[playerNumber])
        elseif ( udg_temp_ability == 'A0C1' ) then
            call SetUnitAnimation( trigU, udg_DecoSystem_Anims[PlayerNumber(trigU)] )
        elseif ( udg_temp_ability == 'A0C2' ) then
            call GUMSSetUnitAnimSpeed(trigU, udg_DecoSystem_animSpeed[PlayerNumber(trigU)]/100)
        endif
        
        set trigU = null
        return false
    endfunction
    
endscope

//===========================================================================
function InitTrig_DecoBuilder_Cast_Ability takes nothing returns nothing
    set gg_trg_DecoBuilder_Cast_Ability = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_DecoBuilder_Cast_Ability, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_DecoBuilder_Cast_Ability, Condition( function DecoModAbils_Trig_DecoSystem_Cast_Ability_Conditions ) )
endfunction

