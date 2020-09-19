library PathingMaps requires GMUI, TableStruct, AnyTileDefinition, Matrices, GALimage, GLHS


private module Init
    static method onInit takes nothing returns nothing
        call InitCustomTiles(TILE_SIZE)
    endmethod
endmodule

private struct PathTile extends array

    static constant integer TILE_SIZE = 32
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("counter", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("original", "boolean")
    
    method operator x takes nothing returns real
        return GetCustomTileCenterXById(TILE_SIZE, this)
    endmethod
    
    method operator y takes nothing returns real
        return GetCustomTileCenterYById(TILE_SIZE, this)
    endmethod
    
    method operator i takes nothing returns integer
        return GetCustomTileIndexI(this, TILE_SIZE)
    endmethod
    
    method operator j takes nothing returns integer
        return GetCustomTileIndexJ(this, TILE_SIZE)
    endmethod
    
    method counterAdd takes integer add returns nothing
        local integer counter = .counter
        
        if counter == 0 and add > 0 then
            if not .originalExists() then
                set .original = IsTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY)
            endif
            call SetTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY, false)
        elseif add < 0 and counter > 0 and counter > add then
            if .originalExists() and .original then
                call SetTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY, true)
            endif
        endif
        
        set .counter = counter + add
    endmethod
    
    method counterIncrement takes boolean add returns nothing
        local integer counter = .counter
        
        if add then
            set .counter = counter + 1
            if counter == 0 then
                if not .originalExists() then
                    set .original = IsTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY)
                endif
                call SetTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY, false)
            endif
        else
            set .counter = counter - 1
            if counter == 1 then
                if .originalExists() and .original then
                    call SetTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY, true)
                endif
            endif
        endif
    endmethod

    static method get takes real x, real y returns thistype
        return GetCustomTileId(TILE_SIZE, x, y)
    endmethod
    
    static method fromIndices takes integer i, integer j returns thistype
        return GetCustomTileIdFromIndices(i, j, TILE_SIZE)
    endmethod
    
    static method validateIndices takes integer i, integer j returns boolean
        return ValidateCustomTileIndexI(TILE_SIZE, i) and ValidateCustomTileIndexJ(TILE_SIZE, j)
    endmethod
    
    implement Init
endstruct

struct PathingMap extends array
    
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("width", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("height", "integer")
    
    // normally this would be a List, but LinkedHashSet is faster for our purposes in JASS
    // this is private
    //! runtextmacro TableStruct_NewReadonlyStructField("tiles", "LinkedHashSet")
    
    static constant integer MAX_SIZE = 50
    
    method destroy takes nothing returns nothing
        if this > 0 then
            call .widthClear()
            call .heightClear()
            call .tiles.destroy()  // no need to check if tiles exists, since only custom pathing maps can be destroyed
            call .tilesClear()
        endif
    endmethod
    
    static method getGeneric takes integer width, integer height returns thistype
        local thistype this = -(width*MAX_SIZE + height)
        
        if not .widthExists() then
            set .width = width
            set .height = height
            set .tiles = 0
        endif
        
        return this
    endmethod
    
    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods
    
    static method createWithMatrix takes Matrix matrix returns thistype
        local thistype this = thistype.allocate()
        local integer n = matrix.n
        local integer m = matrix.m
        local integer i = 0
        local integer j = 0
        local LinkedHashSet tiles = LinkedHashSet.create()
    
        set .tiles = tiles
    
        // iteration must be ji instead of ij because tileIds need to be ordered.
        loop
            if i >= n then
                set j = j + 1
                exitwhen j >= m
                set i = 0
            endif
            
            if matrix[i][j] != 0. then
                call tiles.append(PathTile.fromIndices(i, j))
            endif
            
            set i = i + 1
        endloop
        
        return this
    endmethod

    //! textmacro tttt
        local integer i = 0
        local integer j = 0
        local real sin = Sin(angle)
        local real cos = Cos(angle)
        local integer newI
        local integer newJ
        local integer offsetI = PathTile.get(x,y).i
        local integer offsetJ = PathTile.get(x,y).j
        local integer maxI = .height
        local integer maxJ = .width
        
        loop
            if j >= maxJ then
                set i = i + 1
                exitwhen i >= maxI
                set j = 0
            endif
            // call BJDebugMsg("i / j: " + I2S(i) + " / " + I2S(j))
            
            set newJ = MathRound(j*cos - i*sin) + offsetJ
            set newI = MathRound(j*sin + i*cos) + offsetI
    //! endtextmacro
    
    //! textmacro dddd
                set j = j + 1
        endloop
    //! endtextmacro
    
    method applyAtAngledSimple takes real x, real y, boolean enable, real angle returns nothing
        //! runtextmacro tttt()
            // call BJDebugMsg("New i / j: " + I2S(newI) + " / " + I2S(newJ))
            if PathTile.validateIndices(newI,newJ) then
                // call BJDebugMsg("Tile: " + I2S(PathTile.fromIndices(newI,newJ)))
                call PathTile.fromIndices(newI,newJ).counterIncrement(enable)
            else
                call BJDebugMsg("WTF")
            endif
        //! runtextmacro dddd()
    endmethod
    
    method createImages takes real x, real y, boolean enable, real angle returns ArrayList_image
        local LinkedHashSet seen = LinkedHashSet.create()
        local PathTile tile
        local ArrayList_image images = ArrayList.create()
        local image img
        
        //! runtextmacro tttt()
        if PathTile.validateIndices(newI,newJ) then
            set tile = PathTile.fromIndices(newI, newJ)
            
            if not seen.contains(tile) then
                call seen.append(tile)
                set img = CreateImage("Images\\SelectionSquareWhite.tga", PathTile.TILE_SIZE, PathTile.TILE_SIZE, 0, 0, 0, 0, PathTile.TILE_SIZE/2, PathTile.TILE_SIZE/2, 0., 1)
                call SetImageRenderAlways(img, true)
                call SetImagePosition(img, tile.x, tile.y, 0)
                call images.append(img)
            endif
        endif
        //! runtextmacro dddd()
        return images
    endmethod
    
    method applyAtAngled takes real x, real y, boolean enable, real angle returns nothing
        local integer i
        local integer j
        local real sin = Sin(angle)
        local real cos = Cos(angle)
        local LinkedHashSet tiles = .tiles
        local PathTile tile = tiles.begin()
        local integer offsetI = PathTile.get(x,y).i
        local integer offsetJ = PathTile.get(x,y).j
    
        loop
            exitwhen tile == tiles.end()
            set i = tile.i
            set j = tile.j
            
            set j = R2I(j*cos - i*sin) + offsetJ
            set i = R2I(j*sin + i*cos) + offsetI
            if PathTile.validateIndices(i,j) then
                call PathTile.fromIndices(i,j).counterIncrement(enable)
            endif
            
            set tile = tiles.next(tile)
        endloop
    endmethod

endstruct


endlibrary