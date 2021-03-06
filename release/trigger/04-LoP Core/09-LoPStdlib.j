library LoPStdLib requires AttachedSFX, UnitVisualMods, LoPWidgets, LoPCommandsAbility
/*
=========
 Description
=========

    This library defines the LoP struct library, which follows the Import Library Standard.
    
    Utilities that use may external libraries are defined here. The LoP struct also imports libraries
using convenient abbreviations.
    
=========
 Documentation
=========
    
    lib LoP:
    
        scope H    -> LoPHeader
        scope UVS  -> UnitVisualsSetters
        
        Constants:
            player NEUTRAL_PASSIVE  -> imported from LoPHeader
            
        Globals:
            player gameMaster  -> imported from LoPHeader

*/
//==================================================================================================
//                                        Source Code
//==================================================================================================

struct LoP extends array
    
    //! runtextmacro ImportLibAs("LoPHeader", "H")
    //! runtextmacro ImportLibAs("UnitVisualsSetters", "UVS")
    
    //! runtextmacro FromLibImportConstant("H", "NEUTRAL_PASSIVE", "player")
    //! runtextmacro FromLibImportGlobal("H", "gameMaster", "player")

endstruct

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
    local integer skin
    
    if newType < 1 then
        set newType = GetUnitTypeId(whichUnit)
        set skin = BlzGetUnitSkin(whichUnit)
        if skin == GetUnitTypeId(whichUnit) then
            set skin = 0
        endif
    else
        set skin = 0
    endif
    
    set DefaultPathingMaps_dontApplyPathMap = true 
    set u = LoP.UVS.Copy(whichUnit, owner, newType)
    
    if u != null then
        if UnitHasAttachedEffect(whichUnit) then
            call UnitAttachEffect(u, GetUnitAttachedEffect(whichUnit).copy(newType, skin))
        endif
        
        if skin != 0 then
            call BlzSetUnitSkin(u, skin)
        endif
        
        if LoP_IsUnitHero(whichUnit) then
            call UnitAddAbilities(u, UnitEnumRemoveableAbilityIds(whichUnit))
        endif
        
        if DefaultPathingMap.fromTypeOfUnit(u).hasPathing() then
            set ObjectPathing.get(u).isDisabled = ObjectPathing.get(whichUnit).isDisabled
            call DefaultPathingMap.fromTypeOfUnit(u).update(u, GetUnitX(u), GetUnitY(u), GetUnitFacing(u)*bj_DEGTORAD)
        endif
    else
        set u = null
    endif
    
    set whichUnit = null
    return u
endfunction


function LopCopyUnitSameType takes unit whichUnit, player owner returns unit
    return LopCopyUnit(whichUnit, owner, 0)
endfunction


endlibrary