scope TreeSystemCastAbility

// This function should inline
private function DistanceSquared takes real x, real x0, real y, real y0 returns real
    return Pow(x - x0, 2.) + Pow(y - y0, 2.)
endfunction

//! textmacro DestructableInCircleHeader takes NAME
private function $NAME$ takes nothing returns boolean
    local destructable dest = GetFilterDestructable()
    
    if bj_enumDestructableRadius >= DistanceSquared(GetDestructableX(dest), GetLocationX(bj_enumDestructableCenter), GetDestructableY(dest), GetLocationY(bj_enumDestructableCenter)) then
//! endtextmacro

//! textmacro DestructableInCircleFooter
    endif

    set dest = null
    return false
endfunction
//! endtextmacro

//! runtextmacro DestructableInCircleHeader("RemoveDests")
    if IsDestructableTree(dest) and not LoP_IsDestructableProtected(dest) then
        call RemoveDestructable(dest)
    endif
//! runtextmacro DestructableInCircleFooter()

//! runtextmacro DestructableInCircleHeader("ReviveDests")
    call DestructableRestoreLife(dest, GetDestructableMaxLife(dest), false)
//! runtextmacro DestructableInCircleFooter()

//! runtextmacro DestructableInCircleHeader("KillDests")
    if not LoP_IsDestructableProtected(dest) then
        call KillDestructable(dest)
    endif
//! runtextmacro DestructableInCircleFooter()

private function EnumDestructablesInRange takes real x, real y, real radius, boolexpr actionFunc returns nothing
    local rect r

    if (radius >= 0) then
        set bj_enumDestructableCenter = Location(x, y)
        set bj_enumDestructableRadius = radius*radius
        set r = GetRectFromCircleBJ(bj_enumDestructableCenter, radius)
        call EnumDestructablesInRect(r, actionFunc, null)
        call RemoveRect(r)
        call RemoveLocation(bj_enumDestructableCenter)
    endif
endfunction

private function onCast takes nothing returns boolean
    local boolexpr action = null
    
    if GetUnitTypeId(GetTriggerUnit()) == 'u015' then
    
        if ( GetSpellAbilityId() == 'A000' ) then
            set action = Filter(function KillDests)
        elseif ( GetSpellAbilityId() == 'A004' ) then
            set action = Filter(function ReviveDests)
        elseif ( GetSpellAbilityId() == 'A005' ) then
            set action = Filter(function RemoveDests)
        elseif ( GetSpellAbilityId() == 'A00A' ) then
            call TreeSystemCreateTrees()
        endif
        
        if action != null then
            call EnumDestructablesInRange(GetSpellTargetX(), GetSpellTargetY(), /*
                                        */128. * udg_DecoSystem_Value[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))+1],/*
                                        */action)
        endif
    
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_TreeSystem_Cast_Ability takes nothing returns nothing
    set gg_trg_TreeSystem_Cast_Ability = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_TreeSystem_Cast_Ability, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_TreeSystem_Cast_Ability, Condition( function onCast ) )
endfunction

endscope
