
globals
    boolean flagFlag = true
endglobals

function Trig_Commands_A_Func001A takes nothing returns nothing
    //call PauseUnitBJ( true, GetEnumUnit() )
    //call BlzUnitDisableAbility(GetEnumUnit(), 'Amov', false, false)
    //call BlzUnitDisableAbility(GetEnumUnit(), 'Aatk', false, false)
    //call BlzUnitDisableAbility(GetEnumUnit(), 'AInv', false, true)
    call BlzUnitDisableAbility(GetEnumUnit(), 'AInv', flagFlag, flagFlag)
    set flagFlag = not flagFlag
endfunction

function Trig_Commands_A_Actions takes nothing returns nothing
    call ForGroupBJ( GetUnitsSelectedAll(Player(0)), function Trig_Commands_A_Func001A )
endfunction

//===========================================================================
function InitTrig_Enabling_Inventory takes nothing returns nothing
    set gg_trg_Enabling_Inventory = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( gg_trg_Enabling_Inventory, Player(0), "hweo", true )
    call TriggerAddAction( gg_trg_Enabling_Inventory, function Trig_Commands_A_Actions )
endfunction

