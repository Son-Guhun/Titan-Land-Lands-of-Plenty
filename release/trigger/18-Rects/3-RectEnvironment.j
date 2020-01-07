library RectEnvironment requires GMUI, TableStruct

struct DNC extends array
    static string array terrainLights
    static string array unitLights
    static integer totalLights
    
    static constant method operator DEFAULT_TERRAIN_LIGHT takes nothing returns integer
        return 5
    endmethod
    
    static constant method operator DEFAULT_UNIT_LIGHT takes nothing returns integer
        return 5
    endmethod
    
    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods

    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("pLock", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("lightTerrain", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("lightUnit", "integer")
    
    static method applyDefault takes nothing returns nothing
        call SetDayNightModels(.terrainLights[.DEFAULT_TERRAIN_LIGHT], .unitLights[.DEFAULT_UNIT_LIGHT])
    endmethod

    method apply takes nothing returns nothing
        call SetDayNightModels(.terrainLights[.lightTerrain], .unitLights[.lightUnit])
    endmethod
    
    method applyForPlayer takes player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call this.apply()
        endif
    endmethod
        
    static method create takes nothing returns thistype
        local thistype this = thistype.allocate()
        set this.pLock = 0
        set this.lightTerrain = .DEFAULT_TERRAIN_LIGHT
        set this.lightUnit = .DEFAULT_UNIT_LIGHT
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        if this.pLockExists() then  
            call this.pLockClear()
            call this.lightTerrainClear()
            call this.lightUnitClear()
            call this.deallocate()
        endif
    endmethod
    
    method lock takes nothing returns nothing
        set .pLock = .pLock + 1
    endmethod
    
    method unlock takes nothing returns nothing
        local integer v
        if this.pLockExists() then
            set v = .pLock
            set v = v-1
            if v <= 0 then
                call this.pLockClear()
                call this.lightTerrainClear()
                call this.lightUnitClear()
                call this.deallocate()
            else
                set .pLock = v
            endif
        endif
    endmethod
    
    static method onInit takes nothing returns nothing
        set .terrainLights[0] = ""
        set .unitLights[0] = ""
        
        set .terrainLights[1] = "Environment\\DNC\\DNCAshenvale\\DNCAshenValeTerrain\\DNCAshenValeTerrain.mdx"
        set .unitLights[1] = "Environment\\DNC\\DNCAshenvale\\DNCAshenValeUnit\\DNCAshenValeUnit.mdx"
        
        set .terrainLights[2] = "Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdx"
        set .unitLights[2] = "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdx"
        
        set .terrainLights[3] = "Environment\\DNC\\DNCDungeon\\DNCDungeonUnit\\DNCDungeonUnit.mdx" // "Environment\\DNC\\DNCDungeon\\DNCDungeonTerrain\\DNCDungeonTerrain.mdx"
        set .unitLights[3] = "Environment\\DNC\\DNCDungeon\\DNCDungeonUnit\\DNCDungeonUnit.mdx"
         
        set .terrainLights[4] = "Environment\\DNC\\DNCFelwood\\DNCFelWoodTerrain\\DNCFelWoodTerrain.mdx"
        set .unitLights[4] = "Environment\\DNC\\DNCFelwood\\DNCFelWoodUnit\\DNCFelWoodUnit.mdx"
        
        set .terrainLights[5] = "Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdx"
        set .unitLights[5] = "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdx"
        
        set .terrainLights[6] = "Environment\\DNC\\DNCUnderground\\DNCUndergroundUnit\\DNCUndergroundUnit.mdx" // "Environment\\DNC\\DNCUnderground\\DNCUndergroundTerrain\\DNCUndergroundTerrain.mdx"
        set .unitLights[6] = "Environment\\DNC\\DNCUnderground\\DNCUndergroundUnit\\DNCUndergroundUnit.mdx"
        
        set .totalLights = 7
    endmethod
endstruct

struct TerrainFog extends array
    static constant integer LINEAR       = 0
    static constant integer EXPONENTIAL  = 1
    static constant integer EXPONENTIAL2 = 2

    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods
    
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("pLock", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("style", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("zStart", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("zEnd", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("density", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("red", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("green", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("blue", "real")
    
    method apply takes nothing returns nothing
        call SetTerrainFogEx(.style, .zStart, .zEnd, .density, .red, .green, .blue)
    endmethod
    
    method applyForPlayer takes player whichPlayer returns nothing
        if GetLocalPlayer() == whichPlayer then
            call this.apply()
        endif
    endmethod
        
    static method create takes nothing returns TerrainFog
        local TerrainFog this = TerrainFog.allocate()
        set this.style = 0
        return this
    endmethod
    
    method unlock takes nothing returns nothing
        local integer v
        if this.pLockExists() then
            set v = .pLock
            set v = v-1
            if v <= 0 then
                call this.pLockClear()
                call this.styleClear()
                call this.zStartClear()
                call this.zEndClear()
                call this.densityClear()
                call this.redClear()
                call this.greenClear()
                call this.blueClear()
                call this.deallocate()
            else
                set .pLock = v
            endif
        endif
    endmethod
    
endstruct



struct RectEnvironment extends array

    //! runtextmacro TableStruct_NewStructField("fog_impl", "TerrainFog")
    //! runtextmacro TableStruct_NewStructField("dnc_impl", "DNC")
    
    method operator fog takes nothing returns TerrainFog
        return .fog_impl
    endmethod
    method operator fog= takes TerrainFog fog returns nothing
        if this.fog != 0 then
            call this.fog.unlock()
        endif
        set this.fog_impl = fog
    endmethod
    
    method operator dnc takes nothing returns DNC
        return .dnc_impl
    endmethod
    method operator dnc= takes DNC dnc returns nothing
        if this.dnc != 0 then
            call this.dnc.unlock()
        endif
        set this.dnc_impl = dnc
    endmethod
    
    method hasFog takes nothing returns boolean
        return .fog_implExists()
    endmethod
    
    method apply takes nothing returns nothing        
        if this.fog != 0 then
            call this.fog.apply()
        else
            call ResetTerrainFog()
        endif
        if this.dnc != 0 then
            call this.dnc.apply()
        else
            call DNC.applyDefault()
        endif
    endmethod
    
    static method operator default takes nothing returns RectEnvironment
        return 0
    endmethod
    
    static method get takes rect r returns thistype
        return GetHandleId(r)
    endmethod
    
    method destroy takes nothing returns nothing
        call this.fog.unlock()
        call this.dnc.unlock()
        call this.fog_implClear()
        call this.dnc_implClear()
    endmethod
endstruct

endlibrary