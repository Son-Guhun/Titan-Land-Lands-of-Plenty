scope CommandsDUnitMods

private function SetMatrixScale takes unit u, string args returns nothing
    local real scaleX
    local real scaleY
    local real scaleZ
    
    local integer cutToComma = CutToCharacter(args," ")
    set scaleX = S2R(SubString(args, 0, cutToComma))/100.
    
    if cutToComma < StringLength(args) then
        set args = SubString(args, cutToComma+1, StringLength(args))
        
        set cutToComma = CutToCharacter(args," ")
        set scaleY = S2R(SubString(args, 0, cutToComma))/100.
        
        if cutToComma < StringLength(args) then
            set args = SubString(args, cutToComma+1, StringLength(args))
        
            set scaleZ = S2R(args)/100.
        else
            set scaleZ = 100.
        endif
        
        call GUMSSetUnitMatrixScale(u, scaleX, scaleY, scaleZ)
    else
        call GUMSSetUnitScale(u, scaleX)
    endif
endfunction

// Check if unit is Deco Special so this trigger is not run for every unit that casts a ability
private function groupFunc takes nothing returns nothing
    local player trigPlayer = GetTriggerPlayer()
    local string command
    local string args
    local integer playerNumber
    local unit enumUnit = GetEnumUnit()
    
    if ( not LoP_PlayerOwnsUnit(trigPlayer, enumUnit) ) then
        call DisplayTextToPlayer( trigPlayer, 0, 0, "This is not your unit!" )
        set enumUnit = null
        return
    endif
    
    set args = LoP_Command.getArguments()
    set playerNumber = GetPlayerId(trigPlayer) + 1
    set command = LoP_Command.getCommand()

    if ( command == "'size" ) then
        if args == "" then
            call GUMSSetUnitScale(enumUnit, udg_DecoSystem_Scale[playerNumber]/100)
        else
            call SetMatrixScale(enumUnit, args)
        endif
    elseif ( command == "'fly" or command == "'h") then
        if IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE) then
            if args == "" then
                call GUMSSetStructureFlyHeight(enumUnit, udg_DecoSystem_Height[playerNumber], not LoP_IsUnitDecoration(enumUnit))
            else
                call GUMSSetStructureFlyHeight(enumUnit, S2R(args), not LoP_IsUnitDecoration(enumUnit))
            endif
        else
            if args == "" then
                call GUMSSetUnitFlyHeight(enumUnit, udg_DecoSystem_Height[playerNumber])
            else
                call GUMSSetUnitFlyHeight(enumUnit, S2R(args))
            endif
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
    elseif ( command == "'roll" ) then
        if args != "" then
            if not UnitHasAttachedEffect(enumUnit) then
                set UnitCreateAttachedEffect(enumUnit).roll = S2R(args)*bj_DEGTORAD
            else
                set GetUnitAttachedEffect(enumUnit).roll = S2R(args)*bj_DEGTORAD
            endif
        endif
    elseif ( command == "'pitch" ) then
        if args != "" then
            if not UnitHasAttachedEffect(enumUnit) then
                set UnitCreateAttachedEffect(enumUnit).pitch = S2R(args)*bj_DEGTORAD
            else
                set GetUnitAttachedEffect(enumUnit).pitch = S2R(args)*bj_DEGTORAD
            endif
        endif
    endif
    
    set enumUnit = null
endfunction

private function onCommand takes nothing returns boolean
    local group udg_temp_group
    local integer genId
    local unit enumUnit
    set udg_temp_group = CreateGroup()
    // ---------------------------------------------
    // PICK SELECTED UNITS AND CHECK FOR RECT GENERATOR
    call Commands_EnumSelectedCheckForGenerator(udg_temp_group, GetTriggerPlayer(), null)
    // ---------------------------------------------
    call ForGroup( udg_temp_group, function groupFunc )
    call DestroyGroup(udg_temp_group)
    set udg_temp_group = null
    set enumUnit = null
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Unit_Mods takes nothing returns nothing
    call LoP_Command.create("'size", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'face", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'f", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'fly", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'h", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'anim", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'speed", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'color", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'pitch", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'roll", ACCESS_USER, Condition(function onCommand))
    
    call LoP_Command.create("'rgb", ACCESS_USER, Condition(function onCommand))
endfunction

endscope

