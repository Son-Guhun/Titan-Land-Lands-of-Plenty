library UnitVisualModsCopy requires UnitVisualValues

public module Module
    static method CopyValues takes unit source, unit target returns nothing
        local real fangle = GetUnitFacing(source)
        local UnitVisuals sourceId = GetHandleId(source)
        //! runtextmacro ASSERT("source != null")
        //! runtextmacro ASSERT("target != null")
        
        if IsUnitType(target, UNIT_TYPE_STRUCTURE) then
            call thistype.StructureFlyHeight(target, GetUnitFlyHeight(source), GetUnitAbilityLevel(source, 'DEDF') == 0)
        else
            call thistype.FlyHeight(target, GetUnitFlyHeight(source))
        endif
        
        if sourceId.hasScale() then
            call thistype.Scale(target, sourceId.raw.getScale())
        endif
        if sourceId.hasVertexColor(UnitVisualValues_RED) then
            call thistype.VertexColorInt(target, sourceId.raw.getVertexRed(), sourceId.raw.getVertexGreen(), sourceId.raw.getVertexBlue(), sourceId.raw.getVertexAlpha())
        endif
        if sourceId.hasColor() then
            call thistype.Color(target, sourceId.raw.getColor())
        endif
        if sourceId.hasAnimSpeed() then
            call thistype.AnimSpeed(target, sourceId.raw.getAnimSpeed())
        endif
        if sourceId.hasAnimTag() then
            call thistype.AnimTag(target, sourceId.raw.getAnimTag())
        endif
    endmethod

    // Creates a new unit and copies all the GUMS values from the old unit to the newly created one.
    // bj_lastCreatedUnit is set to the newly created unit.
    // If the specified newType is nonpositive, then the created unit will have the same type as the copied one
    static method Copy takes unit whichUnit, player owner, integer newType returns unit
        local real fangle = GetUnitFacing(whichUnit)
        local unit newUnit
        //! runtextmacro ASSERT("whichUnit != null")
        
        if newType < 1 then
            set newType = GetUnitTypeId(whichUnit)
        endif
        set newUnit = CreateUnit( owner, newType, GetUnitX(whichUnit), GetUnitY(whichUnit), fangle)
        
        call CopyValues(whichUnit, newUnit)
        
        set bj_lastCreatedUnit = newUnit
        set newUnit = null
        return bj_lastCreatedUnit
    endmethod

    static method CopySameType takes unit whichUnit, player owner returns unit
        return Copy(whichUnit, owner, 0)
    endmethod

endmodule

endlibrary