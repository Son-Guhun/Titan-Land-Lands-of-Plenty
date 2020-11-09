library LoPUI requires UILib, UpperButtonBarView, WidescreenUI

globals
    public framehandle ConsoleUIBackdropDummy
    private framehandle array commandButtons
    public boolean altZEnabled = true
endglobals

function IsFullScreen takes nothing returns boolean
    return not BlzFrameIsVisible(ConsoleUIBackdropDummy)
endfunction

function FullScreen takes boolean enable, integer cmdBtnAlpha returns nothing
    local integer i = 0
    
    if IsFullScreen() != enable then

        call BlzHideOriginFrames(enable)
        call BlzEnableUIAutoPosition(not enable)
        call BlzFrameSetVisible(ConsoleUIBackdropDummy, not enable)
        call BlzFrameSetVisible(UpperButtonBar.rightFrame, not enable)
        call BlzFrameSetVisible(UpperButtonBar.resourceBar, false)
    endif

    if not enable then
        set cmdBtnAlpha = 255
    endif
    loop
    exitwhen i == 12
        call BlzFrameSetAlpha(commandButtons[i], cmdBtnAlpha)
        set i = i + 1
    endloop
endfunction

private function onStart takes nothing returns nothing
    local integer i = 0

    set ConsoleUIBackdropDummy = BlzCreateFrame("ConsoleUIBackdrop", UIView.ConsoleUIBackdrop, 0, 1)
    call BlzFrameSetTexture(UIView.ConsoleUIBackdrop, "ReplaceableTextures\\CommandButtons\\PAS__EmptyDummy.tga", 0, true)
    loop
    exitwhen i == 12
        set commandButtons[i] = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, i)
        set i = i + 1
    endloop 
    
    call DestroyTimer(GetExpiredTimer())
endfunction

private module Init
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function onStart)
    endmethod
endmodule
private struct InitStruct extends array
    implement Init
endstruct

endlibrary