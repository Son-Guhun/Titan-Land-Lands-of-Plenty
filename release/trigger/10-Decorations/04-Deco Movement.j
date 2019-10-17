scope DecoMovement
    //! runtextmacro optional DefineHooks()

    globals
        public constant integer CONTROLLER = 'h0KD'
        
        public constant integer MOVE_UP = 'A032'
        public constant integer MOVE_LEFT = 'A02Y'
        public constant integer MOVE_RIGHT = 'A02Z'
        public constant integer MOVE_DOWN = 'A031'
        
        public constant integer MOVE = 'A037'
        
        public constant integer SUICIDE = 'A0B7'
        public constant integer FACE = 'A00T'
        public constant integer COPY = 'A012'
        public constant integer ROTATE = 'A011'
        
        public constant integer UPGRADE_PREV = 'A048'
        public constant integer UPGRADE_NEXT = 'A01T'
        
        public constant integer GATE_OPEN = 'A0B3'
        public constant integer GATE_CLOSE = 'A0B5'
    endglobals

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
                
                if ( spellId == MOVE_LEFT ) then
                    call SetUnitPosition(enumU, X(enumU) - udg_System_DecoGrid[PlayerNumber(enumU)], Y(enumU))
                    
                elseif ( spellId == MOVE_RIGHT ) then
                    call SetUnitPosition(enumU, X(enumU) + udg_System_DecoGrid[PlayerNumber(enumU)], Y(enumU))
                    
                elseif ( spellId == MOVE_DOWN ) then
                    call SetUnitPosition(enumU, X(enumU), Y(enumU) - udg_System_DecoGrid[PlayerNumber(enumU)])
                    
                elseif ( spellId == MOVE_UP ) then
                    call SetUnitPosition(enumU, X(enumU), Y(enumU) + udg_System_DecoGrid[PlayerNumber(enumU)])
                    
                elseif ( spellId == MOVE ) then
                    call SetUnitPosition(enumU, GetSpellTargetX(), GetSpellTargetY())
                    
                elseif ( spellId == FACE ) then
                    call GUMSSetUnitFacing(enumU, bj_RADTODEG * Atan2(GetSpellTargetY() - Y(enumU), GetSpellTargetX() - X(enumU)))
                    
                elseif ( spellId == ROTATE ) then
                    set angle = I2R(( ( ( R2I(( GetUnitFacing(enumU) + 1 )) / 90 ) + 1 ) * 90 ))
                    if angle > 270 then
                        set angle = 0
                    endif
                    call GUMSSetUnitFacing(enumU, angle)
                    
                elseif ( spellId == COPY ) then
                    if not IsUnitInGroup(enumU, udg_System_ProtectedGroup) then
                        call LopCopyUnitSameType(enumU, GetOwningPlayer(enumU))
                    endif
                endif
                
                set enumU = null
        endfunction
    endscope

    public function Trigger_Conditions takes nothing returns boolean
        local unit trigU = GetTriggerUnit()
        local integer spellId = GetSpellAbilityId()
        local real angle
        local UpgradeData typeId
        
        // Checking if a unit is a rect generator is necesarry because this reuses their ability. Maybe change?
        if not LoP_IsUnitDecoration(trigU) or RectGenerator_Conditions(trigU) then 
            set trigU = null
            return false
        endif
        
        if ( GetUnitTypeId(trigU) == CONTROLLER ) then
            if ( spellId == RectGenerator_MOVE ) then
                call SetUnitPosition(trigU, GetSpellTargetX(), GetSpellTargetY())
            else
                call ForGroup( udg_Player_ControlGroup[PlayerNumber(trigU)], function Controller_ForGroupFunc )
            endif
			
        elseif ( spellId == MOVE_LEFT ) then
            call SetUnitPosition(trigU, X(trigU) - udg_System_DecoGrid[PlayerNumber(trigU)], Y(trigU))
            
        elseif ( spellId == MOVE_RIGHT ) then
            call SetUnitPosition(trigU, X(trigU) + udg_System_DecoGrid[PlayerNumber(trigU)], Y(trigU))
            
        elseif ( spellId == MOVE_DOWN ) then
            call SetUnitPosition(trigU, X(trigU), Y(trigU) - udg_System_DecoGrid[PlayerNumber(trigU)])
            
        elseif ( spellId == MOVE_UP ) then
            call SetUnitPosition(trigU, X(trigU), Y(trigU) + udg_System_DecoGrid[PlayerNumber(trigU)])
            
        elseif ( spellId == MOVE or spellId == RectGenerator_MOVE ) then
            call SetUnitPosition(trigU, GetSpellTargetX(), GetSpellTargetY())
            
        elseif ( spellId == FACE ) then
            call GUMSSetUnitFacing(trigU, bj_RADTODEG * Atan2(GetSpellTargetY() - Y(trigU), GetSpellTargetX() - X(trigU)))
        
        elseif ( spellId == ROTATE ) then
            set spellId = LoP_PlayerData.get(GetOwningPlayer(trigU)).rotationStep
            set angle = I2R(( ( ( R2I(( GetUnitFacing(trigU) + 1 )) / spellId ) + 1 ) * spellId ))
            
            set angle = ModuloReal(angle, 360.)
            call GUMSSetUnitFacing(trigU, angle)
            
        elseif ( spellId == COPY ) then
            call LopCopyUnitSameType(trigU, GetOwningPlayer(trigU))
        
        elseif ( spellId == UPGRADE_NEXT  or spellId == UPGRADE_PREV ) then
            set typeId = GetUnitTypeId(trigU)
            if typeId.hasUpgrades() then
                if spellId == UPGRADE_PREV and typeId.hasPrev() then
                    call IssueImmediateOrderById(trigU, typeId.prev)
                else
                    call IssueImmediateOrderById(trigU, typeId.next)
                endif
            endif
        endif
        
        if IsUnitType(trigU, UNIT_TYPE_STRUCTURE) and GetUnitAbilityLevel(trigU, GATE_CLOSE) > 0 then
            call PlayGateOpenAnimation(trigU)
        endif
        set trigU = null
        return false
    endfunction
    
    
//===========================================================================
function InitTrig_Deco_Movement takes nothing returns nothing
    local unit u = CreateUnit(Player(0), 'hpea', 0., 0., 0.)
    
    set gg_trg_Deco_Movement = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Deco_Movement, EVENT_PLAYER_UNIT_SPELL_CAST )
    call TriggerAddCondition( gg_trg_Deco_Movement, Condition( function DecoMovement_Trigger_Conditions ) )
    
    call UnitAddAbility(u, MOVE_UP)
    call UnitAddAbility(u, MOVE_LEFT)
    call UnitAddAbility(u, MOVE_RIGHT)
    call UnitAddAbility(u, MOVE_DOWN)
    call UnitAddAbility(u, MOVE)
    call UnitAddAbility(u, SUICIDE)
    call UnitAddAbility(u, FACE)
    call UnitAddAbility(u, COPY)
    call UnitAddAbility(u, ROTATE)
    call UnitAddAbility(u, UPGRADE_NEXT)
    call UnitAddAbility(u, UPGRADE_PREV)
    
    call UnitAddAbility(u, GATE_CLOSE)  // Gate Close
    call UnitAddAbility(u, GATE_OPEN)  // Gate Open
    call UnitAddAbility(u, 'DEDF')  // Enable/Disable Fly
    call RemoveUnit(u)
    set u= null
endfunction
endscope




