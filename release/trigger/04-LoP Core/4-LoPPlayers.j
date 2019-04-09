library LoPPlayers

struct LoP_PlayerData extends array
    
    // Initialized in Init Main (probably should make an initializer module here, but... ^_^)
    static playercolor array playerColors
    
    static method get takes player whichPlayer returns LoP_PlayerData
        return GetPlayerId(whichPlayer)
    endmethod
    
    method toPlayerId takes nothing returns integer
        return this
    endmethod
    
    method toPlayerNumber takes nothing returns integer
        return this+1
    endmethod

    // Why use an array and not ConvertPlayerColor? Because ConvertPlayerColor can crash.
    // Would make finding any bugs caused by this really hard, since it could happen anywhere.
    method getUnitColor takes nothing returns playercolor
        return playerColors[this]  
    endmethod
    
    method setUnitColor takes playercolor color returns nothing
        set playerColors[this] = color
    endmethod

endstruct



endlibrary