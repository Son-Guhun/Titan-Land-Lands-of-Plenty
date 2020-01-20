library MultiBoard requires GLHS, TableStruct


struct MultiBoard extends array

    //! runtextmacro TableStruct_NewReadonlyStructField("items", "Table")
    
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("cols", "integer")
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("rows", "integer")
    
    //! runtextmacro TableStruct_NewReadonlyAgentField("multiboard", "multiboard")
    
    method get takes integer i, integer j returns multiboarditem
        return .items[i].multiboarditem[j]
    endmethod
    
    method setValue takes integer i, integer j, string value returns nothing
        call MultiboardSetItemValue(.get(i,j), value)
    endmethod
    
    method setValueColor takes integer i, integer j, integer r , integer g, integer b, integer a returns nothing
        call MultiboardSetItemValueColor(.get(i,j), r, g, b, a)
    endmethod
    
    method setIcon takes integer i, integer j, string iconFileName returns nothing
        call MultiboardSetItemIcon(.get(i,j), iconFileName)
    endmethod
    
    method setStyle takes integer i, integer j, boolean showValue, boolean showIcon returns nothing
        call MultiboardSetItemStyle(.get(i,j), showValue, showIcon)
    endmethod
    
    method setWidth takes integer i, integer j, real width returns nothing
        call MultiboardSetItemWidth(.get(i,j), width)
    endmethod
    
    static method refresh takes multiboard mb returns MultiBoard
        local integer this = GetHandleId(mb)
        local integer rows = MultiboardGetRowCount(mb)
        local integer cols = MultiboardGetColumnCount(mb)
        
        local integer oldCols = .cols
        local integer oldRows = .rows
        
        local integer i = 0
        local integer j
        
        if .items == 0 then
            set .items = Table.create()
            set .multiboard = mb
        endif

        loop
        exitwhen i >= rows
            if i >= oldRows then
                set .items[i] = Table.create()
                set j = 0
            else
                set j = cols
                loop
                exitwhen j >= oldCols
                    call MultiboardReleaseItem(.items[i].multiboarditem[j])
                    call .items[i].handle.remove(j)
                    set j = j + 1
                endloop
                set j = oldCols
            endif
            set .items[0] = Table.create()
            loop
            exitwhen j >= cols
                set .items[i].multiboarditem[j] = MultiboardGetItem(mb, i, j)
                set j = j + 1
            endloop
            set i = i + 1
        endloop
        
        loop
        exitwhen i >= oldCols
            set j = 0
            loop
                exitwhen j >= oldCols
                call MultiboardReleaseItem(items[i].multiboarditem[j])
                set j = j + 1
            endloop
            call .items[i].destroy()
            set i = i + 1
        endloop
        
        set .cols = cols
        set .rows = rows
    
        return this
    endmethod
    
    // TODO:
    method destroy takes nothing returns nothing
        call .itemsClear()
        call .rowsClear()
        call .colsClear()
        call .multiboardClear()
    endmethod

endstruct

endlibrary