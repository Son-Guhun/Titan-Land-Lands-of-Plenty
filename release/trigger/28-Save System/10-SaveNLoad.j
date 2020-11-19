library SaveNLoadConfig requires LoPHeader, LoPNeutralUnits
    
public function StructureShouldAutoLand takes unit structure returns boolean
    return not LoP_IsUnitDecoration(structure)
endfunction    

endlibrary

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

public struct BoolFlags extends array
    static method isAnyFlag takes integer data, integer flags returns boolean
        return BlzBitAnd(data, flags) > 0
    endmethod
    
    static method isAllFlags takes integer data, integer flags returns boolean
        return BlzBitAnd(data, flags) == flags
    endmethod

    static constant method operator UNROOTED takes nothing returns integer
        return 1
    endmethod
    
    static constant method operator NEUTRAL takes nothing returns integer
        return 2
    endmethod
    
    static constant method operator FLAG_3 takes nothing returns integer
        return 4
    endmethod
endstruct

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

globals
    public boolean AUTO_LAND = false  // Can be overwritten by SaveNLoadConfig StructureShouldAutoLand
endglobals

public function FormatString takes string prefix, string data returns string
    return SaveIO_FormatString(prefix, data)
endfunction

function LoadDestructable takes string chatStr, real centerX, real centerY returns nothing
    local integer destType
    local real destX
    local real destY
    local integer cutToComma
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destType = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destX = S2R(SubString(chatStr,0,cutToComma)) + centerX
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destY = S2R(SubString(chatStr,0,cutToComma)) + centerY
    //set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    if IsPointInRegion(WorldBounds.worldRegion, destX, destY) then
        set bj_lastCreatedDestructable = CreateDestructable(destType, destX, destY, 270, 1, 0)
        //if not IsDestructableTree(bj_lastCreatedDestructable) then
          //  call RemoveDestructable(bj_lastCreatedDestructable)
        //endif
    endif
endfunction


endlibrary