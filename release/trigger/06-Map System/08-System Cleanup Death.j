library LoPCleanUpDeath requires LoPWidgets, MoveSpeedBonus, UnitVisualMods, UserDefinedRects, DummyDmg, MultiPatrol, UnitEvents, LoPNeutralUnits, MountSystem, RectSaveLoader, optional NativeRedefinitions

//! runtextmacro optional RedefineNatives()

function LoP_onDeath takes unit whichUnit returns nothing
    debug call BJDebugMsg("OnDeath")
    
    call UnitEvents.evalOnDeath(whichUnit)
    
    if ( GetUnitPointValue(whichUnit) == 37 ) then
    
        call DummyDmg_ClearData(whichUnit)
        //call RemoveUnit( whichUnit )
        
    else
        if not LoP_IsUnitDecoration(whichUnit) then
            call MountSystem_ClearData(whichUnit)
        
        // DECO BUILDER DECREASE COUNT
            if LoP_IsUnitDecoBuilder(whichUnit)  then
                call RemoveUnit(whichUnit)
            else
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
            call LoP_ClearNeutralData(whichUnit)
            call ClearSaveLoaderData(whichUnit)
            
            if UnitHasAttachedEffect(whichUnit) then
                call UnitDetachEffect(whichUnit).destroy()
            endif
            
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

