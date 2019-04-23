scope MakeHeroic 

private struct Globals extends array
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticHandleField("dummy","unit")
    
endstruct

// Attempts at giving units Hero armor  (Currently, the unrooted unit cannot use items in its inventory.
/*
struct ABCDE extends array

    //! runtextmacro TableStruct_NewHandleField("unit","unit")
    
    method destroy takes nothing returns nothing
        call unitClear()
    endmethod

endstruct

function onExpireHeroic takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local ABCDE tData = GetHandleId(t)
    local unit whichUnit = tData.unit
    
    call UnitRemoveAbility(whichUnit, 'A008')
    call tData.destroy()
    
    call BlzUnitDisableAbility(whichUnit, 'AHer', false, false)
    call UnitRemoveAbility(whichUnit, 'AInv')
    call UnitAddAbility(whichUnit, 'AInv')
    call BlzUnitDisableAbility(whichUnit, 'AInv', false, false)
    
    call UnitApplyTimedLife(whichUnit, 'BHwe', 1)
    call UnitPauseTimedLife(whichUnit, true)
    call UnitAddItemById(whichUnit, 'I013')
    call BlzSetUnitMaxHP(whichUnit, 100)
    call BlzSetUnitMaxMana(whichUnit, 0)
    call BlzSetUnitDiceNumber(whichUnit, 2, 1)
    call BlzSetUnitDiceSides(whichUnit, 6, 1)
    call BlzSetUnitBaseDamage(whichUnit, 0, 1)
    call BlzSetUnitArmor(whichUnit, 0)
    call UnitAddItemById(whichUnit, 'I00S')
    
    call PauseTimer(t)
    call DestroyTimer(t)
    set t  = null
    set whichUnit = null
endfunction


function onExpireHeroic2 takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local ABCDE tData = GetHandleId(t)

    call IssueImmediateOrder(tData.unit, "unroot")
    call TimerStart(t, 1, false, function onExpireHeroic)

    set t  = null
    
endfunction
*/

function GiveHeroStats takes unit whichUnit returns nothing
    // Attempts at giving units Hero armor  (Currently, the unrooted unit cannot use items in its inventory.
    /*
    local timer t = CreateTimer()
    call UnitAddAbility(whichUnit, 'A008')
    
    call TimerStart(t, 1, false, function onExpireHeroic2)
    set ABCDE(GetHandleId(t)).unit = whichUnit
    set t = null
    */
    
    call UnitApplyTimedLife(whichUnit, 'BHwe', 1)
    call UnitPauseTimedLife(whichUnit, true)
    call UnitAddItemById(whichUnit, 'I013')
    call BlzSetUnitMaxHP(whichUnit, 100)
    call BlzSetUnitMaxMana(whichUnit, 0)
    call BlzSetUnitDiceNumber(whichUnit, 2, 1)
    call BlzSetUnitDiceSides(whichUnit, 6, 1)
    call BlzSetUnitBaseDamage(whichUnit, 0, 1)
    call BlzSetUnitArmor(whichUnit, 0)
    call BlzSetUnitAttackCooldown(whichUnit, 1.8, 1)
    call UnitAddItemById(whichUnit, 'I00S')
endfunction

private function FilterUnitsMakeHero takes nothing returns boolean
    local unit filterU = GetFilterUnit()
    local boolean hasMana
    
    if GetTriggerPlayer() == udg_GAME_MASTER or GetOwningPlayer(filterU) == GetTriggerPlayer() then
    
        if LoP_IsUnitDecoration(filterU) then
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "Decorations cannot be heroes")
            
        elseif LoP_IsUnitDecoBuilder(filterU) then
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "Deco builders cannot be heroes")
            
        elseif IsUnitType(filterU, UNIT_TYPE_PEON) then
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "Builders cannot be heroes")
        
        elseif IsUnitType(filterU, UNIT_TYPE_STRUCTURE) then
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "Buildings cannot be heroes")
            
        elseif GetUnitAbilityLevel(filterU, 'Adef') > 0 then
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "Units with the Defend ability cannot be heroes")
            
        elseif GetUnitAbilityLevel(filterU, 'AHer') > 0 then
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "This unit is already a hero.")
            
        elseif GetUnitAbilityLevel(filterU, 'AInv') > 0 then  // Detects all inventory skills.
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "This unit has an inventory, it can't be a hero.")
        
        else 
            call DisplayTextToPlayer(udg_GAME_MASTER, 0, 0, "-makehero is an experimental command which needs more testing. Use it wisely. Do not give to units that can morph!")
            
            set hasMana = GetUnitState(filterU, UNIT_STATE_MAX_MANA) > 1
            if UnitMakeHeroic(filterU) then
                call UnitAddAbility(filterU, 'A09Y' )
                //call UnitMakeAbilityPermanent(filterU, true, 'A09Y' )
                // call BlzSetUnitMaxHP()
                set LoP_UnitData.get(filterU).isHeroic = true
                
                call GiveHeroStats(filterU)
            else
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Unable to make unit " + GetUnitName(filterU) + " a hero. Report this problem please.")
            endif
            
            // Refresh hero icons on the left side of the screen
            call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
            call SetUnitOwner(Globals.dummy, GetOwningPlayer(filterU), false)
            call SetUnitOwner(Globals.dummy, Player(bj_PLAYER_NEUTRAL_EXTRA), false)
            call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
        endif
    endif
    
    set filterU = null
    return false
endfunction

function Trig_Commands_Make_Hero_Conditions takes nothing returns nothing
    if GetTriggerPlayer() == udg_GAME_MASTER then
        call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Condition(function FilterUnitsMakeHero))
    endif
endfunction

//===========================================================================
function InitTrig_Commands_Make_Hero takes nothing returns nothing
    call LoP_Command.create("-makehero", ACCESS_TITAN, Condition(function Trig_Commands_Make_Hero_Conditions ))
    set Globals.dummy = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), 'Hpal', 0., 0., bj_UNIT_FACING )
    call ShowUnit(Globals.dummy, false)
endfunction

endscope
