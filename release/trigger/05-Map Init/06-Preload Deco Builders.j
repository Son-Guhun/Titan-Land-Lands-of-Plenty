library PreloadDecoBuilders requires LoPDecoBuilders, DecoBuilderCount, LoPWarn, LoPCleanUpRemoval, PreloadDecoBuildersView, LoPCommands

globals
    public constant boolean ENABLE = true
    
    private constant integer STEP = 10
    private integer current = 0
    private boolean reforged = false
endglobals

private struct G extends array

    static method getReforgedCurrent takes integer current returns integer
        return current + LoP_DecoBuilders.DecoLastIndex - LoP_DecoBuilders.SpecialDecoLastIndex
    endmethod

    static method operator finalTotal takes nothing returns integer
        return LoP_DecoBuilders.ReforgedDecoLastIndex + LoP_DecoBuilders.DecoLastIndex - LoP_DecoBuilders.SpecialDecoLastIndex
    endmethod

endstruct

private function CreateDecos takes nothing returns nothing
    local group g = CreateGroup()
    local unit u
    local integer i
    local integer end
    
    if current == 0 then
        call BlzFrameSetVisible(PreloadDecoBuildersView_loadBar, true)
        call BlzFrameSetVisible(PreloadDecoBuildersView_textBox, true)
        call FullScreen(true, 0)
        set LoPUI_altZEnabled = false
        set LoP_Command.disabled = true
    endif
    
    if not reforged then
        set end = IMinBJ(LoP_DecoBuilders.DecoLastIndex, current+STEP)
        call LoPDecoBuilders_CreateMissing(udg_GAME_MASTER, 0., 0., g, current, end, false)
        call BlzFrameSetText(PreloadDecoBuildersView_loadBarText, "Preloading Deco Builders: " + I2S(end) + " / " + I2S(G.finalTotal))
        call BlzFrameSetValue(PreloadDecoBuildersView_loadBar, 100.*end/G.finalTotal)
    else
        set end = IMinBJ(LoP_DecoBuilders.ReforgedDecoLastIndex, current+STEP)
        call LoPDecoBuilders_CreateMissing(udg_GAME_MASTER, 0., 0., g, current, end, true)
        call BlzFrameSetText(PreloadDecoBuildersView_loadBarText, "Preloading Deco Builders: " + I2S(G.getReforgedCurrent(end)) + " / " + I2S(G.finalTotal))
        call BlzFrameSetValue(PreloadDecoBuildersView_loadBar, 100.*G.getReforgedCurrent(end)/G.finalTotal)
    endif
    
    set i = BlzGroupGetSize(g)
    loop
        //! runtextmacro ForUnitInGroupCountedReverse("u", "i", "g")
        
        call LoP_RemoveUnit(u)
    endloop
    
    set current = end+1
    set u = null
    call DestroyGroup(g)
    set g = null
    if not reforged then
        if end == LoP_DecoBuilders.DecoLastIndex then
            set current = LoP_DecoBuilders.SpecialDecoLastIndex
            set reforged = true
        endif
    elseif end == LoP_DecoBuilders.ReforgedDecoLastIndex then
        call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, "Map Initialization was finished! Welcome to the Lands of Plenty!
    ---------
    To get a race selector: |cffffff00-start|r
    To get deco builders: |cffffff00-decos|r
    To select unit/terrain/tree modification deco: |cffffff00-seln special|r")
        
        call BlzFrameSetVisible(PreloadDecoBuildersView_loadBar, false)
        call BlzFrameSetVisible(PreloadDecoBuildersView_textBox, false)
        call FullScreen(false, 0)
        set LoPUI_altZEnabled = true
        set LoP_Command.disabled = false
        
        call DestroyTimer(GetExpiredTimer())
    endif
        
    
endfunction

// Recommended delay above 1 second, so players can see any warning messages before the system is initialized.
public function Initialize takes real delay returns nothing
    static if ENABLE then
        call TimerStart(CreateTimer(), delay, true, function CreateDecos)
    else
        call RMaxBJ(0, delay)
    endif
endfunction

endlibrary

