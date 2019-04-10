library LoPPlayers requires TableStruct

struct LoP_PlayerData extends array
    
    
    
    static method get takes player whichPlayer returns LoP_PlayerData
        return GetPlayerId(whichPlayer)
    endmethod
    
    method toPlayerId takes nothing returns integer
        return this
    endmethod
    
    method toPlayerNumber takes nothing returns integer
        return this+1
    endmethod
    
    //==================================
    
    // Initialized in Init Main (probably should make an initializer module here, but... ^_^)
    static playercolor array playerColors

    // Why use an array and not ConvertPlayerColor? Because ConvertPlayerColor can crash.
    // Would make finding any bugs caused by this really hard, since it could happen anywhere.
    method getUnitColor takes nothing returns playercolor
        return playerColors[this]  
    endmethod
    
    method setUnitColor takes playercolor color returns nothing
        set playerColors[this] = color
    endmethod
    
    //==================================
    // Enable/Disable function (to be called by the Save System when loading)
    
    
    // Should add a timer to check if player finished loading, because they might not type -load end
    
    // Alternative: create seperate command trigger for each player. Disable it or destroy it when they leave the game.
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("commandsEnabled_internal","boolean")
    method enableCommands takes nothing returns nothing
        call commandsEnabled_internalClear()
    endmethod
    method disableCommands takes nothing returns nothing
        set commandsEnabled_internal = true
    endmethod
    method operator commandsEnabled takes nothing returns boolean
        return not commandsEnabled_internalExists()
    endmethod
    

endstruct



endlibrary