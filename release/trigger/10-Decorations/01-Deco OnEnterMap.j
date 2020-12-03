// This trigger disables movement for all units that are marked as decorations 
// (have the "ZZIsDecoration" ability in Custom->Humans->Items)

// This is executed as soon as a unit is created (before the next line of code) and is called in the Unit Event trigger



library DecoOnEnterMap requires UnitVisualValues, RectGenerator, LoPStdLib, LoPConstants, DefaultPathingMaps  // for textmacro

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

private function DecoOnEnterMapEx takes unit trigU returns nothing
    local UpgradeData typeId = GetUnitTypeId(trigU)
    local ObjectPathing handleId = ObjectPathing[trigU]
    local string name = GetUnitName(trigU)
    //! runtextmacro ASSERT("trigU != null")
    //! runtextmacro ASSERT("LoP_IsUnitDecoration(trigU)")
    
    if StringStartsWith(name, "_BLDG") then
        call BlzSetUnitName(trigU, SubString(name, 6, StringLength(name)))
    endif
    
    // REMOVE ATTACK AND MOVE ABILITIES
    call UnitRemoveAbility(trigU, 'Amov')
    call UnitRemoveAbility(trigU, 'Aatk')
    if RectGenerator_Conditions(trigU) then
        //! runtextmacro GUDR_FirstPage("Add","trigU")
    endif
    
    call SetUnitPathing(trigU, false)  // If UNIT_IF_MOVE_TYPE ever works, check if this line is only necessary before or after the unit move type is set
    call BlzSetUnitIntegerField(trigU, UNIT_IF_MOVE_TYPE, GetHandleId(MOVE_TYPE_FLOAT))  // Use Float because Amphibious does not go above the water level in shallow water.
    call SetUnitPathing(trigU, false)
    
    if typeId.hasUpgrades() then
        call UnitAddAbility(trigU, DECO_ABIL_UPGRADE_NEXT)
        call UnitAddAbility(trigU, DECO_ABIL_UPGRADE_PREV)
    endif
    
    if DefaultPathingMap(typeId).hasPathing() then
        call UnitRemoveAbility(trigU, DECO_ABIL_SUICIDE)
        
        if handleId.isDisabled then
            call UnitAddAbility(trigU, DECO_ABIL_PATHING_ON)
        else
            call UnitAddAbility(trigU, DECO_ABIL_PATHING_OFF)
            if not DefaultPathingMaps_dontApplyPathMap then
                if handleId.isActive and handleId.pathMap == DefaultPathingMap(typeId).path then
                    // Do nothing, correct pathing already exists
                else
                    call DefaultPathingMap(typeId).update(trigU, GetUnitX(trigU), GetUnitY(trigU), GetUnitFacing(trigU)*bj_DEGTORAD)
                endif
            endif
        endif
    endif
    set DefaultPathingMaps_dontApplyPathMap = false
    
    if ( GetUnitAbilityLevel(trigU, DECO_ABIL_GATE_CLOSE) != 0 ) then
        call PlayGateOpenAnimation(trigU)
    else
        call SetUnitAnimation(trigU, "stand")
    endif

    set trigU = null
endfunction

function DecoOnEnterMap takes unit trigU returns nothing
    call DecoOnEnterMapEx(trigU)
endfunction

function DecoOnUpgrade takes unit trigU returns nothing
    call DecoOnEnterMapEx(trigU)
endfunction

endlibrary