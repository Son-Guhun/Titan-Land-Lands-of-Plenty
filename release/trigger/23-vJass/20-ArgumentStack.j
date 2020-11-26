library ArgumentStack
/*

    How to use:
        Args.newStack()
        Args.s.real[0] = x
        Args.s.real[1] = y
        call ExecuteFunc("DoStuffWithXY")
        call Args.s.flush()
        call Args.pop()
*/

private struct G extends array

    private static key tabKey
    private static method operator tab takes nothing returns ConstTable
        return tabKey
    endmethod
    
    static method getVar takes integer key returns integer
        return .tab[key]
    endmethod

    static method setVar takes integer key, integer val returns integer
        set .tab[key] = val
        return val
    endmethod


endstruct


module ArgumentStack

        private static key tab
        private static key current
        readonly static Table stack
        
        private static method stackStack takes nothing returns ConstHashTable
            return tab
        endmethod
        
        static method newStack takes nothing returns nothing
            set stack = stackStack()[G.setVar(current, G.getVar(current + 1))]
        endmethod
        
        static method pop takes nothing returns nothing
            set stack = stackStack()[G.setVar(current, G.getVar(current - 1))]
        endmethod

endmodule

struct Args extends array

    implement ArgumentStack
    
    static method operator s takes nothing returns Table
        return stack
    endmethod

endstruct



endlibrary
