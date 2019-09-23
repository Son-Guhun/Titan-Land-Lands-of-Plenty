library Base36
constant function LoadAlphabet takes nothing returns string

return "0123456789abcdefghijklmnopqrstuvwxyz"

endfunction

function LoadD2H takes integer int returns string
    return SubString(LoadAlphabet(),int,int+1)
endfunction

function LoadH2D takes string char returns integer
    local integer i = 0
    
    loop
    exitwhen SubString(LoadAlphabet(),i,i+1) == char
        set i = i+1
    endloop
    
    return i
endfunction
endlibrary

library SaveNLoadConfig requires LoPHeader
    
public function StructureShouldAutoLand takes unit structure returns boolean
    return not LoP_IsUnitDecoration(structure)
endfunction    

endlibrary

library SaveNLoad requires UnitVisualMods, Rawcode2String, Base36, TerrainTools, DecorationSFX, UnitTypeDefaultValues, optional UserDefinedRects, optional SaveNLoadConfig optional LoPDeprecated
////////////////////////////////////////////////////////////////////////////////////////////////////
//SaveNLoad v3.0
////////////////////////////////////////////////////////////////////////////////////////////////////
constant function SaveLoadVersion takes nothing returns integer
    return 3
endfunction

public constant function FOLDER takes nothing returns string
    return "TitanLandLoP\\"
endfunction

globals
    public boolean AUTO_LAND = false  // Can be overwritten by SaveNLoadConfig StructureShouldAutoLand
endglobals

public function FormatString takes string prefix, string data returns string
    return "\" )\ncall BlzSendSyncData(\"" + prefix + "\", \"" + data + "\")\n//"
endfunction

//////////////////////////////////////////////////////
//SaveNLoad by Guhun

// Requires:
// -GUDR
// -GUMS
// -ID2S function (Takes raw obejct ID, returns string)
// -Hexa to Decimal
//////////////////////////////////////////////////////
function Save_GetCenterX takes integer playerId returns real
    return udg_load_center[playerId + 1]
endfunction

function Save_GetCenterY takes integer playerId returns real
    return udg_load_center[playerId + 1 + bj_MAX_PLAYERS]
endfunction

function Save_IsPlayerLoading takes integer playerId returns boolean
    return udg_save_load_boolean[playerId + 1 + bj_MAX_PLAYERS]
endfunction

function Save_SetPlayerLoading takes integer playerId, boolean flag returns nothing
    set udg_save_load_boolean[playerId + 1 + bj_MAX_PLAYERS] = flag
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
        
        local real length = GetRectMaxX(userRect) - GetRectCenterX(userRect)
        local real height = GetRectMaxY(userRect) - GetRectCenterY(userRect)
        local integer weatherType = GUDR_GetGeneratorIdWeatherType(generatorId)
        local boolean hidden 
        local TerrainFog fog
        
        if RectEnvironment.get(userRect).hasFog() then
            set fog = RectEnvironment.get(userRect).fog
            
            return R2S(length) + "=" + R2S(height) + "=" + I2S(weatherType) + "=" + "T" + "=" +/*
                 */ I2S(fog.style) + "=" + R2S(fog.zStart) + "=" + R2S(fog.zEnd) + "=" +/*
                 */ R2S(fog.density*10000) + "=" + R2S(fog.red) + "=" + R2S(fog.green) + "=" + R2S(fog.blue) + "="
        else
            return R2S(length) + "=" + R2S(height) + "=" + I2S(weatherType) + "="
        endif
    endfunction

    function Load_RestoreGUDR takes unit generator, string restoreStr returns nothing
        local integer splitterIndex
        
        local real length
        local real height
        local integer weatherType
        
        local TerrainFog fog
        
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
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        // show/hide
        set restoreStr = SubString(restoreStr,splitterIndex+1,StringLength(restoreStr))
        
        call CreateGUDR(generator)
        call MoveGUDR(generator, length, height, false)
        call ChangeGUDRWeatherNew(generator, 0, weatherType)
        
        set splitterIndex = CutToCharacter(restoreStr, "=")
        if splitterIndex != 0 and splitterIndex < StringLength(restoreStr) then
            set fog = RectEnvironment.get(GUDR_GetGeneratorRect(generator)).fog

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
            
            call AutoRectEnvironment_RegisterRect(GUDR_GetGeneratorRect(generator))
        endif
    endfunction
endif

function LoadSpecialEffect takes player owner, UnitTypeDefaultValues unitType, real x, real y, real height, real facing, string scale, string red, string green, string blue, string alpha, string color, string aSpeed, string aTags returns nothing
    local DecorationEffect result = DecorationEffect.create(owner, unitType, x, y)
    local real value
    local integer redRaw
    local integer greenRaw
    
    set result.height = height
    set result.yaw = Deg2Rad(facing)
    
    if scale != "D" then
        set value = S2R(scale)
        call result.setScale(value, value, value)
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

function LoadUnit takes string chat_str, player un_owner returns nothing
    local integer str_index
    local integer un_type
    local real un_posx
    local real un_posy
    local real un_flyH
    local real un_fangle
    local integer len_str = StringLength(chat_str)
    local unit resultUnit
    local integer playerId = GetPlayerId(un_owner)
    
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

    set udg_save_LastLoadedUnit[playerId] = null
    set str_index = CutToComma(chat_str)
    set un_type = (S2ID((SubString(chat_str,0,str_index))))
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)
    set udg_save_LoadUnitType = un_type
    
    //LoadUnit Trigger Conidtions
    if not TriggerEvaluate(gg_trg_LoadUnit) then
        set udg_save_LoadUnitType = 0
        return
    endif
    set udg_save_LoadUnitType = 0

    //Start translating the chat input
    set str_index = CutToComma(chat_str)
    set un_posx = S2R(SubString(chat_str,0,str_index)) + Save_GetCenterX(playerId)
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)

    set str_index = CutToComma(chat_str)
    set un_posy = S2R(SubString(chat_str,0,str_index)) + Save_GetCenterY(playerId)
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)

    set str_index = CutToComma(chat_str)
    set un_flyH = S2R(SubString(chat_str,0,str_index))
    set chat_str = SubString(chat_str,str_index+1,len_str)
    set len_str = StringLength(chat_str)

    set str_index = CutToComma(chat_str)
    set un_fangle = S2R(SubString(chat_str,0,str_index))
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
                //set chat_str = SubString(chat_str,str_index+1,len_str+1)
                //set len_str = StringLength(chat_str)
            endif
        endif
        
    endif

    //If the desired position is outside of the playable map area, abort the opertaion
    if  un_posx > GetRectMaxX(udg_save_WholeMapRect) then
        return
    endif
    if un_posx < GetRectMinX(udg_save_WholeMapRect) then
        return
    endif
    if un_posy > GetRectMaxY(udg_save_WholeMapRect) then
        return
    endif
    if un_posy < GetRectMinY(udg_save_WholeMapRect) then
        return
    endif
    
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
    
    // Only selectable decorations should become units. Except: structres with pathing map and no height, waygates.
    if select != "2" or (IsUnitIdType(un_type, UNIT_TYPE_STRUCTURE) and un_flyH < GUMS_MINIMUM_FLY_HEIGHT()) or (un_type == 'nwgt') then
        //Create the unit and modify it according to the chat input data
        set resultUnit = CreateUnit (un_owner, un_type, un_posx, un_posy, un_fangle )
        
        
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
            call GUMSSetUnitScale(resultUnit, S2R(size))
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
            call GUMSAddUnitAnimationTag(resultUnit,GUMSConvertTags(UnitVisualMods_TAGS_DECOMPRESS, animTag))
        endif
        if select == "1" then
            call GUMSMakeUnitDragSelectable(resultUnit)
        elseif select == "2" then
            call GUMSMakeUnitUnSelectable(resultUnit)
        endif
        
        set udg_save_LastLoadedUnit[playerId] = resultUnit
        set resultUnit = null
    else
        call LoadSpecialEffect(un_owner, un_type, un_posx, un_posy, un_flyH, un_fangle, size, red, green, blue, alpha, color, aSpeed, animTag)
    endif
endfunction

function LoadDestructable takes string chatStr returns nothing
    local integer destType
    local real destX
    local real destY
    local integer cutToComma
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destType = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destX = S2R(SubString(chatStr,0,cutToComma)) + Save_GetCenterX(playerId)
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"|")
    set destY = S2R(SubString(chatStr,0,cutToComma)) + Save_GetCenterY(playerId)
    //set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    //call BJDebugMsg(I2S(destType) + " " + R2S(destX) + " " + R2S(destY))
    
    set bj_lastCreatedDestructable = CreateDestructable(destType, destX, destY, 270, 1, 0)
    //if not IsDestructableTree(bj_lastCreatedDestructable) then
      //  call RemoveDestructable(bj_lastCreatedDestructable)
    //endif
endfunction

function LoadTerrain takes string chatStr returns nothing

    local integer cutToComma
    local integer playerNumber = GetPlayerId(GetTriggerPlayer())
    local integer i = 1
    local integer strSize
    
    local real offsetX
    local real offsetY
    local real centerY
    local real centerX

    if not (SubString(chatStr, 0, 1) == "@") then
    
    set cutToComma = CutToCharacter(chatStr,"@")
    set udg_save_XYminmaxcur[playerNumber] = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))

    set cutToComma = CutToCharacter(chatStr,"@")
    set udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS] = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"@")
    set udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS] = S2I(SubString(chatStr,0,cutToComma))
    set chatStr = SubString(chatStr,cutToComma+1,StringLength(chatStr))
    
    set cutToComma = CutToCharacter(chatStr,"@")
    set udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS] = S2I(SubString(chatStr,0,cutToComma))
    
    if Save_GetCenterX(playerNumber) != 0 or Save_GetCenterY(playerNumber) != 0 then
        set centerX = (udg_save_XYminmaxcur[playerNumber] + udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS])/2
        set centerY = (udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS] + udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS])/2
        set offsetX = Save_GetCenterX(playerNumber) - centerX
        set offsetY = Save_GetCenterY(playerNumber) - centerY
        
        set udg_save_XYminmaxcur[playerNumber] = udg_save_XYminmaxcur[playerNumber] + offsetX
        set udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS] + offsetX
        set udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS] + offsetY
        set udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+4*bj_MAX_PLAYERS] + offsetY
    endif
    
    set udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber]
    set udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+3*bj_MAX_PLAYERS]
    
    return
    endif
    
    set strSize = StringLength(chatStr)
    loop
    exitwhen i >= strSize
        call SetTerrainType(udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS], udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS], TerrainTools_GetTexture(LoadH2D(SubString(chatStr,i,i+1))), LoadH2D(SubString(chatStr,i+1,i+2)), 1, 0)
        set i = i + 2
        if udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] > udg_save_XYminmaxcur[playerNumber+bj_MAX_PLAYERS] then
            set udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+5*bj_MAX_PLAYERS] + 128
            set udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber]
        else
            set udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] = udg_save_XYminmaxcur[playerNumber+2*bj_MAX_PLAYERS] + 128
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