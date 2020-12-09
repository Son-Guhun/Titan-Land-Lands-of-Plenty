library LoPNeutralUnits requires TableStruct, LoPStdLib

    struct PlayerData extends array
        //! runtextmacro TableStruct_NewHandleField("neutralUnits", "group")
        
        static method get takes player whichPlayer returns thistype
            return GetPlayerId(whichPlayer)
        endmethod
    endstruct

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
    
    function LoP_RefreshNeutralUnits takes player whichPlayer returns nothing
        call GroupRefresh(PlayerData.get(whichPlayer).neutralUnits)
    endfunction

    function LoP_GiveToNeutral takes unit whichUnit returns nothing
        local player owner = GetOwningPlayer(whichUnit)
        set UnitData.get(whichUnit).owner = owner
        call GroupAddUnit(PlayerData.get(owner).neutralUnits, whichUnit)
        call SetUnitOwner(whichUnit, LoP.NEUTRAL_PASSIVE, false )
    endfunction
    
    function LoP_EnumNeutralUnits takes player whichPlayer, group whichGroup returns nothing
        call BlzGroupAddGroupFast(PlayerData.get(whichPlayer).neutralUnits, whichGroup)
    endfunction
    
    function LoP_ForNeutralUnits takes player whichPlayer, code callback returns nothing
        call ForGroup(PlayerData.get(whichPlayer).neutralUnits, callback)
    endfunction
    
    function LoP_InitializeNeutralUnits takes player whichPlayer returns nothing
        debug if PlayerData.get(whichPlayer).neutralUnits != null then
            debug call BJDebugMsg("ERROR! Initialized neutral units twice for player: " + I2S(GetPlayerId(whichPlayer)))
        debug endif
        set PlayerData.get(whichPlayer).neutralUnits = CreateGroup()
    endfunction

    // This function should be called when a unit changes owner and is not inside of the old owner's neutral grp.
    // This function accepts in-scope and out-of-scope units.
    function LoP_ClearNeutralData takes unit whichUnit returns nothing
        local UnitData handleId = UnitData.get(whichUnit)
        if handleId.hasOwner() then
            if GetUnitTypeId(whichUnit) != 0 then
                call GroupRemoveUnit(PlayerData.get(handleId.owner).neutralUnits, whichUnit)
            endif
            call handleId.clearOwner()
        endif
    endfunction

    function LoP_GetOwningPlayer takes unit whichUnit returns player
        local player owner = GetOwningPlayer(whichUnit) 
        local UnitData data = UnitData.get(whichUnit)
        
        if LoP.NEUTRAL_PASSIVE != owner then
            return owner
        else
            if data.hasOwner() then
                return UnitData.get(whichUnit).owner
            else
                return LoP.NEUTRAL_PASSIVE
            endif
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
        call LoP_WarnPlayerTimeout(GetTriggerPlayer(), LoPChannels.ERROR, LoPMsgKeys.NO_UNIT_ACCESS, 0., "This is not your unit." )
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
    call LoP_Command.create("-neut", ACCESS_USER, Condition(function Trig_Commands_Neutral_Conditions )) /*
    */.createChained("-neut decos", ACCESS_USER, Condition(function Trig_Commands_Neutral_Conditions ))
endfunction

