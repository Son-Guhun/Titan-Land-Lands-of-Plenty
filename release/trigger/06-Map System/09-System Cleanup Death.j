library LoPCleanUpDeath requires PlayerUnitLimit, LoPWidgets, MoveSpeedBonus, UserDefinedRects, DummyDmg, MultiPatrol, UnitEvents

function LoP_onDeath takes unit whichUnit returns nothing
    debug call BJDebugMsg("OnDeath")
    
    call UnitEvents.evalOnDeath(whichUnit)
    
    if ( GetUnitPointValue(whichUnit) == 37 ) then
    
        call DummyDmg_FlushKey(DummyDmg_GetKey(whichUnit))
        //call RemoveUnit( whichUnit )
        
    else
        if not LoP_IsUnitDecoration(whichUnit) then
        // DECO BUILDER DECREASE COUNT
            if LoP_IsUnitDecoBuilder(whichUnit)  then
                call RemoveUnit(whichUnit)
            else
                if ( Limit_IsPlayerLimited(GetOwningPlayer(whichUnit)) and Limit_IsUnitLimited(whichUnit) ) then
                    call Limit_UnregisterUnit(whichUnit)
                endif
                if LoP_UnitData.get(whichUnit).isHeroic then
                    call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
                    call SetUnitOwner(whichUnit, Player(bj_PLAYER_NEUTRAL_EXTRA), false)
                    call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
                    call RemoveUnit(whichUnit)
                endif
            endif
        else
            call DestroyGUDR(whichUnit)
            call GUMSClearUnitData(whichUnit)
            
            // Performance: Instantly remove decorations from the game
            set g_unitHasBeenRemoved = true
            call RemoveUnit( whichUnit )
        endif
    endif
endfunction
endlibrary

function Trig_System_Cleanup_Death_Actions takes nothing returns boolean
    call LoP_onDeath(GetTriggerUnit())
    return false
endfunction

//===========================================================================
function InitTrig_System_Cleanup_Death takes nothing returns nothing
    set gg_trg_System_Cleanup_Death = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_System_Cleanup_Death, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition( gg_trg_System_Cleanup_Death, Condition(function Trig_System_Cleanup_Death_Actions ))
endfunction

