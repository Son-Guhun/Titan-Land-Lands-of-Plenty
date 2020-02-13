library GameView requires Screen

private keyword InitModule

struct UpperButtonBar extends array
    
    readonly static framehandle array buttons
    readonly static framehandle mainFrame
    
    implement InitModule

endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        local framehandle mainButton
        call BlzLoadTOCFile("war3mapImported\\Templates.toc")

        set thistype.mainFrame = BlzGetFrameByName("UpperButtonBarFrame",0)
        set mainButton = BlzCreateSimpleFrame("LoPUpperButtonBarFrame", thistype.mainFrame,0)
        call BlzFrameSetAllPoints(mainButton, BlzGetFrameByName("ResourceBarFrame",0))
        
        set buttons[0] = BlzGetFrameByName("UpperButtonBarQuestButton", 0)
        set buttons[1] = BlzGetFrameByName("UpperButtonBarMenuButton", 0)
        set buttons[2] = BlzGetFrameByName("UpperButtonBarAllyButton", 0)
        set buttons[3] = BlzGetFrameByName("UpperButtonBarChatButton", 0)
        set buttons[4] = BlzGetFrameByName("LoPUpperButtonBarButtonOne", 0)
        set buttons[5] = BlzGetFrameByName("LoPUpperButtonBarButtonTwo", 0)
        set buttons[6] = BlzGetFrameByName("LoPUpperButtonBarButtonThree", 0)
        set buttons[7] = BlzGetFrameByName("LoPUpperButtonBarButtonFour", 0)
        
        call BlzFrameSetEnable(mainButton, false)  // Disable the parent frame to allow players to move camera by dragging mouse to upper border
        call BlzFrameSetEnable(buttons[4], false)
        call BlzFrameSetEnable(buttons[5], false)
        call BlzFrameSetEnable(buttons[6], false)
    endmethod
endmodule


endlibrary