library Deformations requires TileDefinition, optional HashtableWrapper, optional Table
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
endglobals

// =================================================================================================
//                                         Source Code
// =================================================================================================


struct Deformation extends array

    //! runtextmacro TableStruct_NewPrimitiveField("depth_impl","real")
    
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
    
    method operator depth= takes real depth returns nothing
        call TerrainDeformCrater(GetTileCenterXById(this), GetTileCenterYById(this), .CELL_SIZE, depth - .depth_impl, 1, true)
        set .depth_impl = depth
    endmethod
endstruct


endlibrary