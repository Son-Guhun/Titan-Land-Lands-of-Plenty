scope TriggerSaveRequest

globals
    DecorationEffect array save_decoration_effects
endglobals

function Trig_SaveRequest_Conditions takes nothing returns boolean
    if ( not ( SubStringBJ(GetEventPlayerChatString(), 1, 6) == "-save " ) ) then
        return false
    endif
    return true
endfunction

function EnumFilter takes nothing returns boolean
    return not (RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) or GetUnitTypeId(GetFilterUnit()) == 'h07Q' /*dummy unit*/)
endfunction

function Trig_SaveRequest_Actions takes nothing returns nothing
    local integer playerNumber = GetPlayerId(GetTriggerPlayer()) + 1
    
    call SaveLoopStartTimer()
    set udg_save_password[playerNumber] = SubString(GetEventPlayerChatString(), 6, StringLength(GetEventPlayerChatString()))
    
    call DestroyGroup(udg_save_grp[playerNumber])
    set udg_save_grp[playerNumber] = CreateGroup()
    call GroupEnumUnitsOfPlayer(udg_save_grp[playerNumber], GetTriggerPlayer(), Filter(function EnumFilter))
    call GroupRemoveUnit(udg_save_grp[playerNumber], TerrainEditorUI_GetEditorUnit(GetTriggerPlayer()))
    
    set save_decoration_effects[playerNumber] = EnumDecorationsOfPlayer(GetTriggerPlayer())

    call BlzGroupAddGroupFast(udg_save_grp[playerNumber], udg_System_NeutralUnits[(playerNumber - 1)])
    set udg_save_unit_nmbr[playerNumber] = 0
    set udg_save_load_boolean[playerNumber] = true
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, udg_RealNames[playerNumber] + ( " has started saving."))// Expected save time: " + R2S(BlzGroupGetSize(udg_save_grp[playerNumber])/25.00)))
endfunction

//===========================================================================
function InitTrig_SaveRequest takes nothing returns nothing
    set gg_trg_SaveRequest = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_SaveRequest, Condition( function Trig_SaveRequest_Conditions ) )
    call TriggerAddAction( gg_trg_SaveRequest, function Trig_SaveRequest_Actions )
endfunction

endscope
