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

//! textmacro TreeSystem_ShowDoodads takes showOrHide
        // Rock Chunks
        call SetDoodadAnimationRect(r, 'D00C', "$showOrHide$", false)  // Dark Gray
        call SetDoodadAnimationRect(r, 'D02B', "$showOrHide$", false)  // Dark Green
        call SetDoodadAnimationRect(r, 'D01I', "$showOrHide$", false)  // Orange Rock
        call SetDoodadAnimationRect(r, 'D00D', "$showOrHide$", false)  // Normal
        
        // Dungeon Rock Chunks
        call SetDoodadAnimationRect(r, 'D003', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'D002', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'D004', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'D005', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'D006', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'D007', "$showOrHide$", false)
        
        // Ice Cliff
        call SetDoodadAnimationRect(r, 'D00G', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'D00H', "$showOrHide$", false)
        
        call SetDoodadAnimationRect(r, 'D000', "$showOrHide$", false)  // Acid
        call SetDoodadAnimationRect(r, 'D008', "$showOrHide$", false)  // Lava
        
        
        call SetDoodadAnimationRect(r, 'D009', "$showOrHide$", false)  // Lavafall
        call SetDoodadAnimationRect(r, 'IWw0', "$showOrHide$", false)  // Icy Waterfall
        call SetDoodadAnimationRect(r, 'LWw0', "$showOrHide$", false)  // Waterfall
        
        // Archways
        call SetDoodadAnimationRect(r, 'YSaw', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'DSar', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'CSra', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'NSra', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ZSas', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ZSab', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'GSar', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'YSa1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ZSb1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'DSa1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'CSr1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'NSr1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ZSs1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'GSa1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ISs1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ISa1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ZSa1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'OSa1', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'GSa2', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'DSa2', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ISsr', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ISar', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'ZSar', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'OSar', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'JSar', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'JSax', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'DSah', "$showOrHide$", false)
        call SetDoodadAnimationRect(r, 'GSah', "$showOrHide$", false)
        
//! endtextmacro

private function onCast takes nothing returns boolean
    local boolexpr action = null
    local rect r
    local integer val = udg_DecoSystem_Value[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))+1]
    
    if GetUnitTypeId(GetTriggerUnit()) == DECO_BUILDER_SPECIAL then
    
        if ( GetSpellAbilityId() == 'A000' ) then
            set action = Filter(function KillDests)
        elseif ( GetSpellAbilityId() == 'A004' ) then
            set action = Filter(function ReviveDests)
        elseif ( GetSpellAbilityId() == 'A005' ) then
            set action = Filter(function RemoveDests)
        elseif ( GetSpellAbilityId() == 'A00A' ) then
            call TreeSystemCreateTrees()
        elseif ( GetSpellAbilityId() == 'A06A' ) then
                set r = Rect(GetSpellTargetX() - 64.*val, GetSpellTargetY()-64*val, GetSpellTargetX()+64*val, GetSpellTargetY()+64*val)
                //! runtextmacro TreeSystem_ShowDoodads("hide")
                call RemoveRect(r)
                set r = null
                
        elseif ( GetSpellAbilityId() == 'A06B' ) then
                set r = Rect(GetSpellTargetX() - 64.*val, GetSpellTargetY()-64*val, GetSpellTargetX()+64*val, GetSpellTargetY()+64*val)
                //! runtextmacro TreeSystem_ShowDoodads("show")
                call RemoveRect(r)
                set r = null
        endif
        
        if action != null then
            call EnumDestructablesInRange(GetSpellTargetX(), GetSpellTargetY(), /*
                                        */128. * val,/*
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
