library DecoBuilderCount
function DecoBuilderReduceCountEx takes integer playerNumber, integer unitType returns nothing
    local integer decoCount = LoadInteger(udg_Hashtable_2, playerNumber, unitType )
    if decoCount > 0 then
        debug call BJDebugMsg("Deco count reduced!")
        call SaveInteger(udg_Hashtable_2, playerNumber, unitType, decoCount - 1)
    endif
endfunction

function DecoBuilderReduceCount takes unit whichUnit returns nothing
    call DecoBuilderReduceCountEx(GetPlayerId( GetOwningPlayer( whichUnit ) ) + 1, GetUnitTypeId(whichUnit))
endfunction

function IsUnitDecoBuilderEx takes integer ownerNumber, integer unitType returns boolean
    return LoadInteger(udg_Hashtable_2, ownerNumber, unitType ) > 0
endfunction

function IsUnitDecoBuilder takes unit whichUnit returns boolean
    return  IsUnitDecoBuilderEx(GetPlayerId(GetOwningPlayer(whichUnit)) + 1, GetUnitTypeId(whichUnit))
endfunction
endlibrary

library LoPtwo requires LoPone
function LoP_onRemoval takes unit whichUnit returns nothing
    debug call BJDebugMsg("OnRemove")
    if DummyDmg_IsDummy(DummyDmg_GetKey(whichUnit)) then
    
        debug call BJDebugMsg("Dummy Removed from the game!")
        //call DummyDmg_FlushKey(DummyDmg_GetKey(whichUnit))
        
    else

        set g_unitHasBeenRemoved = true
        // CLEAR KNOCKBACK DATA FOR SPELLS
        call FlushChildHashtable(udg_Hashtable_2, -GetUnitUserData(whichUnit))
        // CLEAR CUSTOM STAT HASHTABLE
        call FlushChildHashtable(udg_CSS_Hashtable, GetHandleId(whichUnit))
        // DECO BUILDER DECREASE COUNT
        call DecoBuilderReduceCount(whichUnit)

        
        call GUMSClearUnitData(whichUnit)
        call Patrol_ClearUnitData(whichUnit)
        call GMSS_ClearData(whichUnit)
        
        if Limit_IsPlayerLimited(GetOwningPlayer(whichUnit)) and Limit_IsUnitLimited(whichUnit) then
            call Limit_UnregisterUnit(whichUnit)
        endif
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

