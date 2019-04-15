function steppp takes nothing returns real
    return 512.
endfunction

function Trig_Untitled_Trigger_001_Actions takes nothing returns nothing
    local real minX = WorldBounds.minX
    local real minY = WorldBounds.minY
    local real x = minX
    local real y
    

    loop
    exitwhen x > WorldBounds.maxX
        set y = minY
        loop
        exitwhen y > WorldBounds.maxY
            call BlzSetSpecialEffectZ(AddSpecialEffect("Doodads\\WaterPlane.mdl", x, y), 422.)
            set y = y + steppp()
        endloop
        set x = x + steppp()
    endloop
    
endfunction

//===========================================================================
function InitTrig_Create_Water takes nothing returns nothing
    set gg_trg_Create_Water = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Create_Water, function Trig_Untitled_Trigger_001_Actions )
    call TriggerRegisterPlayerChatEvent(gg_trg_Create_Water, Player(0), "getwater", true )
endfunction

