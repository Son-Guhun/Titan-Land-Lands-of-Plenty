//************************************************************************************************************
//*                                                                                                          *
//*                              CUSTOM STAT SYSTEM (CSS)                                                    *
//*                                                                                                          *
//*   Author:   Doomlord                                                                                     *
//*   Version:  1.5g                                                                                         *
//*                                                                                                          *
//*   Credits:                                                                                               *
//*   + Earth-Fury:    BonusMod binary algoritm; implementation macro.                                       *
//*   + Crigges:       A great amount of help and support.                                                   *
//*   + Geries:        Help me with the item hashtable values cleanup.                                       *
//*   + rulerofiron99: Item Socketing method referenced from [GUI]Right Click Item Recipe v1.05.             *
//*   + Vexorian:      CSS_SimError [url]http://www.wc3c.net/showthread.php?t=101260[/url]                   *
//*   + Magtheridon96: [Snippet]BoundInt [url]http://www.hiveworkshop.com/forums/2294066-post804.html[/url]  *
//*   + WaterKnight:   Help with the stack for custom Event Response.                                        *
//*   + PurgeandFire:  Pinpoint a possible desync bug with the system.                                       *
//*   + Nestharus:     Mentioning the possible negative life bug in his Bonus lib.                           *
//*                                                                                                          *
//************************************************************************************************************


//**************************************************************************************
//* INTRODUCTION:                                                                      *
//*                                                                                    *
//* An alternative to BonusMod for those who prefer a vanilla JASS approach.           *
//*                                                                                    *
//* Just follow the API and you are pretty much done.                                  *
//**************************************************************************************


//********************************************************************************************************
//* REQUIREMENTS:                                                                                        *
//*                                                                                                      *
//* JNGP [url]http://www.hiveworkshop.com/forums/tools-560/jassnewgenpack-5d-227445[/url] (Recommended)  *
//* OR:                                                                                                  *
//* Your superhuman capability to transfer 198 abilities to your map. (Not Recommended)                  *
//********************************************************************************************************


//************************************************************************************************************************************************
//* INSTALLATION INSTRUCTION:                                                                                                                    *
//*                                                                                                                                              *
//* Step 1: Copy the custom code for bonus handling to your map header.                                                                          *
//* Step 2: Use JNGP to implement the system's abilities through macro. Instruction is included in the Implementation Macro trigger.             *
//* Step 3: Copy the whole CSS folder to your map. Don't forget to turn on "Automatically create unknown variables while pasting trigger data".  *
//* Step 4: Except for this trigger, delete every other useless elements.                                                                        *
//* Step 5: Use this BonusMod alternative however you want.                                                                                      *
//*                                                                                                                                              *
//************************************************************************************************************************************************


//**************************************************************************************
//* Bonus Types Identifier:                                                            *
//*                                                                                    *
//* Armor Bonus:        0                                                              *
//* Attack Speed Bonus: 1                                                              *
//* Damage Bonus:       2                                                              *
//* Agility Bonus:      3                                                              *
//* Intelligence Bonus: 4                                                              *
//* Strength Bonus:     5                                                              *
//* Life Regen Bonus:   6                                                              *
//* Mana Regen Bonus:   7                                                              *
//* Life Bonus:         8                                                              *
//* Mana Bonus:         9                                                              *
//* Sight Range Bonus:  10                                                             *
//**************************************************************************************


//********************************************************************************
//* Generic Bonus APIs                                                           *
//*                                                                              *
//* CSS_GetBonus takes unit u, integer bonusType returns integer                 *
//* CSS_AddBonus takes unit u, integer amount, integer bonusType returns nothing *
//* CSS_ClearBonus takes unit u, integer bonusType                               *
//********************************************************************************


// For preloading abilities

function CSS_Preload takes nothing returns nothing
    local integer i = 0
    local unit u = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'hfoo', 0, 0, 0.00)

    loop
        exitwhen i > 197
        call UnitAddAbility(u, udg_CSS_Abilities[i])
        set i = i + 1
    endloop

    call RemoveUnit(u)
    set u = null
endfunction

//===========================================================================
function InitTrig_CSS_Standalone_Bonus takes nothing returns nothing
    local integer i = 0
    local integer a = 1

    set udg_CSS_Abilities[0] = 'ZxA0'
    set udg_CSS_Abilities[1] = 'ZxA1'
    set udg_CSS_Abilities[2] = 'ZxA2'
    set udg_CSS_Abilities[3] = 'ZxA3'
    set udg_CSS_Abilities[4] = 'ZxA4'
    set udg_CSS_Abilities[5] = 'ZxA5'
    set udg_CSS_Abilities[6] = 'ZxA6'
    set udg_CSS_Abilities[7] = 'ZxA7'
    set udg_CSS_Abilities[8] = 'ZxA8'
    set udg_CSS_Abilities[9] = 'ZxA9'
    set udg_CSS_Abilities[10] = 'ZxAa'
    set udg_CSS_Abilities[11] = 'ZxAb'
    set udg_CSS_Abilities[12] = 'ZxAc'
    set udg_CSS_Abilities[13] = 'ZxAd'
    set udg_CSS_Abilities[14] = 'ZxAe'
    set udg_CSS_Abilities[15] = 'ZxAf'
    set udg_CSS_Abilities[16] = 'ZxAg'
    set udg_CSS_Abilities[17] = 'ZxAh'
    set udg_CSS_Abilities[18] = 'ZxI0'
    set udg_CSS_Abilities[19] = 'ZxI1'
    set udg_CSS_Abilities[20] = 'ZxI2'
    set udg_CSS_Abilities[21] = 'ZxI3'
    set udg_CSS_Abilities[22] = 'ZxI4'
    set udg_CSS_Abilities[23] = 'ZxI5'
    set udg_CSS_Abilities[24] = 'ZxI6'
    set udg_CSS_Abilities[25] = 'ZxI7'
    set udg_CSS_Abilities[26] = 'ZxI8'
    set udg_CSS_Abilities[27] = 'ZxI9'
    set udg_CSS_Abilities[28] = 'ZxIa'
    set udg_CSS_Abilities[29] = 'ZxIb'
    set udg_CSS_Abilities[30] = 'ZxIc'
    set udg_CSS_Abilities[31] = 'ZxId'
    set udg_CSS_Abilities[32] = 'ZxIe'
    set udg_CSS_Abilities[33] = 'ZxIf'
    set udg_CSS_Abilities[34] = 'ZxIg'
    set udg_CSS_Abilities[35] = 'ZxIh'
    set udg_CSS_Abilities[36] = 'ZxB0'
    set udg_CSS_Abilities[37] = 'ZxB1'
    set udg_CSS_Abilities[38] = 'ZxB2'
    set udg_CSS_Abilities[39] = 'ZxB3'
    set udg_CSS_Abilities[40] = 'ZxB4'
    set udg_CSS_Abilities[41] = 'ZxB5'
    set udg_CSS_Abilities[42] = 'ZxB6'
    set udg_CSS_Abilities[43] = 'ZxB7'
    set udg_CSS_Abilities[44] = 'ZxB8'
    set udg_CSS_Abilities[45] = 'ZxB9'
    set udg_CSS_Abilities[46] = 'ZxBa'
    set udg_CSS_Abilities[47] = 'ZxBb'
    set udg_CSS_Abilities[48] = 'ZxBc'
    set udg_CSS_Abilities[49] = 'ZxBd'
    set udg_CSS_Abilities[50] = 'ZxBe'
    set udg_CSS_Abilities[51] = 'ZxBf'
    set udg_CSS_Abilities[52] = 'ZxBg'
    set udg_CSS_Abilities[53] = 'ZxBh'
    set udg_CSS_Abilities[54] = 'ZxG0'
    set udg_CSS_Abilities[55] = 'ZxG1'
    set udg_CSS_Abilities[56] = 'ZxG2'
    set udg_CSS_Abilities[57] = 'ZxG3'
    set udg_CSS_Abilities[58] = 'ZxG4'
    set udg_CSS_Abilities[59] = 'ZxG5'
    set udg_CSS_Abilities[60] = 'ZxG6'
    set udg_CSS_Abilities[61] = 'ZxG7'
    set udg_CSS_Abilities[62] = 'ZxG8'
    set udg_CSS_Abilities[63] = 'ZxG9'
    set udg_CSS_Abilities[64] = 'ZxGa'
    set udg_CSS_Abilities[65] = 'ZxGb'
    set udg_CSS_Abilities[66] = 'ZxGc'
    set udg_CSS_Abilities[67] = 'ZxGd'
    set udg_CSS_Abilities[68] = 'ZxGe'
    set udg_CSS_Abilities[69] = 'ZxGf'
    set udg_CSS_Abilities[70] = 'ZxGg'
    set udg_CSS_Abilities[71] = 'ZxGh'
    set udg_CSS_Abilities[72] = 'ZxH0'
    set udg_CSS_Abilities[73] = 'ZxH1'
    set udg_CSS_Abilities[74] = 'ZxH2'
    set udg_CSS_Abilities[75] = 'ZxH3'
    set udg_CSS_Abilities[76] = 'ZxH4'
    set udg_CSS_Abilities[77] = 'ZxH5'
    set udg_CSS_Abilities[78] = 'ZxH6'
    set udg_CSS_Abilities[79] = 'ZxH7'
    set udg_CSS_Abilities[80] = 'ZxH8'
    set udg_CSS_Abilities[81] = 'ZxH9'
    set udg_CSS_Abilities[82] = 'ZxHa'
    set udg_CSS_Abilities[83] = 'ZxHb'
    set udg_CSS_Abilities[84] = 'ZxHc'
    set udg_CSS_Abilities[85] = 'ZxHd'
    set udg_CSS_Abilities[86] = 'ZxHe'
    set udg_CSS_Abilities[87] = 'ZxHf'
    set udg_CSS_Abilities[88] = 'ZxHg'
    set udg_CSS_Abilities[89] = 'ZxHh'
    set udg_CSS_Abilities[90] = 'ZxF0'
    set udg_CSS_Abilities[91] = 'ZxF1'
    set udg_CSS_Abilities[92] = 'ZxF2'
    set udg_CSS_Abilities[93] = 'ZxF3'
    set udg_CSS_Abilities[94] = 'ZxF4'
    set udg_CSS_Abilities[95] = 'ZxF5'
    set udg_CSS_Abilities[96] = 'ZxF6'
    set udg_CSS_Abilities[97] = 'ZxF7'
    set udg_CSS_Abilities[98] = 'ZxF8'
    set udg_CSS_Abilities[99] = 'ZxF9'
    set udg_CSS_Abilities[100] = 'ZxFa'
    set udg_CSS_Abilities[101] = 'ZxFb'
    set udg_CSS_Abilities[102] = 'ZxFc'
    set udg_CSS_Abilities[103] = 'ZxFd'
    set udg_CSS_Abilities[104] = 'ZxFe'
    set udg_CSS_Abilities[105] = 'ZxFf'
    set udg_CSS_Abilities[106] = 'ZxFg'
    set udg_CSS_Abilities[107] = 'ZxFh'
    set udg_CSS_Abilities[108] = 'ZxJ0'
    set udg_CSS_Abilities[109] = 'ZxJ1'
    set udg_CSS_Abilities[110] = 'ZxJ2'
    set udg_CSS_Abilities[111] = 'ZxJ3'
    set udg_CSS_Abilities[112] = 'ZxJ4'
    set udg_CSS_Abilities[113] = 'ZxJ5'
    set udg_CSS_Abilities[114] = 'ZxJ6'
    set udg_CSS_Abilities[115] = 'ZxJ7'
    set udg_CSS_Abilities[116] = 'ZxJ8'
    set udg_CSS_Abilities[117] = 'ZxJ9'
    set udg_CSS_Abilities[118] = 'ZxJa'
    set udg_CSS_Abilities[119] = 'ZxJb'
    set udg_CSS_Abilities[120] = 'ZxJc'
    set udg_CSS_Abilities[121] = 'ZxJd'
    set udg_CSS_Abilities[122] = 'ZxJe'
    set udg_CSS_Abilities[123] = 'ZxJf'
    set udg_CSS_Abilities[124] = 'ZxJg'
    set udg_CSS_Abilities[125] = 'ZxJh'
    set udg_CSS_Abilities[126] = 'ZxK0'
    set udg_CSS_Abilities[127] = 'ZxK1'
    set udg_CSS_Abilities[128] = 'ZxK2'
    set udg_CSS_Abilities[129] = 'ZxK3'
    set udg_CSS_Abilities[130] = 'ZxK4'
    set udg_CSS_Abilities[131] = 'ZxK5'
    set udg_CSS_Abilities[132] = 'ZxK6'
    set udg_CSS_Abilities[133] = 'ZxK7'
    set udg_CSS_Abilities[134] = 'ZxK8'
    set udg_CSS_Abilities[135] = 'ZxK9'
    set udg_CSS_Abilities[136] = 'ZxKa'
    set udg_CSS_Abilities[137] = 'ZxKb'
    set udg_CSS_Abilities[138] = 'ZxKc'
    set udg_CSS_Abilities[139] = 'ZxKd'
    set udg_CSS_Abilities[140] = 'ZxKe'
    set udg_CSS_Abilities[141] = 'ZxKf'
    set udg_CSS_Abilities[142] = 'ZxKg'
    set udg_CSS_Abilities[143] = 'ZxKh'
    set udg_CSS_Abilities[144] = 'ZxE0'
    set udg_CSS_Abilities[145] = 'ZxE1'
    set udg_CSS_Abilities[146] = 'ZxE2'
    set udg_CSS_Abilities[147] = 'ZxE3'
    set udg_CSS_Abilities[148] = 'ZxE4'
    set udg_CSS_Abilities[149] = 'ZxE5'
    set udg_CSS_Abilities[150] = 'ZxE6'
    set udg_CSS_Abilities[151] = 'ZxE7'
    set udg_CSS_Abilities[152] = 'ZxE8'
    set udg_CSS_Abilities[153] = 'ZxE9'
    set udg_CSS_Abilities[154] = 'ZxEa'
    set udg_CSS_Abilities[155] = 'ZxEb'
    set udg_CSS_Abilities[156] = 'ZxEc'
    set udg_CSS_Abilities[157] = 'ZxEd'
    set udg_CSS_Abilities[158] = 'ZxEe'
    set udg_CSS_Abilities[159] = 'ZxEf'
    set udg_CSS_Abilities[160] = 'ZxEg'
    set udg_CSS_Abilities[161] = 'ZxEh'
    set udg_CSS_Abilities[162] = 'ZxD0'
    set udg_CSS_Abilities[163] = 'ZxD1'
    set udg_CSS_Abilities[164] = 'ZxD2'
    set udg_CSS_Abilities[165] = 'ZxD3'
    set udg_CSS_Abilities[166] = 'ZxD4'
    set udg_CSS_Abilities[167] = 'ZxD5'
    set udg_CSS_Abilities[168] = 'ZxD6'
    set udg_CSS_Abilities[169] = 'ZxD7'
    set udg_CSS_Abilities[170] = 'ZxD8'
    set udg_CSS_Abilities[171] = 'ZxD9'
    set udg_CSS_Abilities[172] = 'ZxDa'
    set udg_CSS_Abilities[173] = 'ZxDb'
    set udg_CSS_Abilities[174] = 'ZxDc'
    set udg_CSS_Abilities[175] = 'ZxDd'
    set udg_CSS_Abilities[176] = 'ZxDe'
    set udg_CSS_Abilities[177] = 'ZxDf'
    set udg_CSS_Abilities[178] = 'ZxDg'
    set udg_CSS_Abilities[179] = 'ZxDh'
    set udg_CSS_Abilities[180] = 'ZxC0'
    set udg_CSS_Abilities[181] = 'ZxC1'
    set udg_CSS_Abilities[182] = 'ZxC2'
    set udg_CSS_Abilities[183] = 'ZxC3'
    set udg_CSS_Abilities[184] = 'ZxC4'
    set udg_CSS_Abilities[185] = 'ZxC5'
    set udg_CSS_Abilities[186] = 'ZxC6'
    set udg_CSS_Abilities[187] = 'ZxC7'
    set udg_CSS_Abilities[188] = 'ZxC8'
    set udg_CSS_Abilities[189] = 'ZxC9'
    set udg_CSS_Abilities[190] = 'ZxCa'
    set udg_CSS_Abilities[191] = 'ZxCb'
    set udg_CSS_Abilities[192] = 'ZxCc'
    set udg_CSS_Abilities[193] = 'ZxCd'
    set udg_CSS_Abilities[194] = 'ZxCe'
    set udg_CSS_Abilities[195] = 'ZxCf'
    set udg_CSS_Abilities[196] = 'ZxCg'
    set udg_CSS_Abilities[197] = 'ZxCh'

    loop
        exitwhen i > 30
        set udg_CSS_Power[i] = a
        set a = a*2
        set i = i + 1
    endloop

    set udg_CSS_Hashtable = InitHashtable()

    if udg_CSS_PreloadBoolean then
        call CSS_Preload()
    endif
endfunction