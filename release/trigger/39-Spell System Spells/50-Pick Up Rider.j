function Trig_Pick_Up_Rider_Actions takes nothing returns nothing
    local integer error
    local player trigP = GetTriggerPlayer()
    
    if LoP_PlayerOwnsUnit(udg_Spell__CasterOwner, udg_Spell__Target) then
        set error = MountSystem_MountUnit(udg_Spell__Target, udg_Spell__Caster)
        
        if error == MountSystem_Errors.NO_AMOV then
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Units with no movement cannot have a mount.")
        elseif error == MountSystem_Errors.MOUNT_SELF then
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Unit cannot be its own mount.")
        elseif error == MountSystem_Errors.MOUNT_RIDER then
            call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "Unit cannot mount its own rider.")
        endif
    else
        call LoP_WarnPlayer(trigP, LoPChannels.ERROR, "This is not your unit!")
    endif
endfunction

//===========================================================================
function InitTrig_Pick_Up_Rider takes nothing returns nothing
    call RegisterSpellSimple('A04S', function Trig_Pick_Up_Rider_Actions, null)
endfunction

