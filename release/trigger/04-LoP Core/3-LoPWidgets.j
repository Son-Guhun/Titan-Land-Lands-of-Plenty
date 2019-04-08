library LoPWidgets requires LoPHeader, TableStruct

private struct Globals extends array
    
    //! runtextmacro TableStruct_NewConstTableField("","destructablesTab")
    
endstruct

// Destructables
function LoP_IsDestructableProtected takes destructable dest returns boolean
    return Globals.destructablesTab.boolean.has(GetHandleId(dest))
endfunction

function LoP_ProtectDestructable takes destructable dest returns nothing
    set Globals.destructablesTab.boolean[GetHandleId(dest)] = true
endfunction

// Units
function LoP_IsUnitDecoBuilder takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'A00J') > 0
endfunction

function LoP_IsUnitProtected takes unit whichUnit returns boolean
    return IsUnitInGroup(whichUnit, udg_System_ProtectedGroup)
endfunction

function LoP_GetProtectedUnits takes nothing returns group
    return udg_System_ProtectedGroup
endfunction
endlibrary