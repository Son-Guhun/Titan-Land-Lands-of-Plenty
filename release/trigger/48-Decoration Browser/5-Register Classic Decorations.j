library RegisterClassicDecorations requires RegisterDecorationNames

//! runtextmacro optional LoPUnitCompatibility()

private function StringHash takes string str returns integer
    return StringHashEx(str)
endfunction


globals
    private hashtable hashHandle = InitHashtable()
endglobals  
//! runtextmacro DeclareParentHashtableWrapperModule("hashHandle", "true", "GeneralHashtable", "private")
//! runtextmacro DeclareParentHashtableWrapperStruct("GeneralHashtable","private")

struct DecorationList extends array
    //! runtextmacro HashStruct_SetHashtableWrapper("GeneralHashtable")
    
    //! runtextmacro HashStruct_NewPrimitiveFieldEx("GeneralHashtable", "size", "integer", "-1")
    //! runtextmacro HashStruct_NewStructFieldEx("GeneralHashtable", "sub", "thistype", "-2")
    //! runtextmacro HashStruct_NewStructFieldEx("GeneralHashtable", "sup", "thistype", "-3")

    implement DecorationListTemplate
endstruct
    
//! runtextmacro RegisterDecorationNamesFunctionTemplate("DecorationList")

/*
Registering unit names on the decoration list takes quite a lot of processing, which means it can 
easily hit the OP limit imposed by JASS. To avoid this, we have to execute the code in separate threads.

This code is automatically generated using the searchindexernew.py script in the repository.
*/

private module A0
private static method onInit takes nothing returns nothing
call RegisterThing('h08J')
call RegisterThing('h00R')
call RegisterThing('h0HS')
call RegisterThing('h0HU')
call RegisterThing('h0HV')
call RegisterThing('h0IB')
call RegisterThing('h0HW')
call RegisterThing('h0HX')
call RegisterThing('h0HY')
call RegisterThing('h0HZ')
call RegisterThing('h0HP')
call RegisterThing('h0HT')
call RegisterThing('h0I0')
call RegisterThing('h0I1')
call RegisterThing('h0I2')
call RegisterThing('h0I3')
call RegisterThing('h0I4')
call RegisterThing('h0I5')
call RegisterThing('h0I6')
call RegisterThing('h0I7')
call RegisterThing('h0I8')
call RegisterThing('h0I9')
call RegisterThing('h03C')
call RegisterThing('h03E')
call RegisterThing('h03D')
call RegisterThing('h03F')
call RegisterThing('h03G')
call RegisterThing('h03A')
call RegisterThing('h039')
call RegisterThing('h03B')
call RegisterThing('h0SG')
call RegisterThing('h038')
call RegisterThing('h13L')
call RegisterThing('h13M')
call RegisterThing('h13T')
call RegisterThing('h13N')
call RegisterThing('h13P')
call RegisterThing('h13Q')
call RegisterThing('h13R')
call RegisterThing('h13S')
call RegisterThing('h13U')
call RegisterThing('h13O')
call RegisterThing('h04H')
call RegisterThing('h04O')
call RegisterThing('h04K')
call RegisterThing('h04M')
call RegisterThing('h04G')
call RegisterThing('h04N')
call RegisterThing('h04L')
call RegisterThing('h04I')
call RegisterThing('h04J')
call RegisterThing('h0LZ')
call RegisterThing('h0M1')
call RegisterThing('h0MB')
call RegisterThing('h0MD')
call RegisterThing('h0C9')
call RegisterThing('h0CA')
call RegisterThing('h0CB')
call RegisterThing('h0CC')
call RegisterThing('h0BI')
call RegisterThing('h0CD')
call RegisterThing('h0CE')
call RegisterThing('h0CF')
call RegisterThing('h0CG')
call RegisterThing('h0CH')
call RegisterThing('h088')
call RegisterThing('h089')
call RegisterThing('h08C')
call RegisterThing('h08D')
call RegisterThing('h08A')
call RegisterThing('h11V')
call RegisterThing('h11X')
call RegisterThing('h124')
call RegisterThing('h122')
call RegisterThing('h11Y')
call RegisterThing('h126')
call RegisterThing('h0F2')
call RegisterThing('h0F3')
call RegisterThing('h0F4')
call RegisterThing('h0F5')
call RegisterThing('h0F6')
call RegisterThing('h0F7')
call RegisterThing('h0LN')
call RegisterThing('h0LO')
call RegisterThing('h0LP')
call RegisterThing('h0Q3')
call RegisterThing('h0LQ')
call RegisterThing('h0LR')
call RegisterThing('h0LS')
call RegisterThing('u05F')
call RegisterThing('h0LT')
call RegisterThing('h0LV')
call RegisterThing('h0LU')
call RegisterThing('h1MU')
call RegisterThing('ncb3')
call RegisterThing('ncb4')
call RegisterThing('ncb5')
call RegisterThing('ncb1')
call RegisterThing('ncb2')
call RegisterThing('ncb0')
call RegisterThing('ncb8')
call RegisterThing('ncb7')
call RegisterThing('ncb6')
call RegisterThing('ncbe')
call RegisterThing('ncbd')
call RegisterThing('ncbf')
call RegisterThing('ncbc')
call RegisterThing('ncbb')
call RegisterThing('ncb9')
call RegisterThing('ncba')
call RegisterThing('h0AY')
call RegisterThing('h0AT')
call RegisterThing('h0AX')
call RegisterThing('h0AW')
call RegisterThing('h0AU')
call RegisterThing('h0AV')
call RegisterThing('h0TG')
call RegisterThing('h03H')
call RegisterThing('h03I')
call RegisterThing('h1BP')
call RegisterThing('h03L')
call RegisterThing('h03K')
call RegisterThing('h03J')
call RegisterThing('h1LB')
call RegisterThing('h1IB')
call RegisterThing('h1N2')
call RegisterThing('h1MT')
call RegisterThing('h1N4')
call RegisterThing('h18P')
call RegisterThing('h1MS')
call RegisterThing('h1IG')
call RegisterThing('h1LL')
call RegisterThing('h02M')
call RegisterThing('h02L')
call RegisterThing('h02I')
call RegisterThing('h02C')
call RegisterThing('h02H')
call RegisterThing('h02J')
call RegisterThing('h02G')
call RegisterThing('h02D')
call RegisterThing('h02E')
call RegisterThing('h02F')
call RegisterThing('h02K')
call RegisterThing('h0CL')
call RegisterThing('h0CM')
call RegisterThing('h0CI')
call RegisterThing('h0CK')
call RegisterThing('h0CJ')
call RegisterThing('h0EG')
call RegisterThing('h0EH')
call RegisterThing('h0EI')
call RegisterThing('h0EP')
call RegisterThing('h0EQ')
call RegisterThing('h1CA')
call RegisterThing('h1CE')
call RegisterThing('h1CG')
call RegisterThing('h1CK')
call RegisterThing('h1BV')
call RegisterThing('h1BZ')
call RegisterThing('h1C1')
call RegisterThing('h1C5')
call RegisterThing('h1CP')
call RegisterThing('h1CT')
call RegisterThing('h1CV')
call RegisterThing('h1CZ')
call RegisterThing('h0EJ')
call RegisterThing('h1D4')
call RegisterThing('h1D8')
call RegisterThing('h1DA')
call RegisterThing('h1DE')
call RegisterThing('h0EK')
call RegisterThing('h0EL')
call RegisterThing('h0EM')
call RegisterThing('h0EO')
call RegisterThing('h0EN')
call RegisterThing('h0GA')
call RegisterThing('h0GG')
call RegisterThing('h0GI')
call RegisterThing('h0GJ')
call RegisterThing('e010')
call RegisterThing('h0GD')
call RegisterThing('h0GL')
call RegisterThing('h0GH')
call RegisterThing('h0GC')
call RegisterThing('h0GP')
call RegisterThing('h0GE')
call RegisterThing('h0GF')
call RegisterThing('h0RR')
call RegisterThing('e00Z')
call RegisterThing('h0RS')
call RegisterThing('h0RT')
call RegisterThing('h0RU')
call RegisterThing('h0RV')
call RegisterThing('h0RW')
call RegisterThing('h0RX')
call RegisterThing('h0RY')
call RegisterThing('h07J')
call RegisterThing('h07I')
call RegisterThing('h07H')
call RegisterThing('h07G')
call RegisterThing('h07K')
call RegisterThing('h07A')
call RegisterThing('h07D')
call RegisterThing('h07E')
call RegisterThing('h079')
call RegisterThing('h07C')
call RegisterThing('h07B')
call RegisterThing('h0LH')
call RegisterThing('h0L7')
call RegisterThing('h0L8')
call RegisterThing('h0LC')
call RegisterThing('h0L6')
call RegisterThing('h0LD')
call RegisterThing('h0L9')
call RegisterThing('h0LG')
call RegisterThing('h0LE')
call RegisterThing('h0LB')
call RegisterThing('h0LA')
call RegisterThing('h0ES')
call RegisterThing('h0ET')
call RegisterThing('h0EU')
call RegisterThing('h0EW')
call RegisterThing('h0EV')
call RegisterThing('h0EY')
call RegisterThing('h0EZ')
call RegisterThing('h0EX')
call RegisterThing('h0F0')
call RegisterThing('h0F1')
call RegisterThing('h0NK')
call RegisterThing('h0NN')
call RegisterThing('h0NM')
call RegisterThing('h0NP')
call RegisterThing('h0NO')
call RegisterThing('h0NL')
call RegisterThing('h0AH')
call RegisterThing('h0JJ')
call RegisterThing('h0JM')
call RegisterThing('h0JL')
call RegisterThing('h0AG')
call RegisterThing('h0JP')
call RegisterThing('h0JO')
call RegisterThing('h0AM')
call RegisterThing('h057')
call RegisterThing('h052')
call RegisterThing('h054')
call RegisterThing('h0WZ')
call RegisterThing('h059')
call RegisterThing('h058')
call RegisterThing('h056')
call RegisterThing('h0VF')
call RegisterThing('h0VE')
call RegisterThing('h053')
call RegisterThing('h051')
call RegisterThing('h08U')
call RegisterThing('h091')
call RegisterThing('h08V')
call RegisterThing('h08W')
call RegisterThing('h1NU')
call RegisterThing('h08X')
call RegisterThing('h1NV')
call RegisterThing('h08Y')
call RegisterThing('h1NP')
call RegisterThing('h0BE')
call RegisterThing('h0HN')
call RegisterThing('h0HO')
call RegisterThing('h0AA')
call RegisterThing('h0F9')
call RegisterThing('h0AD')
call RegisterThing('h0AC')
call RegisterThing('h0BQ')
call RegisterThing('h0BR')
call RegisterThing('h0BS')
call RegisterThing('h0BT')
call RegisterThing('h0C7')
call RegisterThing('h0BJ')
call RegisterThing('h0BK')
call RegisterThing('h0BN')
call RegisterThing('h0BM')
call RegisterThing('h0BL')
call RegisterThing('h0BO')
call RegisterThing('h0BP')
call RegisterThing('h0C4')
call RegisterThing('h0C3')
call RegisterThing('h0C5')
call RegisterThing('h0C6')
call RegisterThing('h0BZ')
call RegisterThing('h0C0')
call RegisterThing('h0C1')
call RegisterThing('h0C2')
call RegisterThing('h0BU')
call RegisterThing('h0C8')
call RegisterThing('h0S7')
call RegisterThing('h0SJ')
call RegisterThing('h0SK')
call RegisterThing('h0SL')
call RegisterThing('h0SM')
call RegisterThing('h0SN')
call RegisterThing('h0SO')
call RegisterThing('h0SP')
call RegisterThing('e02D')
endmethod
endmodule
private module A300
private static method onInit takes nothing returns nothing
call RegisterThing('h0SQ')
call RegisterThing('h0D1')
call RegisterThing('h0D5')
call RegisterThing('h0D4')
call RegisterThing('h0D8')
call RegisterThing('h0D6')
call RegisterThing('h0DC')
call RegisterThing('h0D9')
call RegisterThing('h0D3')
call RegisterThing('h0D2')
call RegisterThing('h0DB')
call RegisterThing('h0DD')
call RegisterThing('h0P2')
call RegisterThing('h0P4')
call RegisterThing('h0VW')
call RegisterThing('h0P8')
call RegisterThing('h0P6')
call RegisterThing('h0VV')
call RegisterThing('h0VT')
call RegisterThing('h0VR')
call RegisterThing('h1EH')
call RegisterThing('h1EC')
call RegisterThing('h1EE')
call RegisterThing('h0FH')
call RegisterThing('h0FF')
call RegisterThing('h0FI')
call RegisterThing('h0FK')
call RegisterThing('h0FG')
call RegisterThing('h0FJ')
call RegisterThing('h1EG')
call RegisterThing('h00B')
call RegisterThing('h0S8')
call RegisterThing('h0AR')
call RegisterThing('1Dgt')
call RegisterThing('h0NT')
call RegisterThing('h0NR')
call RegisterThing('h0SA')
call RegisterThing('h0RA')
call RegisterThing('h0R7')
call RegisterThing('h0R8')
call RegisterThing('h0SE')
call RegisterThing('h0JT')
call RegisterThing('h0JS')
call RegisterThing('o02E')
call RegisterThing('h0JV')
call RegisterThing('h0JQ')
call RegisterThing('h0JR')
call RegisterThing('h0JU')
call RegisterThing('h0JW')
call RegisterThing('h0K5')
call RegisterThing('h0K0')
call RegisterThing('h0K1')
call RegisterThing('h0K2')
call RegisterThing('h0K3')
call RegisterThing('h0JZ')
call RegisterThing('h0JY')
call RegisterThing('h0JX')
call RegisterThing('u018')
call RegisterThing('h137')
call RegisterThing('h13C')
call RegisterThing('h138')
call RegisterThing('h139')
call RegisterThing('h13A')
call RegisterThing('h13B')
call RegisterThing('h13D')
call RegisterThing('h13E')
call RegisterThing('h13F')
call RegisterThing('h13G')
call RegisterThing('h13H')
call RegisterThing('h14X')
call RegisterThing('h14Y')
call RegisterThing('h14Z')
call RegisterThing('h150')
call RegisterThing('h151')
call RegisterThing('h154')
call RegisterThing('h152')
call RegisterThing('h155')
call RegisterThing('h153')
call RegisterThing('h0WO')
call RegisterThing('h0WQ')
call RegisterThing('h06Q')
call RegisterThing('h0WS')
call RegisterThing('h0WU')
call RegisterThing('h0WW')
call RegisterThing('h0WP')
call RegisterThing('h0WR')
call RegisterThing('h0WT')
call RegisterThing('h0WV')
call RegisterThing('h0WX')
call RegisterThing('halt')
call RegisterThing('h1IF')
call RegisterThing('hvlt')
call RegisterThing('h1I9')
call RegisterThing('hbla')
call RegisterThing('hhou')
call RegisterThing('hlum')
call RegisterThing('hwtw')
call RegisterThing('htow')
call RegisterThing('ncnt')
call RegisterThing('ndh0')
call RegisterThing('nfh0')
call RegisterThing('nfr1')
call RegisterThing('ngnh')
call RegisterThing('nhns')
call RegisterThing('nth0')
call RegisterThing('nmh0')
call RegisterThing('nnzg')
call RegisterThing('ntnt')
call RegisterThing('h0O5')
call RegisterThing('h0NV')
call RegisterThing('h0OB')
call RegisterThing('h0OU')
call RegisterThing('h0OK')
call RegisterThing('h0OA')
call RegisterThing('u03J')
call RegisterThing('h0O9')
call RegisterThing('h0OY')
call RegisterThing('h1EM')
call RegisterThing('h1EI')
call RegisterThing('h1EK')
call RegisterThing('h1EL')
call RegisterThing('h1EN')
call RegisterThing('h1EO')
call RegisterThing('h1EP')
call RegisterThing('h1EQ')
call RegisterThing('h1EJ')
call RegisterThing('h1ER')
call RegisterThing('h1ES')
call RegisterThing('h0JA')
call RegisterThing('h0AZ')
call RegisterThing('h0J5')
call RegisterThing('h0J8')
call RegisterThing('h0J9')
call RegisterThing('h0J7')
call RegisterThing('h0J6')
call RegisterThing('h0J4')
call RegisterThing('h0J3')
call RegisterThing('h0B2')
call RegisterThing('h04D')
call RegisterThing('h048')
call RegisterThing('h04A')
call RegisterThing('h047')
call RegisterThing('h046')
call RegisterThing('h049')
call RegisterThing('h04C')
call RegisterThing('h04B')
call RegisterThing('h04F')
call RegisterThing('h04E')
call RegisterThing('h084')
call RegisterThing('h05W')
call RegisterThing('h11T')
call RegisterThing('n031')
call RegisterThing('h1NI')
call RegisterThing('h15Q')
call RegisterThing('h0WY')
call RegisterThing('h078')
call RegisterThing('u00Q')
call RegisterThing('u00C')
call RegisterThing('n02S')
call RegisterThing('h1DL')
call RegisterThing('h1DM')
call RegisterThing('h1DN')
call RegisterThing('h1DP')
call RegisterThing('h1DO')
call RegisterThing('h0TY')
call RegisterThing('h0UC')
call RegisterThing('h0U8')
call RegisterThing('h102')
call RegisterThing('h106')
call RegisterThing('h0U2')
call RegisterThing('h10A')
call RegisterThing('h12X')
call RegisterThing('h0PA')
call RegisterThing('h12O')
call RegisterThing('h12P')
call RegisterThing('h12Q')
call RegisterThing('h12R')
call RegisterThing('h12S')
call RegisterThing('h12T')
call RegisterThing('h12Y')
call RegisterThing('h12V')
call RegisterThing('h12U')
call RegisterThing('h12Z')
call RegisterThing('h131')
call RegisterThing('h0PB')
call RegisterThing('h134')
call RegisterThing('h0PC')
call RegisterThing('h0PD')
call RegisterThing('h0PE')
call RegisterThing('h0PF')
call RegisterThing('h0PG')
call RegisterThing('h136')
call RegisterThing('h0NE')
call RegisterThing('h0PZ')
call RegisterThing('h0PW')
call RegisterThing('h0PX')
call RegisterThing('h0PY')
call RegisterThing('h0Q0')
call RegisterThing('h15G')
call RegisterThing('h15H')
call RegisterThing('h15I')
call RegisterThing('h15K')
call RegisterThing('h15J')
call RegisterThing('h15L')
call RegisterThing('h018')
call RegisterThing('h01D')
call RegisterThing('h01B')
call RegisterThing('h01C')
call RegisterThing('h01F')
call RegisterThing('h01A')
call RegisterThing('h019')
call RegisterThing('h015')
call RegisterThing('h017')
call RegisterThing('h01E')
call RegisterThing('h016')
call RegisterThing('h1MK')
call RegisterThing('h1ML')
call RegisterThing('h1MN')
call RegisterThing('h1LW')
call RegisterThing('h1M9')
call RegisterThing('h1MH')
call RegisterThing('h1M7')
call RegisterThing('h1MD')
call RegisterThing('h1M2')
call RegisterThing('h1M6')
call RegisterThing('h0ID')
call RegisterThing('h0J0')
call RegisterThing('h0IJ')
call RegisterThing('h06D')
call RegisterThing('h0IH')
call RegisterThing('h0IG')
call RegisterThing('h0IS')
call RegisterThing('u02F')
call RegisterThing('h0IX')
call RegisterThing('h0IQ')
call RegisterThing('h0IU')
call RegisterThing('h1HU')
call RegisterThing('h1HV')
call RegisterThing('h1HX')
call RegisterThing('h1I6')
call RegisterThing('h1I5')
call RegisterThing('h1HY')
call RegisterThing('h1I1')
call RegisterThing('h1I2')
call RegisterThing('o04N')
call RegisterThing('h1I4')
call RegisterThing('h1HZ')
call RegisterThing('h1I7')
call RegisterThing('h0BV')
call RegisterThing('h0BW')
call RegisterThing('h0BY')
call RegisterThing('h0BX')
call RegisterThing('h0DE')
call RegisterThing('h0DF')
call RegisterThing('h0DG')
call RegisterThing('h0DH')
call RegisterThing('h0DI')
call RegisterThing('h0DJ')
call RegisterThing('h0DK')
call RegisterThing('h0DL')
call RegisterThing('h0DM')
call RegisterThing('h0DN')
call RegisterThing('h02N')
call RegisterThing('u031')
call RegisterThing('u00K')
call RegisterThing('h0VK')
call RegisterThing('h0VH')
call RegisterThing('h0VG')
call RegisterThing('h0KI')
call RegisterThing('h1F5')
call RegisterThing('h1F7')
call RegisterThing('h1F8')
call RegisterThing('h1F9')
call RegisterThing('h1FA')
call RegisterThing('h1FB')
call RegisterThing('h1FE')
call RegisterThing('h1F4')
call RegisterThing('h09U')
call RegisterThing('h09Z')
call RegisterThing('h06G')
call RegisterThing('h09V')
call RegisterThing('h09W')
call RegisterThing('h09X')
call RegisterThing('h0A0')
call RegisterThing('h0KA')
call RegisterThing('h041')
call RegisterThing('h03T')
call RegisterThing('h03V')
call RegisterThing('h03Q')
call RegisterThing('h00J')
call RegisterThing('h0UY')
call RegisterThing('h00I')
call RegisterThing('h0UU')
call RegisterThing('h0K6')
call RegisterThing('h0V1')
call RegisterThing('h0K7')
call RegisterThing('h0K9')
call RegisterThing('h0V6')
call RegisterThing('h0V4')
call RegisterThing('h0KB')
endmethod
endmodule
private module A600
private static method onInit takes nothing returns nothing
call RegisterThing('h0KC')
call RegisterThing('h0K8')
call RegisterThing('h00X')
call RegisterThing('h00W')
call RegisterThing('h013')
call RegisterThing('h012')
call RegisterThing('h012')
call RegisterThing('h011')
call RegisterThing('h010')
call RegisterThing('h0KV')
call RegisterThing('h08R')
call RegisterThing('h08S')
call RegisterThing('h08L')
call RegisterThing('h08N')
call RegisterThing('h08K')
call RegisterThing('h08M')
call RegisterThing('h08O')
call RegisterThing('h08P')
call RegisterThing('h08Q')
call RegisterThing('h0GQ')
call RegisterThing('h0GR')
call RegisterThing('h0GS')
call RegisterThing('h0GU')
call RegisterThing('h0GV')
call RegisterThing('h0GW')
call RegisterThing('h0GX')
call RegisterThing('h0GT')
call RegisterThing('h0DX')
call RegisterThing('h0GY')
call RegisterThing('h10H')
call RegisterThing('h10I')
call RegisterThing('h10L')
call RegisterThing('h10O')
call RegisterThing('h10R')
call RegisterThing('h10S')
call RegisterThing('h10T')
call RegisterThing('h10U')
call RegisterThing('h10W')
call RegisterThing('h10X')
call RegisterThing('h10Y')
call RegisterThing('h110')
call RegisterThing('h119')
call RegisterThing('h11B')
call RegisterThing('h11D')
call RegisterThing('h11G')
call RegisterThing('h11H')
call RegisterThing('h11J')
call RegisterThing('h11K')
call RegisterThing('h11M')
call RegisterThing('h11P')
call RegisterThing('h11Q')
call RegisterThing('h0XH')
call RegisterThing('h0XL')
call RegisterThing('h0XO')
call RegisterThing('h0XT')
call RegisterThing('h0XW')
call RegisterThing('h0XX')
call RegisterThing('h0Y1')
call RegisterThing('h0Y5')
call RegisterThing('h0Y9')
call RegisterThing('h0YD')
call RegisterThing('h0YG')
call RegisterThing('h0YH')
call RegisterThing('h0YM')
call RegisterThing('h0YS')
call RegisterThing('h0YO')
call RegisterThing('h0Z0')
call RegisterThing('h0Z2')
call RegisterThing('h0Z3')
call RegisterThing('h0ZA')
call RegisterThing('h0ZI')
call RegisterThing('h0ZE')
call RegisterThing('h0ZO')
call RegisterThing('h17M')
call RegisterThing('h1AD')
call RegisterThing('h19K')
call RegisterThing('h17S')
call RegisterThing('h17W')
call RegisterThing('h17Z')
call RegisterThing('h182')
call RegisterThing('h1AP')
call RegisterThing('h185')
call RegisterThing('h187')
call RegisterThing('h18A')
call RegisterThing('h18H')
call RegisterThing('h18O')
call RegisterThing('h18W')
call RegisterThing('h194')
call RegisterThing('h19B')
call RegisterThing('h19F')
call RegisterThing('h1A1')
call RegisterThing('h1B1')
call RegisterThing('h19J')
call RegisterThing('h1BD')
call RegisterThing('h19Z')
call RegisterThing('h0P0')
call RegisterThing('h08G')
call RegisterThing('h08F')
call RegisterThing('h0OZ')
call RegisterThing('h09B')
call RegisterThing('h09A')
call RegisterThing('h08B')
call RegisterThing('h08E')
call RegisterThing('h08I')
call RegisterThing('h08H')
call RegisterThing('h1NH')
call RegisterThing('h06X')
call RegisterThing('h0BG')
call RegisterThing('h0K4')
call RegisterThing('h06V')
call RegisterThing('h0V8')
call RegisterThing('h0VD')
call RegisterThing('h0BH')
call RegisterThing('h06R')
call RegisterThing('h06S')
call RegisterThing('h06T')
call RegisterThing('h0BF')
call RegisterThing('h0IY')
call RegisterThing('h077')
call RegisterThing('h00Y')
call RegisterThing('h00Z')
call RegisterThing('h06Y')
call RegisterThing('h06W')
call RegisterThing('u01U')
call RegisterThing('h0XG')
call RegisterThing('h0XB')
call RegisterThing('h1NO')
call RegisterThing('h0XD')
call RegisterThing('h0XF')
call RegisterThing('h050')
call RegisterThing('h04Z')
call RegisterThing('h04W')
call RegisterThing('h04X')
call RegisterThing('h13K')
call RegisterThing('h04Y')
call RegisterThing('h1NK')
call RegisterThing('h1KP')
call RegisterThing('h1KQ')
call RegisterThing('h1KR')
call RegisterThing('h1KF')
call RegisterThing('h1KD')
call RegisterThing('h1KV')
call RegisterThing('h1KC')
call RegisterThing('h1K7')
call RegisterThing('h1JX')
call RegisterThing('h1KW')
call RegisterThing('h1KT')
call RegisterThing('h14B')
call RegisterThing('h14I')
call RegisterThing('h14C')
call RegisterThing('h14D')
call RegisterThing('h14E')
call RegisterThing('h14F')
call RegisterThing('h14G')
call RegisterThing('h14H')
call RegisterThing('h14J')
call RegisterThing('h14K')
call RegisterThing('h14L')
call RegisterThing('h166')
call RegisterThing('h1KX')
call RegisterThing('h175')
call RegisterThing('h1IK')
call RegisterThing('h1LD')
call RegisterThing('h177')
call RegisterThing('h179')
call RegisterThing('h16D')
call RegisterThing('h1L3')
call RegisterThing('h1IL')
call RegisterThing('h167')
call RegisterThing('h1LC')
call RegisterThing('h1L4')
call RegisterThing('h1LE')
call RegisterThing('h1LI')
call RegisterThing('h1LK')
call RegisterThing('h168')
call RegisterThing('h176')
call RegisterThing('h1IH')
call RegisterThing('h169')
call RegisterThing('h1L5')
call RegisterThing('h1LM')
call RegisterThing('h1LP')
call RegisterThing('h1LQ')
call RegisterThing('h1L6')
call RegisterThing('h165')
call RegisterThing('h17E')
call RegisterThing('h17D')
call RegisterThing('h16C')
call RegisterThing('h1IN')
call RegisterThing('h16B')
call RegisterThing('h1IM')
call RegisterThing('h17A')
call RegisterThing('h17B')
call RegisterThing('h1LR')
call RegisterThing('h16A')
call RegisterThing('h1IO')
call RegisterThing('h16E')
call RegisterThing('h17C')
call RegisterThing('h178')
call RegisterThing('h17F')
call RegisterThing('h1IE')
call RegisterThing('h16F')
call RegisterThing('h070')
call RegisterThing('h0BC')
call RegisterThing('h0BD')
call RegisterThing('h074')
call RegisterThing('h15M')
call RegisterThing('h072')
call RegisterThing('h02X')
call RegisterThing('h0BB')
call RegisterThing('h0BA')
call RegisterThing('h071')
call RegisterThing('h06Z')
call RegisterThing('h0IA')
call RegisterThing('h044')
call RegisterThing('h042')
call RegisterThing('h045')
call RegisterThing('h043')
call RegisterThing('h01W')
call RegisterThing('h01X')
call RegisterThing('h0E2')
call RegisterThing('h0E1')
call RegisterThing('h0E3')
call RegisterThing('h0E4')
call RegisterThing('h0E5')
call RegisterThing('h0E6')
call RegisterThing('h0E7')
call RegisterThing('h0E8')
call RegisterThing('h0E9')
call RegisterThing('h0EA')
call RegisterThing('h0EB')
call RegisterThing('h0EB')
call RegisterThing('h0EC')
call RegisterThing('h0ED')
call RegisterThing('h0EE')
call RegisterThing('h0EF')
call RegisterThing('h024')
call RegisterThing('h029')
call RegisterThing('h01S')
call RegisterThing('h01T')
call RegisterThing('h0B1')
call RegisterThing('h034')
call RegisterThing('h035')
call RegisterThing('h01R')
call RegisterThing('h01N')
call RegisterThing('h01M')
call RegisterThing('h01L')
call RegisterThing('h01P')
call RegisterThing('h01K')
call RegisterThing('h17K')
call RegisterThing('h13J')
call RegisterThing('h01O')
call RegisterThing('h01Q')
call RegisterThing('h01J')
call RegisterThing('nwgt')
call RegisterThing('h05H')
call RegisterThing('h05I')
call RegisterThing('h09S')
call RegisterThing('h09T')
call RegisterThing('h05F')
call RegisterThing('h05G')
call RegisterThing('h1ET')
call RegisterThing('h1EZ')
call RegisterThing('h1EW')
call RegisterThing('h1EX')
call RegisterThing('h1EV')
call RegisterThing('h1EY')
call RegisterThing('h1F0')
call RegisterThing('h1F2')
call RegisterThing('h1EU')
call RegisterThing('h1F3')
call RegisterThing('h1F1')
endmethod
endmodule
private struct Nice extends array
implement A0
implement A300
implement A600
endstruct

endlibrary