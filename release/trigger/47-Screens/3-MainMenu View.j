library MainMenuView requires Screen, UILib

globals
    public Screen mainFrame
endglobals

//! runtextmacro Begin0SecondInitializer("Init")
    local framehandle mainButton
    
    call BlzLoadTOCFile("war3mapimported\\BoxedText.toc")
    
    set mainFrame = Screen.create()
    call mainFrame.show(false)
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 7*View4by3.h/8)
    call BlzFrameSetText(mainButton, "Terrain Editor")
    set mainFrame["terrainEditor"] = mainButton
    call BlzFrameSetText(CreateTooltip(mainButton, "Terrain Editor", 0.30, 0.15, 0.002, 0.002), "
Allows you to edit the map's terrain as if you were using the World Editor. Works in multiplayer, with a small delay.

Hotkeys:
H: Changes current height tool.
P: Enables/Disables texturing.
1, 2, 3, 4 and 5: Changes the brush size.")
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 6*View4by3.h/8)
    call BlzFrameSetText(mainButton, "Free Camera")
    set mainFrame["freeCamera"] = mainButton
    call BlzFrameSetText(CreateTooltip(mainButton, "Free Camera", 0.30, 0.15, 0.002, 0.002), "
Allows you to explore the world using a first-person camera style. For best results, use a zoom value of 0.

Hotkeys:
WASD: Moves the camera.
IJKL: Rotates the camera sidewayds (JL) or up/down (IK)
NUMPAD 4/6: Decreases/increases speed.
NUMPAD 8/9: Decreases/increases speed (precise ajustment).")
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 5*View4by3.h/8)
    call BlzFrameSetText(mainButton, "SotDRP Chat")
    set mainFrame["sotdrp"] = mainButton
    call BlzFrameSetText(CreateTooltip(mainButton, "SotDRP Mode", 0.30, 0.15, 0.002, 0.002), "
Changes the chat to function like the chat in SotDRP-style maps. Your name will be the name of your currently selected unit, if that unit has a custom name. This will also hide the chat. To be able to communicate with players who aren't using this chat mode, you must not send messages to the observer chat.

OOC prefix: ((
OOC suffix: ))")

    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 4*View4by3.h/8)
    call BlzFrameSetText(mainButton, "Special Units")
    set mainFrame["specialUnits"] = mainButton
    call CreateTooltip(mainButton, "Spawn Special Units", 0.15, 0.08, 0.002, 0.002)
    call BlzFrameSetEnable(mainButton, false)
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 3*View4by3.h/8)
    call BlzFrameSetText(mainButton, "Chat Logs")
    set mainFrame["chatLogs"] = mainButton
    call BlzFrameSetText(CreateTooltip(mainButton, "Chat Logs", 0.30, 0.15, 0.002, 0.002), "
Allows you to view separate chat logs for OOC/IC messages. These chat logs should reach further into past messages than the game's default chat log.

This chat log is also the only way to view messages sent using the Advanced Chat Box. To access the advanced chat box, use the hotkey |cffffcc00Shift+Ctrl|r+Enter.
")
    // call CreateTooltip(mainButton, "Spawn Special Units", 0.15, 0.08, 0.002, 0.002)
//! runtextmacro End0SecondInitializer()



endlibrary