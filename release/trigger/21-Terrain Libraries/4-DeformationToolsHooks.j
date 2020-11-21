library DeformationToolsHooks initializer Init requires DecorationSFX, AttachedSFX
/*
This library fixes z height for structures and effects. It is specific to the LoP map and is not needed
in order for the DeformationTools library to function.


*/

    globals
        private LinkedHashSet taggedBlocks
        private group g
        private rect r
    endglobals

    private function UpdateEffects takes nothing returns nothing
        local integer block = taggedBlocks.begin()
        local SpecialEffect deco
        local integer i = 0
        local unit u
        
        if not taggedBlocks.isEmpty() then
            loop
                exitwhen block == taggedBlocks.end()
                
                call DecorationSFX_ResetHeightsInBlock(block)

                
                call MoveRectTo(r, GetCustomTileCenterXById(DecorationSFX_BLOCK_SIZE, block), GetCustomTileCenterYById(DecorationSFX_BLOCK_SIZE, block))
                call GroupEnumUnitsInRect(g, r, null)
                if FirstOfGroup(g) != null then
                    loop
                        set u = BlzGroupUnitAt(g, i)
                        exitwhen u == null
                        set deco = GetUnitAttachedEffect(u)
                        if deco != 0 then
                            set deco.height = deco.height
                        endif
                        set i = i + 1
                    endloop
                endif
                
                set block = taggedBlocks.next(block)
            endloop
            
            set u = null
            call taggedBlocks.clear()
        endif
    endfunction

    private function Init takes nothing returns nothing
        set taggedBlocks = LinkedHashSet.create()
        set g = CreateGroup()
        set r = Rect(0, 0, DecorationSFX_BLOCK_SIZE, DecorationSFX_BLOCK_SIZE)
        
        call TimerStart(CreateTimer(), 1., true, function UpdateEffects)
    endfunction

    public function TagBlocks takes real minX, real minY, real maxX, real maxY returns nothing
        //! runtextmacro TilesInRectLoopDeclare("block", "DecorationSFX_BLOCK_SIZE", "minX", "minY", "maxX", "maxY")

        loop
            if not taggedBlocks.contains(block) then
                call taggedBlocks.append(block)
            endif
            
            //! runtextmacro TilesInRectLoop("block", "DecorationSFX_BLOCK_SIZE")
        endloop
    endfunction
    
    
    //! textmacro DeformationToolsHook takes x0, y0, radius
        call DeformationToolsHooks_TagBlocks($x0$ - $radius$*128., $y0$ - $radius$*128., $x0$ + $radius$*128., $y0$ + $radius$*128.)
    //! endtextmacro
endlibrary