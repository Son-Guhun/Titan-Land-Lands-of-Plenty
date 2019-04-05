scope DecoMovement

    private function PlayerNumber takes unit whichUnit returns integer
        return GetPlayerId(GetOwningPlayer(whichUnit)) + 1
    endfunction
    
    private function X takes unit whichUnit returns real
        return GetUnitX(whichUnit)
    endfunction
    
    private function Y takes unit whichUnit returns real
        return GetUnitY(whichUnit)
    endfunction
    
     scope Controller
        public function ForGroupFunc takes nothing returns nothing
                local unit enumU = GetEnumUnit()
                local integer spellId = GetSpellAbilityId()
                local real angle
                
                if ( spellId == 'A02Y' ) then
                    call SetUnitPosition(enumU, X(enumU) - udg_System_DecoGrid[PlayerNumber(enumU)], Y(enumU))
                elseif ( spellId == 'A02Z' ) then
                    call SetUnitPosition(enumU, X(enumU) + udg_System_DecoGrid[PlayerNumber(enumU)], Y(enumU))
                elseif ( spellId == 'A031' ) then
                    call SetUnitPosition(enumU, X(enumU), Y(enumU) - udg_System_DecoGrid[PlayerNumber(enumU)])
                elseif ( spellId == 'A032' ) then
                    call SetUnitPosition(enumU, X(enumU), Y(enumU) + udg_System_DecoGrid[PlayerNumber(enumU)])
                elseif ( spellId == 'A037' ) then
                    call SetUnitPosition(enumU, GetSpellTargetX(), GetSpellTargetY())
                elseif ( spellId == 'A00T' ) then
                    call GUMSSetUnitFacing(enumU, bj_RADTODEG * Atan2(GetSpellTargetY() - Y(enumU), GetSpellTargetX() - X(enumU)))
                elseif ( spellId == 'A011' ) then
                    set angle = I2R(( ( ( R2I(( GetUnitFacing(enumU) + 1 )) / 90 ) + 1 ) * 90 ))
                    if angle > 270 then
                        set angle = 0
                    endif
                    call GUMSSetUnitFacing(enumU, angle)
                elseif ( spellId == 'A012' ) then
                    if not IsUnitInGroup(enumU, udg_System_ProtectedGroup) then
                        call GUMSCopyUnit(enumU, GetOwningPlayer(enumU),0)
                    endif
                endif
                
                set enumU = null
        endfunction
    endscope

    public function Trigger_Conditions takes nothing returns boolean
        local unit trigU = GetTriggerUnit()
        local integer spellId = GetSpellAbilityId()
        local real angle
        
        if not ( LoP_IsUnitDecoration(trigU) ) then 
            set trigU = null
            return false
        endif
        
        if ( GetUnitTypeId(trigU) == 'h0KD' ) then
            call ForGroup( udg_Player_ControlGroup[PlayerNumber(trigU)], function Controller_ForGroupFunc )
        elseif ( spellId == 'A02Y' ) then
            call SetUnitPosition(trigU, X(trigU) - udg_System_DecoGrid[PlayerNumber(trigU)], Y(trigU))
        elseif ( spellId == 'A02Z' ) then
            call SetUnitPosition(trigU, X(trigU) + udg_System_DecoGrid[PlayerNumber(trigU)], Y(trigU))
        elseif ( spellId == 'A031' ) then
            call SetUnitPosition(trigU, X(trigU), Y(trigU) - udg_System_DecoGrid[PlayerNumber(trigU)])
        elseif ( spellId == 'A032' ) then
            call SetUnitPosition(trigU, X(trigU), Y(trigU) + udg_System_DecoGrid[PlayerNumber(trigU)])
        elseif ( spellId == 'A037' ) then
            call SetUnitPosition(trigU, GetSpellTargetX(), GetSpellTargetY())
        elseif ( spellId == 'A00T' ) then
            call GUMSSetUnitFacing(trigU, bj_RADTODEG * Atan2(GetSpellTargetY() - Y(trigU), GetSpellTargetX() - X(trigU)))
        elseif ( spellId == 'A011' ) then
            set angle = I2R(( ( ( R2I(( GetUnitFacing(trigU) + 1 )) / 90 ) + 1 ) * 90 ))
            if angle > 270 then
                set angle = 0
            endif
            call GUMSSetUnitFacing(trigU, angle)
        elseif ( spellId == 'A012' ) then
            call GUMSCopyUnit(trigU, GetOwningPlayer(trigU),0)
        endif
        
        set trigU = null
        return false
    endfunction
    
endscope


//===========================================================================
function InitTrig_Deco_Movement takes nothing returns nothing
    set gg_trg_Deco_Movement = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Deco_Movement, EVENT_PLAYER_UNIT_SPELL_CAST )
    call TriggerAddCondition( gg_trg_Deco_Movement, Condition( function DecoMovement_Trigger_Conditions ) )
endfunction

