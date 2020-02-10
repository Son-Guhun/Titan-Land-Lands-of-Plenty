library LoPStdLib initializer Init requires AttachedSFX, UnitVisualMods, LoPWidgets, LoPCommandsAbility

private function UnitAddAbilities takes unit whichUnit, LinkedHashSet abilities returns nothing
    local LinkedHashSet oldAbilities = UnitEnumRemoveableAbilityIds(whichUnit)
    local RemoveableAbility abilId = abilities.begin()
    
    
    call LoPCommandsAbility_ClearAbilities(whichUnit)
    loop
    exitwhen abilId == abilities.end()
        if abilId.isHero or oldAbilities.contains(abilId) then
            call UnitAddAbility(whichUnit, abilId)
        endif
        set abilId = abilities.next(abilId)
    endloop
    
    call abilities.destroy()
    call oldAbilities.destroy()
endfunction

function LopCopyUnit takes unit u, player owner, integer newType returns unit
    local unit whichUnit = u
    
    if newType < 1 then
        set newType = GetUnitTypeId(whichUnit)
    endif
    
    set u = GUMSCopyUnit(whichUnit, owner, newType)
    if UnitHasAttachedEffect(whichUnit) then
        call UnitAttachEffect(u, GetUnitAttachedEffect(whichUnit).copy(newType))
    endif
    
    if LoP_IsUnitHero(whichUnit) then
        call UnitAddAbilities(u, UnitEnumRemoveableAbilityIds(whichUnit))
    endif
    
    set whichUnit = null
    return u
endfunction


function LopCopyUnitSameType takes unit whichUnit, player owner returns unit
    return LopCopyUnit(whichUnit, owner, 0)
endfunction


globals
    private framehandle ConsoleUIBackdrop
    private framehandle array commandButtons
    public boolean altZEnabled = true
endglobals


function IsFullScreen takes nothing returns boolean
    return not BlzFrameIsVisible(ConsoleUIBackdrop)
endfunction

function FullScreen takes boolean enable, integer cmdBtnAlpha returns nothing
    local integer i = 0
    
    if IsFullScreen() != enable then

        call BlzHideOriginFrames(enable)
        call BlzEnableUIAutoPosition(not enable)
        call BlzFrameSetVisible(ConsoleUIBackdrop, not enable)
    endif

    if not enable then
        set cmdBtnAlpha = 255
    endif
    loop
    exitwhen i == 12
        call BlzFrameSetAlpha(commandButtons[i], cmdBtnAlpha)
        set i = i + 1
    endloop
endfunction

private function Init takes nothing returns nothing
    local integer i = 0

    set ConsoleUIBackdrop = BlzGetFrameByName("ConsoleUIBackdrop", 0)
    loop
    exitwhen i == 12
        set commandButtons[i] = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, i)
        set i = i + 1
    endloop
endfunction



endlibrary