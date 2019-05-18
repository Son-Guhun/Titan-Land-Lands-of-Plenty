library LoPInitDecoTents requires LoPDecoBuilders
/*
    It also defines functions to create the Deco Tents in the Titan Palace, which are dynamically
    generated.
*/
    globals
        constant integer Special_RED = 255
        constant integer Special_GREEN = 165
        constant integer Special_BLUE = 0
        constant integer Special_ALPHA = 255
        
        constant integer Basic_RED = 255
        constant integer Basic_GREEN = 255
        constant integer Basic_BLUE = 255
        constant integer Basic_ALPHA = 255
        
        constant integer Adv_RED = 255
        constant integer Adv_GREEN = 0
        constant integer Adv_BLUE = 0
        constant integer Adv_ALPHA = 255
    endglobals

// This function is called in Init 0 seconds (to reduce loading time)
function InitDecoTents takes nothing returns nothing
    local rect decoRect = gg_rct_Deco_Tents_Rect
    
    local real xStep = 256.
    local real yStep = 192.
    
    local real xMax = GetRectMaxX(decoRect) - xStep
    local real xMin = GetRectMinX(decoRect)
    local real yMax = GetRectMaxY(decoRect)
    local real yMin = GetRectMinY(decoRect)
    
    local real xStart = xMin + xStep/2.
    local real yStart = yMin + yStep/2.
    local real xCur = xStart
    local real yCur = yStart
        
    local unit decoTent = null
    local integer decoNumber = 0
    
    local integer i
    
    local integer decoTentCount
    
    //! textmacro DecoBuilders_MakeTents takes name
    set decoTentCount = 1
    loop
    exitwhen decoNumber > LoP_DecoBuilders.$name$DecoLastIndex
        set decoTent = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'n03H', xCur, yCur, bj_UNIT_FACING)
        call BlzSetUnitName(decoTent, "Deco Tent $name$ "+ I2S(decoTentCount))
        call SetUnitVertexColor(decoTent, $name$_RED, $name$_GREEN, $name$_BLUE, $name$_ALPHA)
        
        set i = 0
        loop
        exitwhen i >= bj_MAX_STOCK_UNIT_SLOTS or decoNumber > LoP_DecoBuilders.$name$DecoLastIndex
            call AddUnitToStock(decoTent, LoP_DecoBuilders.rawcodes[decoNumber], 1, 3)
            set i = i + 1
            set decoNumber = decoNumber + 1
        endloop
        
        set xCur = xCur + xStep
        if xCur > xMax then
            set yCur = yCur + yStep
            set xCur = xStart
        endif
        set decoTentCount = decoTentCount + 1

    endloop
    //! endtextmacro
    
    //! runtextmacro DecoBuilders_MakeTents("Special")
    //! runtextmacro DecoBuilders_MakeTents("Basic")
    //! runtextmacro DecoBuilders_MakeTents("Adv")
    
    set decoTent = null
endfunction


endlibrary