library WidescreenUI
/*
    Credits:
    - Kazeon: UIUtils
        The logic behind DPI calculations is based on UIUtils.
        https://www.hiveworkshop.com/threads/ui-utils-v1-05.320005/
   
    - Tasyen: for UI Tutorials and discovering that ConsoleUIBackdrop allows frames to go out of the 4:3 view
        This library would not be possible without Tasyen's efforts. Enough said.


    Problem:
        - Frames can normally only stay within the 4:3 bounds at the center of the screen.
     
    Solution:
        - Depending on the Frames parent, it can actually go outside those bounds (discovered by Tasyen).
        - One such parent is ConsoleUIBackdrop.

    How to use this library:
        - Any frames that go outside the 4:3 screen must be children/grandchildren of UIView.ConsoleUIBackdrop.
   
        - Attach your frames to UIView.LEFT_BORDER and UIView.RIGHT_BORDER and they will automatically reposition when resolution changes.
   
        - Do not use UIView.LEFT_BORDER, UIView.RIGHT_BORDER as parents unless you know what you're doing.
   
        - This library is initialized at map start (0 seconds). Any code that uses it to create frames should also do that.
   
        - Useful variables:
            - UIView.minX => minimum X coordinate for the local user's screen.
            - UIView.maxX => maximum X coordinate for the local user's screen.
            - UIView.minY => 0.0
            - UIView.maxY => 0.6
 
 
/////////////// Detailed documentation (mostly copied from UI Utils)///////////

struct UIView
    1. Static Members
    • Values might be async between clients
 
        - Maximum x coordinate for the user's screen.
            | readonly static real maxX
       
        - Minimum x coordinate for the user's screen.
            | readonly static real minX
       
        - Screen width in pixels.
            | readonly static integer ResolutionWidth
       
        - Screen height in pixels.
            | readonly static integer ResolutionHeight
       
        - Frames
            | readonly static framehandle ConsoleUIBackdrop
       
            - The first child of ConsoleUIBackdrop.
                | readonly static framehandle LEFT_BORDER
           
            - The second child of ConsoleUIBackdrop.
                | readonly static framehandle RIGHT_BORDER
     
    2. Static methods
    • Values might be async between clients
 
        - Convert pixel unit to DPI and vice versa
            • Usage: [value]*UIUtils.PXTODPI
                     [value]*UIUtils.DPITOPX
                | static method operator PXTODPI takes nothing returns real
                | static method operator DPITOPX takes nothing returns real
           
        - Width of the 4:3 bound
            | static method operator width4by3 takes nothing returns real

        - Convert from pixel to screen x/y coordinate (in DPI unit)
            | static method getScreenPosX takes real x returns real
            | static method getScreenPosY takes real y returns real
                   
*/
//////////////////////////////// Source Code /////////////////////////////////////////////

private keyword UIViewInit

struct UIView extends array
    // Credits to Kazeon for UIUtils library, where this code was taken from.
    // https://www.hiveworkshop.com/threads/ui-utils-v1-05.320005/

    readonly static integer ResolutionWidth = 1920
    readonly static integer ResolutionHeight = 1080
    readonly static real maxX = 0.933
    readonly static real minX = -0.133
 
    readonly static framehandle ConsoleUIBackdrop
    readonly static framehandle LEFT_BORDER = null
    readonly static framehandle RIGHT_BORDER
 
    static constant method operator minY takes nothing returns real
        return 0.0
    endmethod
 
    static constant method operator maxY takes nothing returns real
        return 0.6
    endmethod
 
    static method operator PXTODPI takes nothing returns real
        return maxY/ResolutionHeight
    endmethod
 
    static method operator DPITOPX takes nothing returns real
        return ResolutionHeight/maxY
    endmethod
 
    static method operator width4by3 takes nothing returns real
        return (ResolutionWidth-ResolutionHeight/600.*800.)/2.
    endmethod
 
    static method getScreenPosX takes integer x returns real
        return (-UIView.width4by3+x)*UIView.PXTODPI
    endmethod
 
    static method getScreenPosY takes integer y returns real
        return y*UIView.PXTODPI
    endmethod
 
    static method onTimer takes nothing returns nothing
        local integer w = BlzGetLocalClientWidth()
        local integer h = BlzGetLocalClientHeight()
   
        if LEFT_BORDER == null then
            //! runtextmacro UIViewInitMacro("GetExpiredTimer()")
       
            // This is here just for the author of the system, because he was too lazy to change how his map worked.
            //! runtextmacro optional LoPUILibLoadTOCFiles()
        endif
 
        if ResolutionWidth != w or ResolutionHeight != h then
            set ResolutionWidth = w
            set ResolutionHeight = h
       
            set minX = getScreenPosX(0)
            set maxX = getScreenPosX(ResolutionWidth)
            call BlzFrameSetAbsPoint(LEFT_BORDER, FRAMEPOINT_TOPLEFT, minX, 0.6)
            call BlzFrameSetAbsPoint(RIGHT_BORDER, FRAMEPOINT_TOPRIGHT, maxX, 0.6)
            call BlzFrameSetSize(LEFT_BORDER, 0.001, 0.6)
            call BlzFrameSetSize(RIGHT_BORDER, 0.001, 0.6)
        endif
    endmethod
 
    implement UIViewInit
   
endstruct

private module UIViewInit
    //! textmacro UIViewInitMacro takes timer
        set ConsoleUIBackdrop = BlzGetFrameByName("ConsoleUIBackdrop", 0)
        set LEFT_BORDER = BlzCreateFrameByType("FRAME", "LeftBorderFrame", ConsoleUIBackdrop, "", 0)
        set RIGHT_BORDER = BlzCreateFrameByType("FRAME", "RightBorderFrame", ConsoleUIBackdrop, "", 0)
   
        call TimerStart($timer$, 0.5, true, function thistype.onTimer)
        set ResolutionWidth = 0
        set ResolutionHeight = 0
    //! endtextmacro

    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function thistype.onTimer)
    endmethod
endmodule





endlibrary