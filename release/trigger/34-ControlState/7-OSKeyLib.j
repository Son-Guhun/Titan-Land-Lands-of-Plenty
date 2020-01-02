library OSKeyLib requires PlayerUtils

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
        return .isPressedPlayer(GetLocalPlayer())
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
                    set p = p + 1
                endloop
            endif
        endif
    endmethod
    
    private static method onKey takes nothing returns nothing
        set g_isPressed[GetHandleId(BlzGetTriggerPlayerKey())][GetPlayerId(GetTriggerPlayer())] = BlzGetTriggerPlayerIsKeyDown()
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
    //! runtextmacro OSKeyLib_Const("KEY                           ","$39")
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