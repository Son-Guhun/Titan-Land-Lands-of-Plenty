library CommandsDUnitMods requires LoPCommands, CutToComma, LoPStdLib

private struct Globals extends array
    
    static method operator value takes nothing returns real
        return MathParser.ans
    endmethod
    
    static location loc

endstruct

public function SetMatrixScale takes unit u, string args returns nothing
    local real scaleX
    local real scaleY
    local real scaleZ
    
    local integer cutToComma = CutToCharacter(args," ")
    set scaleX = Arguments_ParseNumber(SubString(args, 0, cutToComma))/100.
    
    if cutToComma < StringLength(args) then
        set args = SubString(args, cutToComma+1, StringLength(args))
        
        set cutToComma = CutToCharacter(args," ")
        set scaleY = Arguments_ParseNumber(SubString(args, 0, cutToComma))/100.
        
        if cutToComma < StringLength(args) then
            set args = SubString(args, cutToComma+1, StringLength(args))
        
            set scaleZ = Arguments_ParseNumber(args)/100.
        else
            set scaleZ = 100.
        endif
        
        call LoP.UVS.MatrixScale(u, scaleX, scaleY, scaleZ)
    else
        call LoP.UVS.Scale(u, scaleX)
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
            call CommandsDUnitMods_SetMatrixScale(enumUnit, udg_DecoSystem_Scale[playerNumber])
        else
            call CommandsDUnitMods_SetMatrixScale(enumUnit, args)
        endif
    elseif ( command == "'fly" or command == "'h") then
        if IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE) then
            if args == "" then
                call LoP.UVS.StructureFlyHeight(enumUnit, udg_DecoSystem_Height[playerNumber], not LoP_IsUnitDecoration(enumUnit))
            else
                call LoP.UVS.StructureFlyHeight(enumUnit, Globals.value, not LoP_IsUnitDecoration(enumUnit))
            endif
        else
            if args == "" then
                call LoP.UVS.FlyHeight(enumUnit, udg_DecoSystem_Height[playerNumber])
            else
                call LoP.UVS.FlyHeight(enumUnit, Globals.value)
            endif
        endif
    elseif ( command == "'ah" ) then
        if LoP_IsUnitDecoration(enumUnit) then
            call MoveLocation(Globals.loc, GetUnitX(enumUnit), GetUnitY(enumUnit))
            if IsUnitType(enumUnit, UNIT_TYPE_STRUCTURE) then
                if args == "" then
                    call LoP.UVS.StructureFlyHeight(enumUnit, udg_DecoSystem_Height[playerNumber] - GetLocationZ(Globals.loc), not LoP_IsUnitDecoration(enumUnit))
                else
                    call LoP.UVS.StructureFlyHeight(enumUnit, Globals.value - GetLocationZ(Globals.loc), not LoP_IsUnitDecoration(enumUnit))
                endif
            else
                if args == "" then
                    call LoP.UVS.FlyHeight(enumUnit, udg_DecoSystem_Height[playerNumber] - GetLocationZ(Globals.loc))
                else
                    call LoP.UVS.FlyHeight(enumUnit, Globals.value - GetLocationZ(Globals.loc))
                endif
            endif
        endif
    elseif ( command == "'face" or command == "'f") then
        if args == "" then
            call LoP.UVS.Facing(enumUnit, udg_DecoSystem_Facing[playerNumber])
        else
            call LoP.UVS.Facing(enumUnit, Globals.value)
        endif
    elseif ( SubString(command, 0, 4) == "'rgb") then
        call UnitVisualsSetters.VertexColorInt(enumUnit, udg_ColorSystem_Red[playerNumber], udg_ColorSystem_Green[playerNumber], udg_ColorSystem_Blue[playerNumber], udg_ColorSystem_Alpha[playerNumber])
    elseif ( command == "'anim" ) then
        if args == "" then
            call SetUnitAnimation( enumUnit, udg_DecoSystem_Anims[playerNumber] )
        else
            call SetUnitAnimation( enumUnit, args )
        endif
    elseif ( command == "'speed" ) then
        if args == "" then
            call UnitVisualsSetters.AnimSpeed(enumUnit, udg_DecoSystem_animSpeed[playerNumber]/100)
        else
            call UnitVisualsSetters.AnimSpeed(enumUnit, Globals.value/100)
        endif
    elseif ( command == "'color" ) then
        if args == "" then
            call UnitVisualsSetters.Color(enumUnit, udg_DecoSystem_PlayerColor[playerNumber])
        else
            call UnitVisualsSetters.Color(enumUnit,  Commands_GetChatMessagePlayerNumber(args))
        endif
    elseif ( command == "'roll" ) then
        if args != "" then
            call UnitSetRoll(enumUnit, Globals.value*bj_DEGTORAD)
        endif
    elseif ( command == "'pitch" ) then
        if args != "" then
            call UnitSetPitch(enumUnit, Globals.value*bj_DEGTORAD)
        endif
    endif
    
    set enumUnit = null
endfunction

private function onCommand takes nothing returns boolean
    local group udg_temp_group
    local integer genId
    local unit enumUnit
    local string cmd = LoP_Command.getCommand()
    local string args = LoP_Command.getArguments()
    local integer cutToComma
    
    local integer pN = GetPlayerId(GetTriggerPlayer()) + 1
    local integer red   = udg_ColorSystem_Red[pN]
    local integer green = udg_ColorSystem_Green[pN]
    local integer blue  = udg_ColorSystem_Blue[pN]
    local integer alpha = udg_ColorSystem_Alpha[pN]
    
    if cmd == "'rgb" then
        call Commands_SetRGBAFromString(GetTriggerPlayer(), args, false)
    elseif cmd == "'rgbi" then
        call Commands_SetRGBAFromString(GetTriggerPlayer(), args, true)
    elseif cmd == "'rgbh" then
        call Commands_SetRGBAFromHex(GetTriggerPlayer(), args)
    elseif cmd != "'anim" and cmd != "'color" then
        call MathParser.calculate(LoP_Command.getArguments())
    endif
        
    
    set udg_temp_group = CreateGroup()
    // ---------------------------------------------
    // PICK SELECTED UNITS AND CHECK FOR RECT GENERATOR
    call Commands_EnumSelectedCheckForGenerator(udg_temp_group, GetTriggerPlayer(), null)
    // ---------------------------------------------
    call ForGroup( udg_temp_group, function groupFunc )
    call DestroyGroup(udg_temp_group)
    
    set udg_ColorSystem_Red[pN] = red
    set udg_ColorSystem_Green[pN] = green
    set udg_ColorSystem_Blue[pN] = blue
    set udg_ColorSystem_Alpha[pN] = alpha
    
    
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
    call LoP_Command.create("'ah", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'anim", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'speed", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'color", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'pitch", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'roll", ACCESS_USER, Condition(function onCommand))
    
    call LoP_Command.create("'rgb", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'rgbi", ACCESS_USER, Condition(function onCommand))
    call LoP_Command.create("'rgbh", ACCESS_USER, Condition(function onCommand))
    
    set Globals.loc = Location(0., 0.)
endfunction

endlibrary

