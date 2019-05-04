

library TerrainTools requires TableStruct

    struct TerrainType2Id extends array
        
        //! runtextmacro TableStruct_NewConstTableField("private","data")
        
        static method operator[] takes integer key returns integer
            return .data[key]
        endmethod
        
        static method operator[]= takes integer key, integer value returns nothing
            set .data[key] = value
        endmethod

    endstruct
    
    function GUMS_GetTerrainTileIndex takes integer terrainType returns integer
        return TerrainType2Id[terrainType]
    endfunction

    private module InitModule
        private static method onInit takes nothing returns nothing
            local integer i = 0
            
            // Terrain Settings
            set udg_TileSystem_ABILITIES[0] = 'A0BH'
            set udg_TileSystem_TILES[0] = 'Ygsb'
            set udg_TileSystem_ABILITIES[1] = 'A0BK'
            set udg_TileSystem_TILES[1] = 'Ngrs'
            set udg_TileSystem_ABILITIES[2] = 'A0BE'
            set udg_TileSystem_TILES[2] = 'cIc2'
            set udg_TileSystem_ABILITIES[3] = 'A0BI'
            set udg_TileSystem_TILES[3] = 'Yhdg'
            set udg_TileSystem_ABILITIES[4] = 'A0BF'
            set udg_TileSystem_TILES[4] = 'Ydrt'
            set udg_TileSystem_ABILITIES[5] = 'A0BM'
            set udg_TileSystem_TILES[5] = 'Frok'
            set udg_TileSystem_ABILITIES[6] = 'A0BO'
            set udg_TileSystem_TILES[6] = 'cWc1'
            set udg_TileSystem_ABILITIES[7] = 'A0BN'
            set udg_TileSystem_TILES[7] = 'Nrck'
            set udg_TileSystem_ABILITIES[8] = 'A0BJ'
            set udg_TileSystem_TILES[8] = 'Nice'
            set udg_TileSystem_ABILITIES[9] = 'A0BL'
            set udg_TileSystem_TILES[9] = 'Cvin'
            set udg_TileSystem_ABILITIES[10] = 'A0BP'
            set udg_TileSystem_TILES[10] = 'Adrd'
            set udg_TileSystem_ABILITIES[11] = 'A0BQ'
            set udg_TileSystem_TILES[11] = 'Olgb'
            set udg_TileSystem_ABILITIES[12] = 'A0BT'
            set udg_TileSystem_TILES[12] = 'Zsan'
            set udg_TileSystem_ABILITIES[13] = 'A0BS'
            set udg_TileSystem_TILES[13] = 'Ywmb'
            set udg_TileSystem_ABILITIES[14] = 'A0BU'
            set udg_TileSystem_TILES[14] = 'Yrtl'
            set udg_TileSystem_ABILITIES[15] = 'A0BG'
            set udg_TileSystem_TILES[15] = 'Ysqd'
            
            set i = 0
            loop
                exitwhen i > 15
                set TerrainType2Id[udg_TileSystem_TILES[i]] = i
                set i = i + 1
            endloop
        endmethod
    endmodule
    private struct InitStruct extends array
        implement InitModule
    endstruct



endlibrary