library MoveSpeedModification requires MoveSpeedBonus

function UnitAddMoveSpeed takes unit whichUnit, real amount returns nothing
    call GMSS_UnitAddMoveSpeed(whichUnit, amount)
endfunction

function UnitMultiplyMoveSpeed takes unit whichUnit, real amount returns nothing
    call GMSS_UnitMultiplyMoveSpeed(whichUnit, amount)
endfunction

endlibrary