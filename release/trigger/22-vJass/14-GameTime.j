library GameTime requires TableStruct, MultiBoard

struct GameTime extends array
    static integer a
    private static key static_members_key
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("hours", "integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("minutes", "integer")
    //! runtextmacro TableStruct_NewReadonlyStaticPrimitiveField("seconds", "integer")
    
    //! runtextmacro TableStruct_NewReadonlyStaticHandleField("timer", "timer")
    //! runtextmacro TableStruct_NewReadonlyStaticHandleField("multiboard", "multiboard")
    
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
        local MultiBoard sec = .seconds
        local string s
    
        if sec == 0 and .minutes == 0 and .hours == 0 then
            set .multiboard = CreateMultiboard()
            call MultiboardSetRowCount(thistype.multiboard, 1)
            call MultiboardSetColumnCount(thistype.multiboard, 5)
            call MultiboardSetTitleText(.multiboard, "Elapsed Time")
            
            set sec = MultiBoard.refresh(.multiboard)
            call sec.setStyle(0, 0, true, false)
            call sec.setStyle(0, 1, true, false)
            call sec.setStyle(0, 2, true, false)
            call sec.setStyle(0, 3, true, false)
            call sec.setStyle(0, 4, true, false)
            call sec.setWidth(0, 0, 0.015)
            call sec.setWidth(0, 1, 0.005)
            call sec.setWidth(0, 2, 0.015)
            call sec.setWidth(0, 3, 0.005)
            call sec.setWidth(0, 4, 0.015)
            
            set sec = 0
        endif
    
        if sec == 60 then
            if .minutes == 60 then
                set .hours = .hours + 1
                set .minutes = 0
            else
                set .minutes = .minutes + 1
            endif
            set .seconds = 0
        else
            set .seconds = sec + 1
        endif
        
        set sec = GetHandleId(.multiboard)
        //call MultiboardSuppressDisplay(false)
        
        set s = I2S(.hours)
        if StringLength(s) == 1 then
            set s = "0" + s
        endif
        call sec.setValue(0, 0, s)
        call sec.setValue(0, 1, ":")
        set s = I2S(.minutes)
        if StringLength(s) == 1 then
            set s = "0" + s
        endif
        call sec.setValue(0, 2, s)
        call sec.setValue(0, 3, ":")
        set s = I2S(.seconds)
        if StringLength(s) == 1 then
            set s = "0" + s
        endif
        call sec.setValue(0, 4, s)
        
        call MultiboardDisplay(thistype.multiboard, true)
    endmethod
    
    private static method onInit takes nothing returns nothing
        set thistype.timer = CreateTimer()
                
        
        call TimerStart(thistype.timer, 1., true, function thistype.onTimer)
    endmethod
endstruct


endlibrary

