library LoPHeroicUnit requires LoPStdLib, optional NativeRedefinitions, UnitName

//! runtextmacro optional RedefineNatives()

    globals
        private integer array heroicUnitCount
        private group countedUnits
    endglobals

    private module InitModule
        private static method onInit takes nothing returns nothing
            set countedUnits = CreateGroup()
        endmethod
    endmodule
    public struct Globals extends array
        private static key static_members_key
        //! runtextmacro TableStruct_NewStaticAgentField("dummy","unit")
        
        implement InitModule
    endstruct
    
    
    function LoP_GetPlayerHeroicUnitCount takes player whichPlayer returns integer
        return heroicUnitCount[GetPlayerId(whichPlayer)]
    endfunction
    
    function LoP_IsUnitCustomHero takes unit whichUnit returns boolean
        return IsUnitInGroup(whichUnit, countedUnits)
    endfunction

    function GiveHeroStats takes unit whichUnit returns nothing
        // call UnitApplyTimedLife(whichUnit, 'BHwe', 1)
        call UnitPauseTimedLife(whichUnit, true)
        call UnitAddAbility(whichUnit, 'A09Y')
        call UnitAddAbility(whichUnit, 'A008')
        call UnitAddItemById(whichUnit, 'I013')  // Add item in order to keep unit separate in selection
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
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "Decorations cannot be heroes.")
            
        elseif LoP_IsUnitDecoBuilder(whichUnit) then
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "Deco builders cannot be heroes.")
            
        elseif IsUnitType(whichUnit, UNIT_TYPE_PEON) then
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "Builders cannot be heroes.")
        
        elseif IsUnitType(whichUnit, UNIT_TYPE_STRUCTURE) then
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "Buildings cannot be heroes.")
            
        elseif GetUnitAbilityLevel(whichUnit, 'Adef') > 0 then
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "Units with the Defend ability cannot be heroes.")  // Crashes the game.
            
        elseif GetUnitAbilityLevel(whichUnit, 'AHer') > 0 then
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "This unit is already a hero.")
            
        elseif GetUnitAbilityLevel(whichUnit, 'AInv') > 0 then  // Detects all inventory skills. Add inventory to units with morph so they don't crash.
            // call DisplayTextToPlayer(errorMsgPlayer, 0, 0, "This unit has an inventory, it can't be a hero.")
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "This type of unit cannot become a hero.")
            
        elseif LoP_TransportHasUnits(whichUnit) then
            call LoP_WarnPlayer(errorMsgPlayer, LoPChannels.ERROR, "Must unload transport first.")
        
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
    
    function StoreGUMSValues takes unit whichUnit returns Table
        local Table result = Table.create()
        local UnitVisuals visuals = UnitVisuals.get(whichUnit)
        
        set result.real['flyH'] = GetUnitFlyHeight(whichUnit)
        
        if visuals.hasScale() then
            set result.real['size'] = visuals.raw.getScale()
        endif
        
        if visuals.hasVertexColor() then
            set result['vtxR'] = visuals.raw.getVertexRed()
            set result['vtxG'] = visuals.raw.getVertexGreen()
            set result['vtxB'] = visuals.raw.getVertexBlue()
            set result['vtxA'] = visuals.raw.getVertexAlpha()
        endif
        
        if visuals.hasColor() then
            set result['pClr'] = visuals.raw.getColor()
        endif
        
        if visuals.hasAnimSpeed() then
            set result.real['Aspd'] = visuals.raw.getAnimSpeed()
        endif
        
        if visuals.hasCustomName() then
            set result.string['name'] = UnitVisuals.getUnitName(whichUnit)
        endif
        
        //call BJDebugMsg(visuals.raw.getAnimTag())
        //result.string['Atag'] = visuals.rraw.getAnimTag()

        return result
    endfunction

    function RestoreGUMSValues takes unit whichUnit, Table values returns nothing
        call LoP.UVS.FlyHeight(whichUnit, values.real['flyH'])
        
        if values.real.has('size') then
            call LoP.UVS.Scale(whichUnit, values.real['size'])
        endif
        if values.has('vtxR') then
            call LoP.UVS.VertexColorInt(whichUnit, values['vtxR'], values['vtxG'], values['vtxB'], values['vtxA'])
        endif
        if values.has('pClr') then
            call LoP.UVS.Color(whichUnit, values['pClr'])
        endif
        if values.real.has('Aspd') then
            call LoP.UVS.AnimSpeed(whichUnit, values.real['Aspd'])
        endif
        if values.string.has('name') then
            call LoP.UVS.Name(whichUnit, values.string['name'])
        endif
        //GUMSSetUnitAnimTags(whichUnit, values.
    endfunction
    
    function LoP_UnitMakeHeroic  takes unit whichUnit returns boolean
        local Table visualValues = StoreGUMSValues(whichUnit)
        local boolean result = UnitMakeHeroic(whichUnit)
        if result then
            // call UnitAddAbility(whichUnit, 'A008' )
            set LoP_UnitData.get(whichUnit).isHeroic = true
            call GroupAddUnit(countedUnits, whichUnit)
            set heroicUnitCount[GetPlayerId(GetOwningPlayer(whichUnit))] = heroicUnitCount[GetPlayerId(GetOwningPlayer(whichUnit))] + 1
            
            call GiveHeroStats(whichUnit)
            call RestoreGUMSValues(whichUnit, visualValues)
            call UnitName_Register(whichUnit)
        else
            call LoP_WarnPlayer(GetLocalPlayer(), LoPChannels.ERROR, "Unable to make unit " + GetUnitName(whichUnit) + " a hero. Report this problem please.")
        endif
        
        call visualValues.destroy()
        return result
    endfunction

    public function OnRemove takes unit whichUnit returns nothing
        if IsUnitInGroup(whichUnit, countedUnits) then
            set heroicUnitCount[GetPlayerId(GetOwningPlayer(whichUnit))] = heroicUnitCount[GetPlayerId(GetOwningPlayer(whichUnit))] - 1
            call GroupRemoveUnit(countedUnits, whichUnit)
        endif
    endfunction
    
    public function OnChangeOwner takes unit whichUnit, player oldOwner returns nothing
        if IsUnitInGroup(whichUnit, countedUnits) then
            set heroicUnitCount[GetPlayerId(GetOwningPlayer(whichUnit))] = heroicUnitCount[GetPlayerId(GetOwningPlayer(whichUnit))] + 1
            set heroicUnitCount[GetPlayerId(oldOwner)] = heroicUnitCount[GetPlayerId(oldOwner)] - 1
            
            if heroicUnitCount[GetPlayerId(GetOwningPlayer(whichUnit))] >= 12 then
                call RemoveUnit(whichUnit)
            endif
        endif
    endfunction

endlibrary

scope MakeHeroic 




private function FilterUnitsMakeHero takes nothing returns boolean
    local unit filterU = GetFilterUnit()
    local boolean hasMana
    
    if GetTriggerPlayer() == udg_GAME_MASTER or GetOwningPlayer(filterU) == GetTriggerPlayer() then
    
        
        
        if IsValidHeroicUnit(filterU, GetTriggerPlayer()) then 
            set hasMana = GetUnitState(filterU, UNIT_STATE_MAX_MANA) > 1
            
            if LoP_GetPlayerHeroicUnitCount(GetOwningPlayer(filterU)) >= 12 and GetTriggerPlayer() != udg_GAME_MASTER then
                call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.LIMIT, 0., "Heroic unit limit reached for player. Only the Titan can make heroic units over this limit.")
            elseif GetOwningPlayer(filterU) != GetTriggerPlayer() and GetTriggerPlayer() != udg_GAME_MASTER then
                call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit.")
            else
            
                if GetTriggerPlayer() != udg_GAME_MASTER then
                    call LoP_WarnPlayer(udg_GAME_MASTER, LoPChannels.SYSTEM, "Player " + GetPlayerName(GetTriggerPlayer()) + " created a custom hero.")
                endif
                call LoP_UnitMakeHeroic(filterU)
            endif
            
            call RefreshHeroIcons(GetOwningPlayer(filterU))
        endif
    endif
    
    set filterU = null
    return false
endfunction

function Trig_Commands_Make_Hero_Conditions takes nothing returns nothing
    call GroupEnumUnitsSelected(ENUM_GROUP, GetTriggerPlayer(), Condition(function FilterUnitsMakeHero))
endfunction

//===========================================================================
function InitTrig_Commands_Make_Hero takes nothing returns nothing
    call LoP_Command.create("-makehero", ACCESS_USER, Condition(function Trig_Commands_Make_Hero_Conditions ))
    
    set LoPHeroicUnit_Globals.dummy = CreateUnit(Player(bj_PLAYER_NEUTRAL_EXTRA), 'Hpal', 0., 0., bj_UNIT_FACING )
    call ShowUnit(LoPHeroicUnit_Globals.dummy, false)
endfunction

endscope
