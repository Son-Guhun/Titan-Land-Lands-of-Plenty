library NativeRedefinitions

globals
    group REMOVE_GRP = CreateGroup()
endglobals

private function onTimer takes nothing returns nothing
    local unit u
    
    loop
        //! runtextmacro ForUnitInGroup("u", "REMOVE_GRP")
        call RemoveUnit(u)
    endloop
    
    call DestroyTimer(GetExpiredTimer())
endfunction

public function NewRemoveUnit takes unit whichUnit returns nothing
    if IsUnitHidden(whichUnit) then
        call ShowUnit(whichUnit, true)
    endif
    if IsGroupEmpty(REMOVE_GRP) then
        call TimerStart(CreateTimer(), 0, false, function onTimer)
    endif
    call GroupAddUnit(REMOVE_GRP, whichUnit)
endfunction


//! textmacro RedefineNatives

private function RemoveUnit takes unit whichUnit returns nothing
    call NativeRedefinitions_NewRemoveUnit(whichUnit)
endfunction

//! endtextmacro




endlibrary