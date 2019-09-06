library TerrainTools requires Table

//! textmacro TerrainTools_InitTextureArray

    // There must be no actual textures after the first 0.
    set TEXTURES[0]  = 'Ygsb'
    set TEXTURES[1]  = 'Ngrs'
    set TEXTURES[2]  = 'cIc2'
    set TEXTURES[3]  = 'Yhdg'
    set TEXTURES[4]  = 'Ydrt'
    set TEXTURES[5]  = 'Frok'
    set TEXTURES[6]  = 'cWc1'
    set TEXTURES[7]  = 'Nrck'
    set TEXTURES[8]  = 'Nice'
    set TEXTURES[9]  = 'Cvin'
    set TEXTURES[10] = 'Adrd'
    set TEXTURES[11] = 'Olgb'
    set TEXTURES[12] = 'Zsan'
    set TEXTURES[13] = 'Ywmb'
    set TEXTURES[14] = 'Yrtl'
    set TEXTURES[15] = 'Ysqd'
//! endtextmacro

scope SHAPE
    globals
        public constant integer CIRCLE = 0
        public constant integer SQUARE = 1
    endglobals
endscope

globals
    private integer array TEXTURES
    private integer totalTextures
    
    private constant key TEXTURE2ID
endglobals

public function AddNewTexture takes integer texture returns boolean
    if totalTextures < 16 then
        set TEXTURES[totalTextures] = texture
        set Table(TEXTURE2ID)[texture] = totalTextures
        set totalTextures = totalTextures + 1
        return true
    endif
    return false
endfunction

public function GetTexture takes integer index returns integer
    return TEXTURES[index]
endfunction

public function GetTextureId takes integer texture returns integer
    return Table(TEXTURE2ID)[texture]
endfunction

private module InitModule
    private static method onInit takes nothing returns nothing
        local integer i = 0
        //! runtextmacro TerrainTools_InitTextureArray()
        
        loop
        exitwhen TEXTURES[i] == 0
            set Table(TEXTURE2ID)[TEXTURES[i]] = i
            set i = i + 1
        endloop
        set totalTextures = i
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct
endlibrary