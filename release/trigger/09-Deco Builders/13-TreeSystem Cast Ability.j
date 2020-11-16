scope TreeSystemCastAbility
/*
    Event callback for handling tree manipulation abilities of Deco Builder Special.

    Notice:
        This code stinks, but I have no idea how to refactor it while maintaining the same optimizations.
    The code is super simple though, so it should be easy to understand.
*/

private function DistanceSquared takes real x, real x0, real y, real y0 returns real
    return Pow(x - x0, 2.) + Pow(y - y0, 2.)  // This function should inline
endfunction

// A faster EnumDestructablesInCircleBJ that correctly nulls local variables, avoiding reference counter leaks.
// Uses boolexpr instead of code so that it is faster.
private function EnumDestructablesInRange takes real x, real y, real radius, boolexpr actionFunc returns nothing
    local rect r

    if (radius >= 0) then
        set bj_enumDestructableCenter = Location(x, y)
        set bj_enumDestructableRadius = radius*radius                   // Use radius squared to compare with DistanceSquared.
        set r = GetRectFromCircleBJ(bj_enumDestructableCenter, radius)  // safe BJ, no reference counter leak.
        call EnumDestructablesInRect(r, actionFunc, null)
        call RemoveRect(r)
        call RemoveLocation(bj_enumDestructableCenter)
        
        set r= null
        set bj_enumDestructableCenter = null
    endif
endfunction

private function IsPointInRange takes real x, real y returns boolean
    return bj_enumDestructableRadius >= DistanceSquared(x, GetLocationX(bj_enumDestructableCenter), y, GetLocationY(bj_enumDestructableCenter))
endfunction

// ========
// Macros
// Used to declare a function for use as a boolexpr with EnumDestructablesInRange.

// Defines local var 'dest', which is the filtered destructable.
//! textmacro DestructableInRangeHeader
    local destructable dest = GetFilterDestructable()
    
    if IsPointInRange(GetDestructableX(dest), GetDestructableY(dest))  then
//! endtextmacro

// Must be called after to close the function declared by DestructableInRangeHeader.
//! textmacro DestructableInRangeFooter
    endif

    set dest = null
    return false
//! endtextmacro

// ========

private function RemoveDests takes nothing returns boolean
    //! runtextmacro DestructableInRangeHeader()
        if IsDestructableTree(dest) and not LoP_IsDestructableProtected(dest) then
            call RemoveDestructable(dest)
        endif
    //! runtextmacro DestructableInRangeFooter()
endfunction

private function ReviveDests takes nothing returns boolean
    //! runtextmacro DestructableInRangeHeader()
        call DestructableRestoreLife(dest, GetDestructableMaxLife(dest), false)
    //! runtextmacro DestructableInRangeFooter()
endfunction

private function KillDests takes nothing returns boolean
    //! runtextmacro DestructableInRangeHeader()
        if not LoP_IsDestructableProtected(dest) then
            call KillDestructable(dest)
        endif
    //! runtextmacro DestructableInRangeFooter()
endfunction

private function onCast takes nothing returns boolean
    local boolexpr action = null
    
    if GetUnitTypeId(GetTriggerUnit()) == DECO_BUILDER_SPECIAL then
    
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
