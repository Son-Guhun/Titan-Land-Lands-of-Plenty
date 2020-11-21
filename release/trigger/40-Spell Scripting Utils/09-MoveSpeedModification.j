library MoveSpeedModification requires MoveSpeedBonus
/* A compatiblity layer for MoveSpeedBonus that exposes the old API used by LoP. */

function UnitAddMoveSpeed takes unit whichUnit, real amount returns nothing
    call GMSS_UnitAddMoveSpeed(whichUnit, amount)
endfunction

function UnitMultiplyMoveSpeed takes unit whichUnit, real amount returns nothing
    call GMSS_UnitMultiplyMoveSpeed(whichUnit, amount)
endfunction

endlibrary