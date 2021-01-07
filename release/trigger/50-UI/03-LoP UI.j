library LoPUI requires UILib, UpperButtonBarView, WidescreenUI 
/*
    Library with UI utilities for Titan Land LoP.

    // Useful globals/functions:
        public boolean altZEnabled = true
        function IsFullScreen takes nothing returns boolean
        function FullScreen takes boolean enable, integer cmdBtnAlpha returns nothing
*/

globals
    public framehandle ConsoleUIBackdropDummy  // A dummy frame that replaces the normal ConsoleUIBackdrop
    public boolean altZEnabled = true  // used to check whether the Alt+Z hotkey is enabled (may be disabled in Terrain Editor, for example)
    
    private framehandle array commandButtons
endglobals


/*////////////////
    Public functions
*/////////////////

// Checks whether the game is in full screen mode.
function IsFullScreen takes nothing returns boolean
    return not BlzFrameIsVisible(ConsoleUIBackdropDummy)
endfunction

// Sets the game to full screen mode, using 'cmdBtnAlpha' as the transparency for the command card buttons.
function FullScreen takes boolean enable, integer cmdBtnAlpha returns nothing
    local integer i = 0
    
    if IsFullScreen() != enable then

        call BlzHideOriginFrames(enable)
        call BlzEnableUIAutoPosition(not enable)
        call BlzFrameSetVisible(ConsoleUIBackdropDummy, not enable)
        call BlzFrameSetVisible(UpperButtonBar.rightFrame, not enable)
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

/*////////////////
    Private functions
*/////////////////

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