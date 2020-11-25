library UnitVisualModsUpgrade requires UnitVisualValues
/*

=========
 Description
=========

    Implements the handling of unit upgrades (when a unit upgrades to another type) for the UnitVisualsSetters
library struct defined in UnitVisualMods.

    This code is necessary because, when a unit upgrades, it loses it's flying height. Therefore, the
previous flying height must be stored so that it can be restored. This storage happens whenever one
of the flying height setter functions is called.

    Restoration is perfomed by the UpgradeHandler handler function, which is defined in this library
and implemented in UnitVisualsSetters.

    This library can be configured to automatically respond to unit upgrade events. If you choose to
not use this, then you must call UnitVisualsSetters.UpgradeHandler() yourself for any unit that upgrades.

=========
 Documentation
=========

    TODO
    nothing UpgradeHandler(unit u)

*/

//==================================================================================================
//                                       Configuration
//==================================================================================================

globals

    // If this is true, then a trigger is created which automatically calls the upgrade handling
    // function whenever a 'Unit Finishes Upgrade' or 'Unit Cancels Upgrade' event is fired.
    constant boolean AUTOMATIC_ON_UPGRADE = false
endglobals

//==================================================================================================
//                                        Source Code
//==================================================================================================

globals
    constant key SAVED_FLY_HEIGHT  // Used to save flying height for units (to keep height after upgrading)
endglobals

// Cannot store fly height in the "begins upgrade" event, as it is already lost by then.
public module StorageStructModule

    static if LIBRARY_HashtableWrapper and UnitVisualValues_INIT_HASHTABLE then
        method operator tab takes nothing returns UnitVisualValues_data_Child
            return this
        endmethod
    else
        method operator tab takes nothing returns Table
            return this
        endmethod
    endif
    

    method operator height takes nothing returns real
        return .tab.real[-SAVED_FLY_HEIGHT]
    endmethod
    
    method operator height= takes real value returns nothing
        set .tab.real[-SAVED_FLY_HEIGHT] = value
    endmethod
    
    method clearHeight takes nothing returns nothing
        call .tab.real.remove(-SAVED_FLY_HEIGHT)
    endmethod
    
    method hasHeight takes nothing returns boolean
        return .tab.real.has(-SAVED_FLY_HEIGHT)
    endmethod

endmodule

struct SaveFlyHeight extends array
    implement StorageStructModule
endstruct

// When a unit cancels of finishes an upgrade, reapply its Visual modifications.
public module Module

    static method UpgradeHandler takes unit trigU returns nothing
            local SaveFlyHeight unitData = GetHandleId(trigU)
            local real height
            //! runtextmacro ASSERT("trigU != null")
            
            
            if unitData.hasHeight() and unitData.height > UnitVisuals.MIN_FLY_HEIGHT then
                set height = unitData.height
            
                call UnitVisualsSetters.CopyValues(trigU, trigU)

                call UnitVisualsSetters.FlyHeight(trigU, height)
            else
                call UnitVisualsSetters.CopyValues(trigU, trigU)
            endif
            
            set trigU = null
    endmethod


    static if AUTOMATIC_ON_UPGRADE then
        private static method onUpgradeHandler takes nothing returns nothing
            call GUMSOnUpgradeHandler(GetTriggerUnit())
        endmethod
    


        private static method onInit takes nothing returns nothing
            local trigger fixUpgrades = CreateTrigger()
            
            call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_CANCEL )
            call TriggerRegisterAnyUnitEventBJ( fixUpgrades, EVENT_PLAYER_UNIT_UPGRADE_FINISH )
            call TriggerAddAction( fixUpgrades, function thistype.onUpgradeHandler )
        endmethod
    endif
    
endmodule




endlibrary