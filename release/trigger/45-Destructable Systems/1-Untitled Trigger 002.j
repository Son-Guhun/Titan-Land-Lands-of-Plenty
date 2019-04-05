function CreateDestructableAtUnit takes unit u, integer destId, integer var returns boolean
    local destructable dest
    set dest = CreateDestructable(destId, GetUnitX(u), GetUnitY(u), GetUnitFacing(u), GUMSGetUnitScale(u), var)
    if dest == null then
        return false
    endif
    call SetUnitX(u, GetDestructableX(dest))
    call SetUnitY(u, GetDestructableY(dest))
    call SaveDestructableHandle(udg_Dest_Hashtable, GetHandleId(u), 0, dest)
    call SaveInteger(udg_Dest_Hashtable, GetHandleId(dest), 0, var)
    set dest = null
    return true
endfunction

function UnbindDestructable takes unit u returns nothing
    call FlushChildHashtable(udg_Dest_Hashtable, GetHandleId(u))
endfunction

function BindDestructable takes unit u, destructable dest returns nothing
    call SaveDestructableHandle(udg_Dest_Hashtable, GetHandleId(u), 0, dest)
    call SetUnitX(u, GetDestructableX(dest))
    call SetUnitY(u, GetDestructableY(dest))
endfunction

function MoveBoundDestructable takes unit u returns boolean
    local destructable dest = LoadDestructableHandle(udg_Dest_Hashtable, GetHandleId(u), 0)
    local integer var
    if dest == null then
        return false
    endif
    
    set var = LoadInteger(udg_Dest_Hashtable, GetHandleId(dest), 0)
    call CreateDestructableAtUnit(u, GetDestructableTypeId(dest), var)
    
    call FlushChildHashtable(udg_Dest_Hashtable, GetHandleId(dest))
    call RemoveDestructable(dest)
    
    set dest = null
endfunction


//===========================================================================
function InitTrig_Untitled_Trigger_002 takes nothing returns nothing
    set gg_trg_Untitled_Trigger_002 = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Untitled_Trigger_002, function Trig_Untitled_Trigger_002_Actions )
endfunction

