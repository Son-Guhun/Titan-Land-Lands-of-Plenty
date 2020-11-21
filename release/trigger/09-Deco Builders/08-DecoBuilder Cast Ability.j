scope DecoModAbils

    private function PlayerNumber takes unit whichUnit returns integer
        return GetPlayerId(GetOwningPlayer(whichUnit)) + 1
    endfunction

    public function Trig_DecoSystem_Cast_Ability_Conditions takes nothing returns boolean
        local unit trigU = GetTriggerUnit()
        local integer spellId = GetSpellAbilityId()
        local player owner = GetOwningPlayer(trigU)
        local integer playerNumber = GetPlayerId(owner) + 1
        local unit targetU = GetSpellTargetUnit()

        if GetUnitTypeId(trigU) != 'u015' then
            // Do nothing if unit is not Special Deco (performance)
        elseif GetOwningPlayer(targetU) != owner then
            // Do nothing if target owner is not same as caster owner
        
        
        elseif spellId == 'A0C0' then
            call CommandsDUnitMods_SetMatrixScale(targetU, udg_DecoSystem_Scale[playerNumber])
            
        elseif spellId == 'A04A' then
            call LoP.UVS.FlyHeight(targetU, udg_DecoSystem_Height[playerNumber])
            
        elseif spellId == 'A0C4' then
            call LoP.UVS.Facing(targetU, udg_DecoSystem_Facing[playerNumber])
            
        elseif spellId == 'A0C3' then
            call LoP.UVS.VertexColor(targetU, udg_ColorSystem_Red[playerNumber], udg_ColorSystem_Green[playerNumber], udg_ColorSystem_Blue[playerNumber], udg_ColorSystem_Alpha[playerNumber])
        
        elseif spellId == 'A0C1' then
            call SetUnitAnimation( targetU, udg_DecoSystem_Anims[playerNumber] )
            
        elseif spellId == 'A0C2' then
            call LoP.UVS.AnimSpeed(targetU, udg_DecoSystem_animSpeed[playerNumber]/100)
        endif
        
        set trigU = null
        set targetU = null
        return false
    endfunction
    
endscope

//===========================================================================
function InitTrig_DecoBuilder_Cast_Ability takes nothing returns nothing
    set gg_trg_DecoBuilder_Cast_Ability = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_DecoBuilder_Cast_Ability, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_DecoBuilder_Cast_Ability, Condition( function DecoModAbils_Trig_DecoSystem_Cast_Ability_Conditions ) )
endfunction

