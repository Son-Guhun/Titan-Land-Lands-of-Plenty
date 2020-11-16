library SaveUnitExtras requires SaveNLoad, SaveIO, optional UserDefinedRects, optional LoPHeroicUnit, optional CustomizableAbilityList, optional MultiPatrol
/*
    Saves extra data from units which is not included in the main string.


        -> Rect settings
        -> Removeable abilities
        -> Patrol Points
        -> Waypoint destination
        -> HeroicUnit state
*/

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
endif

private function EncodeRemoveableAbilities takes unit whichUnit returns string
    local ArrayList_ability abilities = UnitEnumRemoveableAbilities(whichUnit)
    local integer i = 0
    local string result = "=a "
    
    loop
    exitwhen i == abilities.end()
        set result = result + ID2S(RemoveableAbility.fromAbility(abilities[i])) + ","
        set i = abilities.next(i)
    endloop
    
    call abilities.destroy()
    return result
endfunction

function IsUnitWaygate takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'Awrp') > 0
endfunction

function Save_PatrolPointStr takes real x, real y returns string
    return SaveNLoad_FormatString("SnL_unit_extra", "=p " + R2S(x) + "=" +  R2S(y))
endfunction

function Save_SaveUnitPatrolPoints takes SaveWriter saveData, integer unitHandleId returns nothing
    local integer i = 1
    local integer totalPoints = Patrol_GetTotalPatrolPoints(unitHandleId)
    local string saveStr
    
    loop
    exitwhen i > totalPoints
        call saveData.write(Save_PatrolPointStr(Patrol_GetPointX(unitHandleId, i),Patrol_GetPointY(unitHandleId, i)))
        set i = i+1
    endloop
endfunction

function SaveUnitExtraStrings takes SaveWriter saveData, unit saveUnit, integer unitHandleId returns nothing
        
        static if LIBRARY_UserDefinedRects then
            if GUDR_IsUnitIdGenerator(unitHandleId) then
                call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", Save_GetGUDRSaveString(unitHandleId)))
            endif
        endif
        
        if IsUnitWaygate(saveUnit) then
            if WaygateIsActive(saveUnit) then
                call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=w " + R2S(WaygateGetDestinationX(saveUnit)) + "=" + R2S(WaygateGetDestinationY(saveUnit)) + "=T="))
            else
                call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=w " + R2S(WaygateGetDestinationX(saveUnit)) + "=" + R2S(WaygateGetDestinationY(saveUnit)) + "=F="))
            endif
        endif
        
        static if LIBRARY_MultiPatrol then
            if Patrol_UnitIdHasPatrolPoints(unitHandleId) then
                call Save_SaveUnitPatrolPoints(saveData, unitHandleId)
            endif
        endif
        
        static if LIBRARY_LoPHeroicUnit then
            if LoP_IsUnitCustomHero(saveUnit) then
                call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=h S"))
            endif
        endif
        
        static if LIBRARY_CustomizableAbilityList then
            if GetUnitAbilityLevel(saveUnit, 'AHer') > 0 then
                call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", EncodeRemoveableAbilities(saveUnit)))
            endif
        endif
endfunction


endlibrary