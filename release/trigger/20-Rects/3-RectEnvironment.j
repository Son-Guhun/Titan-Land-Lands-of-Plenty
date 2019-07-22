library RectEnvironment requires GMUI, TableStruct

struct TerrainFog extends array
    static constant integer LINEAR       = 0
    static constant integer EXPONENTIAL  = 1
    static constant integer EXPONENTIAL2 = 2

    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods
    
    //! runtextmacro TableStruct_NewPrimitiveField("style", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("zStart", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("zEnd", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("density", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("red", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("green", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("blue", "real")
    
    method applyForPlayer takes player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call SetTerrainFogEx(.style, .zStart, .zEnd, .density, .red, .green, .blue)
        endif
    endmethod
    
    method apply takes nothing returns nothing
        call SetTerrainFogEx(.style, .zStart, .zEnd, .density, .red, .green, .blue)
    endmethod
        
    static method create takes nothing returns TerrainFog
        local TerrainFog this = TerrainFog.allocate()
        set this.style = 0
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        if this.styleExists() then
            call this.styleClear()
            call this.zStartClear()
            call this.zEndClear()
            call this.densityClear()
            call this.redClear()
            call this.greenClear()
            call this.blueClear()
            call this.deallocate()
        endif
    endmethod
    
endstruct



struct RectEnvironment extends array

    //! runtextmacro TableStruct_NewStructField("fog", "TerrainFog")
    
    method apply takes nothing returns nothing
        local integer fog = this.fog
        if this.fog != 0 then
            call this.fog.apply()
        else
            call ResetTerrainFog()
        endif
    endmethod
    
    static method operator default takes nothing returns RectEnvironment
        return 0
    endmethod
    
    static method get takes rect r returns thistype
        return GetHandleId(r)
    endmethod
    
    method destroy takes nothing returns nothing
        call this.fogClear()
    endmethod
endstruct

endlibrary