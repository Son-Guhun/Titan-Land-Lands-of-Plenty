library UnitVisualValues requires HashtableWrapper, CutToComma

globals
    private constant boolean INIT_HASHTABLE = true // Set this to false if you want to use a Table-based HashTable.
    private hashtable hashTable = InitHashtable()  // Set this to null if you want to use a Table-based HashTable.
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

private module Constants
    // SELECTION TYPE CONSTANTS
    static constant integer SELECTION_DEFAULT      = 0
    static constant integer SELECTION_DRAG         = 1  // Units that can only be drag-selected.
    static constant integer SELECTION_UNSELECTABLE = 2  // Units that are unselectable and may be converted to SFX.
    static constant integer SELECTION_LOCUST       = 3  // Units that are unselectable and should not be converted to SFX.
    
    static constant real MIN_FLY_HEIGHT = 0.02
endmodule

//==========================================
// GUMS Animation Tag Utilities


//==========================================
// GUMS Getters

//! textmacro UnitVisualValues_DeclareValuesField
    static if not INIT_HASHTABLE  and LIBRARY_HashtableWrapper then
        private method operator values takes nothing returns Table
            return data[this]
        endmethod
    else
        private method operator values takes nothing returns data_Child
            return data[this]
        endmethod
    endif
//! endtextmacro

// Contains the Raw values of each UnitVisuals struct. Returned by the .raw method operator.
private struct UnitVisualsRaw extends array

    //! runtextmacro UnitVisualValues_DeclareValuesField()
    
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
    
    method getSelectionType takes nothing returns integer
        return .values[SELECT]
    endmethod
endstruct

// Contains getters for all UnitVisualMods-related data. These getters return strings, not raw values.
struct UnitVisuals extends array
    static constant string allTags = "gold lumber work flesh ready one two throw slam large medium small victory alternate defend swim spin fast upgrade first second third fourth fifth"
    implement Constants
    
    //! runtextmacro UnitVisualValues_DeclareValuesField()
    
    method operator raw takes nothing returns UnitVisualsRaw
        return this
    endmethod
    
    static method get takes unit whichUnit returns UnitVisuals
        return GetHandleId(whichUnit)
    endmethod
    
    static method operator[] takes unit whichUnit returns UnitVisuals
        return get(whichUnit)
    endmethod
    
    method destroy takes nothing returns nothing
        call data.flushChild(this)
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
    
    method getSelectionType takes nothing returns string
        return I2S(.raw.getSelectionType())
    endmethod
    
    method hasCustomName takes nothing returns boolean
        return .values.string.has(NAME)
    endmethod
    
    method getOriginalName takes nothing returns string
        return .values.string[NAME]
    endmethod
    
    static method getUnitName takes unit u returns string
        local string name = GetUnitName(u)
        //! runtextmacro ASSERT("whichUnit != null")
        
        if thistype[u].hasCustomName() then
            return SubString(name, 10, StringLength(name) - 2)
        else
            return name
        endif
    endmethod

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