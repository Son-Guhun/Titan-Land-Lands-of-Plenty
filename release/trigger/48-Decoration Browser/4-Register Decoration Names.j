library RegisterDecorationNames requires StringHashEx, HashStruct, Table, optional LoPUnitCompatibility
/*
This library defines DecorationListTemplate, a module used to create a searchable list. To see an example
of this module in use, see the "Register Classic Decorations" or "Register Reforged Decorations" triggers.

module DecorationListTemplate

static method get takes string searchStr returns thistype
- This is a factory method to return a sublist of the complete list. The sublist will contain all
strings which have "searchStr" as a substring. This is not case-sensitive.

endmodule
*/


//! runtextmacro optional LoPUnitCompatibility()

private function StringHash takes string str returns integer
    return StringHashEx(str)
endfunction

function StringContains takes string str, string subStr returns boolean
    local integer step = StringLength(subStr)
    local integer size = StringLength(str)
    local integer i = size - step
    
    loop
        exitwhen i < 0
        if SubString(str, i, i+step) == subStr then
            return true
        endif
        
        set i = i - 1
    endloop
    return false
endfunction

module DecorationListTemplate

    method operator[] takes integer index returns integer
        return thistype.getChildTable(this)[index]
    endmethod
    
    method operator[]= takes integer index, integer newVal returns nothing
        set thistype.getChildTable(this)[index] = newVal
    endmethod
    
    private method calculateSize takes string searchStr, thistype list returns integer
        local integer i = 0
        local integer size = 0
        local integer rawcode
        // populate a new list using the first 4 chars
        
        loop
            exitwhen i >=  list.size
            set rawcode = list[i]
            
            if StringContains(StringCase(GetObjectName(rawcode), false), searchStr) then
                set this[size] = rawcode
                set size = size + 1
            endif
        
            set i = i + 1
        endloop
        
        if size > 0 then
            set .size = size
        endif
        return size
    endmethod
    
    // if the size of a substr is equal to size of the current search, then return substr 
    private method a takes string searchStr returns string
        local integer i = StringLength(searchStr) - 1
        local thistype hash = StringHash(SubString(searchStr, 0, 4))

        if hash.size > 0 then
            loop
                exitwhen i < 4
                set hash = StringHash(SubString(searchStr, 0, i))
                if hash.size > 0 then
                    return SubString(searchStr, 0, i)
                else
                    // This block would not exist if the lists for all substrings is already calculated
                    // You could just get the sub of the sub instead (it would always be a valid list)
                    if not hash.sub_exists() then
                        set hash.sup = this
                    endif
                endif
                
                set i = i - 1
            endloop
        endif
        
        return null
    endmethod
    
    static method get takes string searchStr returns thistype
        local thistype this = StringHash(searchStr)
        local thistype sub
        local string temp
        
        if this.sub_exists() then
            set sub = this.sub
            // This block would not exist if the lists for all substrings is already calculated
            if sub.sub_exists() then
                loop
                    set this.sub = sub.sub
                    set this = sub
                    set sub = sub.sub
                    exitwhen not sub.sub_exists()
                endloop
            endif
            set this = sub
        elseif not this.size_exists() then
            if StringLength(searchStr) > 4 then
                set temp = .a(searchStr)
                if temp != null then
                    set sub = StringHash(temp)
                    
                    if .calculateSize(searchStr, sub) == sub.size then
                        call getChildTable(this).flush()
                        set .sub = sub
                        set this = sub
                    endif
                    
                    // This block would not exist if the lists for all substrings is already calculated
                    if this.sup_exists() and this.sup.size == this.size then
                        call getChildTable(this.sup).flush()
                        if this.sub_exists() then
                            set this.sup.sub = this.sub
                        else
                            set this.sup.sub = this
                        endif
                        call this.sup_clear()
                    endif
                endif
                
            endif
        endif
        
        return this
    endmethod
endmodule


//! textmacro RegisterDecorationNamesFunctionTemplate takes TYPENAME
    globals
        private key seen
    endglobals

    private function RegisterThing takes integer rawcode returns nothing
        local string str = GetObjectName(rawcode)
        local integer i = 0
        local integer j = 1
        local string subStr
        local integer size = StringLength(str)
        local integer lastIndex = IMinBJ(i+4, size)
        local $TYPENAME$ hash
        
        call Table(seen).flush()
        set str = StringCase(str, false)
        
        set hash = StringHash("")
        set hash[hash.size] = rawcode
        set hash.size = hash.size + 1
        loop
            exitwhen i == size
            set subStr = SubString(str, i, j)
            
            
            set hash = StringHash(subStr)
            if not Table(seen).boolean.has(hash) then
                set hash[hash.size] = rawcode
                set hash.size = hash.size + 1
                set Table(seen).boolean[hash] = true
            endif
            

            if j == lastIndex then
                set i = i + 1
                set j = i + 1
                if i+4 >= size then
                    set lastIndex = size
                else
                    set lastIndex = i+4
                endif
            else
                set j = j + 1
            endif
        endloop
    endfunction
//! endtextmacro


endlibrary