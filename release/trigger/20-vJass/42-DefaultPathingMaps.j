library DefaultPathingMaps requires PathingMaps, TableStruct, HashStruct

// When unit has a larger scale, also apply this scale to the pathing map by getting a larger one (default maps only)
// By default offset will be set so the pathing map is centralized
// Ability to remove pathing map will replace the self-destruct ability

globals
        private hashtable hashTableHandle = InitHashtable()
endglobals  

//! runtextmacro DeclareParentHashtableWrapperModule("hashTableHandle", "true", "hT", "public")
//! runtextmacro DeclareParentHashtableWrapperStruct("hT","public")

struct ObjectPathing extends array
    /* This struct stores pathing data for the currently active pathing map on an object */
    
    //! runtextmacro TableStruct_NewPrimitiveField("isDisabled", "boolean")

    
    //! runtextmacro HashStruct_SetHashtableWrapper("DefaultPathingMaps_hT")


    //! runtextmacro HashStruct_NewReadonlyStructField("pathMap", "PathingMap")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("x", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("y", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("angle", "real")
    
    static method get takes handle h returns thistype
        return GetHandleId(h)
    endmethod
    
    method exists takes nothing returns boolean
        return .pathMap_exists() 
    endmethod
    
    method update takes PathingMap path, real x, real y, real ang returns thistype
    
        if this.exists() then
            call .pathMap.applyAtAngledSimple(.x, .y, false, .angle)
            // call path.createImages(x0, y0, true, ang)
        endif
        
        if path != 0 and not .isDisabled then
            // call path.createImages(x0, y0, true, ang)
            call path.applyAtAngledSimple(x, y, true, ang)
            set .pathMap = path
            set .x = x
            set .y = y
            set .angle = ang
        else
            call .tab.flush()
        endif
        
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        call .update(0, 0, 0, 0).isDisabledClear()
    endmethod

endstruct

struct ObjectPathMap extends array
    /*This struct contains data about an objects unique pathing map */
    
    //! runtextmacro TableStruct_NewStructField("pathMap", "PathingMap")
    //! runtextmacro TableStruct_NewPrimitiveField("offsetX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("offsetY", "real")
    
    method update takes real x, real y, real angle returns nothing
        local real sin = Sin(angle)
        local real cos = Cos(angle)
        local real offsetX = .offsetX
        local real offsetY = .offsetY
    
        set x = (offsetX*cos - offsetY*sin) + x
        set y = (offsetX*sin + offsetY*cos) + y
        
        call ObjectPathing(this).update(.pathMap, x, y, angle)
    endmethod

endstruct

struct DefaultPathingMap extends array

    //! runtextmacro TableStruct_NewStructField("path", "PathingMap")

    static method get takes unit whichUnit returns thistype
        return GetUnitTypeId(whichUnit)
    endmethod
    
    method hasPathing takes nothing returns boolean
        return .pathExists()
    endmethod

    private static method onInit takes nothing returns nothing
        set thistype('e00B').path = PathingMap.getGeneric(5, 2)
        set thistype('Hart').path = PathingMap.getGeneric(5, 5)
        set thistype('Harf').path = PathingMap.getGeneric(10, 10)
    endmethod
    
    //! textmacro DefaultPathingMapsUpdate
        local PathingMap path = get(u).path
        local real offsetX =  -path.width*16.
        local real offsetY =  -path.height*16.
        local real sin = Sin(ang)
        local real cos = Cos(ang)
        local ObjectPathing lastPathData = ObjectPathing.get(u)
        
        set x = (offsetX*cos - offsetY*sin) + x
        set y = (offsetX*sin + offsetY*cos) + y
    
        call lastPathData.update(path, x, y, ang)
    //! endtextmacro
    

    static method onMove takes unit u, real x, real y returns nothing   
        local real ang = GetUnitFacing(u)*bj_DEGTORAD
        //! runtextmacro DefaultPathingMapsUpdate()
    endmethod
    
    static method onSetFacing takes unit u, real angle returns nothing
        local real ang = angle*bj_DEGTORAD
        local real x = GetUnitX(u)
        local real y = GetUnitY(u)
        //! runtextmacro DefaultPathingMapsUpdate()
    endmethod

endstruct

endlibrary