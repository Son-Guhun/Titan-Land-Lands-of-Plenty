function Trig_System_TPalace_Doors_Actions takes nothing returns nothing
    local group rectGroup = CreateGroup()
    
    call GroupEnumUnitsInRect(rectGroup,gg_rct_DoorIceTitan, null)
    if IsGroupEmpty(rectGroup) then
        call ModifyGateBJ( bj_GATEOPERATION_CLOSE, gg_dest_LTe3_0005 )
    else
        call ModifyGateBJ( bj_GATEOPERATION_OPEN, gg_dest_LTe3_0005 )
    endif
    call GroupClear(rectGroup)
    
    call GroupEnumUnitsInRect(rectGroup,gg_rct_DoorTitanA, null)
    if IsGroupEmpty(rectGroup) then
        call ModifyGateBJ( bj_GATEOPERATION_CLOSE, gg_dest_ATg3_0004 )
    else
        call ModifyGateBJ( bj_GATEOPERATION_OPEN, gg_dest_ATg3_0004 )
    endif
    call GroupClear(rectGroup)
    
    call GroupEnumUnitsInRect(rectGroup,gg_rct_DoorTitanB, null)
    if IsGroupEmpty(rectGroup) then
        call ModifyGateBJ( bj_GATEOPERATION_CLOSE, gg_dest_ATg1_0003 )
    else
        call ModifyGateBJ( bj_GATEOPERATION_OPEN, gg_dest_ATg1_0003 )
    endif
    call GroupClear(rectGroup)
    
    call GroupEnumUnitsInRect(rectGroup,gg_rct_DoorTreasureA, null)
    if IsGroupEmpty(rectGroup) then
        call ModifyGateBJ( bj_GATEOPERATION_CLOSE, gg_dest_DTg5_0007 )
    else
        call ModifyGateBJ( bj_GATEOPERATION_OPEN, gg_dest_DTg5_0007 )
    endif
    call GroupClear(rectGroup)
    
    call GroupEnumUnitsInRect(rectGroup,gg_rct_DoorTreasureB, null)
    if IsGroupEmpty(rectGroup) then
        call ModifyGateBJ( bj_GATEOPERATION_CLOSE, gg_dest_DTg5_0008 )
    else
        call ModifyGateBJ( bj_GATEOPERATION_OPEN, gg_dest_DTg5_0008 )
    endif
    
    call DestroyGroup(rectGroup)
    set rectGroup = null
endfunction

//===========================================================================
function InitTrig_System_TPalace_Doors takes nothing returns nothing
    set gg_trg_System_TPalace_Doors = CreateTrigger(  )
    call TriggerRegisterTimerEvent( gg_trg_System_TPalace_Doors, 0.50, true )
    call TriggerAddAction( gg_trg_System_TPalace_Doors, function Trig_System_TPalace_Doors_Actions )
endfunction

