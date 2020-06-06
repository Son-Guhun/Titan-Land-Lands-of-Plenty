library SaveNLoadConfig requires LoPHeader, LoPNeutralUnits
    
public function StructureShouldAutoLand takes unit structure returns boolean
    return not LoP_IsUnitDecoration(structure)
endfunction    

endlibrary

library SaveNLoad requires WorldBounds, UnitVisualMods, AnyBase, TerrainTools, DecorationSFX, UnitTypeDefaultValues, AttachedSFX, SaveIO/* 

   */ optional UserDefinedRects, optional SaveNLoadConfig optional LoPDeprecated
////////////////////////////////////////////////////////////////////////////////////////////////////
//SaveNLoad v7.0
////////////////////////////////////////////////////////////////////////////////////////////////////
public constant function OLDFOLDER takes nothing returns string
    return "TitanLandLoP\\"
endfunction

public constant function FOLDER takes nothing returns string
    return "TLLoP\\Saves\\"
endfunction

function LoadD2H takes integer int returns string
    return SubString(AnyBase.digits,int,int+1)
endfunction

function LoadH2D takes string char returns integer
    return AnyBase.values[StringHashEx(char)]
endfunction

public struct BoolFlags extends array
    static method isAnyFlag takes integer data, integer flags returns boolean
        return BlzBitAnd(data, flags) > 0
    endmethod
    
    static method isAllFlags takes integer data, integer flags returns boolean
        return BlzBitAnd(data, flags) == flags
    endmethod

    static constant method operator UNROOTED takes nothing returns integer
        return 1
    endmethod
    
    static constant method operator NEUTRAL takes nothing returns integer
        return 2
    endmethod
    
    static constant method operator FLAG_3 takes nothing returns integer
        return 4
    endmethod
endstruct

//! textmacro SaveXYMethod takes name, offset
    method operator $name$ takes nothing returns real
        return udg_save_XYminmaxcur[this$offset$]
    endmethod
    
    method operator $name$= takes real value returns nothing
        set udg_save_XYminmaxcur[this$offset$] = value
    endmethod
//! endtextmacro

private struct PlayerTerrainData extends array
    //! runtextmacro SaveXYMethod("minX", "")
    //! runtextmacro SaveXYMethod("maxX", "+bj_MAX_PLAYERS")
    //! runtextmacro SaveXYMethod("curX", "+2*bj_MAX_PLAYERS")
    //! runtextmacro SaveXYMethod("minY", "+3*bj_MAX_PLAYERS")
    //! runtextmacro SaveXYMethod("maxY", "+4*bj_MAX_PLAYERS")
    //! runtextmacro SaveXYMethod("curY", "+5*bj_MAX_PLAYERS")
endstruct

struct SaveNLoad_PlayerData extends array
    
    private static real array loadCenter
    
    public method operator centerX takes nothing returns real
        return loadCenter[this]
    endmethod
    
    public method operator centerY takes nothing returns real
        return loadCenter[this + bj_MAX_PLAYERS]
    endmethod
    
    public method operator centerX= takes real value returns nothing
        set loadCenter[this] = value
    endmethod
    
    public method operator centerY= takes real value returns nothing
        set loadCenter[this + bj_MAX_PLAYERS] = value
    endmethod
    
    method operator terrain takes nothing returns PlayerTerrainData
        return this
    endmethod
    
endstruct

globals
    public boolean AUTO_LAND = false  // Can be overwritten by SaveNLoadConfig StructureShouldAutoLand
endglobals

public function FormatString takes string prefix, string data returns string
    return SaveIO_FormatString(prefix, data)
endfunction

function B2S takes boolean bool returns string
    if bool then
        return "True"
    endif
    return "False"
endfunction

function S2B takes string str returns boolean
    if str == "True" then
        return true
    endif
    return false
endfunction
        
static if LIBRARY_UserDefinedRects then
    function Save_GetGUDRSaveString takes integer generatorId returns string
        local rect userRect = GUDR_GetGeneratorIdRect(generatorId)
        local real length = GUDR_GetGeneratorIdExtentX(generatorId)
        local real height = GUDR_GetGeneratorIdExtentY(generatorId)
        local string hidden
        local DNC dnc
        local TerrainFog fog
        
        if GUDR_IsGeneratorIdHidden(generatorId) then
            set hidden = "0"
        else
            set hidden = "1"
        endif
        
        if RectEnvironment.get(userRect).hasFog() then
            set fog = RectEnvironment.get(userRect).fog
            set dnc = RectEnvironment.get(userRect).dnc
            
            return R2S(length) + "=" + R2S(height) + "=" + I2S(GUDR_GetGeneratorIdWeatherType(generatorId)) + "=" + hidden + "=" +/*
                 */ I2S(fog.style) + "=" + R2S(fog.zStart) + "=" + R2S(fog.zEnd) + "=" +/*
                 */ R2S(fog.density*10000) + "=" + R2S(fog.red) + "=" + R2S(fog.green) + "=" + R2S(fog.blue) + "=" +/*
                 */ I2S(dnc.lightTerrain) + "=" + I2S(dnc.lightUnit) + "="
        else
            return R2S(length) + "=" + R2S(height) + "=" + I2S(GUDR_GetGeneratorIdWeatherType(generatorId)) + "=" + hidden
        endif
    endfunction

    function Load_RestoreGUDR takes unit generator, string restoreStr returns nothing
        local integer splitterIndex
        
        local real length
        local real height
        local integer weatherType
        
        local TerrainFog fog
        local DNC dnc
        
        //Str = "length=height=weather= (we need an equal at the end in order to make future versions backwards-compatible
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        set length = S2R(SubString(restoreStr,0,splitterIndex))
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
        set splitterIndex = CutToCharacter(restoreStr, "=")
        set height = S2R(SubString(restoreStr,0,splitterIndex))
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        set weatherType = S2I(SubString(restoreStr,0,splitterIndex))
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
        
        call CreateGUDR(generator)
        call MoveGUDR(generator, length, height, false)
        call ChangeGUDRWeatherNew(generator, 0, weatherType)
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        if SubString(restoreStr,0,splitterIndex) != "0" then
            call ToggleGUDRVisibility(generator, false, true)
        else
            call ToggleGUDRVisibility(generator, false, false)
        endif
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        if splitterIndex != 0 and splitterIndex < StringLength(restoreStr) then
            set fog = RectEnvironment.get(GUDR_GetGeneratorRect(generator)).fog
            set dnc = RectEnvironment.get(GUDR_GetGeneratorRect(generator)).dnc

            set fog.style = S2I(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.zStart = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.zEnd = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.density = S2R(SubString(restoreStr,0,splitterIndex))/10000.
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.red = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.green = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            set fog.blue = S2R(SubString(restoreStr,0,splitterIndex))
            set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            
            
            set splitterIndex = CutToCharacter(restoreStr, "=")
            if splitterIndex < StringLength(restoreStr)-1 then
                set dnc.lightTerrain = S2I(SubString(restoreStr,0,splitterIndex))
                set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
                
                set splitterIndex = CutToCharacter(restoreStr, "=")
                set dnc.lightUnit = S2I(SubString(restoreStr,0,splitterIndex))
                set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
            endif
            
            call AutoRectEnvironment_RegisterRect(GUDR_GetGeneratorRect(generator))
        endif
    endfunction
endif

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
    if BoolFlags.isAnyFlag(flags, BoolFlags.UNROOTED) then
        call IssueImmediateOrder(whichUnit, "unroot")
    endif
    
    if BoolFlags.isAnyFlag(flags, BoolFlags.NEUTRAL) then
        call LoP_GiveToNeutral(whichUnit)
    endif
endfunction

globals
    private constant key forbiddenTypes // ConstTable
endglobals

public function ForbidUnitType takes integer unitType returns nothing
    set ConstTable(forbiddenTypes).boolean[unitType] = false
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
            
            set un_type = DeprecatedData(un_type).equivalent
        endif
    endif
    
    // Selection type 3 (locust) was only added in version 4, so version 3 saves must handle exceptions for unselectable decorations that should be loaded as units
    if unitData.selectState != "2" or (SaveIO_GetCurrentlyLoadingSave(un_owner).version < 4 and ((IsUnitIdType(un_type, UNIT_TYPE_STRUCTURE) and unitData.flyHeight < GUMS_MINIMUM_FLY_HEIGHT()) or (un_type == 'nwgt'))) then
        //Create the unit and modify it according to the chat input data
        set resultUnit = CreateUnit (un_owner, un_type, unitData.x, unitData.y, unitData.yaw)
        
        if resultUnit != null then
            if IsUnitIdType(un_type, UNIT_TYPE_ANCIENT) then
                call SetUnitFacing(resultUnit, unitData.yaw)
            endif
            
            call LoadUnitFlags(resultUnit, unitData.flags)
            
            if unitData.pitch != 0. or unitData.yaw != 0. then
                if AttachedSFX_IsUnitValid(resultUnit) then
                    if UnitHasAttachedEffect(resultUnit) then
                        call GetUnitAttachedEffect(resultUnit).setOrientation(unitData.yaw*bj_DEGTORAD, unitData.pitch, unitData.roll)
                    else
                        call UnitCreateAttachedEffect(resultUnit).setOrientation(unitData.yaw*bj_DEGTORAD, unitData.pitch, unitData.roll)
                    endif
                endif
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
            call DisplayTextToPlayer(un_owner, 0., 0., "Failed to load unit of type: " + ID2S(un_type))
        endif
        
        set udg_save_LastLoadedUnit[playerId] = resultUnit
        set resultUnit = null
    else
        call LoadSpecialEffect(un_owner, un_type, unitData.x, unitData.y, unitData.flyHeight, unitData.yaw, unitData.pitch, unitData.roll, unitData.size, unitData.red, unitData.green, unitData.blue, unitData.alpha, unitData.color, unitData.animSpeed, unitData.animTag)
    endif
    
    call unitData.destroy()
endfunction

function LoadDestructable takes string chatStr, real centerX, real centerY returns nothing
    local integer destType
    local real destX
    local real destY
    local integer cutToComma
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destType = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destX = S2R(SubString(chatStr,0,cutToComma)) + centerX
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destY = S2R(SubString(chatStr,0,cutToComma)) + centerY
    //set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    //call BJDebugMsg(I2S(destType) + " " + R2S(destX) + " " + R2S(destY))
    
    set bj_lastCreatedDestructable = CreateDestructable(destType, destX, destY, 270, 1, 0)
    //if not IsDestructableTree(bj_lastCreatedDestructable) then
      //  call RemoveDestructable(bj_lastCreatedDestructable)
    //endif
endfunction

function IsTerrainHeader takes string chatStr returns boolean
    return not (SubString(chatStr, 0, 1) == "@")
endfunction

function IsTerrainHeaderV7 takes string chatStr returns boolean
    return SubString(chatStr, 0, 1) == "="
endfunction

// Loads the first line of a terrain save, which contains the coords of the rect
// offsetIsCenter indicates that offsetX and offsetY should be interpreted as the coords of a new center for the rect, and not actual offsets. Used for version 3 saves.
function LoadTerrainHeader takes string chatStr, real offsetX, real offsetY, boolean offsetIsCenter returns nothing
    local integer cutToComma
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    local real centerY
    local real centerX
    
    if IsTerrainHeaderV7(chatStr) then
        set chatStr = SubString(chatStr, 1, StringLength(chatStr))
    endif

    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.minX = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))

    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.maxX = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.minY = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"@")
    set playerId.terrain.maxY = S2I(SubString(chatStr,0,cutToComma))
    
    if offsetX != 0 or offsetY != 0 then
    
        if offsetIsCenter then // old versions support
            set centerX = (playerId.terrain.minX + playerId.terrain.maxX)/2
            set centerY = (playerId.terrain.minY + playerId.terrain.maxY)/2
            set offsetX = offsetX - centerX
            set offsetY = offsetY - centerY
        endif
        
        set playerId.terrain.minX = playerId.terrain.minX + offsetX
        set playerId.terrain.maxX = playerId.terrain.maxX + offsetX
        set playerId.terrain.minY = playerId.terrain.minY + offsetY
        set playerId.terrain.maxY = playerId.terrain.maxY + offsetY
    endif

    set playerId.terrain.curX = playerId.terrain.minX
    set playerId.terrain.curY = playerId.terrain.minY
endfunction

public constant function BASE_92_OFFSET takes nothing returns integer
    return 4232
endfunction

function LoadTerrain takes string chatStr returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer strSize
    local integer i
    
    set strSize = StringLength(chatStr)
    if SubString(chatStr, 0, 1) == "@" then  // if string starts with @, then there is no height data
        set i = 1
        loop
        exitwhen i >= strSize
            call SetTerrainType(playerId.terrain.curX, playerId.terrain.curY, TerrainTools_GetTexture(LoadH2D(SubString(chatStr,i,i+1))), LoadH2D(SubString(chatStr,i+1,i+2)), 1, 0)
            set i = i + 2
            if playerId.terrain.curX > playerId.terrain.maxX then
                set playerId.terrain.curY = playerId.terrain.curY + 128
                set playerId.terrain.curX = playerId.terrain.minX
            else
                set playerId.terrain.curX = playerId.terrain.curX + 128
            endif
        endloop
    else
        set i = 0
        loop
        exitwhen i >= strSize
            call SetTerrainType(playerId.terrain.curX, playerId.terrain.curY, TerrainTools_GetTexture(LoadH2D(SubString(chatStr,i,i+1))), LoadH2D(SubString(chatStr,i+1,i+2)), 1, 0)
            set Deformation.fromCoords(playerId.terrain.curX, playerId.terrain.curY).depth = AnyBase(92).decode(SubString(chatStr,i+2,i+4)) - BASE_92_OFFSET()
            set i = i + 4
            if playerId.terrain.curX > playerId.terrain.maxX then
                set playerId.terrain.curY = playerId.terrain.curY + 128
                set playerId.terrain.curX = playerId.terrain.minX
            else
                set playerId.terrain.curX = playerId.terrain.curX + 128
            endif
        endloop
    endif

endfunction


endlibrary