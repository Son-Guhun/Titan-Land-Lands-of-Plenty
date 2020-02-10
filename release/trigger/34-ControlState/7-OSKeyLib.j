library OSKeyLib requires PlayerUtils, Timeline
/*
*   v1.0.0 - by Guhun
*
*
* This is a library that facilitates usage of the oskey API added in patch 1.31.
*
*
* You can register a listener (event) that will fire for every keypress of any key that was registered
* in the system. You can also determined whether any key is currently up or down, and you can also get
* the time that a key has been pressed/released for.
*
************
* Configuration
************
*/
// No configuration available.
//! novjass
'                                                                                                  '
'                                              API                                                 '
$inline$ -> "this means a function inlines, so only natives are actually called"

/* 
    Structs
*/

struct MetaKeys extends array
    static constant integer NONE  = 0
    static constant integer SHIFT = 1
    static constant integer CTRL  = 2
    static constant integer ALT   = 4
endstruct

struct OSKeys extends array
    
    // This method must be called for OSKeys that you will use. It should be called at initialization.
    method register takes nothing returns nothing
    
    // Check whether a player is pressing a key.
    $inline$ method isPressedId takes integer pId returns boolean
    $inline$ method isPressedPlayer takes player whichPlayer returns boolean
    
    // Check whether the local player (GetLocalPlayer) is pressing a key.
    $inline$ method isPressed takes nothing returns boolean
    
    // Returns the amount of time since a key was pressed (isPressed -> true) or released (isPressed -> false).
    // If the key was never pressed, returns the amount of time since it was registered.
    $inline$ method getDuration takes nothing returns real
    
    // Adds a listener, which will evalute a boolexpr whenever any key is pressed. The boolexpr should return true.
    /*
    You can use these natives in listeners:
    GetTriggerPlayer()
    BlzGetTriggerPlayerKey()
    BlzGetTriggerPlayerMetaKey()
    BlzGetTriggerPlayerIsKeyDown()
    
    NOTE: listeners will be executed in the order they were added
    */
    $inline$ static method addListener takes boolexpr expr returns triggercondition
    
    // Removes a previously added listener.
    $inline$ static method removeListener takes triggercondition listener returns nothing
    
    readonly oskeytype handle
    readonly boolean isRegistered
endstruct

/*
    Examples
*/
OSKeys.BACKSPACE.register()
OSKeys.CONTROL.isPressed()

// This is for number 2 on the keyboard, not the numpad
OSKeys.KEY2.getDuration()

// This is for number 4 on the numpad
OSKeys.NUMPAD4.isPressedPlayer(Player(2))

OSKeys.A.handle
OSKeys.ESCAPE.isRegistered

// This will fire whenever any player presses/releases any key while holding any meta key.
function onKeyPressFunc takes nothing returns boolean
    
    // If we registered CONROL, we can check if it's pressed instead of using BlzGetTriggerPlayerMetaKey()
    if GetTriggerPlayer() == Player(0) and OSKeys.CONTROL.isPressedId(0) then
        // Do something
    endif

    return true // important to return true here
endfunction

triggercondition listener

// Add a listener
set listener = OSKeys.addListener(Filter(function onKeyPressFunc))

// Remove listener when no longer needed
call OSKeys.removeListener(listener)

/*
    Constants
*/
OSKeys.BACKSPACE    OSKeys.TAB          OSKeys.CLEAR
OSKeys.RETURN       OSKeys.SHIFT        OSKeys.CONTROL
OSKeys.ALT          OSKeys.PAUSE        OSKeys.CAPSLOCK
OSKeys.KANA         OSKeys.HANGUL       OSKeys.JUNJA
OSKeys.FINAL        OSKeys.HANJA        OSKeys.KANJI
OSKeys.ESCAPE       OSKeys.CONVERT      OSKeys.NONCONVERT
OSKeys.ACCEPT       OSKeys.MODECHANGE   OSKeys.SPACE
OSKeys.PAGEUP       OSKeys.PAGEDOWN     OSKeys.END
OSKeys.HOME         OSKeys.LEFT         OSKeys.UP
OSKeys.RIGHT        OSKeys.DOWN         OSKeys.SELECT
OSKeys.PRINT        OSKeys.EXECUTE      OSKeys.PRINTSCREEN
OSKeys.INSERT       OSKeys.DELETE       OSKeys.HELP
OSKeys.KEY0         OSKeys.KEY1         OSKeys.KEY2
OSKeys.KEY3         OSKeys.KEY4         OSKeys.KEY5
OSKeys.KEY6         OSKeys.KEY7         OSKeys.KEY8
OSKeys.KEY9         OSKeys.A            OSKeys.B
OSKeys.C            OSKeys.D            OSKeys.E
OSKeys.F            OSKeys.G            OSKeys.H
OSKeys.I            OSKeys.J            OSKeys.K
OSKeys.L            OSKeys.M            OSKeys.N
OSKeys.O            OSKeys.P            OSKeys.Q
OSKeys.R            OSKeys.S            OSKeys.T
OSKeys.U            OSKeys.V            OSKeys.W
OSKeys.X            OSKeys.Y            OSKeys.Z
OSKeys.LMETA        OSKeys.RMETA        OSKeys.APPS
OSKeys.SLEEP        OSKeys.NUMPAD0      OSKeys.NUMPAD1
OSKeys.NUMPAD2      OSKeys.NUMPAD3      OSKeys.NUMPAD4
OSKeys.NUMPAD5      OSKeys.NUMPAD6      OSKeys.NUMPAD7
OSKeys.NUMPAD8      OSKeys.NUMPAD9      OSKeys.MULTIPLY
OSKeys.ADD          OSKeys.SEPARATOR    OSKeys.SUBTRACT
OSKeys.DECIMAL      OSKeys.DIVIDE       OSKeys.F1
OSKeys.F2           OSKeys.F3           OSKeys.F4
OSKeys.F5           OSKeys.F6           OSKeys.F7
OSKeys.F8           OSKeys.F9           OSKeys.F10
OSKeys.F11          OSKeys.F12          OSKeys.F13
OSKeys.F14          OSKeys.F15          OSKeys.F16
OSKeys.F17          OSKeys.F18          OSKeys.F19
OSKeys.F20          OSKeys.F21          OSKeys.F22
OSKeys.F23          OSKeys.F24          OSKeys.NUMLOCK
OSKeys.SCROLLLOCK           OSKeys.OEM_NEC_EQUAL    OSKeys.OEM_FJ_JISHO
OSKeys.OEM_FJ_MASSHOU       OSKeys.OEM_FJ_TOUROKU   OSKeys.OEM_FJ_LOYA
OSKeys.OEM_FJ_ROYA          OSKeys.LSHIFT           OSKeys.RSHIFT
OSKeys.LCONTROL             OSKeys.RCONTROL         OSKeys.LALT
OSKeys.RALT                 OSKeys.BROWSER_BACK     OSKeys.BROWSER_FORWARD
OSKeys.BROWSER_REFRESH      OSKeys.BROWSER_STOP     OSKeys.BROWSER_SEARCH
OSKeys.BROWSER_FAVORITES    OSKeys.BROWSER_HOME     OSKeys.OEM_CLEAR
OSKeys.VOLUME_MUTE          OSKeys.VOLUME_DOWN      OSKeys.VOLUME_UP
OSKeys.MEDIA_NEXT_TRACK     OSKeys.MEDIA_PREV_TRACK OSKeys.MEDIA_STOP
OSKeys.MEDIA_PLAY_PAUSE     OSKeys.LAUNCH_MAIL      OSKeys.LAUNCH_MEDIA_SELECT
OSKeys.LAUNCH_APP1          OSKeys.LAUNCH_APP2      OSKeys.OEM_1
OSKeys.OEM_PLUS             OSKeys.OEM_COMMA        OSKeys.OEM_MINUS
OSKeys.OEM_PERIOD           OSKeys.OEM_2            OSKeys.OEM_3
OSKeys.OEM_4                OSKeys.OEM_5            OSKeys.OEM_6
OSKeys.OEM_7                OSKeys.OEM_8            OSKeys.OEM_AX
OSKeys.OEM_102              OSKeys.ICO_HELP         OSKeys.ICO_00
OSKeys.PROCESSKEY           OSKeys.ICO_CLEAR        OSKeys.PACKET
OSKeys.OEM_RESET            OSKeys.OEM_JUMP         OSKeys.OEM_PA1
OSKeys.OEM_PA2              OSKeys.OEM_PA3          OSKeys.OEM_WSCTRL
OSKeys.OEM_CUSEL            OSKeys.OEM_ATTN         OSKeys.OEM_FINISH
OSKeys.OEM_COPY             OSKeys.OEM_AUTO         OSKeys.OEM_ENLW
OSKeys.OEM_BACKTAB          OSKeys.ATTN             OSKeys.CRSEL
OSKeys.EXSEL                OSKeys.EREOF            OSKeys.PLAY
OSKeys.ZOOM                 OSKeys.NONAME           OSKeys.PA1
    
endstruct
'                                                                                                  '
'                                         Source Code                                              '
//! endnovjass

struct MetaKeys extends array

    static constant method operator NONE takes nothing returns integer
        return 0
    endmethod

    static constant method operator SHIFT takes nothing returns integer
        return 1
    endmethod
    
    static constant method operator CTRL takes nothing returns integer
        return 2
    endmethod
    
    static constant method operator ALT takes nothing returns integer
        return 4
    endmethod

endstruct

private function RegisterKeyEvent takes trigger whichTrigger, player whichPlayer, oskeytype whichKey returns nothing
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.NONE, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.NONE, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.ALT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.ALT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL + MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.CTRL + MetaKeys.ALT, true)
    
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL + MetaKeys.ALT, false)
    call BlzTriggerRegisterPlayerKeyEvent(whichTrigger, whichPlayer, whichKey, MetaKeys.SHIFT + MetaKeys.CTRL + MetaKeys.ALT, true)
endfunction

private keyword Constants

struct OSKeys extends array
    private static boolean array g_isPressed[256][24]
    private static real array timestamp[256][24]
    readonly boolean isRegistered
    private static trigger eventResponder = null
    private static trigger executer = CreateTrigger()
    
    static method addListener takes boolexpr expr returns triggercondition
        return TriggerAddCondition(executer, expr)
    endmethod
    
    static method removeListener takes triggercondition listener returns nothing
        call TriggerRemoveCondition(executer, listener)
    endmethod

    method isPressedId takes integer playerId returns boolean
        return g_isPressed[this][playerId]
    endmethod
    
    method isPressedPlayer takes player whichPlayer returns boolean
        return .isPressedId(GetPlayerId(whichPlayer))
    endmethod
    
    method isPressed takes nothing returns boolean
        return .isPressedId(User.fromLocal().id)
    endmethod
    
    method getDuration takes nothing returns real
        return Timeline.game.elapsed - timestamp[this][User.fromLocal().id]
    endmethod
    
    method operator handle takes nothing returns oskeytype
        return ConvertOsKeyType(this)
    endmethod
    
    method register takes nothing returns nothing
        local User p
        if not isRegistered then
            set .isRegistered = true
            if .eventResponder != null then
                set p = 0
                loop
                    exitwhen p >= bj_MAX_PLAYERS
                    call RegisterKeyEvent(.eventResponder, p.handle, this.handle)
                    set timestamp[this][p.id] = Timeline.game.elapsed
                    set p = p + 1
                endloop
            endif
        endif
    endmethod
    
    private static method onKey takes nothing returns nothing
        local boolean pressed = BlzGetTriggerPlayerIsKeyDown()
        local integer key = GetHandleId(BlzGetTriggerPlayerKey())
        local integer pId = GetPlayerId(GetTriggerPlayer())
        
        set g_isPressed[key][pId] = pressed
        
        set timestamp[key][pId] = Timeline.game.elapsed
        
        call TriggerEvaluate(executer)
    endmethod
    
    private static method onStart takes nothing returns nothing
        local trigger trig = CreateTrigger()
        local User p
        local thistype key = 0
        
        set .eventResponder = trig
        
        loop
            exitwhen key == 256
            if key.isRegistered then
                set p = 0
                loop
                    exitwhen p >= bj_MAX_PLAYERS
                    call RegisterKeyEvent(trig, p.handle, key.handle)
                    set timestamp[key][p.id] = Timeline.game.elapsed
                    set p = p + 1
                endloop
            endif
            set key = key + 1
        endloop
        
        call TriggerAddAction(trig, function thistype.onKey)
        
        call PauseTimer(GetExpiredTimer())
        call DestroyTimer(GetExpiredTimer())

        set trig = null
    endmethod
    
    implement Constants
endstruct

//! textmacro OSKeyLib_Const takes NAME, value
    static constant method operator $NAME$ takes nothing returns thistype
        return $value$
    endmethod
//! endtextmacro
private module Constants
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function thistype.onStart)
    endmethod

    //! runtextmacro OSKeyLib_Const("BACKSPACE                     ","$08")
    //! runtextmacro OSKeyLib_Const("TAB                           ","$09")
    //! runtextmacro OSKeyLib_Const("CLEAR                         ","$0C")
    //! runtextmacro OSKeyLib_Const("RETURN                        ","$0D")
    //! runtextmacro OSKeyLib_Const("SHIFT                         ","$10")
    //! runtextmacro OSKeyLib_Const("CONTROL                       ","$11")
    //! runtextmacro OSKeyLib_Const("ALT                           ","$12")
    //! runtextmacro OSKeyLib_Const("PAUSE                         ","$13")
    //! runtextmacro OSKeyLib_Const("CAPSLOCK                      ","$14")
    //! runtextmacro OSKeyLib_Const("KANA                          ","$15")
    //! runtextmacro OSKeyLib_Const("HANGUL                        ","$15")
    //! runtextmacro OSKeyLib_Const("JUNJA                         ","$17")
    //! runtextmacro OSKeyLib_Const("FINAL                         ","$18")
    //! runtextmacro OSKeyLib_Const("HANJA                         ","$19")
    //! runtextmacro OSKeyLib_Const("KANJI                         ","$19")
    //! runtextmacro OSKeyLib_Const("ESCAPE                        ","$1B")
    //! runtextmacro OSKeyLib_Const("CONVERT                       ","$1C")
    //! runtextmacro OSKeyLib_Const("NONCONVERT                    ","$1D")
    //! runtextmacro OSKeyLib_Const("ACCEPT                        ","$1E")
    //! runtextmacro OSKeyLib_Const("MODECHANGE                    ","$1F")
    //! runtextmacro OSKeyLib_Const("SPACE                         ","$20")
    //! runtextmacro OSKeyLib_Const("PAGEUP                        ","$21")
    //! runtextmacro OSKeyLib_Const("PAGEDOWN                      ","$22")
    //! runtextmacro OSKeyLib_Const("END                           ","$23")
    //! runtextmacro OSKeyLib_Const("HOME                          ","$24")
    //! runtextmacro OSKeyLib_Const("LEFT                          ","$25")
    //! runtextmacro OSKeyLib_Const("UP                            ","$26")
    //! runtextmacro OSKeyLib_Const("RIGHT                         ","$27")
    //! runtextmacro OSKeyLib_Const("DOWN                          ","$28")
    //! runtextmacro OSKeyLib_Const("SELECT                        ","$29")
    //! runtextmacro OSKeyLib_Const("PRINT                         ","$2A")
    //! runtextmacro OSKeyLib_Const("EXECUTE                       ","$2B")
    //! runtextmacro OSKeyLib_Const("PRINTSCREEN                   ","$2C")
    //! runtextmacro OSKeyLib_Const("INSERT                        ","$2D")
    //! runtextmacro OSKeyLib_Const("DELETE                        ","$2E")
    //! runtextmacro OSKeyLib_Const("HELP                          ","$2F")
    //! runtextmacro OSKeyLib_Const("KEY0                          ","$30")
    //! runtextmacro OSKeyLib_Const("KEY1                          ","$31")
    //! runtextmacro OSKeyLib_Const("KEY2                          ","$32")
    //! runtextmacro OSKeyLib_Const("KEY3                          ","$33")
    //! runtextmacro OSKeyLib_Const("KEY4                          ","$34")
    //! runtextmacro OSKeyLib_Const("KEY5                          ","$35")
    //! runtextmacro OSKeyLib_Const("KEY6                          ","$36")
    //! runtextmacro OSKeyLib_Const("KEY7                          ","$37")
    //! runtextmacro OSKeyLib_Const("KEY8                          ","$38")
    //! runtextmacro OSKeyLib_Const("KEY9                          ","$39")
    //! runtextmacro OSKeyLib_Const("A                             ","$41")
    //! runtextmacro OSKeyLib_Const("B                             ","$42")
    //! runtextmacro OSKeyLib_Const("C                             ","$43")
    //! runtextmacro OSKeyLib_Const("D                             ","$44")
    //! runtextmacro OSKeyLib_Const("E                             ","$45")
    //! runtextmacro OSKeyLib_Const("F                             ","$46")
    //! runtextmacro OSKeyLib_Const("G                             ","$47")
    //! runtextmacro OSKeyLib_Const("H                             ","$48")
    //! runtextmacro OSKeyLib_Const("I                             ","$49")
    //! runtextmacro OSKeyLib_Const("J                             ","$4A")
    //! runtextmacro OSKeyLib_Const("K                             ","$4B")
    //! runtextmacro OSKeyLib_Const("L                             ","$4C")
    //! runtextmacro OSKeyLib_Const("M                             ","$4D")
    //! runtextmacro OSKeyLib_Const("N                             ","$4E")
    //! runtextmacro OSKeyLib_Const("O                             ","$4F")
    //! runtextmacro OSKeyLib_Const("P                             ","$50")
    //! runtextmacro OSKeyLib_Const("Q                             ","$51")
    //! runtextmacro OSKeyLib_Const("R                             ","$52")
    //! runtextmacro OSKeyLib_Const("S                             ","$53")
    //! runtextmacro OSKeyLib_Const("T                             ","$54")
    //! runtextmacro OSKeyLib_Const("U                             ","$55")
    //! runtextmacro OSKeyLib_Const("V                             ","$56")
    //! runtextmacro OSKeyLib_Const("W                             ","$57")
    //! runtextmacro OSKeyLib_Const("X                             ","$58")
    //! runtextmacro OSKeyLib_Const("Y                             ","$59")
    //! runtextmacro OSKeyLib_Const("Z                             ","$5A")
    //! runtextmacro OSKeyLib_Const("LMETA                         ","$5B")
    //! runtextmacro OSKeyLib_Const("RMETA                         ","$5C")
    //! runtextmacro OSKeyLib_Const("APPS                          ","$5D")
    //! runtextmacro OSKeyLib_Const("SLEEP                         ","$5F")
    //! runtextmacro OSKeyLib_Const("NUMPAD0                       ","$60")
    //! runtextmacro OSKeyLib_Const("NUMPAD1                       ","$61")
    //! runtextmacro OSKeyLib_Const("NUMPAD2                       ","$62")
    //! runtextmacro OSKeyLib_Const("NUMPAD3                       ","$63")
    //! runtextmacro OSKeyLib_Const("NUMPAD4                       ","$64")
    //! runtextmacro OSKeyLib_Const("NUMPAD5                       ","$65")
    //! runtextmacro OSKeyLib_Const("NUMPAD6                       ","$66")
    //! runtextmacro OSKeyLib_Const("NUMPAD7                       ","$67")
    //! runtextmacro OSKeyLib_Const("NUMPAD8                       ","$68")
    //! runtextmacro OSKeyLib_Const("NUMPAD9                       ","$69")
    //! runtextmacro OSKeyLib_Const("MULTIPLY                      ","$6A")
    //! runtextmacro OSKeyLib_Const("ADD                           ","$6B")
    //! runtextmacro OSKeyLib_Const("SEPARATOR                     ","$6C")
    //! runtextmacro OSKeyLib_Const("SUBTRACT                      ","$6D")
    //! runtextmacro OSKeyLib_Const("DECIMAL                       ","$6E")
    //! runtextmacro OSKeyLib_Const("DIVIDE                        ","$6F")
    //! runtextmacro OSKeyLib_Const("F1                            ","$70")
    //! runtextmacro OSKeyLib_Const("F2                            ","$71")
    //! runtextmacro OSKeyLib_Const("F3                            ","$72")
    //! runtextmacro OSKeyLib_Const("F4                            ","$73")
    //! runtextmacro OSKeyLib_Const("F5                            ","$74")
    //! runtextmacro OSKeyLib_Const("F6                            ","$75")
    //! runtextmacro OSKeyLib_Const("F7                            ","$76")
    //! runtextmacro OSKeyLib_Const("F8                            ","$77")
    //! runtextmacro OSKeyLib_Const("F9                            ","$78")
    //! runtextmacro OSKeyLib_Const("F10                           ","$79")
    //! runtextmacro OSKeyLib_Const("F11                           ","$7A")
    //! runtextmacro OSKeyLib_Const("F12                           ","$7B")
    //! runtextmacro OSKeyLib_Const("F13                           ","$7C")
    //! runtextmacro OSKeyLib_Const("F14                           ","$7D")
    //! runtextmacro OSKeyLib_Const("F15                           ","$7E")
    //! runtextmacro OSKeyLib_Const("F16                           ","$7F")
    //! runtextmacro OSKeyLib_Const("F17                           ","$80")
    //! runtextmacro OSKeyLib_Const("F18                           ","$81")
    //! runtextmacro OSKeyLib_Const("F19                           ","$82")
    //! runtextmacro OSKeyLib_Const("F20                           ","$83")
    //! runtextmacro OSKeyLib_Const("F21                           ","$84")
    //! runtextmacro OSKeyLib_Const("F22                           ","$85")
    //! runtextmacro OSKeyLib_Const("F23                           ","$86")
    //! runtextmacro OSKeyLib_Const("F24                           ","$87")
    //! runtextmacro OSKeyLib_Const("NUMLOCK                       ","$90")
    //! runtextmacro OSKeyLib_Const("SCROLLLOCK                    ","$91")
    //! runtextmacro OSKeyLib_Const("OEM_NEC_EQUAL                 ","$92")
    //! runtextmacro OSKeyLib_Const("OEM_FJ_JISHO                  ","$92")
    //! runtextmacro OSKeyLib_Const("OEM_FJ_MASSHOU                ","$93")
    //! runtextmacro OSKeyLib_Const("OEM_FJ_TOUROKU                ","$94")
    //! runtextmacro OSKeyLib_Const("OEM_FJ_LOYA                   ","$95")
    //! runtextmacro OSKeyLib_Const("OEM_FJ_ROYA                   ","$96")
    //! runtextmacro OSKeyLib_Const("LSHIFT                        ","$A0")
    //! runtextmacro OSKeyLib_Const("RSHIFT                        ","$A1")
    //! runtextmacro OSKeyLib_Const("LCONTROL                      ","$A2")
    //! runtextmacro OSKeyLib_Const("RCONTROL                      ","$A3")
    //! runtextmacro OSKeyLib_Const("LALT                          ","$A4")
    //! runtextmacro OSKeyLib_Const("RALT                          ","$A5")
    //! runtextmacro OSKeyLib_Const("BROWSER_BACK                  ","$A6")
    //! runtextmacro OSKeyLib_Const("BROWSER_FORWARD               ","$A7")
    //! runtextmacro OSKeyLib_Const("BROWSER_REFRESH               ","$A8")
    //! runtextmacro OSKeyLib_Const("BROWSER_STOP                  ","$A9")
    //! runtextmacro OSKeyLib_Const("BROWSER_SEARCH                ","$AA")
    //! runtextmacro OSKeyLib_Const("BROWSER_FAVORITES             ","$AB")
    //! runtextmacro OSKeyLib_Const("BROWSER_HOME                  ","$AC")
    //! runtextmacro OSKeyLib_Const("VOLUME_MUTE                   ","$AD")
    //! runtextmacro OSKeyLib_Const("VOLUME_DOWN                   ","$AE")
    //! runtextmacro OSKeyLib_Const("VOLUME_UP                     ","$AF")
    //! runtextmacro OSKeyLib_Const("MEDIA_NEXT_TRACK              ","$B0")
    //! runtextmacro OSKeyLib_Const("MEDIA_PREV_TRACK              ","$B1")
    //! runtextmacro OSKeyLib_Const("MEDIA_STOP                    ","$B2")
    //! runtextmacro OSKeyLib_Const("MEDIA_PLAY_PAUSE              ","$B3")
    //! runtextmacro OSKeyLib_Const("LAUNCH_MAIL                   ","$B4")
    //! runtextmacro OSKeyLib_Const("LAUNCH_MEDIA_SELECT           ","$B5")
    //! runtextmacro OSKeyLib_Const("LAUNCH_APP1                   ","$B6")
    //! runtextmacro OSKeyLib_Const("LAUNCH_APP2                   ","$B7")
    //! runtextmacro OSKeyLib_Const("OEM_1                         ","$BA")
    //! runtextmacro OSKeyLib_Const("OEM_PLUS                      ","$BB")
    //! runtextmacro OSKeyLib_Const("OEM_COMMA                     ","$BC")
    //! runtextmacro OSKeyLib_Const("OEM_MINUS                     ","$BD")
    //! runtextmacro OSKeyLib_Const("OEM_PERIOD                    ","$BE")
    //! runtextmacro OSKeyLib_Const("OEM_2                         ","$BF")
    //! runtextmacro OSKeyLib_Const("OEM_3                         ","$C0")
    //! runtextmacro OSKeyLib_Const("OEM_4                         ","$DB")
    //! runtextmacro OSKeyLib_Const("OEM_5                         ","$DC")
    //! runtextmacro OSKeyLib_Const("OEM_6                         ","$DD")
    //! runtextmacro OSKeyLib_Const("OEM_7                         ","$DE")
    //! runtextmacro OSKeyLib_Const("OEM_8                         ","$DF")
    //! runtextmacro OSKeyLib_Const("OEM_AX                        ","$E1")
    //! runtextmacro OSKeyLib_Const("OEM_102                       ","$E2")
    //! runtextmacro OSKeyLib_Const("ICO_HELP                      ","$E3")
    //! runtextmacro OSKeyLib_Const("ICO_00                        ","$E4")
    //! runtextmacro OSKeyLib_Const("PROCESSKEY                    ","$E5")
    //! runtextmacro OSKeyLib_Const("ICO_CLEAR                     ","$E6")
    //! runtextmacro OSKeyLib_Const("PACKET                        ","$E7")
    //! runtextmacro OSKeyLib_Const("OEM_RESET                     ","$E9")
    //! runtextmacro OSKeyLib_Const("OEM_JUMP                      ","$EA")
    //! runtextmacro OSKeyLib_Const("OEM_PA1                       ","$EB")
    //! runtextmacro OSKeyLib_Const("OEM_PA2                       ","$EC")
    //! runtextmacro OSKeyLib_Const("OEM_PA3                       ","$ED")
    //! runtextmacro OSKeyLib_Const("OEM_WSCTRL                    ","$EE")
    //! runtextmacro OSKeyLib_Const("OEM_CUSEL                     ","$EF")
    //! runtextmacro OSKeyLib_Const("OEM_ATTN                      ","$F0")
    //! runtextmacro OSKeyLib_Const("OEM_FINISH                    ","$F1")
    //! runtextmacro OSKeyLib_Const("OEM_COPY                      ","$F2")
    //! runtextmacro OSKeyLib_Const("OEM_AUTO                      ","$F3")
    //! runtextmacro OSKeyLib_Const("OEM_ENLW                      ","$F4")
    //! runtextmacro OSKeyLib_Const("OEM_BACKTAB                   ","$F5")
    //! runtextmacro OSKeyLib_Const("ATTN                          ","$F6")
    //! runtextmacro OSKeyLib_Const("CRSEL                         ","$F7")
    //! runtextmacro OSKeyLib_Const("EXSEL                         ","$F8")
    //! runtextmacro OSKeyLib_Const("EREOF                         ","$F9")
    //! runtextmacro OSKeyLib_Const("PLAY                          ","$FA")
    //! runtextmacro OSKeyLib_Const("ZOOM                          ","$FB")
    //! runtextmacro OSKeyLib_Const("NONAME                        ","$FC")
    //! runtextmacro OSKeyLib_Const("PA1                           ","$FD")
    //! runtextmacro OSKeyLib_Const("OEM_CLEAR                     ","$FE")
endmodule

endlibrary