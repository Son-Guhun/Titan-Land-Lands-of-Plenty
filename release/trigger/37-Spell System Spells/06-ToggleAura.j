library ToggleAura requires TableStruct, GLHS
/*
To add more active abilities that toggle auras, find the initializer module below.

*/

private struct Globals extends array
    //! runtextmacro TableStruct_NewConstTableField("","tab")
endstruct

private function onCast takes nothing returns nothing
    local integer activeAbility = udg_Spell__Ability
    local integer auraAbility = Globals.tab[activeAbility]
    local unit trigU = udg_Spell__Caster
    
    if auraAbility != 0 then
        if GetUnitAbilityLevel(trigU, auraAbility) == 0 then
            call UnitAddAbility(trigU, auraAbility)
            call BlzUnitHideAbility(trigU, auraAbility, true)
            call UnitMakeAbilityPermanent(trigU, true, auraAbility)
        else
            call UnitRemoveAbility(trigU, auraAbility)
        endif
    endif
endfunction

function IsAbilityAuraToggle takes integer abilId returns boolean
    return Globals.tab.has(abilId)
endfunction

function GetToggleAbilityAura takes integer abilId returns integer
    return Globals.tab[abilId]
endfunction

public function Initialize takes nothing returns nothing
    local trigger trig = CreateTrigger()
    call TriggerAddAction(trig, function onCast)
    
    // Configuration here.
    // =================================
    // 1st argument: active ability
    // 2nd argument: actual aura ability
    //! runtextmacro ToggleAura_InitAura("A04L", "AHab")  // Brilliance
    //! runtextmacro ToggleAura_InitAura("A03P", "A0A2")  // Command
    //! runtextmacro ToggleAura_InitAura("A03I", "AHad")  // Devotion
    //! runtextmacro ToggleAura_InitAura("A03Q", "AOr2")  // Endurance
    //! runtextmacro ToggleAura_InitAura("A04D", "AEah")  // Thorns
    //! runtextmacro ToggleAura_InitAura("A040", "AEar")  // Trueshot
    //! runtextmacro ToggleAura_InitAura("A03S", "AUau")  // Unholy
    //! runtextmacro ToggleAura_InitAura("A046", "AUav")  // Vampiric
    
    // =================================
    
endfunction

//! textmacro ToggleAura_InitAura takes activeAbility, auraAbility
        set Globals.tab['$activeAbility$'] = '$auraAbility$'
        set udg_Spell__Ability = '$activeAbility$'
        set udg_Spell__Trigger_OnEffect = trig
        call TriggerExecute( gg_trg_Spell_System )
//! endtextmacro
endlibrary

/*
Brilliance A04L AHab
Command    A03P A0A2
Devotion   A03I AHad
Endurance  A03Q AOr2
Thorns     A04D AEah
Trueshot   A040 AEar
Unholy     A03S AUau
Vampiric   A046 AUav
*/