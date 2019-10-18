library LoPCleanUpRemoval requires LoPCleanUpDeath, UnitEvents, optional RedefineNatives

//! runtextmacro optional RedefineNatives()

function LoP_onRemoval takes unit whichUnit returns nothing
    debug call BJDebugMsg("OnRemove")
    
    call UnitEvents.evalOnRemove(whichUnit)
    
    if DummyDmg_IsDummy(DummyDmg_GetKey(whichUnit)) then
    
        debug call BJDebugMsg("Dummy Removed from the game!")
        call DummyDmg_ClearData(whichUnit)
        
    else

        set g_unitHasBeenRemoved = true
        // CLEAR KNOCKBACK DATA FOR SPELLS
        call FlushChildHashtable(udg_Hashtable_2, -GetUnitUserData(whichUnit))
        // DECO BUILDER DECREASE COUNT
        call DecoBuilderCount_ReduceCount(whichUnit)

        
        call GUMSClearUnitData(whichUnit)
        call Patrol_ClearUnitData(whichUnit)
        call GMSS_ClearData(whichUnit)
        call LoP_ClearNeutralData(whichUnit)
        
        if LoP_UnitData.get(whichUnit).isHeroic then
            call LoPHeroicUnit_OnRemove(whichUnit)
            
            // Avoid crashes due to invalid hero icon in sidebar
            call DisableTrigger(gg_trg_System_Cleanup_Owner_Change)
            call SetUnitOwner(whichUnit, Player(bj_PLAYER_NEUTRAL_EXTRA), false)
            call EnableTrigger(gg_trg_System_Cleanup_Owner_Change)
        endif
        
        call LoP_UnitData.get(whichUnit).destroy()
    endif
endfunction

function LoP_RemoveUnit takes unit whichUnit returns nothing
    if LoP_IsUnitProtected(whichUnit) or LoP_IsUnitDummy(whichUnit) then
        // do nothing
    else
        if not LoP_IsUnitDecoration(whichUnit) then
            call RemoveUnit(whichUnit)  // Removing unit does not fire event immediately.
        else
            call DisableTrigger(gg_trg_System_Cleanup_Death)
            call KillUnit(whichUnit)
            call LoP_onDeath(whichUnit)
            call EnableTrigger(gg_trg_System_Cleanup_Death)
        endif
    endif
endfunction

function LoP_KillUnit takes unit whichUnit returns nothing
     if not LoP_IsUnitProtected(whichUnit) then
        call DisableTrigger(gg_trg_System_Cleanup_Death)
        call KillUnit(whichUnit)  // More efficient to not even call this at all for decorations. TODO
        call LoP_onDeath(whichUnit)
        call EnableTrigger(gg_trg_System_Cleanup_Death)
    endif   
endfunction

endlibrary

function Trig_System_Cleanup_Removal_Conditions takes nothing returns boolean
    call LoP_onRemoval(udg_UDexUnits[udg_UDex])
    return false
endfunction


//===========================================================================
function InitTrig_System_Cleanup_Removal takes nothing returns nothing
    set gg_trg_System_Cleanup_Removal = CreateTrigger(  )
    call TriggerRegisterVariableEvent( gg_trg_System_Cleanup_Removal, "udg_UnitIndexEvent", EQUAL, 2.00 )
    call TriggerAddCondition( gg_trg_System_Cleanup_Removal, Condition( function Trig_System_Cleanup_Removal_Conditions ) )
endfunction

