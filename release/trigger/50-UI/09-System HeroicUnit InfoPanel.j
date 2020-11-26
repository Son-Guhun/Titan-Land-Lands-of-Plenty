scope HeroicUnitInfoPanel

globals
    private string lastValue = null
    
    private framehandle InfoPanelHero
    private framehandle InfoPanelRank
    private framehandle InfoPanelDamage1
    
    private framehandle InfoPanelDescriptionHolder
    private framehandle InfoPanelProgressBar
    private framehandle InfoPanelExpBar
    
    private framehandle InfoPanelNameText
    private framehandle InfoPanelClassText
    
    
    private framehandle InfoPanelHeroIcon
    private framehandle InfoPanelHeroStr
    private framehandle InfoPanelHeroAgi
    private framehandle InfoPanelHeroInt
endglobals

private function onTimer takes nothing returns nothing
    local string text = BlzFrameGetText(InfoPanelNameText)
    local integer id
    
    if lastValue != text then
        if UnitName_ValidateName(text) then
            call BlzFrameSetText(InfoPanelNameText, UnitName_GetActualName(text))
            set lastValue = UnitName_GetActualName(text)
            
            set id = UnitName_GetUserData(text)
            if LoP_UnitData.get(udg_UDexUnits[id]).isHeroic then
            
                if GetOwningPlayer(udg_UDexUnits[id]) == GetLocalPlayer() or /*
                */ GetPlayerAlliance(GetOwningPlayer(udg_UDexUnits[id]), GetLocalPlayer(), ALLIANCE_SHARED_CONTROL) or/*
                */ GetPlayerAlliance(GetOwningPlayer(udg_UDexUnits[id]), GetLocalPlayer(), ALLIANCE_SHARED_ADVANCED_CONTROL) then
                
                    call BlzFrameSetVisible(InfoPanelProgressBar, false)
                    call BlzFrameSetVisible(InfoPanelExpBar, true)
                    call BlzFrameSetValue(InfoPanelExpBar, 0.)
                endif
            
                call BlzFrameSetVisible(InfoPanelHero, true)
                call BlzFrameSetVisible(InfoPanelRank, false)
                call BlzFrameSetVisible(InfoPanelDamage1, false)
                
                call BlzFrameSetVisible(InfoPanelDescriptionHolder, true)
                call BlzFrameSetText(InfoPanelClassText, "Level " + I2S(BlzGetUnitIntegerField(udg_UDexUnits[id], UNIT_IF_LEVEL)) + " Hero")

                call BlzFrameSetTexture(InfoPanelHeroIcon, "Images\\UI\\AttrStamina.blp", 0, true)
                call BlzFrameSetText(InfoPanelHeroStr, I2S(BlzGetUnitIntegerField(udg_UDexUnits[id], UNIT_IF_STRENGTH_PERMANENT)))
                call BlzFrameSetText(InfoPanelHeroAgi, I2S(BlzGetUnitIntegerField(udg_UDexUnits[id], UNIT_IF_AGILITY_PERMANENT)))
                call BlzFrameSetText(InfoPanelHeroInt, I2S(BlzGetUnitIntegerField(udg_UDexUnits[id], UNIT_IF_INTELLIGENCE_PERMANENT)))
            endif
        else
            set lastValue = text
        endif
    endif
endfunction

private function onStart takes nothing returns nothing
    set InfoPanelHero = BlzGetFrameByName("SimpleInfoPanelIconHero", 6)
    set InfoPanelRank = BlzGetFrameByName("SimpleInfoPanelIconRank", 3)
    set InfoPanelDamage1 = BlzGetFrameByName("SimpleInfoPanelIconDamage", 1)
    
    set InfoPanelDescriptionHolder = BlzGetFrameByName("SimpleHoldDescriptionValue", 0)
    set InfoPanelProgressBar = BlzGetFrameByName("SimpleProgressIndicator", 0)
    set InfoPanelExpBar = BlzGetFrameByName("SimpleHeroLevelBar", 0)
    
    set InfoPanelNameText = BlzGetFrameByName("SimpleNameValue", 0)
    set InfoPanelClassText = BlzGetFrameByName("SimpleClassValue", 0)
    
    
    set InfoPanelHeroIcon = BlzGetFrameByName("InfoPanelIconHeroIcon", 6)
    set InfoPanelHeroStr = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)
    set InfoPanelHeroAgi = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)
    set InfoPanelHeroInt = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)
    
    call TimerStart(GetExpiredTimer(), 0.01, true, function onTimer)
endfunction

//===========================================================================
function InitTrig_System_HeroicUnit_InfoPanel takes nothing returns nothing
    call TimerStart(CreateTimer(), 0, false, function onStart)
endfunction

endscope