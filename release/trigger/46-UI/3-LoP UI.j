library LoPUI initializer Init requires UpperButtonBarView

globals
    private framehandle ConsoleUIBackdrop
    private framehandle array commandButtons
    public boolean altZEnabled = true
endglobals

function IsFullScreen takes nothing returns boolean
    return not BlzFrameIsVisible(ConsoleUIBackdrop)
endfunction

function FullScreen takes boolean enable, integer cmdBtnAlpha returns nothing
    local integer i = 0
    
    if IsFullScreen() != enable then

        call BlzHideOriginFrames(enable)
        call BlzEnableUIAutoPosition(not enable)
        call BlzFrameSetVisible(ConsoleUIBackdrop, not enable)
        call BlzFrameSetVisible(UpperButtonBar.leftFrame, not enable)
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

private function Init takes nothing returns nothing
    local integer i = 0

    set ConsoleUIBackdrop = BlzGetFrameByName("ConsoleUIBackdrop", 0)
    loop
    exitwhen i == 12
        set commandButtons[i] = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, i)
        set i = i + 1
    endloop
endfunction

endlibrary