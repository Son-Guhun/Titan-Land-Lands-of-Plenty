function Trig_Deco_DisableMovement_Conditions takes nothing returns boolean
    if ( not LoP_IsUnitDecoration(GetTriggerUnit()) ) then
        return false
    endif
    return true
endfunction

function Trig_Deco_DisableMovement_Actions takes nothing returns nothing
    local real udg_temp_real
    local string str
    // -
    // REMOVE ATTACK AND MOVE ABILITIES
    call UnitRemoveAbility(GetTriggerUnit(), 'Amov')
    call UnitRemoveAbility(GetTriggerUnit(), 'Aatk')
    if RectGenerator_Conditions(GetTriggerUnit()) then
        //! runtextmacro GUDR_FirstPage("Add","GetTriggerUnit()")
    endif
    // -
    // ADD ENABLE/DISABLE FLY TO STRUCTURES
    if IsUnitType(GetTriggerUnit(), UNIT_TYPE_STRUCTURE) then
        if GetUnitAbilityLevel(GetTriggerUnit(), 'A037') != 0 then
        else
            call GUMS_AddStructureFlightAbility(GetTriggerUnit())
            // -
            // PLAY OPEN ANIMATION FOR OPENED GATES
            // OTHERWISE, PLAY STAND ANIMATION
            if ( GetUnitAbilityLevel(GetTriggerUnit(), 'A0B5') != 0 ) then
                if GUMS_HaveSavedAnimationTag(GetTriggerUnit()) then
                    call SetUnitAnimation(GetTriggerUnit(), "death alternate " +GUMSConvertTags( GUMSGetUnitAnimationTag(GetTriggerUnit())))
                else
                    call SetUnitAnimation(GetTriggerUnit(), "death alternate")
                endif
            else
                if GUMS_HaveSavedAnimationTag(GetTriggerUnit()) then
                    call SetUnitAnimation(GetTriggerUnit(), "stand " +GUMSConvertTags( GUMSGetUnitAnimationTag(GetTriggerUnit())))
                else
                    call SetUnitAnimation(GetTriggerUnit(), "stand")
                endif
            endif
        endif
    else
    endif
endfunction

//===========================================================================
function InitTrig_Deco_DisableMovement takes nothing returns nothing
    set gg_trg_Deco_DisableMovement = CreateTrigger(  )
    call TriggerRegisterEnterRectSimple( gg_trg_Deco_DisableMovement, GetEntireMapRect() )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Deco_DisableMovement, EVENT_PLAYER_UNIT_UPGRADE_FINISH )
    call TriggerAddCondition( gg_trg_Deco_DisableMovement, Condition( function Trig_Deco_DisableMovement_Conditions ) )
    call TriggerAddAction( gg_trg_Deco_DisableMovement, function Trig_Deco_DisableMovement_Actions )
endfunction

