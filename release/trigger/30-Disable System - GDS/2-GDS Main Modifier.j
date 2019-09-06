function GDSModifier0 takes nothing returns nothing

//Greater Frost Armor
if GetUnitAbilityLevel(udg_GDS_Target, 'B02R') > 0 then
    set udg_GDS_DurAdd = udg_GDS_DurAdd -3
endif
//--------------
endfunction

function GDSModifier1 takes nothing returns nothing
endfunction

function GDSModifier2 takes nothing returns nothing
endfunction

function GDSModifier3 takes nothing returns nothing
endfunction

function GDSModifier4 takes nothing returns nothing
endfunction

function GDSModifier5 takes nothing returns nothing
endfunction

function GDSModifier6 takes nothing returns nothing
endfunction

function GDSModifier7 takes nothing returns nothing
endfunction

function GDSModifier8 takes nothing returns nothing
endfunction

function GDSModifier9 takes nothing returns nothing
endfunction

function GDSChooseMod takes nothing returns nothing
    if udg_GDS_Type == 0 then
        call GDSModifier0()
    endif
    if udg_GDS_Type == 1 then
        call GDSModifier1()
    endif
    if udg_GDS_Type == 2 then
        call GDSModifier2()
    endif
    if udg_GDS_Type == 3 then
        call GDSModifier3()
    endif
    if udg_GDS_Type == 4 then
        call GDSModifier4()
    endif
    if udg_GDS_Type == 5 then
        call GDSModifier5()
    endif
    if udg_GDS_Type == 6 then
        call GDSModifier6()
    endif
    if udg_GDS_Type == 7 then
        call GDSModifier7()
    endif
    if udg_GDS_Type == 8 then
        call GDSModifier8()
    endif
    if udg_GDS_Type == 9 then
        call GDSModifier9()
    endif
endfunction

function GDSGeneral takes nothing returns nothing
    //if IsUnitType(udg_GDS_Target , UNIT_TYPE_HERO) then
        //set udg_GDS_DurMul = udg_GDS_DurMul * 0.80
    //endif    

endfunction

function Trig_GDS_Main_Modifier_Actions takes nothing returns nothing
    local real storeDur = udg_GDS_Duration

    // Declare your modifying conditions here
    
    set udg_GDS_DurAdd = 0
    set udg_GDS_DurMul = 1
    set udg_GDS_DurMin = 0

    call GDSChooseMod()
    call GDSGeneral()

    set udg_GDS_Duration = (udg_GDS_Duration + udg_GDS_DurAdd)*udg_GDS_DurMul

    if udg_GDS_Duration < udg_GDS_DurMin then
        set udg_GDS_Duration = udg_GDS_DurMin
    endif

    // Run Main after your conditions have been checked
   
    call TriggerExecute( gg_trg_GDS_Main )

    // Restore duration to old duration (for unit group loops) and reset MinDuration
    //call BJDebugMsg(R2S(udg_GDS_Duration))
    //call BJDebugMsg(GetUnitName(udg_GDS_Target))
    set udg_GDS_Duration = storeDur
endfunction

//===========================================================================
function InitTrig_GDS_Main_Modifier takes nothing returns nothing
    set gg_trg_GDS_Main_Modifier = CreateTrigger(  )
    call TriggerAddAction( gg_trg_GDS_Main_Modifier, function Trig_GDS_Main_Modifier_Actions )
endfunction

