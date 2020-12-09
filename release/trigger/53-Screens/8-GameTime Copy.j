library GameTime requires TableStruct, GameTimeView

struct GameTime extends array
    static integer a
    private static key static_members_key
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("hours", "integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("minutes", "integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("seconds", "integer")
    
    //! runtextmacro TableStruct_NewReadonlyStaticAgentField("timer", "timer")
    
    private static method toString takes nothing returns string
        return I2S(thistype.hours) + " : " + I2S(thistype.minutes) + " : " + I2S(thistype.seconds)
    endmethod
    
    private static method toStringEx takes string sep returns string
        return I2S(thistype.hours) + sep + I2S(thistype.minutes) + sep + I2S(thistype.seconds)
    endmethod
    
    private static method asMinutes takes nothing returns real
        return 60.*thistype.hours + thistype.minutes + thistype.seconds/60.
    endmethod
    
    private static method asHours takes nothing returns real
        return thistype.hours + thistype.minutes/60. + thistype.seconds/3600.
    endmethod
    
    private static method asSeconds takes nothing returns integer
        return thistype.hours*3600 + thistype.minutes*60 + thistype.seconds
    endmethod
    
    private static method onTimer takes nothing returns nothing
        local string s
        
        if .seconds == 0 and .minutes == 0 and .hours == 0 then
            // call BlzTriggerRegisterFrameEvent(trig, GameTimeView_frames.button, FRAMEEVENT_CONTROL_CLICK)
        endif
    
        if .seconds == 59 then
            if .minutes == 59 then
                set .hours = .hours + 1
                set .minutes = 0
            else
                set .minutes = .minutes + 1
            endif
            set .seconds = 0
        else
            set .seconds = .seconds + 1
        endif
        
        set s = I2S(.hours)
        if StringLength(s) == 1 then
            set s = "0" + s
        endif
        call BlzFrameSetText(GameTimeView_frames.hours, s)
        set s = I2S(.minutes)
        if StringLength(s) == 1 then
            set s = "0" + s
        endif
        call BlzFrameSetText(GameTimeView_frames.minutes, s)
        set s = I2S(.seconds)
        if StringLength(s) == 1 then
            set s = "0" + s
        endif
        call BlzFrameSetText(GameTimeView_frames.seconds, s)
    endmethod
    
    private static method onInit takes nothing returns nothing
        set thistype.timer = CreateTimer()
                
        
        call TimerStart(thistype.timer, 1., true, function thistype.onTimer)
    endmethod
endstruct


endlibrary

