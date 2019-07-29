library LoPHeroicUnit requires LoPHeader, LoPWidgets

    public struct Globals extends array
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticHandleField("dummy","unit")
    
    endstruct

    function GiveHeroStats takes unit whichUnit returns nothing
        call UnitApplyTimedLife(whichUnit, 'BHwe', 1)
        call UnitPauseTimedLife(whichUnit, true)
        call UnitAddItemById(whichUnit, 'I013')
        call BlzSetUnitMaxHP(whichUnit, 100)
        call BlzSetUnitMaxMana(whichUnit, 0)
        call BlzSetUnitDiceNumber(whichUnit, 2, 0)
        call BlzSetUnitDiceSides(whichUnit, 6, 0)
        call BlzSetUnitBaseDamage(whichUnit, 0, 0)
        call BlzSetUnitArmor(whichUnit, 0)
        call BlzSetUnitAttackCooldown(whichUnit, 1.8, 0)
        call BlzSetUnitIntegerField(whichUnit, UNIT_IF_DEFENSE_TYPE, GetHandleId(DEFENSE_TYPE_HERO))
        call UnitAddItemById(whichUnit, 'I00S')
    endfunction
    
    function IsValidHeroicUnit takes unit whichUnit, player errorMsgPlayer returns boolean
        if LoP_IsUnitDecoration(whichUnit) then
            call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "Decorations cannot be heroes.")
            
        elseif LoP_IsUnitDecoBuilder(whichUnit) then
            call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "Deco builders cannot be heroes.")
            
        elseif IsUnitType(whichUnit, UNIT_TYPE_PEON) then
            call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "Builders cannot be heroes.")
        
        elseif IsUnitType(whichUnit, UNIT_TYPE_STRUCTURE) then
            call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "Buildings cannot be heroes.")
            
        elseif GetUnitAbilityLevel(whichUnit, 'Adef') > 0 then
            call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "Units with the Defend ability cannot be heroes.")  // Crashes the game.
            
        elseif GetUnitAbilityLevel(whichUnit, 'AHer') > 0 then
            call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "This unit is already a hero.")
            
        elseif GetUnitAbilityLevel(whichUnit, 'AInv') > 0 then  // Detects all inventory skills. Add inventory to units with morph so they don't crash.
            // call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "This unit has an inventory, it can't be a hero.")
            call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "This type of unit cannot become a hero.")
        else
            return true
        endif
        return false
    endfunction
    
    function RefreshHeroIcons takes player whichPlayer returns nothing
        // Refresh hero icons on the left side of the screen
        call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
        call SetUnitOwner(Globals.dummy, whichPlayer, false)
        call SetUnitOwner(Globals.dummy, Player(bj_PLAYER_NEUTRAL_EXTRA), false)
        call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
    endfunction

endlibrary

scope MakeHeroic 




private function FilterUnitsMakeHero takes nothing returns boolean
    local unit filterU = GetFilterUnit()
    local boolean hasMana
    
    if GetTriggerPlayer() == udg_GAME_MASTER or GetOwningPlayer(filterU) == GetTriggerPlayer() then
    
        
        
        if IsValidHeroicUnit(filterU, udg_GAME_MASTER) then 
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
            
            call RefreshHeroIcons(GetOwningPlayer(filterU))
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
    
    set LoPHeroicUnit_Globals.dummy = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), 'Hpal', 0., 0., bj_UNIT_FACING )
    call ShowUnit(LoPHeroicUnit_Globals.dummy, false)
endfunction

endscope
