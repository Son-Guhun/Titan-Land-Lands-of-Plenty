library UpperButtonBarView

private keyword InitModule

struct UpperButtonBar extends array
    
    readonly static framehandle array buttons
    readonly static framehandle rightFrame
    readonly static framehandle resourceBar
    static boolean isEnabled = true
    // readonly static framehandle rightFrame
    
    implement InitModule

endstruct

private module InitModule
    private static method onStart takes nothing returns nothing
        local framehandle mainButton
        call BlzLoadTOCFile("war3mapImported\\Templates.toc")

        // If the parent is set to UpperButtonBarFrame or ResourceBarFrame, camera mouse will bug after a unit is selected
        set rightFrame = BlzCreateSimpleFrame("LoPUpperButtonBarFrame", BlzGetFrameByName("ConsoleUI",0),0)
        set resourceBar = BlzGetFrameByName("ResourceBarFrame",0)
        call BlzFrameSetAllPoints(rightFrame, resourceBar)
        call BlzFrameSetVisible(resourceBar, false)
        
        set buttons[0] = BlzGetFrameByName("UpperButtonBarQuestsButton", 0)
        set buttons[1] = BlzGetFrameByName("UpperButtonBarMenuButton", 0)
        set buttons[2] = BlzGetFrameByName("UpperButtonBarAllyButton", 0)
        set buttons[3] = BlzGetFrameByName("UpperButtonBarChatButton", 0)
        set buttons[4] = BlzGetFrameByName("LoPUpperButtonBarButtonOne", 0)
        set buttons[5] = BlzGetFrameByName("LoPUpperButtonBarButtonTwo", 0)
        set buttons[6] = BlzGetFrameByName("LoPUpperButtonBarButtonThree", 0)
        set buttons[7] = BlzGetFrameByName("LoPUpperButtonBarButtonFour", 0)
        
        call BlzFrameSetEnable(buttons[4], false)
        call BlzFrameSetEnable(buttons[6], false)
        
        call DestroyTimer(GetExpiredTimer())
    endmethod
    
    private static method onInit takes nothing returns nothing
        call TimerStart(CreateTimer(), 0., false, function thistype.onStart)
    endmethod
endmodule


endlibrary