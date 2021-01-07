//! runtextmacro GAL_Generate_List("true","image","ImageHandle","Handle","null")

library PathingMaps requires GMUI, TableStruct, PathingTileDefinition, Matrices, GALimage, GLHS

globals
    private constant boolean DISPLAY_IMAGES = false
endglobals


private module Init
    static method onInit takes nothing returns nothing
        call InitCustomTiles(TILE_SIZE)
    endmethod
endmodule

struct PathTile extends array

    static constant integer TILE_SIZE = 32
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("counter", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("original", "boolean")
    
    static method y2i takes real y returns integer
        return PathingTileY2I(y)
    endmethod
    
    static method x2j takes real x returns integer
        return PathingTileX2J(x)
    endmethod
    
    method operator x takes nothing returns real
        return GetPathingTileCenterXById(this)
    endmethod
    
    method operator y takes nothing returns real
        return GetPathingTileCenterYById(this)
    endmethod
    
    method operator i takes nothing returns integer
        return GetPathingTileIndexI(this)
    endmethod
    
    method operator j takes nothing returns integer
        return GetPathingTileIndexJ(this)
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
    
    static if DISPLAY_IMAGES then
        // Handle Field does not work for images. Apparently the typecast trick is the issue.
        //! runtextmacro TableStruct_NewPrimitiveField("image", "image")
        
        method showImage takes boolean show returns nothing
            if not .imageExists() then 
                set .image = CreateImage("Images\\SelectionSquareWhite.tga", TILE_SIZE, TILE_SIZE, 0, 0, 0, 0, TILE_SIZE/2, TILE_SIZE/2, 0., 1)
                call SetImagePosition(.image, .x, .y, 0)
            endif
            call SetImageRenderAlways(.image, show)
        endmethod
    endif
    
    method counterIncrement takes boolean add returns nothing
        local integer counter = .counter
        
        if add then
            set .counter = counter + 1
            if counter == 0 then
                if not .originalExists() then
                    set .original = not IsTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY)  // this native returns reversed results
                endif
                call SetTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY, false)
                
                static if DISPLAY_IMAGES then
                    call .showImage(true)
                endif
            endif
            
        else
            set .counter = counter - 1
            if counter == 1 then
                if .originalExists() and .original then
                    call SetTerrainPathable(.x, .y, PATHING_TYPE_WALKABILITY, true)
                    
                    static if DISPLAY_IMAGES then
                        call .showImage(false)
                    endif
                endif
            endif
        endif
    endmethod

    static method get takes real x, real y returns thistype
        return GetPathingTileId(x, y)
    endmethod
    
    static method fromIndices takes integer i, integer j returns thistype
        return GetPathingTileIdFromIndices(i, j)
    endmethod
    
    static method validateIndicesUpper takes integer i, integer j returns boolean
        return ValidatePathingTileIndexI(i) and ValidatePathingTileIndexJ(j)
    endmethod
    
    static method validateIndicesLower takes integer i, integer j returns boolean
        return i >= 0 and j >= 0
    endmethod
    
    /*
    static method validateIndices takes integer i, integer j returns boolean
        return validateIndicesLower(i,j) and validateIndicesUpper(i,j)
    endmethod
    */
    

    
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
    
    static method createWithList takes integer width, integer height, LinkedHashSet tiles returns thistype
        local thistype this = thistype.allocate()
        
        set .width = width
        set .height = height
        set .tiles = tiles
        
        return this
    endmethod

    //! textmacro tttt
        local integer i = 0
        local integer j = 0
        local real sin = Sin(angle)
        local real cos = Cos(angle)
        local integer newI
        local integer newJ
        local integer offsetI = PathTile.y2i(y)
        local integer offsetJ = PathTile.x2j(x)
        local integer maxI = .width
        local integer maxJ = .height
        
        loop
            if j >= maxJ then
                set i = i + 1
                exitwhen i >= maxI
                set j = 0
            endif
            
            set newJ = MathRound(j*cos - i*sin) + offsetJ
            set newI = MathRound(j*sin + i*cos) + offsetI
    //! endtextmacro
    
    //! textmacro dddd
                set j = j + 1
        endloop
    //! endtextmacro
    
    private method applyAtAngledSimple takes real x, real y, boolean enable, real angle returns nothing
        //! runtextmacro tttt()
            if PathTile.validateIndicesLower(newI,newJ) and PathTile.validateIndicesUpper(newI,newJ) then
                call PathTile.fromIndices(newI,newJ).counterIncrement(enable)
            endif
        //! runtextmacro dddd()
    endmethod
    
    method createImages takes real x, real y, boolean enable, real angle returns ArrayList_image
        local LinkedHashSet seen = LinkedHashSet.create()
        local PathTile tile
        local ArrayList_image images = ArrayList.create()
        local image img
        
        //! runtextmacro tttt()
        if PathTile.validateIndicesLower(newI,newJ) and PathTile.validateIndicesUpper(newI,newJ) then
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
    
    private method applyAtAngledAdvanced takes real x, real y, boolean enable, real angle returns nothing
        local integer i
        local integer j
        local integer temp
        local real sin = Sin(angle)
        local real cos = Cos(angle)
        local LinkedHashSet tiles = .tiles
        local PathTile tile = tiles.begin()
        local integer offsetI = PathTile.y2i(y)
        local integer offsetJ = PathTile.x2j(x)
    
        loop
            exitwhen tile == tiles.end()
            set i = tile.i
            set j = tile.j
            
            set temp = MathRound(j*cos - i*sin) + offsetJ
            set i = MathRound(j*sin + i*cos) + offsetI
            set j = temp
            
            if PathTile.validateIndicesLower(i,j) and PathTile.validateIndicesUpper(i,j) then
                call PathTile.fromIndices(i,j).counterIncrement(enable)
            endif
            
            set tile = tiles.next(tile)
        endloop
    endmethod
    
    method applyAtAngled takes real x, real y, boolean enable, real angle returns nothing
        if .tiles == 0 then
            call applyAtAngledSimple(x,y,enable,angle)
        else
            call applyAtAngledAdvanced(x,y,enable,angle)
        endif
    endmethod

endstruct


endlibrary