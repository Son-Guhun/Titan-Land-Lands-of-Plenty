library Timeline
//== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ====
//  _____________
//   #  Timeline Lite (by Guhun)
//          Compatible with Timeline v2.0a (by Overfrost)
//  ----------------------------
//
//    - keeps track of elapsed game-time, allowing easy retrieval of it
//
//    - separates the tracked time into 4 variables
//      (hours, minutes, current seconds, total seconds)
//
//    - can also retrieve the time as a generally-formatted string
//
//    - has a readonly global instance that tracks the timeline of the game
//
//
//    - can return time-difference values by comparing current time
//      and previously marked time
//
//
//== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ====
//! novjass

    //
    struct Timeline extends array

        //-------------
        // Game-clock
        //
        readonly static integer game.hours
        readonly static integer game.minutes
        readonly static real game.seconds     // current seconds, 0 to ~59.99
        readonly static real game.elapsed     // total seconds
        //
        static method game.getString takes string separator returns string
        // - returns hours, minutes, and (int)seconds as one formatted string
        // - the format is (H:MM:SS) if (hours > 0) or (M:SS) otherwise, showing 0 minutes
        // - spaces are not included as default separator
        //

//! endnovjass
//== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ==== ====

//
private function pgPad2 takes integer pInt returns string
    if (pInt > 9) then
        return I2S(pInt)
    endif
    return "0" + I2S(pInt)
endfunction
//
private module pm
    private static method onInit takes nothing returns nothing
        call pgInit()
    endmethod
endmodule
private struct ps extends array
    //
    private static timer pgTimer = CreateTimer()

    //--------------------------
    // hours, minutes, seconds
    readonly static integer hours = 0
    readonly static integer minutes = 0
    //
    static method operator seconds takes nothing returns real
        return TimerGetElapsed(pgTimer)
    endmethod

    //----------------
    // total seconds
    private static integer pgSeconds = 0
    //
    static method operator elapsed takes nothing returns real
        return pgSeconds + seconds
    endmethod

    //-------------------
    // formatted string
    static method getString takes string aSep returns string
        if (hours > 0) then
            return I2S(hours) + aSep /*
                */ + pgPad2(minutes) + aSep /*
                */ + pgPad2(R2I(seconds))
        endif
        return I2S(minutes) + aSep + pgPad2(R2I(seconds))
    endmethod

    //
    private static method pgOnExpire takes nothing returns nothing
        set minutes = minutes + 1
        set pgSeconds = pgSeconds + 60
        //
        if (minutes == 60) then
            set minutes = 0
            set hours = hours + 1
        endif
    endmethod
    private static method pgInit takes nothing returns nothing
        call TimerStart(pgTimer, 60, true, function thistype.pgOnExpire)
    endmethod
    implement pm
endstruct
struct Timeline extends array

    static method operator game takes nothing returns ps
        return 0
    endmethod

endstruct

endlibrary