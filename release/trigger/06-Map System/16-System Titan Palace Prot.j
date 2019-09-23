scope TitanPalaceProt

function Trig_System_Titan_Palace_Prot_Func002C takes nothing returns boolean
    if ( not ( UnitHasItemOfTypeBJ(GetEnteringUnit(), 'I008') == false ) ) then
        return false
    endif
    if ( not ( GetOwningPlayer(GetEnteringUnit()) != udg_GAME_MASTER ) ) then
        return false
    endif
    return true
endfunction

function Trig_System_Titan_Palace_Prot_Conditions takes nothing returns boolean
    if ( not Trig_System_Titan_Palace_Prot_Func002C() ) then
        return false
    endif
    return true
endfunction

function Trig_System_Titan_Palace_Prot_Actions takes nothing returns nothing
    local real x = GetRectCenterX(gg_rct_Titan_Palace_Inner_Entrance)
    local real y = GetRectCenterY(gg_rct_Titan_Palace_Inner_Entrance)
    call SetUnitPosition( GetTriggerUnit(), x, y)
endfunction

//===========================================================================
function InitTrig_System_Titan_Palace_Prot takes nothing returns nothing
    set gg_trg_System_Titan_Palace_Prot = CreateTrigger(  )
    call TriggerRegisterEnterRectSimple( gg_trg_System_Titan_Palace_Prot, gg_rct_Titan_Palace_Inner )
    call TriggerAddCondition( gg_trg_System_Titan_Palace_Prot, Condition( function Trig_System_Titan_Palace_Prot_Conditions ) )
    call TriggerAddAction( gg_trg_System_Titan_Palace_Prot, function Trig_System_Titan_Palace_Prot_Actions )
endfunction

endscope