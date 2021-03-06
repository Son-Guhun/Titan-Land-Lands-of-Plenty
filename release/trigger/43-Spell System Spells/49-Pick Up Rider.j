function Trig_Pick_Up_Rider_Actions takes nothing returns nothing
    local integer error
    local player trigP = GetTriggerPlayer()
    
    if LoP_PlayerOwnsUnit(udg_Spell__CasterOwner, udg_Spell__Target) then
        set error = MountSystem_MountUnit(udg_Spell__Target, udg_Spell__Caster)
        
        if error == MountSystem_Errors.NONE then
            call LoP.H.UnitDisableAbility(udg_Spell__Caster, 'A04S', true)
            
        elseif error == MountSystem_Errors.NO_AMOV then
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Units with no movement cannot have a mount.")
            
        elseif error == MountSystem_Errors.MOUNT_SELF then
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Unit cannot be its own mount.")
            
        elseif error == MountSystem_Errors.MOUNT_RIDER then
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Unit cannot mount its own rider.")
        
        elseif error == MountSystem_Errors.OVERFLOW then
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Too many mounted units: no more than " + I2S(MountSystem_MAX_COUNT) + " mounted units can exist concurrently.")
            
        else
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Unkown error. Please report this.") 
        endif
    else
        call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "This is not your unit!")
    endif
endfunction

//===========================================================================
function InitTrig_Pick_Up_Rider takes nothing returns nothing
    call RegisterSpellSimple('A04S', function Trig_Pick_Up_Rider_Actions, null)
endfunction

