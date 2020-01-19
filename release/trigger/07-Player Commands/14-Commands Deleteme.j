globals
    boolean commandsDeleteInsideTitanPalace = false
endglobals

function GroupEnum_RemoveOutsidePalace takes nothing returns boolean
    if RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) == commandsDeleteInsideTitanPalace and Commands_CheckOverflow() then
        call LoP_RemoveUnit(GetFilterUnit())
    endif
    return false
endfunction

function GroupEnum_RemoveDecoBuilders takes nothing returns boolean
    if LoP_IsUnitDecoBuilder(GetFilterUnit()) and Commands_CheckOverflow()then
        call LoP_RemoveUnit(GetFilterUnit())
    endif
    return false
endfunction

function Trig_Commands_Deleteme_Conditions takes nothing returns boolean
    local LinkedHashSet_DecorationEffect test = EnumDecorationsOfPlayer(GetTriggerPlayer())
    local DecorationEffect i = test.begin()

    if LoP_Command.getArguments() == "decos" then
        set udg_Commands_Counter = 0
        set udg_Commands_Counter_Max = 500
        call GroupEnumUnitsOfPlayer(ENUM_GROUP, GetTriggerPlayer(), Filter(function GroupEnum_RemoveDecoBuilders))
    else
        set udg_Commands_Counter = 0
        set udg_Commands_Counter_Max = 1500
        loop
        exitwhen i == test.end() or not CheckCommandOverflow()
            call i.destroy()
            set i = test.next(i)
        endloop
        
        set udg_Commands_Counter = udg_Commands_Counter/3
        set udg_Commands_Counter_Max = 500
        if udg_Commands_Counter < 250 then  // not worth less than 250 executions
            set commandsDeleteInsideTitanPalace = false
            call GroupEnumUnitsOfPlayer(ENUM_GROUP, GetTriggerPlayer(), Filter(function GroupEnum_RemoveOutsidePalace))
        elseif udg_Commands_Counter < udg_Commands_Counter_Max then
            set udg_Commands_Counter = udg_Commands_Counter_Max
            call CheckCommandOverflow()
        endif
    endif
    
    call test.destroy()
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Deleteme takes nothing returns nothing
    call LoP_Command.create("-deleteme", ACCESS_USER, Condition(function Trig_Commands_Deleteme_Conditions ))
endfunction

// For some fucking reason this is slower than a Enum loop
// No idea why, trying to start a new thread when removing a unit doesn't help
/*
function Trig_Commands_Deleteme_Conditions takes nothing returns boolean
    local LinkedHashSet_DecorationEffect test = EnumDecorationsOfPlayer(GetTriggerPlayer())
    local DecorationEffect i = test.begin()
    local group g = CreateGroup()
    local unit u

    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = 1500
    loop
    exitwhen i == test.end() or not CheckCommandOverflow()
        call i.destroy()
        set i = test.next(i)
    endloop
    
    if udg_Commands_Counter < 1500 then
        set udg_Commands_Counter = udg_Commands_Counter/3
        set udg_Commands_Counter_Max = 500
        call GroupEnumUnitsOfPlayer(g, GetTriggerPlayer(), null)
        
        loop
            //! runtextmacro ForUnitInGroup("u", "g")
            if not RectContainsUnit(gg_rct_Titan_Palace, u) then
                // call LoP_RemoveUnit(u)
                call RemoveUnit(u)
                exitwhen not CheckCommandOverflow()
            endif
        endloop
    endif
    
    call test.destroy()
    call DestroyGroup(g)
    call BJDebugMsg("Over")
    set u = null
    return false
endfunction
*/
