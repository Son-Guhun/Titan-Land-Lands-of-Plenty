globals
    boolean commandsDeleteInsideTitanPalace = false
endglobals

function GroupEnum_RemoveOutsidePalace takes nothing returns boolean
    if RectContainsUnit(gg_rct_Titan_Palace, GetFilterUnit()) == commandsDeleteInsideTitanPalace and Commands_CheckOverflow() then
        call LoP_RemoveUnit(GetFilterUnit())
    endif
    return false
endfunction

function Trig_Commands_Deleteme_Conditions takes nothing returns boolean
    local LinkedHashSet_DecorationEffect test = EnumDecorationsOfPlayer(GetTriggerPlayer())
    local DecorationEffect i = test.begin()

    set udg_Commands_Counter = 0
    set udg_Commands_Counter_Max = 500
    set commandsDeleteInsideTitanPalace = false
    call GroupEnumUnitsOfPlayer(ENUM_GROUP, GetTriggerPlayer(), Filter(function GroupEnum_RemoveOutsidePalace))
    
    

    loop
    exitwhen i == test.end()
        call i.destroy()
        set i = test.next(i)
    endloop
    
    call test.destroy()
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Deleteme takes nothing returns nothing
    call LoP_Command.create("-deleteme", ACCESS_USER, Condition(function Trig_Commands_Deleteme_Conditions ))
endfunction

