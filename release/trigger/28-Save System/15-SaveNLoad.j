library SaveNLoadConfig requires LoPHeader, LoPNeutralUnits
    
public function StructureShouldAutoLand takes unit structure returns boolean
    return not LoP_IsUnitDecoration(structure)
endfunction    

endlibrary

library SaveNLoad requires WorldBounds, UnitVisualMods, AnyBase, TerrainTools, DecorationSFX, UnitTypeDefaultValues, AttachedSFX, SaveIO/* 

   */ optional UserDefinedRects, optional SaveNLoadConfig optional LoPDeprecated
////////////////////////////////////////////////////////////////////////////////////////////////////
//SaveNLoad v5.0
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
    return AnyBase.values[StringHash(char)]
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

globals
    private real g_pitch
    private real g_roll
endglobals

function ParseFacing takes string scaleStr returns real
    local real sfx
    local real yaw
    local real pitch
    local real roll
    local integer cutToComma = CutToCharacter(scaleStr,"|")
    
    set yaw = S2R(SubString(scaleStr, 0, cutToComma))
    if cutToComma < StringLength(scaleStr) then
        set scaleStr = SubString(scaleStr, cutToComma+1, StringLength(scaleStr))
        
        set cutToComma = CutToCharacter(scaleStr,"|")
        set g_pitch = S2R(SubString(scaleStr, 0, cutToComma))/128
        set g_roll = S2R(SubString(scaleStr, cutToComma+1, StringLength(scaleStr)))/128
        return yaw/128*bj_RADTODEG
    else
        set g_pitch = 0.
        set g_roll = 0.
        return yaw
    endif
endfunction

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
    local real un_posx
    local real un_posy
    local real un_flyH
    local real un_fangle
    local integer len_str = StringLength(chat_str)
    local unit resultUnit
    local SaveNLoad_PlayerData playerId = GetPlayerId(un_owner)
    
    //Values saved by GUMS
    local string size
    local string red
    local string green
    local string blue
    local string alpha
    local string color
    local string aSpeed
    local string animTag
    local string select
    local integer flags

    set udg_save_LastLoadedUnit[playerId] = null
    set str_index = CutToComma(chat_str)
    set un_type = (S2ID((SubString(chat_str,0,str_index))))
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)
    
    if ConstTable(forbiddenTypes).has(un_type) then
        return
    endif

    //Start translating the chat input
    set str_index = CutToComma(chat_str)
    set un_posx = S2R(SubString(chat_str,0,str_index)) + centerX
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)

    set str_index = CutToComma(chat_str)
    set un_posy = S2R(SubString(chat_str,0,str_index)) + centerY
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)

    set str_index = CutToComma(chat_str)
    set un_flyH = S2R(SubString(chat_str,0,str_index))
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)

    set str_index = CutToComma(chat_str)
    set un_fangle = ParseFacing(SubString(chat_str,0,str_index))
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)
    
    if chat_str != "" then //Version 1 backwards compatibility
        set str_index = CutToComma(chat_str)
        set size = (SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)
        
        set str_index = CutToComma(chat_str)
        set red = (SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str) 
        
        set str_index = CutToComma(chat_str)
        set green = (SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)
        
        set str_index = CutToComma(chat_str)
        set blue = (SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)
        
        set str_index = CutToComma(chat_str)
        set alpha = (SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)
        
        set str_index = CutToComma(chat_str)
        set color = (SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)
        
        set str_index = CutToComma(chat_str)
        set aSpeed = (SubString(chat_str,0,str_index))
        set chat_str = SubString(chat_str,str_index+1,len_str)
        set len_str = StringLength(chat_str)
        
        if chat_str != "" then
            set str_index = CutToComma(chat_str)
            set animTag = (SubString(chat_str,0,str_index))
            set chat_str = SubString(chat_str,str_index+1,len_str)
            set len_str = StringLength(chat_str)
            if chat_str != "" then
                set str_index = CutToComma(chat_str)
                set select = (SubString(chat_str,0,str_index))
                set chat_str = SubString(chat_str,str_index+1,len_str+1)
                set len_str = StringLength(chat_str)
                if chat_str != "" then
                    set str_index = CutToComma(chat_str)
                    set flags = S2I(SubString(chat_str,0,str_index))  // TODO: When max flag is larger than 4, we need to use AnyBase(92)
                else
                    set flags = 0
                    // set chat_str = SubString(chat_str,str_index+1,len_str+1)
                    // set len_str = StringLength(chat_str)
                endif
            endif
        endif
        
    endif

    //If the desired position is outside of the playable map area, abort the opertaion
    if not IsPointInRegion(WorldBounds.worldRegion, un_posx, un_posy) then
        return
    endif
    /*
    if  un_posx > WorldBounds.maxX then
        return
    endif
    if un_posx < WorldBounds.minX then
        return
    endif
    if un_posy > WorldBounds.maxY then
        return
    endif
    if un_posy < WorldBounds.minY then
        return
    endif
    */
    
    static if LIBRARY_LoPDeprecated then
        if DeprecatedData.isUnitTypeIdDeprecated(un_type) then
            if DeprecatedData(un_type).hasYawOffset() then
                set un_fangle = ModuloReal(un_fangle + DeprecatedData(un_type).yawOffset, 360.)
            endif
            if DeprecatedData(un_type).hasAnimTags() then
                if animTag == "D" then
                    set animTag = DeprecatedData(un_type).animTags
                endif
            endif
            if DeprecatedData(un_type).hasScale() then
                if size == "D" then
                    set size = R2S(DeprecatedData(un_type).scale)
                endif
            endif
            
            set un_type = DeprecatedData(un_type).equivalent
        endif
    endif
    
    // Selection type 3 (locust) was only added in version 4, so version 3 saves must handle exceptions for unselectable decorations that should be loaded as units
    if select != "2" or (SaveIO_GetCurrentlyLoadingSave(un_owner).version < 4 and ((IsUnitIdType(un_type, UNIT_TYPE_STRUCTURE) and un_flyH < GUMS_MINIMUM_FLY_HEIGHT()) or (un_type == 'nwgt'))) then
        //Create the unit and modify it according to the chat input data
        set resultUnit = CreateUnit (un_owner, un_type, un_posx, un_posy, un_fangle )
        
        if resultUnit != null then
            if IsUnitIdType(un_type, UNIT_TYPE_ANCIENT) then
                call SetUnitFacing(resultUnit, un_fangle)
            endif
            
            call LoadUnitFlags(resultUnit, flags)
            
            if g_pitch != 0. or g_roll != 0. then
                if AttachedSFX_IsUnitValid(resultUnit) then
                    if UnitHasAttachedEffect(resultUnit) then
                        call GetUnitAttachedEffect(resultUnit).setOrientation(un_fangle*bj_DEGTORAD, g_pitch, g_roll)
                    else
                        call UnitCreateAttachedEffect(resultUnit).setOrientation(un_fangle*bj_DEGTORAD, g_pitch, g_roll)
                    endif
                endif
            endif
            
            if IsUnitType(resultUnit, UNIT_TYPE_STRUCTURE) then
                static if LIBRARY_SaveNLoadConfig then
                    call GUMSSetStructureFlyHeight(resultUnit, un_flyH, SaveNLoadConfig_StructureShouldAutoLand(resultUnit))
                else
                    call GUMSSetStructureFlyHeight(resultUnit, un_flyH, AUTO_LAND)
                endif
            else
                call GUMSSetUnitFlyHeight(resultUnit, un_flyH)
            endif

            //GUMS modifications
            if size != "D" then
                call ParseScale(resultUnit, size)
            endif
            if red != "D" then
                call GUMSSetUnitVertexColor(resultUnit, S2I(red)/2.55, S2I(green)/2.55, S2I(blue)/2.55, (255 - S2I(alpha))/2.55)
            endif
            if color != "D" then
                call GUMSSetUnitColor(resultUnit, S2I(color))
            endif
            if aSpeed != "D" then
                call GUMSSetUnitAnimSpeed(resultUnit, S2R(aSpeed))
            endif
            if animTag != "D" then
                call GUMSAddUnitAnimationTag(resultUnit, GUMSConvertTags(UnitVisualMods_TAGS_DECOMPRESS, animTag))
            endif
            if select != "0" then
                call GUMSSetUnitSelectionType(resultUnit, S2I(select))
            endif
        else
            call DisplayTextToPlayer(un_owner, 0., 0., "Failed to load unit of type: " + ID2S(un_type))
        endif
        
        set udg_save_LastLoadedUnit[playerId] = resultUnit
        set resultUnit = null
    else
        call LoadSpecialEffect(un_owner, un_type, un_posx, un_posy, un_flyH, un_fangle, g_pitch, g_roll, size, red, green, blue, alpha, color, aSpeed, animTag)
    endif
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

// Loads the first line of a terrain save, which contains the coords of the rect
// offsetIsCenter indicates that offsetX and offsetY should be interpreted as the coords of a new center for the rect, and not actual offsets. Used for version 3 saves.
function LoadTerrainHeader takes string chatStr, real offsetX, real offsetY, boolean offsetIsCenter returns nothing
    local integer cutToComma
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    
    local real centerY
    local real centerX

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

function LoadTerrain takes string chatStr returns nothing
    local SaveNLoad_PlayerData playerId = GetPlayerId(GetTriggerPlayer())
    local integer strSize
    local integer i = 1
    
    set strSize = StringLength(chatStr)
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

endfunction

function LoadRequest takes player savePlayer, string password returns nothing
    local string filePath = "DataManager\\load.txt"

    if GetLocalPlayer() == savePlayer then
        call PreloadGenStart()
        call PreloadGenClear()
        call Preload(password)
        call PreloadGenEnd(filePath)
    endif
endfunction
endlibrary