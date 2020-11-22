native UnitAlive takes unit whichUnit returns boolean

library Mimic requires LoPHeroicUnit, UnitVisualMods, UnitEvents, optional RedefineNatives
/*
Allows heroes to "mimic" other units, while mantaining some of their original stats. The hero that is
mimicing ("original") is hidden, and a copy of the mimicked unit is created. If the target unit was
not a hero, then the copy is made into a hero using the HeroicUnit library. If the unit cannot be
made heroic, the mimic fails.

Whenever a hero that was alreading mimicking another unit attempts a new mimic, the original unit still
remains hidden, the previous mimic copy is destroyed, and a new mimic copy is created, mimicking the
new target unit.

All items are transfered from the original hero to the mimic, or from an old mimic to a new mimic.

When a mimic dies, the original unit reappears at the dying position, and the mimic is removed from
the game. When a mimic is directly removed from the game, the original unit is also removed.
*/

//! runtextmacro optional RedefineNatives()

private function MAX_INVENTORY takes nothing returns integer
    return bj_MAX_INVENTORY
endfunction

private struct UnitData extends array
    
    //! runtextmacro TableStruct_NewAgentField("original","unit")

    method destroy takes nothing returns nothing
        call .originalClear()
    endmethod
endstruct

function HeroTransferInventory takes unit source, unit target returns nothing
    local item i
    local integer slot = 0
    
    loop
    exitwhen slot >= MAX_INVENTORY()
        set i = UnitItemInSlot(source, slot)
        if  i != null then
            call UnitAddItem(target, i)
        endif
        set slot = slot + 1
    endloop
    
    set i = null
endfunction

function RemoveUnitMimic_impl takes unit mimic, boolean swapItems returns unit
    local unit original = UnitData(GetHandleId(mimic)).original
    local player owner = GetOwningPlayer(mimic)
    
    if original != null then
        call UnitData(GetHandleId(mimic)).destroy()
        if UnitAlive(mimic) then
            call KillUnit(mimic)
        endif
        
        call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
        call SetUnitOwner(mimic, Player(bj_PLAYER_NEUTRAL_EXTRA), false)
        call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
        
        
        call SetUnitOwner(original, owner, false)
        call ShowUnit(original, true)
        if swapItems then
            call HeroTransferInventory(mimic, original)
        endif
        
        call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
        call SetUnitOwner(mimic, Player(0), false)
        call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
        
        call SetUnitX(original, GetUnitX(mimic))
        call SetUnitY(original, GetUnitY(mimic))
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", GetUnitX(mimic), GetUnitY(mimic)))
        // remove heroic unit
    endif
    
    set mimic = original
    set original = null
    return mimic
endfunction

function RemoveUnitMimic takes unit mimic returns unit
    return RemoveUnitMimic_impl(mimic, true)
endfunction

private function OnRemove takes nothing returns boolean
    call RemoveUnit(RemoveUnitMimic_impl(UnitEvents.getEventUnit(), false))
    return false
endfunction

private function OnDeath takes nothing returns boolean
    local unit u = UnitEvents.getEventUnit()
    local player owner = GetOwningPlayer(u)
    local boolean isSelected = IsUnitSelected(u, owner)
    
    call UnitEvents.get(u).onRemove.deregister(Condition(function OnDeath))
    call UnitEvents.get(u).onRemove.deregister(Condition(function OnRemove))
    
    if GetLocalPlayer() == owner and isSelected then
        call SelectUnit(RemoveUnitMimic(u), true)
    else
        call RemoveUnitMimic(u)
    endif

    return false
endfunction



function CreateUnitMimic takes unit whichUnit, unit target returns nothing
    local unit mimic
    local integer mimicId
    local unit original
    local player owner = GetOwningPlayer(whichUnit)
    local boolean wasSelected = IsUnitSelected(whichUnit, owner)
    
    call ShowUnit(whichUnit, false)
    set mimic = CreateUnit(owner, GetUnitTypeId(target), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFacing(whichUnit))
    set mimicId = GetHandleId(mimic)
    
    if IsUnitType(mimic, UNIT_TYPE_HERO) or UnitMakeHeroic(mimic) then
        if UnitData(GetHandleId(whichUnit)).original != null then
            set original = UnitData(GetHandleId(whichUnit)).original
            
            call HeroTransferInventory(whichUnit, mimic)
            
            call UnitEvents.get(whichUnit).onRemove.deregister(Condition(function OnRemove))
            call UnitData(GetHandleId(whichUnit)).destroy()
            call KillUnit(whichUnit)
        else
            set original = whichUnit
            
            call HeroTransferInventory(original, mimic)
            call SetUnitOwner(original, Player(bj_PLAYER_NEUTRAL_EXTRA), false)
        endif
            
        set UnitData(mimicId).original = original
        
        call BlzSetUnitBaseDamage(mimic, BlzGetUnitBaseDamage(original, 1), 1)
        call BlzSetUnitBaseDamage(mimic, BlzGetUnitBaseDamage(original, 2), 2)
        call BlzSetUnitDiceNumber(mimic, BlzGetUnitDiceNumber(original, 1), 1)
        call BlzSetUnitDiceNumber(mimic, BlzGetUnitDiceNumber(original, 2), 2)
        call BlzSetUnitDiceSides(mimic, BlzGetUnitDiceSides(original, 1), 1)
        call BlzSetUnitDiceSides(mimic, BlzGetUnitDiceSides(original, 2), 2)
        call BlzSetUnitAttackCooldown(mimic, BlzGetUnitAttackCooldown(original, 1), 1)
        call BlzSetUnitAttackCooldown(mimic, BlzGetUnitAttackCooldown(original, 2), 2)
        call BlzSetUnitArmor(mimic, BlzGetUnitArmor(original))
        
        call LoP.UVS.CopyValues(target, mimic)
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", GetUnitX(mimic), GetUnitY(mimic)))
        
        call UnitEvents(mimicId).onDeath.register(Condition(function OnDeath))
        call UnitEvents(mimicId).onRemove.register(Condition(function OnRemove))
        call UnitEvents(mimicId).setRemoveOnDeath()
        if not IsUnitType(mimic, UNIT_TYPE_HERO) then
            call RefreshHeroIcons(owner)
            set LoP_UnitData.get(mimic).isHeroic = true
        endif
        if wasSelected and GetLocalPlayer() == owner then
            call SelectUnit(mimic, true)
        endif
    else
        call RemoveUnit(mimic)
        call ShowUnit(whichUnit, true)
    endif
    
    set original = null
    set mimic = null
endfunction

endlibrary