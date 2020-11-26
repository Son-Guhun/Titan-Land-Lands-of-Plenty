library Screen requires OSKeyLib, Table, PlayerUtils, GMUI, LoPUI
/* ========================================
// Documentation
// ========================================

struct Screen:
    A Screen is basically an UI element with multiple frames. Each screen has 3 container frames, and
more frames can be added to it as children of these container frames. Children that need to be referenced
can be stored with a string as the key using the [] operator.

    Fields:
        framehandle main -> a frame that is of ConsoleUIBackdrop, which is supposed to have frame children that go behind simpleframes and can go out of the 4:3 center.
        framehandle simpleContainer -> a simpleframe which is supposed to have children that are simpleframes.
        framehandle topContainer -> a frame which is supposed to have children that are frames and go on top of simpleframes.
        
    Methods:
        method show takes boolean show returns nothing -> shows/hides the main/simpleContainer/topContainer frames.
        
        method operator [] takes string frameName returns framehandle
        method operator []= takes string frameName, framehandle frame returns nothing
        
        Constructors:
            static method create takes nothing returns thistype -> create with only a main frame.
            static method createWithSimple takes nothing returns thistype -> create with main and simpleContainer frames.
            static method createWithSimpleAndTop takes nothing returns thistype -> create with all 3 container frames.



struct ScreenController:
    A ScreenController is generally used to control the behaviour of a screen.
    
    Fields:
        Screen screen -> the screen being controlled
        boolexpr onEnable -> callback for when the enable method is called. Uses FuncInterface and takes (ScreenController, player, boolean)
        readonly boolexpr buttonHandler -> callback for OSKey presses
    
    Methods:
        method enable takes player p, boolean enable returns nothing -> Shows/hides the controlled Screen and evaluates the onEnable callback.
        method isEnabled takes player p returns boolean
        
        Constructors:
            static method create takes Screen screen, boolexpr buttonHandler returns thistype
            
    Macros:
        // Used at the top of an onEnable callback function to receive the arguments as local vars. Parameters are the names of the local variables to be created.
        ScreenControllerOnEnableArguments takes controller, player, enable
     
*/
// ========================================
// Examples
// ========================================
//! novjass

// Example of a boolexpr that could be set as the onEnable callback of a ScreenController.
function onEnableCallback takes nothing returns boolean
    //! runtextmacro ScreenControllerOnEnableArguments("controller", "whichPlayer", "enable")

    if enable then
        call BJDebugMsg(GetPlayerName(whichPlayer))
        call BJDebugMsg(controller.screen)
    else
        call BJDebugMsg("Controller was disabled.")
    endif
    
    return false
endfunction
//! endnovjass
// ========================================
// Source Code
// ========================================

struct Screen extends array

    implement ExtendsTable
    
    //! runtextmacro HashStruct_NewReadonlyHandleFieldIndexed("main", "framehandle", "-1")
    //! runtextmacro HashStruct_NewReadonlyHandleFieldIndexed("simpleContainer", "framehandle", "-2")
    //! runtextmacro HashStruct_NewReadonlyHandleFieldIndexed("topContainer", "framehandle", "-3")
    
    private static method fromFrame takes framehandle mainFrame returns thistype
        local thistype this = Table.create()
        
        set .main = mainFrame
        return this
    endmethod

    static method create takes nothing returns thistype
        return fromFrame(BlzCreateFrameByType("FRAME", "ScreenFrame", UIView.ConsoleUIBackdrop,"", 0)) 
    endmethod
    
    static method createWithSimple takes nothing returns thistype
        local thistype this = .create()
        set .simpleContainer = BlzCreateFrameByType("SIMPLEFRAME", "SimpleScreenFrame", UIView.ConsoleUIBackdrop,"", 0)
        return this
    endmethod
    
    static method createWithSimpleAndTop takes nothing returns thistype
        local thistype this = .createWithSimple()
        set .topContainer = BlzCreateFrameByType("FRAME", "TopScreenFrame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        return this
    endmethod
    
    method show takes boolean show returns nothing
        call BlzFrameSetVisible(.topContainer, show)
        call BlzFrameSetVisible(.simpleContainer, show)
        call BlzFrameSetVisible(.main, show)
    endmethod
    
    method operator [] takes string frameName returns framehandle
        return .tab.framehandle[StringHash(frameName)]
    endmethod
    
    method operator []= takes string frameName, framehandle frame returns nothing
        set .tab.framehandle[StringHash(frameName)] = frame
    endmethod
        

endstruct



struct ScreenController extends array

    implement ExtendsTable

    //! runtextmacro HashStruct_NewStructField("screen", "Screen")
    //! runtextmacro HashStruct_NewReadonlyHandleField("buttonHandler", "boolexpr")
    
    //! runtextmacro HashStruct_NewHandleField("onEnable", "boolexpr")
    
    //! textmacro ScreenControllerOnEnableArguments takes controller, player, enable
        local ScreenController $controller$ = FuncInterface.stack[0]
        local player $player$ = FuncInterface.stack.player[1]
        local boolean $enable$ = FuncInterface.stack.boolean[2]
    //! endtextmacro
    

    static method create takes Screen screen, boolexpr buttonHandler returns thistype
        local thistype this = Table.create()
        
        set .screen = screen
        if buttonHandler != null then
            set .buttonHandler = buttonHandler
            call OSKeys.addListener(buttonHandler)
        endif
        return this
    endmethod
    
    method enable takes player p, boolean enable returns nothing
        local User pId = User[p]
        
        if .tab.boolean[pId] != enable then
            set .tab.boolean[pId] = enable
            if User.fromLocal() == pId then
                call .screen.show(enable)
            endif
            //! runtextmacro FuncInterfaceIntegerPlayerBoolean_evaluate(".onEnable", "this", "p", "enable")
        endif
    endmethod
    
    method isEnabled takes player p returns boolean
        return .tab.boolean[User[p]]
    endmethod

endstruct



endlibrary