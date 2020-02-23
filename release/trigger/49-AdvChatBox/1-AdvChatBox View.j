library AdvChatBoxView

struct AdvChatBox extends array
    readonly static framehandle editBox
    readonly static framehandle typingIndicator
    readonly static framehandle syncButton
    readonly static framehandle charCounter
    readonly static framehandle closeButton
    readonly static framehandle sendButton
    readonly static framehandle oocButtonNoBuffer
    readonly static framehandle speakerButton
    
    private static method onInit takes nothing returns nothing
        call BlzLoadTOCFile("war3mapImported\\Templates.toc")
    
        set AdvChatBox.editBox = BlzCreateFrame("EscMenuEditBoxTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0),0,0)
        call BlzFrameSetAbsPoint(AdvChatBox.editBox, FRAMEPOINT_CENTER, 0.4, 0.18)    
        call BlzFrameSetSize(AdvChatBox.editBox, 0.6, 0.03)
        call BlzFrameSetVisible(AdvChatBox.editBox, false)
        
        set AdvChatBox.typingIndicator = BlzCreateFrameByType("TEXT", "TypingIndicator", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "StandardExtraSmallTextTemplate", 0)
        call BlzFrameSetPoint(AdvChatBox.typingIndicator, FRAMEPOINT_TOPRIGHT, AdvChatBox.editBox, FRAMEPOINT_LEFT, 0, 0.2)
        call BlzFrameSetAbsPoint(AdvChatBox.typingIndicator, FRAMEPOINT_BOTTOMLEFT, 0., 0.)
        
        set AdvChatBox.closeButton = BlzCreateFrame("ScriptDialogButton", AdvChatBox.editBox, 0,0)
        call BlzFrameSetSize(AdvChatBox.closeButton, 0.125, 0.028)
        call BlzFrameSetPoint(AdvChatBox.closeButton, FRAMEPOINT_TOPLEFT, AdvChatBox.editBox, FRAMEPOINT_BOTTOMLEFT, 0.1, 0.001)
        call BlzFrameSetText(AdvChatBox.closeButton, "Close (|cffffffffS+Esc|r)")

        set AdvChatBox.sendButton = BlzCreateFrame("ScriptDialogButton", AdvChatBox.editBox, 0,0)
        call BlzFrameSetSize(AdvChatBox.sendButton, 0.05, 0.028)
        call BlzFrameSetPoint(AdvChatBox.sendButton, FRAMEPOINT_TOPRIGHT, AdvChatBox.editBox, FRAMEPOINT_BOTTOMRIGHT, -0.1, 0.001)
        call BlzFrameSetText(AdvChatBox.sendButton, "OOC")
        
        set AdvChatBox.oocButtonNoBuffer = BlzCreateFrame("ScriptDialogButton", AdvChatBox.editBox, 0,0)
        call BlzFrameSetSize(AdvChatBox.oocButtonNoBuffer, 0.05, 0.028)
        call BlzFrameSetPoint(AdvChatBox.oocButtonNoBuffer, FRAMEPOINT_TOPRIGHT, AdvChatBox.editBox, FRAMEPOINT_BOTTOMRIGHT, -0.1, 0.001)
        call BlzFrameSetVisible(AdvChatBox.oocButtonNoBuffer, false)
        // call BlzFrameSetText(AdvChatBox.sendButton, "OOC")
        
        set AdvChatBox.speakerButton = BlzCreateFrame("ScriptDialogButton", AdvChatBox.editBox, 0,0)
        // call BlzFrameSetSize(AdvChatBox.speakerButton, 0.125, 0.028)
        call BlzFrameSetPoint(AdvChatBox.speakerButton, FRAMEPOINT_TOPLEFT, AdvChatBox.closeButton, FRAMEPOINT_TOPRIGHT, 0, 0)
        call BlzFrameSetPoint(AdvChatBox.speakerButton, FRAMEPOINT_BOTTOMRIGHT, AdvChatBox.sendButton, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(AdvChatBox.speakerButton, "Speaking as: |cffffffffAuto|r")
        call BlzFrameSetEnable(AdvChatBox.speakerButton, false)
        
        set AdvChatBox.syncButton = BlzCreateFrameByType("BUTTON", "AdvChatBoxSyncButton", AdvChatBox.editBox, "",0)
        call BlzFrameSetVisible(AdvChatBox.syncButton, false)
        
        set AdvChatBox.charCounter = BlzCreateFrameByType("TEXT", "CharacterCounter", AdvChatBox.editBox, "StandardSmallTextTemplate", 0)
        call BlzFrameSetSize(AdvChatBox.charCounter, 0.1, 0.028)
        call BlzFrameSetText(AdvChatBox.charCounter, "0/255")
        call BlzFrameSetPoint(AdvChatBox.charCounter, FRAMEPOINT_RIGHT, AdvChatBox.editBox, FRAMEPOINT_RIGHT, 0.05, 0)
    endmethod
endstruct

endlibrary
