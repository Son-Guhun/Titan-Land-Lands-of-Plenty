library UnitVisualModsUpgrade requires UnitVisualValues

globals
    constant boolean AUTOMATIC_ON_UPGRADE = false
    constant key SAVED_FLY_HEIGHT  // Used to save flying height for units (to keep height after upgrading)
endglobals

// Cannot store fly height in the "begins upgrade" event, as it is already lost by then.
public module StorageStructModule

    method operator tab takes nothing returns UnitVisualValues_data_Child
        return this
    endmethod

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