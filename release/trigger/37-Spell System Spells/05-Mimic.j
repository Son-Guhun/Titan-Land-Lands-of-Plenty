native UnitAlive takes unit whichUnit returns boolean

library Mimic requires LoPHeroicUnit, UnitVisualMods, UnitEvents

private function MAX_INVENTORY takes nothing returns integer
    return bj_MAX_INVENTORY
endfunction

private struct UnitData extends array
    
    //! runtextmacro TableStruct_NewHandleField("original","unit")

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

function RemoveUnitMimic takes unit mimic returns nothing
    local unit original = UnitData(GetHandleId(mimic)).original
    
    if original != null then
        call UnitData(GetHandleId(mimic)).destroy()
        if UnitAlive(mimic) then
            call KillUnit(mimic)
        endif
        
        call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
        call SetUnitOwner(mimic, Player(bj_PLAYER_NEUTRAL_EXTRA), false)
        call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
        
        
        call SetUnitOwner(original, /*GetOwningPlayer(mimic)*/Player(0), false)
        call ShowUnit(original, true)
        call HeroTransferInventory(mimic, original)
        
        call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
        call SetUnitOwner(mimic, Player(0), false)
        call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
        
        call SetUnitX(original, GetUnitX(mimic))
        call SetUnitY(original, GetUnitY(mimic))
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", GetUnitX(mimic), GetUnitY(mimic)))
        // remove heroic unit
        set original = null
    endif
endfunction

function onRemove takes nothing returns boolean
    local unit original = UnitData(GetHandleId(UnitEvents.getEventUnit())).original
    call RemoveUnitMimic(UnitEvents.getEventUnit())
    call RemoveUnit(original)
    set original = null
    return false
endfunction

function onDeath takes nothing returns boolean
    call RemoveUnitMimic(UnitEvents.getEventUnit())
    call UnitEvents.get(UnitEvents.getEventUnit()).onRemove.deregister(Condition(function onDeath))
    call UnitEvents.get(UnitEvents.getEventUnit()).onRemove.deregister(Condition(function onRemove))
    return false
endfunction



function CreateUnitMimic takes unit whichUnit, unit target returns nothing
    local unit mimic
    local integer mimicId
    local unit original

    call ShowUnit(whichUnit, false)
    set mimic = CreateUnit(GetOwningPlayer(whichUnit), GetUnitTypeId(target), GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFacing(whichUnit))
    set mimicId = GetHandleId(mimic)
    
    if IsUnitType(mimic, UNIT_TYPE_HERO) or UnitMakeHeroic(mimic) then
        if UnitData(GetHandleId(whichUnit)).original != null then
            set original = UnitData(GetHandleId(whichUnit)).original
            
            call HeroTransferInventory(whichUnit, mimic)
            
            call UnitEvents.get(whichUnit).onRemove.deregister(Condition(function onRemove))
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
        
        call GUMSCopyValues(target, mimic)
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl", GetUnitX(mimic), GetUnitY(mimic)))
        
        call UnitEvents(mimicId).onDeath.register(Condition(function onDeath))
        call UnitEvents(mimicId).onRemove.register(Condition(function onRemove))
        call UnitEvents(mimicId).setRemoveOnDeath()
        if not IsUnitType(mimic, UNIT_TYPE_HERO) then
            call RefreshHeroIcons(GetOwningPlayer(mimic))
            set LoP_UnitData.get(mimic).isHeroic = true
        endif
    else
        call RemoveUnit(mimic)
        call ShowUnit(whichUnit, true)
    endif
    
    set original = null
    set mimic = null
endfunction

endlibrary