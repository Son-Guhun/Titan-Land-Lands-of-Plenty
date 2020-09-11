library PreloadDecoBuilders requires LoPDecoBuilders, DecoBuilderCount, LoPWarn, LoPCleanUpRemoval

private function CreateDecos takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local integer i
    
    call LoPDecoBuilders_CreateMissing(udg_GAME_MASTER, 0., 0., g, LoP_DecoBuilders.SpecialDecoFirstIndex, LoP_DecoBuilders.DecoLastIndex, false)
    call LoPDecoBuilders_CreateMissing(udg_GAME_MASTER, 0., 0., g, LoP_DecoBuilders.SpecialDecoLastIndex, LoP_DecoBuilders.ReforgedDecoLastIndex, true)
    
    set i = BlzGroupGetSize(g)
    loop
        //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
        
        call LoP_RemoveUnit(u)
    endloop
    
    call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, "Map Initialization was finished! Welcome to the Lands of Plenty!
---------
To get a race selector: |cffffff00-start|r
To get deco builders: |cffffff00-decos|r
To select unit/terrain/tree modification deco: |cffffff00-seln special|r")
    
    call DestroyTimer(GetExpiredTimer())
    call DestroyGroup(g)
    set u = null
    set g = null
endfunction

// Recommended delay above 1 second, so players can see any warning messages before the system is initialized.
public function Initialize takes real delay returns nothing
    call TimerStart(CreateTimer(), delay, false, function CreateDecos)
endfunction

endlibrary

