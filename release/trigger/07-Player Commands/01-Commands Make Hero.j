scope MakeHeroic 

private struct Globals extends array
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticHandleField("dummy","unit")
    
endstruct

private function FilterUnitsMakeHero takes nothing returns boolean
    local unit filterU = GetFilterUnit()
    
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
            if UnitMakeHeroic(filterU) then
                call UnitAddAbility(filterU, 'A09Y' )
                //call UnitMakeAbilityPermanent(filterU, true, 'A09Y' )
                // call BlzSetUnitMaxHP()
                set LoP_UnitData.get(filterU).isHeroic = true
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
