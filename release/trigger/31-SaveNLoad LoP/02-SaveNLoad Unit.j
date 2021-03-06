library SaveNLoadUnit requires SaveNLoad, UnitVisualMods, AnyBase, DecorationSFX, UnitTypeDefaultValues, AttachedSFX, optional LoPDeprecated, LoPHeader, LoPNeutralUnits
/*
=========
 Description
=========

    This library defines functions used for unit serialization and deserialization in Titan Land LoP.
    
    It is mainly used to implement the SaveUnit core library of SaveNLoad, though the public-facing
functions may be called elsewhere.
    
=========
 Documentation
=========

    struct SaveNLoad_BoolFlags:
        . This struct contains constants that represent unit flags, which are bit fields used when
        . serializing units.
        
        Constants:
            integer UNROOTED  -> Represents root state for ancients and pathing map state for decorations
            integer NEUTRAL   -> Represents whether a player's unit belongs to neutral passive.
        
        Static Methods:
            boolean isAnyFlag(integer data, integer flags) 
            boolean isAllFlags(integer data, integer flags)
        
    
*/
//==================================================================================================
//                                        Source Code
//==================================================================================================

private struct TAGS extends array

    private static key compress
    private static key decompress
    
    static constant method operator COMPRESS takes nothing returns integer
        return compress
    endmethod
    
    static constant method operator DECOMPRESS takes nothing returns integer
        return decompress
    endmethod
    
endstruct

private function ConvertAnimTags takes ConstTable convertType, string whichStr returns string
    local string result = ""
    local string substring
    local integer cutToComma = CutToCharacter(whichStr, " ")
    local integer stringHash
    
    loop
        set substring = SubString(whichStr, 0, cutToComma)
        if substring != "" then
            set stringHash = StringHash(substring)
            if convertType.string.has(stringHash) then
                set result = result + convertType.string[stringHash] + " "
            else
                set result = result + whichStr + " "
                // call DisplayTextToPlayer(WHO?,0,0, whichStr + " is not a known tag. If you think this is wrong, please report it")
            endif
        endif
        
        exitwhen cutToComma >= StringLength(whichStr)-1
        set whichStr = SubString(whichStr, cutToComma + 1, StringLength(whichStr))
        set cutToComma = CutToCharacter(whichStr, " ")
    endloop
    if result == "" then
        return ""
    else
        return SubString(result,0,StringLength(result) - 1)
    endif
endfunction

private function StructureShouldAutoLand takes unit structure returns boolean
    return not LoP_IsUnitDecoration(structure)
endfunction

struct SaveNLoad_BoolFlags extends array
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

// Used to serialize flags string
private function I2FlagsString takes integer flags returns string
    return I2S(flags)  // TODO: If max flag exceeds 4, we need to use AnyBase(92) instead of I2S
endfunction

// Used to deserialize flags string
private function FlagsString2I takes string flags returns integer
    return S2I(flags)  // TODO: If max flag exceeds 4, we need to use AnyBase(92) instead of S2I
endfunction


scope Serialization

    scope SFX
        /*
            Utility functions to serialize SpecialEffects into strings.
        */

        private function GetFacingString takes SpecialEffect sfx returns string
            if sfx.roll == 0 and sfx.pitch == 0 then
                return R2S(sfx.yaw*bj_RADTODEG)
            else
                return R2S(sfx.yaw*128) + "|" + R2S(sfx.pitch*128) + "|" + R2S(sfx.roll*128)
            endif
        endfunction

        private function GetScaleString takes SpecialEffect sfx returns string
            local real scaleX = sfx.scaleX
            if sfx.scaleY != scaleX  or sfx.scaleZ != scaleX then
                return R2S(sfx.scaleX) + "|" + R2S(sfx.scaleY) + "|" + R2S(sfx.scaleZ)
            else
                return R2S(sfx.scaleX)
            endif
        endfunction

        function SerializeSpecialEffectFlags takes SpecialEffect sfx returns string
            local integer result = 0
            
            if ObjectPathing(sfx).isDisabled then
                set result = result + SaveNLoad_BoolFlags.UNROOTED
            endif

            return I2FlagsString(result)
        endfunction


        function SerializeSpecialEffect takes SpecialEffect whichEffect, player owner, boolean hasCustomColor, integer selectionType, string flags returns string
            local string typeStr
            local string animTags
            local string color
            local SaveNLoad_PlayerData playerId = GetPlayerId(owner)
            
            if whichEffect.hasSkin() then
                set typeStr = ID2S(whichEffect.unitType) + "|" + ID2S(whichEffect.skin)
            else
                set typeStr = ID2S(whichEffect.unitType)
            endif
            
            if hasCustomColor then
                set color = I2S(whichEffect.color + 1)
            else
                set color = "D"
            endif
            
            if whichEffect.hasSubAnimations() then
                set animTags = SaveIO_CleanUpString(ConvertAnimTags(TAGS.COMPRESS, SubAnimations2Tags(whichEffect.subanimations)))
            else
                set animTags = "D"
            endif

            return typeStr + "," +/*
                */ R2S(whichEffect.x) + "," +/*
                */ R2S(whichEffect.y) + "," +/*
                */ R2S(whichEffect.height) + "," +/*
                */ GetFacingString(whichEffect) + "," +/*
                */ GetScaleString(whichEffect) + "," +/*
                */ I2S(whichEffect.red) + "," +/*
                */ I2S(whichEffect.green) + "," +/*
                */ I2S(whichEffect.blue) + "," +/*
                */ I2S(whichEffect.alpha) + "," +/*
                */ color + "," +/*
                */ R2S(whichEffect.animationSpeed) + "," +/*
                */ animTags + "," +/*
                */ I2S(selectionType) + "," +/*
                */ flags
        endfunction

    endscope

    scope Unit
        /*
            Utility functions to serialize units into strings.
        */

        function SerializeUnitFlags takes unit saveUnit returns string
            local integer result = 0
            
            if LoP_IsUnitDecoration(saveUnit) and ObjectPathing.get(saveUnit).isDisabled then
                set result = result + SaveNLoad_BoolFlags.UNROOTED
                
            elseif IsUnitType(saveUnit, UNIT_TYPE_ANCIENT) and BlzGetUnitIntegerField(saveUnit, UNIT_IF_DEFENSE_TYPE) == GetHandleId(DEFENSE_TYPE_LARGE) then
                set result = result + SaveNLoad_BoolFlags.UNROOTED
                
            endif
            if GetOwningPlayer(saveUnit) == Player(PLAYER_NEUTRAL_PASSIVE) then
                set result = result + SaveNLoad_BoolFlags.NEUTRAL
                
            endif
            
            return I2FlagsString(result)
        endfunction
        
        function SerializeUnit takes unit saveUnit returns string
            local UnitVisuals unitHandleId = GetHandleId(saveUnit)
            local string typeStr
            
            if BlzGetUnitSkin(saveUnit) != GetUnitTypeId(saveUnit) then
                set typeStr = ID2S(GetUnitTypeId(saveUnit)) + "|" + ID2S(BlzGetUnitSkin(saveUnit))
            else
                set typeStr = ID2S(GetUnitTypeId(saveUnit))
            endif
        
            if UnitHasAttachedEffect(saveUnit) then
                return SerializeSpecialEffect(GetUnitAttachedEffect(saveUnit), GetOwningPlayer(saveUnit), unitHandleId.hasColor(), unitHandleId.raw.getSelectionType(), SerializeUnitFlags(saveUnit))
            else
                return typeStr + "," + /*
                            */   R2S(GetUnitX(saveUnit))+","+  /*
                            */   R2S(GetUnitY(saveUnit)) + "," + /*
                            */   R2S(GetUnitFlyHeight(saveUnit)) + "," + /*
                            */   R2S(GetUnitFacing(saveUnit)) + "," + /*
                            */   unitHandleId.getScale() + "," + /*
                            */   unitHandleId.getVertexRed() + "," + /*
                            */   unitHandleId.getVertexGreen() + "," + /*
                            */   unitHandleId.getVertexBlue() + "," + /*
                            */   unitHandleId.getVertexAlpha() + "," + /*
                            */   unitHandleId.getColor() + "," + /*
                            */   unitHandleId.getAnimSpeed() + "," + /*
                            */   SaveIO_CleanUpString(unitHandleId.getAnimTag()) + "," + /*
                            */   unitHandleId.getSelectionType() + "," + /*
                            */   SerializeUnitFlags(saveUnit)
            endif
        endfunction

    endscope
endscope

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

function LoadSpecialEffect takes player owner, UnitTypeDefaultValues unitType, integer skin, real x, real y, real height, real facing, real pitch, real roll, string scale, string red, string green, string blue, string alpha, string color, string aSpeed, string aTags, integer flags returns nothing
    local DecorationEffect result
    local real value
    local integer redRaw
    local integer greenRaw
    
    if skin != 0 then
        set result = DecorationEffect.convertSpecialEffectNoPathing(owner, SpecialEffect.createWithSkin(unitType, skin, x, y), false)
    else
        set result = DecorationEffect.createNoPathing(owner, unitType, x, y)
    endif
    
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
        call AddTagsStringAsSubAnimations(result, ConvertAnimTags(TAGS.DECOMPRESS, aTags), true)
    endif
    
    if unitType.hasMaxRoll() then
        set result.roll = Deg2Rad(unitType.maxRoll+180.)
    endif
    
    if DefaultPathingMap(unitType).hasPathing() then
        if SaveNLoad_BoolFlags.isAnyFlag(flags, SaveNLoad_BoolFlags.UNROOTED) then
            set ObjectPathing(result).isDisabled = true
            
        else
            set ObjectPathing(result).isDisabled = false
            call DefaultPathingMap(unitType).update(result.effect, x, y, facing*bj_DEGTORAD)
            
        endif
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
        
        call UnitVisualsSetters.MatrixScale(u, scaleX, scaleY, scaleZ)
    else
        call UnitVisualsSetters.Scale(u, scaleX)
    endif
endfunction

struct UnitSaveFields extends array

    implement ExtendsTable

    //! runtextmacro HashStruct_NewPrimitiveField("unitType", "integer")
    //! runtextmacro HashStruct_NewPrimitiveField("skin", "integer")
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
                        set .flags = FlagsString2I(SubString(chat_str,0,str_index))  // TODO: When max flag is larger than 4, we need to use AnyBase(92)
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
    elseif DefaultPathingMap.fromTypeOfUnit(whichUnit).hasPathing() then
    
        if SaveNLoad_BoolFlags.isAnyFlag(flags, SaveNLoad_BoolFlags.UNROOTED) then
            set ObjectPathing.get(whichUnit).isDisabled = true
        else
            set ObjectPathing.get(whichUnit).isDisabled = false
            call DefaultPathingMap.fromTypeOfUnit(whichUnit).update(whichUnit, GetUnitX(whichUnit), GetUnitY(whichUnit), GetUnitFacing(whichUnit)*bj_DEGTORAD)
        endif
    endif
    
    if SaveNLoad_BoolFlags.isAnyFlag(flags, SaveNLoad_BoolFlags.NEUTRAL) then
        call LoP_GiveToNeutral(whichUnit)
    endif
endfunction

function LoadUnit takes string chat_str, player un_owner, real centerX, real centerY returns nothing
    local ArrayList_string tokens
    local integer un_type
    local integer str_index
    local unit resultUnit
    
    local SaveNLoad_PlayerData playerId = GetPlayerId(un_owner)
    local UnitSaveFields unitData
    
    local SaveLoader saveData = SaveIO_GetCurrentlyLoadingSave(un_owner)
    local boolean asUnit

    set udg_save_LastLoadedUnit[playerId] = null
    set str_index = CutToComma(chat_str)
    set tokens = StringSplit(SubString(chat_str, 0, str_index), "|")
    set chat_str = SubString(chat_str, str_index+1, StringLength(chat_str))
    
    set un_type = S2ID(tokens[0])
    
    if ConstTable(forbiddenTypes).has(un_type) then
        call tokens.destroy()
        return
    endif
    
    set unitData = unitData.create(un_type, chat_str, centerX, centerY)
    
    if tokens.size > 1 then
        set unitData.skin = S2ID(tokens[1])
    else
        set unitData.skin = 0
    endif
    call tokens.destroy()


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
    
    set asUnit = unitData.selectState != "2"
    if saveData.version < 4 then
        // Selection type 3 (locust) was only added in version 4, so version 3 saves must handle exceptions for unselectable decorations that should be loaded as units
        set asUnit = asUnit or ((StringStartsWith(GetObjectName(un_type), "_BLDG") or (IsUnitIdType(un_type, UNIT_TYPE_STRUCTURE)) and unitData.flyHeight < UnitVisuals.MIN_FLY_HEIGHT)) or (un_type == 'nwgt')
    endif
    if saveData.version < 8 then
        // After version 8, locust unselectable decorations no longer exist, since pathing map libs were created.
        if unitData.selectState == "3" or (unitData.selectState == "2" and asUnit) then
            if StringStartsWith(GetObjectName(un_type), "_BLDG") then
                set asUnit = false
            endif   
        elseif not asUnit then
            set unitData.flags = unitData.flags + SaveNLoad_BoolFlags.UNROOTED
        endif
    endif
    
    if asUnit then
        //Create the unit and modify it according to the chat input data
        set DefaultPathingMaps_dontApplyPathMap = true
        set resultUnit = CreateUnit (un_owner, un_type, unitData.x, unitData.y, unitData.yaw)
        
        if resultUnit != null then
            if IsUnitIdType(un_type, UNIT_TYPE_ANCIENT) then
                call SetUnitFacing(resultUnit, unitData.yaw)
            endif
            
            if unitData.skin != 0 then
                call BlzSetUnitSkin(resultUnit, unitData.skin)
            endif
            
            call LoadUnitFlags(resultUnit, unitData.flags)
            
            if unitData.pitch != 0. or unitData.roll != 0. then
                call UnitSetOrientation(resultUnit, unitData.yaw*bj_DEGTORAD, unitData.pitch, unitData.roll)
            endif
            
            if IsUnitType(resultUnit, UNIT_TYPE_STRUCTURE) then
                call UnitVisualsSetters.StructureFlyHeight(resultUnit, unitData.flyHeight, StructureShouldAutoLand(resultUnit))
            else
                call UnitVisualsSetters.FlyHeight(resultUnit, unitData.flyHeight)
            endif

            //GUMS modifications
            if unitData.size != "D" then
                call ParseScale(resultUnit, unitData.size)
            endif
            if unitData.red != "D" then
                call UnitVisualsSetters.VertexColor(resultUnit, S2I(unitData.red)/2.55, S2I(unitData.green)/2.55, S2I(unitData.blue)/2.55, (255 - S2I(unitData.alpha))/2.55)
            endif
            if unitData.color != "D" then
                call UnitVisualsSetters.Color(resultUnit, S2I(unitData.color))
            endif
            if unitData.animSpeed != "D" then
                call UnitVisualsSetters.AnimSpeed(resultUnit, S2R(unitData.animSpeed))
            endif
            if unitData.animTag != "D" then
                call UnitVisualsSetters.AnimTag(resultUnit, ConvertAnimTags(TAGS.DECOMPRESS, unitData.animTag))
            endif
            if unitData.selectState != "0" then
                if unitData.selectState == "2" then
                    call UnitVisualsSetters.SelectionType(resultUnit, UnitVisuals.SELECTION_LOCUST)
                else
                    call UnitVisualsSetters.SelectionType(resultUnit, S2I(unitData.selectState))
                endif
            endif
        else
            set DefaultPathingMaps_dontApplyPathMap = false
            call DisplayTextToPlayer(un_owner, 0., 0., "Failed to load unit of type: " + ID2S(un_type))
        endif
        
        set udg_save_LastLoadedUnit[playerId] = resultUnit
        set resultUnit = null
    else
        call LoadSpecialEffect(un_owner, un_type, unitData.skin, unitData.x, unitData.y, unitData.flyHeight, unitData.yaw, unitData.pitch, unitData.roll, unitData.size, unitData.red, unitData.green, unitData.blue, unitData.alpha, unitData.color, unitData.animSpeed, unitData.animTag, unitData.flags)
    endif
    
    call unitData.destroy()
endfunction

//! textmacro GUMS_RegisterTag takes FULL, COMPRESSED
    set ConstTable(TAGS.COMPRESS).string[StringHash("$FULL$")] = "$COMPRESSED$"
    set ConstTable(TAGS.DECOMPRESS).string[StringHash("$COMPRESSED$")] = "$FULL$"
//! endtextmacro

private module InitModule

    private static method onInit takes nothing returns nothing
        //! runtextmacro GUMS_RegisterTag("gold", "g")
        //! runtextmacro GUMS_RegisterTag("lumber", "l")
        //! runtextmacro GUMS_RegisterTag("work", "w")
        //! runtextmacro GUMS_RegisterTag("flesh", "f")
        //! runtextmacro GUMS_RegisterTag("ready", "r")
        //! runtextmacro GUMS_RegisterTag("one", "1")
        //! runtextmacro GUMS_RegisterTag("two", "2")
        //! runtextmacro GUMS_RegisterTag("throw", "t")
        //! runtextmacro GUMS_RegisterTag("slam", "sl")
        
        //! runtextmacro GUMS_RegisterTag("large", "sl")
        //! runtextmacro GUMS_RegisterTag("medium", "sm")
        //! runtextmacro GUMS_RegisterTag("small", "ss")

        //! runtextmacro GUMS_RegisterTag("victory", "v")
        //! runtextmacro GUMS_RegisterTag("alternate", "a")
        //! runtextmacro GUMS_RegisterTag("defend", "d")
        //! runtextmacro GUMS_RegisterTag("swim", "s")
        
        //! runtextmacro GUMS_RegisterTag("spin", "sp")
        //! runtextmacro GUMS_RegisterTag("fast", "fa")
        //! runtextmacro GUMS_RegisterTag("talk", "ta")
        
        //! runtextmacro GUMS_RegisterTag("upgrade","u")
        //! runtextmacro GUMS_RegisterTag("first","n1")
        //! runtextmacro GUMS_RegisterTag("second","n2")
        //! runtextmacro GUMS_RegisterTag("third","n3")
        //! runtextmacro GUMS_RegisterTag("fourth","n4")
        //! runtextmacro GUMS_RegisterTag("fifth","n5")
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

endlibrary