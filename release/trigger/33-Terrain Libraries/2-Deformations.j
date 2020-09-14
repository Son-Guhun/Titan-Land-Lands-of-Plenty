library LoPDeformLimit initializer init requires TileDefinition, LoPWarn

globals
    public integer limitTile
    public constant key MSGKEY
endglobals

//! textmacro LoPDeformLimitInline
    if (integer(this) - (integer(this) / WorldTilesX) * WorldTilesX) < LoPDeformLimit_limitTile then
        call LoP_WarnPlayerTimeout(User.Local, LoPChannels.ERROR, LoPDeformLimit_MSGKEY, 10., "You cannot change terrain height outside of the Sandbox (eastern side of the map).")
        return
    endif
//! endtextmacro

private function init takes nothing returns nothing
    set limitTile = GetTileId(14300, WorldBounds.minY)
endfunction

endlibrary


library Deformations requires TileDefinition, TableStruct, optional LoPDeformLimit
/*
This library handles the creation and indexing of terrain deformation. Each terrain tile has its own
deformation. Terrain tiles and their IDs are defined in the TileDefinition library.

Example:
set d = Deformation.fromCoords(x, y)
set d.depth = d.depth + 10

*/

globals
    // The value bj_CELLWIDTH in Blizzard.j is unlikely to ever changed. Thus, it's inlined here.
    constant boolean INLINE_bj_CELLWIDTH = true
    public constant real MAX_HEIGHT = 2000.
    public constant real MIN_HEIGHT = -2000.
endglobals

// =================================================================================================
//                                         Source Code
// =================================================================================================


struct Deformation extends array

    //! runtextmacro TableStruct_NewPrimitiveField("depth_impl","real")
    //! runtextmacro TableStruct_NewPrimitiveField("depth_actual","integer")
    
    static constant method operator CELL_SIZE takes nothing returns real
        static if INLINE_bj_CELLWIDTH then
            return 128. // bj_CELLWIDTH <= this value is unlikely to ever change.
        else
            return bj_CELLWIDTH
        endif
    endmethod
    
    static method fromCoords takes real x, real y returns Deformation
        return GetTileId(x,y)
    endmethod
    
    method operator depth takes nothing returns real
        return .depth_impl
    endmethod
    
    method operator idepth takes nothing returns integer
        return .depth_actual
    endmethod
    
    method operator depth= takes real depth returns nothing
        local integer delta
        
        //! runtextmacro LoPDeformLimitInline()
        
        if this >= 0 then
            if depth > MAX_HEIGHT then
                set depth = MAX_HEIGHT
            elseif depth < MIN_HEIGHT then
                set depth = MIN_HEIGHT
            endif
            set delta =  R2I(depth) - .depth_actual
            
            if delta != 0 then
                call TerrainDeformCrater(GetTileCenterXById(this), GetTileCenterYById(this), .CELL_SIZE, delta, 1, true)
                set .depth_impl = depth
                set .depth_actual = R2I(depth)
            endif
        endif
    endmethod
endstruct


endlibrary