function Trig_Commands_Toggle_Autoname_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local player trigP = GetTriggerPlayer()
    
    
    if args == "off" or (args == "" and udg_System_AutonameBoolean[GetPlayerId(trigP)+1]) then
        set udg_System_AutonameBoolean[GetPlayerId(trigP)+1] = false
        call DisplayTextToPlayer( trigP, 0, 0, "Autoname Disabled." )
        
    elseif args == "on" or (args == "" and not udg_System_AutonameBoolean[GetPlayerId(trigP)+1]) then
        set udg_System_AutonameBoolean[GetPlayerId(trigP)+1] = true
        call DisplayTextToPlayer( trigP, 0, 0, "Autoname Enabled." )
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Toggle_Autoname takes nothing returns nothing
    call LoP_Command.create("-autoname", ACCESS_USER, Condition(function Trig_Commands_Toggle_Autoname_Conditions ))
endfunction

