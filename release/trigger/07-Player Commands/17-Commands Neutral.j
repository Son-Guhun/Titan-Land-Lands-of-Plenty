library LoPNeutralUnits requires TableStruct

private struct UnitData extends array
    //! runtextmacro TableStruct_NewPrimitiveField("owner", "player")
    
    method clearOwner takes nothing returns nothing
        call .ownerClear()
    endmethod
    
    method hasOwner takes nothing returns boolean
        return .ownerExists()
    endmethod
    
    static method get takes unit whichUnit returns UnitData
        return GetHandleId(whichUnit)
    endmethod
endstruct


function LoP_GetPlayerNeutralUnits takes player whichPlayer returns group
    return udg_System_NeutralUnits[GetPlayerId(whichPlayer)]
endfunction

function LoP_IsUnitInPlayerNeutralUnits takes unit whichUnit, player whichPlayer returns boolean
    return false
endfunction

function LoP_GiveToNeutral takes unit whichUnit returns nothing
    set UnitData.get(whichUnit).owner = GetOwningPlayer(whichUnit)
    call GroupAddUnit(LoP_GetPlayerNeutralUnits(GetOwningPlayer(whichUnit)), whichUnit)
    call SetUnitOwner(whichUnit, Player(PLAYER_NEUTRAL_PASSIVE), false )
endfunction

function LoP_TakeFromNeutral takes unit whichUnit returns nothing
    local UnitData data = GetHandleId(whichUnit)
    if GetOwningPlayer(whichUnit) == Player(PLAYER_NEUTRAL_PASSIVE) and data.hasOwner() then
        call SetUnitOwner(whichUnit, data.owner, false)
        //call data.clearOwner()
    endif
endfunction

function LoP_ClearNeutralHandleId takes UnitData handleId returns nothing
    call handleId.clearOwner()
endfunction

// This function should be called when a unit changes owner and is not inside of the old owner's neutral grp.
// This function accepts in-scope and out-of-scope units.
function LoP_ClearNeutralData takes unit whichUnit returns nothing
    call UnitData.get(whichUnit).clearOwner()
endfunction

function LoP_GetOwningPlayer takes unit whichUnit returns player
    local player owner = GetOwningPlayer(whichUnit) 
    if Player(PLAYER_NEUTRAL_PASSIVE) != owner then
        return owner
    else
        return UnitData.get(whichUnit).owner
    endif
endfunction
endlibrary

function Trig_Commands_Neutral_Func010Func002A takes nothing returns nothing
    if GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() then
        if LoP_IsUnitDecoration(GetEnumUnit()) then
            if CheckCommandOverflow() then
                call LoP_GiveToNeutral(GetEnumUnit())
            endif
        endif
    // Elseif not in neutral units
    endif
endfunction

function Trig_Commands_Neutral_Func010Func003A takes nothing returns nothing
    if ( GetOwningPlayer(GetEnumUnit()) == GetTriggerPlayer() ) then
        if CheckCommandOverflow() then
            call LoP_GiveToNeutral(GetEnumUnit())
        endif
    else
        call DisplayTextToForce( udg_FORCES_PLAYER[( GetConvertedPlayerId(GetTriggerPlayer()) - 1 )], "This is not your unit." )
    endif
endfunction

function Trig_Commands_Neutral_Conditions takes nothing returns boolean
    local group udg_temp_group = CreateGroup()
    local integer genId
    local unit udg_temp_unit

    call Commands_EnumSelectedCheckForGenerator(udg_temp_group, GetTriggerPlayer(), null)

    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = 2000
    if ( LoP_Command.getArguments() == "decos" ) then
        call ForGroup( udg_temp_group, function Trig_Commands_Neutral_Func010Func002A )
    else
        call ForGroup( udg_temp_group, function Trig_Commands_Neutral_Func010Func003A )
    endif
    
    
    call DestroyGroup( udg_temp_group )
    set udg_temp_group = null
    set udg_temp_unit = null
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Neutral takes nothing returns nothing
    call LoP_Command.create("-neut", ACCESS_USER, Condition(function Trig_Commands_Neutral_Conditions ))
    call LoP_Command.create("-neut decos", ACCESS_USER, Condition(function Trig_Commands_Neutral_Conditions ))
endfunction

