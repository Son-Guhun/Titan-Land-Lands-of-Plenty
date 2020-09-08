globals
    timer initCheckTimer
    boolean initCheckBool = false
endglobals

function InitCheck takes nothing returns nothing
    if initCheckBool == false then
        call BJDebugMsg("Error! Initialization failed.")
    endif
endfunction

//! inject main
    call SetCameraBounds(- 29056.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 19968.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 32256.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 29184.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 29056.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 29184.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 32256.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 19968.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("CityScapeDay")
    call SetAmbientNightSound("CityScapeNight")
    call SetMapMusic("Music", true, 0)
    call InitSounds()
    call CreateRegions()
    call CreateCameras()
    call InitUpgrades()
    call CreateAllDestructables()
    call CreateAllUnits()
    call InitBlizzard()

    call TimerStart(CreateTimer(), 0., false, function InitCheck)
    //! dovjassinit

    call InitGlobals()
    call InitCustomTriggers()
    call RunInitializationTriggers()
    set initCheckBool = true
//! endinject