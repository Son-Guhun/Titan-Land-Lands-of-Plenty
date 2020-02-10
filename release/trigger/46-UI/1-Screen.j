library Screen requires OSKeyLib, Table, PlayerUtils


struct Screen

    private boolean isVisible
    framehandle main
    private Table frames

    static method fromFrame takes framehandle mainFrame returns thistype
        local thistype this = thistype.allocate()
        
        set .main = mainFrame
        set .isVisible = true
        set .frames = Table.create()
        return this
    endmethod

    static method create takes nothing returns thistype
        return fromFrame(BlzCreateFrameByType("FRAME", "ScreenFrame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),"", 0))
    endmethod
    
    method show takes boolean show returns nothing
        if .isVisible != show then
            set .isVisible = show
            call BlzFrameSetVisible(.main, show)
        endif
    endmethod
    
    method operator [] takes string frameName returns framehandle
        return .frames.framehandle[StringHash(frameName)]
    endmethod
    
    method operator []= takes string frameName, framehandle frame returns nothing
        set .frames.framehandle[StringHash(frameName)] = frame
    endmethod
        

endstruct

struct ScreenController extends array

    implement ExtendsTable

    //! runtextmacro HashStruct_NewStructField("screen", "Screen")
    //! runtextmacro HashStruct_NewHandleField("buttonHandler", "boolexpr")

    static method create takes Screen screen, boolexpr buttonHandler returns thistype
        local thistype this = Table.create()
        
        set .screen = screen
        set .buttonHandler = buttonHandler
        call OSKeys.addListener(buttonHandler)
        return this
    endmethod
    
    method enable takes player p, boolean enable returns nothing
        local User pId = User[p]
        
        if .tab.boolean[pId] != enable then
        
            set .tab.boolean[pId] = enable
            if User.fromLocal() == pId then
                call .screen.show(enable)
            endif
        endif
    endmethod
    
    method isEnabled takes player p returns boolean
        return .tab.boolean[User[p]]
    endmethod

endstruct



endlibrary