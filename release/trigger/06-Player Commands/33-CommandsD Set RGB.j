function ColorSystem_Set_RGB_Actions takes nothing returns nothing
    local string input = SubString(GetEventPlayerChatString() , 5 , StringLength(GetEventPlayerChatString())) + ","
    local string output
    local integer pN = GetPlayerId(GetTriggerPlayer())+1
    local integer red = CutToCharacter(input," ")
    local integer green
    local integer blue
    local integer alpha
    set output = SubString(input,0,red)
    set udg_ColorSystem_Red[pN] = S2R(output)
    
    set input = SubString( input , red+1 , ( StringLength(input) + 1) )
    set green = CutToCharacter(input," ")
    set output = SubString(input,0,green)
    set udg_ColorSystem_Green[pN] = S2R(output)

    set input = SubString(input,green+1,StringLength(input))
    set blue = CutToCharacter(input," ")
    set output = SubString(input,0,blue)
    set udg_ColorSystem_Blue[pN] = S2R(output)

    set input = SubString(input,blue+1,StringLength(input))
    set alpha = CutToCharacter(input," ")
    set output = SubString(input,0,alpha)
    set udg_ColorSystem_Alpha[pN] = S2R(output)
    
    //call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "RGBT has been set to: " + R2S(udg_ColorSystem_Red[pN])+ " "+ R2S(udg_ColorSystem_Green[pN])+ " "+ R2S(udg_ColorSystem_Blue[pN])+ " "+ R2S(udg_ColorSystem_Alpha[pN]) + " ")
    call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "RGBT has been set")
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_RGB takes nothing returns nothing
    local integer i = 0
    set gg_trg_CommandsD_Set_RGB = CreateTrigger(  )
    loop
    exitwhen i > 11
        call TriggerRegisterPlayerChatEvent( gg_trg_CommandsD_Set_RGB, Player(i), "-rgb ", false )
    set i = i + 1
    endloop
    call TriggerAddAction( gg_trg_CommandsD_Set_RGB, function ColorSystem_Set_RGB_Actions )
endfunction

