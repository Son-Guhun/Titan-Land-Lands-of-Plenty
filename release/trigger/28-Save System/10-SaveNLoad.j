library SaveNLoad requires WorldBounds, SaveIO, optional SaveNLoadConfig
////////////////////////////////////////////////////////////////////////////////////////////////////
//SaveNLoad v7.0
////////////////////////////////////////////////////////////////////////////////////////////////////
public constant function OLDFOLDER takes nothing returns string
    return "TitanLandLoP\\"
endfunction

public constant function FOLDER takes nothing returns string
    return "TLLoP\\Saves\\"
endfunction

struct SaveInstanceBase
    SaveWriter saveWriter
endstruct

module SaveInstanceBaseModule
    
    method operator saveWriter takes nothing returns SaveWriter
        return SaveInstanceBase(this).saveWriter
    endmethod
    
endmodule


struct SaveNLoad_PlayerData extends array
    
    private static real array loadCenter
    
    public method operator centerX takes nothing returns real
        return loadCenter[this]
    endmethod
    
    public method operator centerY takes nothing returns real
        return loadCenter[this + bj_MAX_PLAYERS]
    endmethod
    
    public method operator centerX= takes real value returns nothing
        set loadCenter[this] = value
    endmethod
    
    public method operator centerY= takes real value returns nothing
        set loadCenter[this + bj_MAX_PLAYERS] = value
    endmethod
    
endstruct

public function FormatString takes string prefix, string data returns string
    return SaveIO_FormatString(prefix, data)
endfunction

endlibrary