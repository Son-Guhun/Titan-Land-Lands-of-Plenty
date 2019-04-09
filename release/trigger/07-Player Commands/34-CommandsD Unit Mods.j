function Trig_CommandsD_Unit_Mods_Copy_Func009A takes nothing returns nothing
    local player trigPlayer = GetTriggerPlayer()
    local string command
    local string args
    local integer playerNumber
    local unit enumUnit
    
    if not Commands_StartsWithCommand() then
        return
    endif
    
    if ( not LoP_PlayerOwnsUnit(trigPlayer, GetEnumUnit()) ) then
        call DisplayTextToPlayer( trigPlayer, 0, 0, "This is not your unit!" )
        return
    endif
    
    set args = Commands_GetArguments()
    
    if args != "" then
        if SubString(args,0,1) != " " then
            call DisplayTextToPlayer( trigPlayer, 0, 0,"Arguments must be passed after a space!")
            return
        else
            set args = SubString(args, 1, StringLength(args))
        endif
    endif
    
    set enumUnit = GetEnumUnit()
    set playerNumber = GetPlayerId(trigPlayer) + 1
    set command = GetEventPlayerChatStringMatched()

    if ( command == "'size" ) then
        if args == "" then
            call GUMSSetUnitScale(enumUnit, udg_DecoSystem_Scale[playerNumber]/100)
        else
            call GUMSSetUnitScale(enumUnit, S2R(args)/100)
        endif
    elseif ( command == "'fly" or command == "'h") then
        if args == "" then
            call GUMSSetUnitFlyHeight(enumUnit, udg_DecoSystem_Height[playerNumber])
        else
            call GUMSSetUnitFlyHeight(enumUnit, S2R(args))
        endif
    elseif ( command == "'face" or command == "'f") then
        if args == "" then
            call GUMSSetUnitFacing(enumUnit, udg_DecoSystem_Facing[playerNumber])
        else
            call GUMSSetUnitFacing(enumUnit, S2R(args))
        endif
    elseif ( command == "'rgb" ) then
        if args == "" then
            call GUMSSetUnitVertexColor(enumUnit, udg_ColorSystem_Red[playerNumber], udg_ColorSystem_Green[playerNumber], udg_ColorSystem_Blue[playerNumber], udg_ColorSystem_Alpha[playerNumber])
        else
            call GUMSSetUnitVertexColorString(enumUnit, args, " ")
        endif
    elseif ( command == "'anim" ) then
        if args == "" then
            call SetUnitAnimation( enumUnit, udg_DecoSystem_Anims[playerNumber] )
        else
            call SetUnitAnimation( enumUnit, args )
        endif
    elseif ( command == "'speed" ) then
        if args == "" then
            call GUMSSetUnitAnimSpeed(enumUnit, udg_DecoSystem_animSpeed[playerNumber]/100)
        else
            call GUMSSetUnitAnimSpeed(enumUnit, S2R(args)/100)
        endif
    elseif ( command == "'color" ) then
        if args == "" then
            call GUMSSetUnitColor(enumUnit, udg_DecoSystem_PlayerColor[playerNumber])
        else
            call GUMSSetUnitColor(enumUnit,  Commands_GetChatMessagePlayerNumber(args))
        endif
    endif
    
    set enumUnit = null
endfunction

function Trig_CommandsD_Unit_Mods_Copy_Actions takes nothing returns nothing
    local group udg_temp_group
    local integer genId
    local unit enumUnit
    set udg_temp_group = CreateGroup()
    // ---------------------------------------------
    // PICK SELECTED UNITS AND CHECK FOR RECT GENERATOR
    call Commands_EnumSelectedCheckForGenerator(udg_temp_group, GetTriggerPlayer(), null)
    // ---------------------------------------------
    call ForGroup( udg_temp_group, function Trig_CommandsD_Unit_Mods_Copy_Func009A )
    call DestroyGroup(udg_temp_group)
    set udg_temp_group = null
    set enumUnit = null
endfunction

//===========================================================================
function InitTrig_CommandsD_Unit_Mods takes nothing returns nothing
    set gg_trg_CommandsD_Unit_Mods = CreateTrigger(  )
    call TriggerAddAction( gg_trg_CommandsD_Unit_Mods, function Trig_CommandsD_Unit_Mods_Copy_Actions )
endfunction

