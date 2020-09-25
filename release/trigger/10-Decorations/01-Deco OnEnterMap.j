// This trigger disables movement for all units that are marked as decorations 
// (have the "ZZIsDecoration" ability in Custom->Humans->Items)


// It also gives an ability based on Root (zz_Enable/Disable Fly in Custom->Special->Units) to any structures.
// This ability allows them to have a flying height.

// This is executed as soon as a unit is created (before the next line of code) and is called in the Unit Event trigger



library DecoOnEnterMap requires UnitVisualValues, RectGenerator, LoPHeader  // for textmacro

globals
    private group G = CreateGroup()
    private timer T = CreateTimer()
endglobals

private function PlayAnim takes nothing returns nothing
    local unit u
    local effect e
    loop
        //! runtextmacro ForUnitInGroup("u", "G")
        call SetUnitAnimation(u, "death alternate")  // call SetUnitAnimation(trigU, "death alternate " +GUMSConvertTags( GUMSGetUnitAnimationTag(trigU)))
        if UnitHasAttachedEffect(u) then
            set e = GetUnitAttachedEffect(u).effect
            call BlzSpecialEffectAddSubAnimation(e, SUBANIM_TYPE_ROOTED)
            call BlzPlaySpecialEffect(e, ANIM_TYPE_DEATH)
            call BlzSpecialEffectRemoveSubAnimation(e, SUBANIM_TYPE_ROOTED)
        endif
    endloop
    set u = null
    set e = null
endfunction

function PlayGateOpenAnimation takes unit u returns nothing
    call GroupAddUnit(G, u)
    call TimerStart(T, 0., false, function PlayAnim)
endfunction

private function DecoOnEnterMapEx takes unit trigU, boolean isUpgrade returns nothing
    local UpgradeData typeId = GetUnitTypeId(trigU)
    //! runtextmacro ASSERT("trigU != null")
    //! runtextmacro ASSERT("LoP_IsUnitDecoration(trigU)")
    
    // REMOVE ATTACK AND MOVE ABILITIES
    call UnitRemoveAbility(trigU, 'Amov')
    call UnitRemoveAbility(trigU, 'Aatk')
    if RectGenerator_Conditions(trigU) then
        //! runtextmacro GUDR_FirstPage("Add","trigU")
    endif
    call SetUnitPathing(trigU, false)  // If UNIT_IF_MOVE_TYPE ever works, check if this line is only necessary before or after the unit move type is set
    // call BlzSetUnitIntegerField(trigU, UNIT_IF_MOVE_TYPE, GetHandleId(MOVE_TYPE_AMPHIBIOUS))
    call BlzSetUnitIntegerField(trigU, UNIT_IF_MOVE_TYPE, GetHandleId(MOVE_TYPE_FLOAT))  // Use Float because Amphibious does not go above the water level in shallow water.
    call SetUnitPathing(trigU, false)
    
    if typeId.hasUpgrades() then
        call UnitAddAbility(trigU, 'A01T')
        call UnitAddAbility(trigU, 'A048')
        if IsUnitType(trigU, UNIT_TYPE_STRUCTURE) and GetUnitAbilityLevel(trigU, 'A0B5') == 0 and GetUnitAbilityLevel(trigU, 'A0B3') == 0 and GetUnitAbilityLevel(trigU, 'A00T') == 0 then
            call UnitAddAbility(trigU, 'A05Z')
        endif
    endif
    
    if not isUpgrade and not DefaultPathingMaps_dontApplyPathMap then
        if DefaultPathingMap.get(trigU).hasPathing() then
            call DefaultPathingMap.get(trigU).update(trigU, GetUnitX(trigU), GetUnitY(trigU), GetUnitFacing(trigU)*bj_DEGTORAD)
        endif
    else
        set DefaultPathingMaps_dontApplyPathMap = false
    endif
    
    // -
    // ADD ENABLE/DISABLE FLY TO STRUCTURES
    if IsUnitType(trigU, UNIT_TYPE_STRUCTURE) then
        if GetUnitAbilityLevel(trigU, 'A037') != 0 then
        else
            call GUMS_AddStructureFlightAbility(trigU)

            if not isUpgrade then
                call BlzUnitDisableAbility(trigU, 'A011', false, false)
                call BlzUnitDisableAbility(trigU, 'A012', false, false)
                call BlzUnitDisableAbility(trigU, 'UDR4', false, false)
                call BlzUnitDisableAbility(trigU, 'A02Y', false, false)
                call BlzUnitDisableAbility(trigU, 'A02Z', false, false)
                call BlzUnitDisableAbility(trigU, 'A031', false, false)
                call BlzUnitDisableAbility(trigU, 'A032', false, false)
                call BlzUnitDisableAbility(trigU, 'A0B7', false, false)
            endif
            // -
            // PLAY OPEN ANIMATION FOR OPENED GATES
            // OTHERWISE, PLAY STAND ANIMATION
            if ( GetUnitAbilityLevel(trigU, 'A0B5') != 0 ) then
                call PlayGateOpenAnimation(trigU)
            else
                    call SetUnitAnimation(trigU, "stand")
            endif
        endif
    endif

    set trigU = null
endfunction

function DecoOnEnterMap takes unit trigU returns nothing
    call DecoOnEnterMapEx(trigU, false)
endfunction

function DecoOnUpgrade takes unit trigU returns nothing
    call DecoOnEnterMapEx(trigU, true)
endfunction

endlibrary