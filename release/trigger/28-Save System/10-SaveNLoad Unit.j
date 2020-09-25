library SaveNLoadUnit requires SaveNLoad, UnitVisualMods, AnyBase, DecorationSFX, UnitTypeDefaultValues, AttachedSFX, optional LoPDeprecated

globals
    private constant key forbiddenTypes // ConstTable
endglobals

function SaveNLoad_ForbidUnitType takes integer unitType returns nothing
    set ConstTable(forbiddenTypes).boolean[unitType] = false
endfunction

function ParseScaleEffect takes DecorationEffect sfx, string scaleStr returns nothing
    local real scaleX
    local real scaleY
    local real scaleZ
    local integer cutToComma = CutToCharacter(scaleStr,"|")
    
    set scaleX = S2R(SubString(scaleStr, 0, cutToComma))
    if cutToComma < StringLength(scaleStr) then
        set scaleStr = SubString(scaleStr, cutToComma+1, StringLength(scaleStr))
        
        set cutToComma = CutToCharacter(scaleStr,"|")
        set scaleY = S2R(SubString(scaleStr, 0, cutToComma))
        set scaleZ = S2R(SubString(scaleStr, cutToComma+1, StringLength(scaleStr)))
        
        call sfx.setScale(scaleX, scaleY, scaleZ)
    else
        call sfx.setScale(scaleX, scaleX, scaleX)
    endif
endfunction

function LoadSpecialEffect takes player owner, UnitTypeDefaultValues unitType, real x, real y, real height, real facing, real pitch, real roll, string scale, string red, string green, string blue, string alpha, string color, string aSpeed, string aTags returns nothing
    local DecorationEffect result = DecorationEffect.create(owner, unitType, x, y)
    local real value
    local integer redRaw
    local integer greenRaw
    
    set result.height = height
    call result.setOrientation(facing*bj_DEGTORAD, pitch, roll)
    // set result.yaw = Deg2Rad(facing)
    
    if scale != "D" then
        call ParseScaleEffect(result, scale)
    elseif unitType.hasModelScale() then
        set value = unitType.modelScale
        call result.setScale(value, value, value)
    endif
    
    if red != "D" then
        call result.setVertexColor(S2I(red), S2I(green), S2I(blue))
        set result.alpha = S2I(alpha)
    else
        if unitType.hasRed() then
            set redRaw = unitType.red
        else
            set redRaw = 255
        endif
        if unitType.hasGreen() then
            set greenRaw = unitType.green
        else
            set greenRaw = 255
        endif
        if unitType.hasBlue() then
            call result.setVertexColor(redRaw, greenRaw, unitType.blue)
        else
            if greenRaw != 255 and redRaw != 255 then
                call result.setVertexColor(redRaw, greenRaw, 255)
            endif
        endif
    endif
    
    if color != "D" then
        set result.color = S2I(color) - 1
    endif
    
    if aSpeed != "D" then
        set result.animationSpeed = S2R(aSpeed)
    endif
    
    if aTags != "D" then
        call AddTagsStringAsSubAnimations(result, GUMSConvertTags(UnitVisualMods_TAGS_DECOMPRESS, aTags), true)
    endif
    
    if unitType.hasMaxRoll() then
        set result.roll = Deg2Rad(unitType.maxRoll+180.)
    endif
    
    call BlzPlaySpecialEffect(result.effect, ANIM_TYPE_STAND)
endfunction

function ParseScale takes unit u, string scaleStr returns nothing
    local real scaleX
    local real scaleY
    local real scaleZ
    local integer cutToComma = CutToCharacter(scaleStr,"|")
    
    set scaleX = S2R(SubString(scaleStr, 0, cutToComma))
    if cutToComma < StringLength(scaleStr) then
        set scaleStr = SubString(scaleStr, cutToComma+1, StringLength(scaleStr))
        
        set cutToComma = CutToCharacter(scaleStr,"|")
        set scaleY = S2R(SubString(scaleStr, 0, cutToComma))
        set scaleZ = S2R(SubString(scaleStr, cutToComma+1, StringLength(scaleStr)))
        
        call GUMSSetUnitMatrixScale(u, scaleX, scaleY, scaleZ)
    else
        call GUMSSetUnitScale(u, scaleX)
    endif
endfunction

struct UnitSaveFields extends array

    implement ExtendsTable

    //! runtextmacro HashStruct_NewPrimitiveField("unitType", "integer")
    //! runtextmacro HashStruct_NewPrimitiveField("x", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("y", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("flyHeight", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("yaw", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("pitch", "real")
    //! runtextmacro HashStruct_NewPrimitiveField("roll", "real")
    
    //Values saved by GUMS
    //! runtextmacro HashStruct_NewPrimitiveField("size", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("red", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("green", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("blue", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("alpha", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("color", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("animSpeed", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("animTag", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("selectState", "string")
    //! runtextmacro HashStruct_NewPrimitiveField("flags", "integer")
    
    method parseFacing takes string scaleStr returns nothing
        local real yaw
        local integer cutToComma = CutToCharacter(scaleStr,"|")
        
        set yaw = S2R(SubString(scaleStr, 0, cutToComma))
        if cutToComma < StringLength(scaleStr) then
            set scaleStr = SubString(scaleStr, cutToComma+1, StringLength(scaleStr))
            
            set cutToComma = CutToCharacter(scaleStr,"|")
            set .pitch = S2R(SubString(scaleStr, 0, cutToComma))/128
            set .roll = S2R(SubString(scaleStr, cutToComma+1, StringLength(scaleStr)))/128
            set .yaw = yaw/128*bj_RADTODEG
        else
            set .pitch = 0.
            set .roll = 0.
            set .yaw = yaw
        endif
    endmethod
    
    static method create takes integer un_type, string chat_str, real centerX, real centerY returns thistype
        local integer str_index
        local thistype this = Table.create()
        local integer len_str = StringLength(chat_str)

        set str_index = CutToComma(chat_str)
        set .x = S2R(SubString(chat_str,0,str_index)) + centerX
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)

        set str_index = CutToComma(chat_str)
        set .y = S2R(SubString(chat_str,0,str_index)) + centerY
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)

        set str_index = CutToComma(chat_str)
        set .flyHeight = S2R(SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)

        set str_index = CutToComma(chat_str)
        call .parseFacing(SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)
        
        if chat_str != "" then //Version 1 backwards compatibility
            set str_index = CutToComma(chat_str)
            set .size = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str)
            
            set str_index = CutToComma(chat_str)
            set .red = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str) 
            
            set str_index = CutToComma(chat_str)
            set .green = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str)
            
            set str_index = CutToComma(chat_str)
            set .blue = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str)
            
            set str_index = CutToComma(chat_str)
            set .alpha = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str)
            
            set str_index = CutToComma(chat_str)
            set .color = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str)
            
            set str_index = CutToComma(chat_str)
            set .animSpeed = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str)
            
            if chat_str != "" then
                set str_index = CutToComma(chat_str)
                set .animTag = (SubString(chat_str,0,str_index))
                set chat_str = SubString(chat_str,str_index+1,len_str)
                set len_str = StringLength(chat_str)
                if chat_str != "" then
                    set str_index = CutToComma(chat_str)
                    set .selectState = (SubString(chat_str,0,str_index))
                    set chat_str = SubString(chat_str,str_index+1,len_str+1)
                    set len_str = StringLength(chat_str)
                    if chat_str != "" then
                        set str_index = CutToComma(chat_str)
                        set .flags = S2I(SubString(chat_str,0,str_index))  // TODO: When max flag is larger than 4, we need to use AnyBase(92)
                    else
                        set .flags = 0
                        // set chat_str = SubString(chat_str,str_index+1,len_str+1)
                        // set len_str = StringLength(chat_str)
                    endif
                endif
            endif
            
        endif
        
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        call Table(this).destroy()
    endmethod

endstruct

function LoadUnitFlags takes unit whichUnit, integer flags returns nothing

    if IsUnitType(whichUnit, UNIT_TYPE_ANCIENT) and SaveNLoad_BoolFlags.isAnyFlag(flags, SaveNLoad_BoolFlags.UNROOTED) then
        call IssueImmediateOrder(whichUnit, "unroot")
    elseif DefaultPathingMap.get(whichUnit).hasPathing() then
    
        if SaveNLoad_BoolFlags.isAnyFlag(flags, SaveNLoad_BoolFlags.UNROOTED) then
            set ObjectPathing.get(whichUnit).isDisabled = false
            call DefaultPathingMap.get(whichUnit).update(whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFacing(whichUnit)*bj_DEGTORAD)
        else
            set ObjectPathing.get(whichUnit).isDisabled = true
        endif
    endif
    
    if SaveNLoad_BoolFlags.isAnyFlag(flags, SaveNLoad_BoolFlags.NEUTRAL) then
        call LoP_GiveToNeutral(whichUnit)
    endif
endfunction

function LoadUnit takes string chat_str, player un_owner, real centerX, real centerY returns nothing
    local integer str_index
    local integer un_type
    local integer len_str = StringLength(chat_str)
    local unit resultUnit
    local SaveNLoad_PlayerData playerId = GetPlayerId(un_owner)
    local UnitSaveFields unitData

    set udg_save_LastLoadedUnit[playerId] = null
    set str_index = CutToComma(chat_str)
    set un_type = (S2ID((SubString(chat_str,0,str_index))))
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)
    
    if ConstTable(forbiddenTypes).has(un_type) then
        return
    endif
    
    set unitData = unitData.create(un_type, chat_str, centerX, centerY)


    //If the desired position is outside of the playable map area, abort the opertaion
    if not IsPointInRegion(WorldBounds.worldRegion, unitData.x, unitData.y) then
        return
    endif
    
    static if LIBRARY_LoPDeprecated then
        if DeprecatedData.isUnitTypeIdDeprecated(un_type) then
            if DeprecatedData(un_type).hasYawOffset() then
                set unitData.yaw = ModuloReal(unitData.yaw + DeprecatedData(un_type).yawOffset, 360.)
            endif
            if DeprecatedData(un_type).hasAnimTags() then
                if unitData.animTag == "D" then
                    set unitData.animTag = DeprecatedData(un_type).animTags
                endif
            endif
            if DeprecatedData(un_type).hasScale() then
                if unitData.size == "D" then
                    set unitData.size = R2S(DeprecatedData(un_type).scale)
                endif
            endif
            if DeprecatedData(un_type).hasRoll() then
                if unitData.roll == 0 then
                    set unitData.roll = DeprecatedData(un_type).roll
                endif
            endif
            if DeprecatedData(un_type).hasPitch() then
                if unitData.pitch == 0 then
                    set unitData.pitch = DeprecatedData(un_type).pitch
                endif
            endif
            
            set un_type = DeprecatedData(un_type).equivalent
        endif
    endif
    
    // Selection type 3 (locust) was only added in version 4, so version 3 saves must handle exceptions for unselectable decorations that should be loaded as units
    if unitData.selectState != "2" or (SaveIO_GetCurrentlyLoadingSave(un_owner).version < 4 and ((IsUnitIdType(un_type, UNIT_TYPE_STRUCTURE) and unitData.flyHeight < GUMS_MINIMUM_FLY_HEIGHT()) or (un_type == 'nwgt'))) then
        //Create the unit and modify it according to the chat input data
        set DefaultPathingMaps_dontApplyPathMap = true
        set resultUnit = CreateUnit (un_owner, un_type, unitData.x, unitData.y, unitData.yaw)
        
        if resultUnit != null then
            if IsUnitIdType(un_type, UNIT_TYPE_ANCIENT) then
                call SetUnitFacing(resultUnit, unitData.yaw)
            endif
            
            call LoadUnitFlags(resultUnit, unitData.flags)
            
            if unitData.pitch != 0. or unitData.roll != 0. then
                call UnitSetOrientation(resultUnit, unitData.yaw*bj_DEGTORAD, unitData.pitch, unitData.roll)
            endif
            
            if IsUnitType(resultUnit, UNIT_TYPE_STRUCTURE) then
                static if LIBRARY_SaveNLoadConfig then
                    call GUMSSetStructureFlyHeight(resultUnit, unitData.flyHeight, SaveNLoadConfig_StructureShouldAutoLand(resultUnit))
                else
                    call GUMSSetStructureFlyHeight(resultUnit, unitData.flyHeight, AUTO_LAND)
                endif
            else
                call GUMSSetUnitFlyHeight(resultUnit, unitData.flyHeight)
            endif

            //GUMS modifications
            if unitData.size != "D" then
                call ParseScale(resultUnit, unitData.size)
            endif
            if unitData.red != "D" then
                call GUMSSetUnitVertexColor(resultUnit, S2I(unitData.red)/2.55, S2I(unitData.green)/2.55, S2I(unitData.blue)/2.55, (255 - S2I(unitData.alpha))/2.55)
            endif
            if unitData.color != "D" then
                call GUMSSetUnitColor(resultUnit, S2I(unitData.color))
            endif
            if unitData.animSpeed != "D" then
                call GUMSSetUnitAnimSpeed(resultUnit, S2R(unitData.animSpeed))
            endif
            if unitData.animTag != "D" then
                call GUMSAddUnitAnimationTag(resultUnit, GUMSConvertTags(UnitVisualMods_TAGS_DECOMPRESS, unitData.animTag))
            endif
            if unitData.selectState != "0" then
                if unitData.selectState == "2" then
                    call GUMSSetUnitSelectionType(resultUnit, 3)
                else
                    call GUMSSetUnitSelectionType(resultUnit, S2I(unitData.selectState))
                endif
            endif
        else
            set DefaultPathingMaps_dontApplyPathMap = false
            call DisplayTextToPlayer(un_owner, 0., 0., "Failed to load unit of type: " + ID2S(un_type))
        endif
        
        set udg_save_LastLoadedUnit[playerId] = resultUnit
        set resultUnit = null
    else
        call LoadSpecialEffect(un_owner, un_type, unitData.x, unitData.y, unitData.flyHeight, unitData.yaw, unitData.pitch, unitData.roll, unitData.size, unitData.red, unitData.green, unitData.blue, unitData.alpha, unitData.color, unitData.animSpeed, unitData.animTag)
    endif
    
    call unitData.destroy()
endfunction

endlibrary