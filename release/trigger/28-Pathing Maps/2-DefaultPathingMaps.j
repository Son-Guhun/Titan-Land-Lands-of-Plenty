library DefaultPathingMaps requires PathingMaps, TableStruct, HashStruct, OOP

globals
    // Set this to true before creating a unit to avoid the application of its default pathing map.
    // This will automatially become false again if the unit is created sucessfully.
    // If CreateUnit returns null, then you will need to manually set this to false.
    public boolean dontApplyPathMap = false
endglobals

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
    
    //! runtextmacro OOP_HandleStruct("handle")
    
    // Returns false if:
    //  -> .update() has never been called.
    //  -> .update() has been called while .isDisabled was set to true.
    method operator isActive takes nothing returns boolean
        return .pathMap_exists() 
    endmethod
    
    method update takes PathingMap path, real x, real y, real ang returns thistype
    
        implement OOP_CatchNullPointer
    
        if this.isActive then
            call .pathMap.applyAtAngled(.x, .y, false, .angle)
        endif
        
        if path != 0 and not .isDisabled then
            call path.applyAtAngled(x, y, true, ang)
            set .pathMap = path
            set .x = x
            set .y = y
            set .angle = ang
        else
            call .tab.flush()  // this makes this.isActive() return false
        endif
        
        return this
    endmethod
    
    method deActivate takes nothing returns thistype
        return .update(0, 0, 0, 0)
    endmethod
    
    method disableAndTransfer takes handle receiver returns nothing
        local thistype receiverData = get(receiver)
        
        implement OOP_CatchNullPointer
        
        if receiverData.isActive then
            call receiverData.pathMap.applyAtAngled(receiverData.x, receiverData.y, false, receiverData.angle)
        endif
        
        if this.isActive then
            set receiverData.pathMap = .pathMap
            set receiverData.x = .x
            set receiverData.y = .y
            set receiverData.angle = .angle
            
            call this.tab.flush()
        endif
        
        set receiverData.isDisabled = .isDisabled
        set this.isDisabled = true
    endmethod

    method destroy takes nothing returns nothing
        call .update(0, 0, 0, 0).isDisabledClear()
    endmethod

endstruct

struct paths extends array

    private static key static_memebers_key
    //! runtextmacro TableStruct_NewConstTableField("private", "tab")
    
    static method operator [] takes string s returns integer
        return tab[StringHash(s)]
    endmethod
    
    static method operator []= takes string s, PathingMap i returns nothing
        set tab[StringHash(s)] = i
    endmethod

endstruct

//struct ObjectPathMap extends array
//    /*This struct contains data about an objects unique pathing map */
//    
//    //! runtextmacro TableStruct_NewStructField("pathMap", "PathingMap")
//    //! runtextmacro TableStruct_NewPrimitiveField("offsetX", "real")
//    //! runtextmacro TableStruct_NewPrimitiveField("offsetY", "real")
//    
//    method update takes real x, real y, real angle returns nothing
//        local real sin = Sin(angle)
//        local real cos = Cos(angle)
//        local real offsetX = .offsetX
//        local real offsetY = .offsetY
//    
//        set x = (offsetX*cos - offsetY*sin) + x
//        set y = (offsetX*sin + offsetY*cos) + y
//        
//        call ObjectPathing(this).update(.pathMap, x, y, angle)
//    endmethod
//
//endstruct

struct DefaultPathingMap extends array

    //! runtextmacro TableStruct_NewStructField("path", "PathingMap")

    static method fromTypeOfUnit takes unit u returns thistype
        return GetUnitTypeId(u)
    endmethod
    
    method hasPathing takes nothing returns boolean
        return .pathExists()
    endmethod

    private static method onInit takes nothing returns nothing
        local LinkedHashSet tiles
        
        //! runtextmacro InitializePathingsMapFromFiles()
        
        //! runtextmacro GeneratedDecorationPathMaps()
    endmethod
    
    //! textmacro DefaultPathingMapsUpdate
        local real offsetX =  -path.height*15.99  // Multiplying by 16. instead of 15.99 is currently a hacky way to avoid rounding issues with 90/180/270 degrees
        local real offsetY =  -path.width*15.99
        local real sin = Sin(ang)
        local real cos = Cos(ang)
        local ObjectPathing lastPathData = ObjectPathing.get(h)
        
        set x = (offsetX*cos - offsetY*sin) + x
        set y = (offsetX*sin + offsetY*cos) + y
        
        call lastPathData.update(path, x, y, ang)
    //! endtextmacro
    
    
    method update takes handle h, real x, real y, real ang returns nothing
        local PathingMap path = this.path
        //! runtextmacro DefaultPathingMapsUpdate()
    endmethod

    static method onMove takes unit h, real x, real y returns nothing   
        local real ang = GetUnitFacing(h)*bj_DEGTORAD
        local PathingMap path = fromTypeOfUnit(h).path
        //! runtextmacro DefaultPathingMapsUpdate()
    endmethod
    
    static method onSetFacing takes unit h, real angle returns nothing
        local real ang = angle*bj_DEGTORAD
        local real x = GetUnitX(h)
        local real y = GetUnitY(h)
        local PathingMap path = fromTypeOfUnit(h).path
        //! runtextmacro DefaultPathingMapsUpdate()
    endmethod

endstruct

endlibrary