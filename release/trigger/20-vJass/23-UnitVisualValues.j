library UnitVisualValues

globals
    private hashtable hashTable = null
    
    private constant boolean INIT_HASHTABLE = true
endglobals

//==================================================================================================
//                                     Hashtable Declaration
//==================================================================================================

// Never use keyword to declare the hashtable at the bottom of the library. That generates callers
// that are unnecessary.

static if LIBRARY_HashtableWrapper and INIT_HASHTABLE then
    //! runtextmacro optional DeclareParentHashtableWrapperModule("hashTable","true", "data","public")
else
    //! runtextmacro DeclareHashTableWrapperModule("data")
endif

public struct data extends array
    static if LIBRARY_HashtableWrapper and INIT_HASHTABLE then
        implement optional data_ParentHashtableWrapper
    else
        implement data_HashTableWrapper
    endif
endstruct


// =========================================
//==========================================
//CONSTANTS FOR HASHTABLE ADDRESSES (Unit Handle Ids)
globals
    private constant integer COUNTER = -1  // Used to count if the unit has had their position set by the timer loop
    private constant integer TARGET_ANGLE = -2  // Used to store the final facing angle of an immovable unit that's turning
    private constant integer AUTO_LAND = -3
    private constant integer STRUCTURE_HEIGHT = -4 // This is only saved for structures, which lose their flying heights when moving
    
    private constant integer saveFlyHeight = -5  // Used to save flying height for immovable units (to keep height after upgrading)

    private constant integer SCALE  = 0
    public constant integer RED    = 1
    public constant integer GREEN  = 2
    public constant integer BLUE   = 3
    public constant integer ALPHA  = 4
    private constant integer COLOR  = 5
    private constant integer ASPEED = 6
    private constant integer ATAG   = 7
    private constant integer SELECT = 8
    private constant integer NAME   = 9
endglobals

//CONSTANTS FOR STATIC TABLES (Must be negative to avoid null-point exceptions of handles and conflics with handles)
globals
    public constant integer TAGS_DECOMPRESS = -1
    public constant integer TAGS_COMPRESS   = -2
endglobals

//==========================================
// GUMS Animation Tag Utilities
//! textmacro GUMS_RegisterTag takes FULL, COMPRESSED
    set UnitVisualValues_data_Child(TAGS_COMPRESS).string[StringHash("$FULL$")] = "$COMPRESSED$"
    set UnitVisualValues_data_Child(TAGS_DECOMPRESS).string[StringHash("$COMPRESSED$")] = "$FULL$"
//! endtextmacro

function GUMSConvertTags takes data_Child convertType, string whichStr returns string
    local string result = ""
    local string substring
    local integer cutToComma = CutToCharacter(whichStr, " ")
    local integer stringHash
    
    loop
        set substring = SubString(whichStr, 0, cutToComma)
        if substring != "" then
            set stringHash = StringHash(substring)
            if convertType.string.has(stringHash) then
                set result = result + convertType.string[stringHash] + " "
            else
                set result = result + whichStr + " "
                // call DisplayTextToPlayer(WHO?,0,0, whichStr + " is not a known tag. If you think this is wrong, please report it")
            endif
        endif
        
        exitwhen cutToComma >= StringLength(whichStr)-1
        set whichStr = SubString(whichStr, cutToComma + 1, StringLength(whichStr))
        set cutToComma = CutToCharacter(whichStr, " ")
    endloop
    if result == "" then
        return ""
    else
        return SubString(result,0,StringLength(result) - 1)
    endif
endfunction

//==========================================
// GUMS Getters

// Contains the Raw values of each UnitVisuals struct. Returned by the .raw method operator.
private struct UnitVisualsRaw extends array
    static if not INIT_HASHTABLE  and LIBRARY_HashtableWrapper then
        private method operator values takes nothing returns Table
            return data[this]
        endmethod
    else
        private method operator values takes nothing returns data_Child
            return data[this]
        endmethod
    endif
    
    method getScale takes nothing returns real
        return (.values.real[SCALE])
    endmethod
    
    method getVertexColor takes integer r1g2b3a4 returns integer
        return (.values[r1g2b3a4])
    endmethod
    
    method getVertexRed takes nothing returns integer
        return .getVertexColor(RED)
    endmethod
    
    method getVertexGreen takes nothing returns integer
        return .getVertexColor(GREEN)
    endmethod
    
    method getVertexBlue takes nothing returns integer
        return .getVertexColor(BLUE)
    endmethod
    
    method getVertexAlpha takes nothing returns integer
        return .getVertexColor(ALPHA)
    endmethod
    
    method getColor takes nothing returns integer
        return (.values[COLOR])
    endmethod
    
    method getAnimSpeed takes nothing returns real
        return (values.real[ASPEED])
    endmethod
    
    method getAnimTag takes nothing returns string
        return .values.string[ATAG]
    endmethod
endstruct

// Contains getters for all UnitVisualMods-related data. These getters return strings, not raw values.
struct UnitVisuals extends array
    static constant string allTags = "gold lumber work flesh ready one two throw slam large medium small victory alternate defend swim spin fast upgrade first second third fourth fifth"
    
    static if not INIT_HASHTABLE  and LIBRARY_HashtableWrapper then
        private method operator values takes nothing returns Table
            return data[this]
        endmethod
    else
        private method operator values takes nothing returns data_Child
            return data[this]
        endmethod
    endif
    
    method operator raw takes nothing returns UnitVisualsRaw
        return this
    endmethod
    
    static method get takes unit whichUnit returns UnitVisuals
        return GetHandleId(whichUnit)
    endmethod
    
    method hasScale takes nothing returns boolean
        return .values.real.has(SCALE)
    endmethod
    
    method hasVertexColor takes integer whichChannel returns boolean
        return .values.has(whichChannel)
    endmethod
    
    method hasVertexRed takes nothing returns boolean
        return .hasVertexColor(RED)
    endmethod
    
    method hasColor takes nothing returns boolean
        return .values.has(COLOR)
    endmethod
    
    method hasAnimSpeed takes nothing returns boolean
        return .values.real.has(ASPEED)
    endmethod
    
    method hasAnimTag takes nothing returns boolean
        return .values.string.has(ATAG)
    endmethod
    
    //THESE FUNCTIONS RETRIEVE THE SAVED VALUES IN THE HASHTABLE OR RETURN "D" IF THERE IS NO SAVED VALUE
    method getScale takes nothing returns string
        if .hasScale() then
            return R2S(.values.real[SCALE])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getVertexColor takes integer r1g2b3a4 returns string
        if .hasVertexColor(r1g2b3a4) then
            return I2S(.values[r1g2b3a4])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getVertexRed takes nothing returns string
        return .getVertexColor(RED)
    endmethod
    
    method getVertexGreen takes nothing returns string
        return .getVertexColor(GREEN)
    endmethod
    
    method getVertexBlue takes nothing returns string
        return .getVertexColor(BLUE)
    endmethod
    
    method getVertexAlpha takes nothing returns string
        return .getVertexColor(ALPHA)
    endmethod
    
    method getColor takes nothing returns string
        if .hasColor() then
            return I2S(.values[COLOR])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getAnimSpeed takes nothing returns string
        if .hasAnimSpeed() then
            return R2S(values.real[ASPEED])
        else
            return "D" //D stands for default
        endif
    endmethod
    
    method getAnimTag takes nothing returns string
        if .hasAnimTag() then
            return .values.string[ATAG]
        else
            return "D" //D stands for default
        endif
    endmethod
endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        static if INIT_HASHTABLE and LIBRARY_HashtableWrapper then
            set hashTable = InitHashtable()
        endif
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

//==================================================================================================
// Include this so it is declared even if HashtableWrapper library is not present
//! textmacro_once DeclareHashTableWrapperModule takes NAME

    module $NAME$_HashTableWrapper
        private static key table
        
        static if LIBRARY_ConstTable then
            static method operator [] takes integer index returns Table
                return ConstHashTable(table)[index]
            endmethod
            
            static method remove takes integer index returns nothing
                call ConstHashTable(table).remove(index)
            endmethod
            
            static method operator ConstHashTable takes nothing returns ConstHashTable
                return table
            endmethod
        else
            static method operator [] takes integer index returns Table
                return HashTable(table)[index]
            endmethod
            
            static method remove takes integer index returns nothing
                call HashTable(table).remove(index)
            endmethod
            
            static method operator HashTable takes nothing returns HashTable
                return table
            endmethod
        endif
    endmodule
//! endtextmacro
endlibrary