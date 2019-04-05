library LoPInit requires ConstTable

public struct Globals

    private static key region_table_impl
    static method operator regionTable takes nothing returns ConstTable
        return region_table_impl
    endmethod

endstruct
// This function is called in Init Main
function InitPlayerCircles takes nothing returns nothing
    local region tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Blue)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(1)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Teal)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(2)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Purple)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(3)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Yellow)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(4)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Orange)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(5)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Green)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(6)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Pink)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(7)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Gray)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(8)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Light_Blue)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(9)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Dark_Green)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(10)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Brown)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(11)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Maroon)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(12)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Navy)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(13)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Turquoise)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(14)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Violet)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(15)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Wheat)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(16)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Peach)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(17)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Mint)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(18)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Lavender)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(19)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Coal)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(20)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Snow)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(21)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Emerald)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(22)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    set tempRegion = CreateRegion()
    call RegionAddRect( tempRegion , gg_rct_GiveTo_Peanut)
    set Globals.regionTable.player[GetHandleId(tempRegion)] =  Player(23)
    call TriggerRegisterEnterRegion( gg_trg_System_Titan_GiveUnit, tempRegion, null)
    // =========
    // End
    // =========
    set tempRegion = null
endfunction

endlibrary