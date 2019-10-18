library NativeRedefinitions



public function NewRemoveUnit takes unit whichUnit returns nothing
    call ShowUnit(whichUnit, true)
    call RemoveUnit(whichUnit)
endfunction


//! textmacro RedefineNatives

private function RemoveUnit takes unit whichUnit returns nothing
    call NativeRedefinitions_NewRemoveUnit(whichUnit)
endfunction

//! endtextmacro




endlibrary