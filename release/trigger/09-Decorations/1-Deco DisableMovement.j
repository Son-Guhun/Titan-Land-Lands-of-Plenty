// This trigger disables movement for all units that are marked as decorations 
// (have the "ZZIsDecoration" ability in Custom->Humans->Items)


// It also gives an ability based on Root (zz_Enable/Disable Fly in Custom->Special->Units) to any structures.
// This ability allows them to have a flying height.


function Trig_Deco_DisableMovement_Conditions takes nothing returns boolean
    local unit trigU

    if not LoP_IsUnitDecoration(GetTriggerUnit()) then
        return false
    endif

    set trigU = GetTriggerUnit()

    // -
    // REMOVE ATTACK AND MOVE ABILITIES
    call UnitRemoveAbility(trigU, 'Amov')
    call UnitRemoveAbility(trigU, 'Aatk')
    if RectGenerator_Conditions(trigU) then
        //! runtextmacro GUDR_FirstPage("Add","trigU")
    endif
    // -
    // ADD ENABLE/DISABLE FLY TO STRUCTURES
    if IsUnitType(trigU, UNIT_TYPE_STRUCTURE) then
        if GetUnitAbilityLevel(trigU, 'A037') != 0 then
        else
            call GUMS_AddStructureFlightAbility(trigU)
            // -
            // PLAY OPEN ANIMATION FOR OPENED GATES
            // OTHERWISE, PLAY STAND ANIMATION
            if ( GetUnitAbilityLevel(trigU, 'A0B5') != 0 ) then
                if GUMS_HaveSavedAnimationTag(trigU) then
                    call SetUnitAnimation(trigU, "death alternate " +GUMSConvertTags( GUMSGetUnitAnimationTag(trigU)))
                else
                    call SetUnitAnimation(trigU, "death alternate")
                endif
            else
                if GUMS_HaveSavedAnimationTag(trigU) then
                    call SetUnitAnimation(trigU, "stand " +GUMSConvertTags( GUMSGetUnitAnimationTag(trigU)))
                else
                    call SetUnitAnimation(trigU, "stand")
                endif
            endif
        endif
    endif

    set trigU = null
    return false
endfunction

//===========================================================================
function InitTrig_Deco_DisableMovement takes nothing returns nothing
    set gg_trg_Deco_DisableMovement = CreateTrigger(  )

    call TriggerRegisterEnterRectSimple( gg_trg_Deco_DisableMovement, GetEntireMapRect() )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Deco_DisableMovement, EVENT_PLAYER_UNIT_UPGRADE_FINISH )
    call TriggerAddCondition( gg_trg_Deco_DisableMovement, Condition( function Trig_Deco_DisableMovement_Conditions ) )
endfunction

