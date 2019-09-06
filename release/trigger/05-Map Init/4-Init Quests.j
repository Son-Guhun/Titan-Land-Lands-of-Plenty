library LoPInitQuests

// This function is called in Init 0 seconds
function InitQuests takes nothing returns nothing
    local string quest_text
    local integer questType = bj_QUESTTYPE_REQ_DISCOVERED
    
    // ====================
    // Commands
    // ====================
    
    // Player Colors
    set quest_text = "
|c00ff0303red = 1|r
|c000042ffblue = 2|r
|c001ce6b9teal = 3|r
|c00540081purple = 4|r
|c00fffc01yellow = 5|r
|c00ff8000orange, oj = 6|r
|c0020c000green = 7|r
|c00e55bb0pink = 8|r
|c00959697gray, grey = 9|r
|c007ebff1light blue, lightblue, lb = 10|r
|c00106246dark green,darkgreen, dg = 11|r
|c004e2a04brown = 12|r
|c009b0000maroon = 13|r
|c000000c3navy = 14|r
|c0000eaffturquoise, tq = 15|r
|c00be00feviolet = 16|r
|c00ebcd87wheat = 17|r
|c00f8a48bpeach = 18|r
|c00bfff80mint = 19|r
|c00dcb9eblavender = 20|r
|c00282828coal = 21|r
|c00ebf0ffsnow = 22|r
|c0000781eemerald = 23|r
|c00a46f33peanut = 24|r
hostile = 25
passive, neutral = 28
"
    call CreateQuestBJ(questType, "Player Numbers & Colors", quest_text, "ReplaceableTextures\\CommandButtons\\BTNScatterRockets.blp")
    // ----------
    
    // Abilities
    set quest_text = "
You can customize your heroes' abilities, including units that were made into heroes using the |cffffff00-makehero|r command. Abilities compatbile with these commands have a special code at the end of their name, written in gray.

The |cffffff00-ability|r command also has an alias: |cffffff00-abil|r.

|cffffff00-ability|r add/a (code)
Adds an ability to all selected heroes. Only hero abilities can be added, unit abilities can only be removed. Heroes can have at most 4 compatible abilities.

|cffffff00-ability|r remove/rem/r (code)
Removes an ability from all selected heroes.

|cffffff00-ability|r clear
Removes all compatible abilities from all selected heroes.
"
    call CreateQuestBJ(questType, "Ability Commands", quest_text, "ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp")
    // ----------
        
    // Titan Commands 1
    set quest_text = "
|cffffff00-mind|r <number>
Will set the target player for Power: Mind. If you write just \"-mind\", it will flag changing ownership of all units on/off.
|cffffff00'mind|r
Use this command to change ownership of units you have selected without having to select the Power: Mind unit.
|cffffff00-kick|r (color or #)
The Titan Player can kick people that make the game suck.
|cffffff00-delete|r/|cffffff00-delneu|r (color or #)
Deletes all non-neutral/neutral (see |cffffff00-neut|r) units of a player. Outside titan palace only.
|cffffff00-delpal|r  (color or #)
Deletes all units (neutral included) inside the titan palace of a player.

|cffffff00-load limit|r (number)
Sets the limit of how many terrain areas, units or doodads can be loaded at a time.
"
    call CreateQuestBJ(questType, "Titan Commands 1", quest_text, "ReplaceableTextures\\CommandButtons\\BTNBloodMage2.blp")
    // ----------
    
    // Titan Commands 2
    set quest_text = "
|cffffff00-water|r (red) [green] [blue] [alpha]
Sets the global water color.
|cffffff00-fog|r (style) [zend] [zstart] [density] [red] [green] [blue]
Sets the global fog. Use the -rect command to spawn a rect generator and test out how fogs work.
|cffffff00-titan|r
Sets a new player as the titan. Player 1 (Red) can always use the -titan command, even if they aren't the Titan.
|cffffff00-summon the creator|r
A traditional Titan Land command.
|cffffff00-combat tags|r
Toggles combat tags on/off. Default: off.
|cffffff00-time|r (value)
Sets the time of day (ingame) to the specified time (24 hour time).
"
    call CreateQuestBJ(questType, "Titan Commands 2", quest_text, "ReplaceableTextures\\CommandButtons\\BTNBloodMage2.blp")
    // ----------
    
    // Unit Commands
    set quest_text = "
|cffff0000Unit Commands:|r
|cffffff00-makehero|r
Makes your selected units heroes. Many restrictions apply. Up to 12 heroes per player.
|cffffff00-copy|r
Copies your selection of units or the locked group of a selected Rect Generator.
|cffffff00-select no|r
Makes selected decorations unselectable. Unselectable decorations consume less computing resources, reducing lag.
|cffffff00-neut|r <decos>
Gives your selected units to Neutral Passive, only working on decorations if decos is specified. Your neutral units are saved along with your normal units. Neutral decorations that are made unselectable are automatically returned to you.
|cffffff00-take|r <all>
Takes selected unit back from Neutral Passive. Typing all next to the command will take all your units.
|cffffff00-hide|r <all>\nHides selected/all deco builders. Use |cffffff00-sele|r to get them back.
"
    call CreateQuestBJ(questType, "Unit Commands 1", quest_text, "ReplaceableTextures\\CommandButtons\\BTNFootman.blp")
    // ----------
    
    // Unit Commands 2
    set quest_text = "
|cffff0000Unit Commands:|r
|cffffff00-sele (deco name)|r | |cffffff00-seln (deco name)|r
Adds deco builders whose name starts with the entered characters to your selection. |cffffff00-seln|r clears your old selection before selecting the new units.
|cff0000ffExamples: -sele wall, -sele sp, -sele pand, -sele gen|r
|cffffff00-remove|r
|cffffff00-kill|r
|cffffff00-collision (on/off)|r
"
    call CreateQuestBJ(questType, "Unit Commands 2", quest_text, "ReplaceableTextures\\CommandButtons\\BTNFootman.blp")
    // ----------
    
    // Unit Modification Commands
    set quest_text = "
|cffff0000Unit Modification Commands:|r
|cffffff00-tag (tag name |ex: first, second, alternate, defend)|r
Removes old animation tag and adds new animation tag to a unit.
|cffffff00-color (number)|r\nSet the color for the 'color command.
|cffffff00-size (number)|r\nSet the size for the 'size command.
|cffffff00-rgb (red green blue transparency)|r
Set the colors for the 'rgb command.
|cffffff00-anim (animation name)|r
Set the animation for the 'anim command.
|cffffff00-speed (number)|r
Set the animation speed for the 'speed command.
|cffffff00-fly (number)|r
Set the flying height for the 'fly command. Has a -h alias.
|cffffff00-face (number)|r
Set the facing angle for the 'face command. Has a -f alias.

|cffffff00'fly|r | |cffffff00'rgb|r | |cffffff00'face|r | |cffffff00'size|r | |cffffff00'color|r | |cffffff00'anim|r
Use the commands above to apply unit modifications. Alternatively, you can use Deco Modifier Special's (use the command |cffffcc00-seln sp|r to select it) abilities.
"
    call CreateQuestBJ(questType, "Unit Modification Commands", quest_text, "ReplaceableTextures\\CommandButtons\\BTNFootman.blp")
    // ----------
    
    // Player Commands
    set quest_text = "
|cffff0000Alliance Commands:|r (Color names are case-insensitive for all commands. You can use a player number instead.)
|cffffff00-ally|r 'color'
|cffffff00-unally|r 'color'

|cffff0000Tips/Hints Commands:|r
|cffffff00-tips|r (on/off)
If no arguments are given, then tips are toggled on/off, according to their current value.
|cffffff00-hints|r (on/off)
An alias for the |cffffff00-tips|r command.

|cffff0000Player Commands:|r
|cffffff00-deleteme|r
Removes all your units that are not in the Titan Palace from the game, except your neutral units.
|cffffff00-start|r
Gives you a Wandering Soul to make a Race Selector.
|cffffff00-decos|r (special/basic/all)
Spawns any decos you may be missing (hidden decos are not considered missing).
"
    call CreateQuestBJ(questType, "Player Commands", quest_text, "ReplaceableTextures\\CommandButtons\\BTNScrollOfRegenerationGreen.blp")
    // ----------
    
    // Camera Commands
    set quest_text = "
|cffffff00-zoom|r (value)
Sets the camera distance to target.

|cffffff00-camera|r/|cffffff00-cam|r/|cffffff00-c|r
This command accepts many different kinds of arguments
    |cffffff00(field)|r |cffffff00(value)|r
    Sets the value of the specified field. Fields are: zoom, roll, rotate, pitch, zoffset. 
    |cff0000ffExample: -c rotate 270|r
    |cffffff00lock|r/|cffffff00unlock|r
    Locks or unlocks the camera to the current view. Locking disables the mouse scroll-wheel adjustment.
    |cffffff00(preset)|r
    Sets the camera to a certain preset. Available presets: far
"
    call CreateQuestBJ(questType, "Camera Commands", quest_text, "ReplaceableTextures\\WorldEditUI\\Doodad-Cinematic.blp")
    // ----------
    
    // Deco Special Commands
    set quest_text = "
|cffff0000Deco Special Commands:|r
These commands work with the modifications abilities of \"Deco Modifier Special\". You can select this unit with the command: (|cffffcc00-seln sp|r)
|cffffff00-val (number)|r
Set the size of the area of terrain and tree mods.
|cffffff00-var (number)|r
Set the variation of terrain tiles created with the Terrain Editor or Deco Builder Special.
|cffffff00-space (number)|r
Set the space between each created tree.
"
    call CreateQuestBJ(questType, "Deco Special Commands", quest_text, "ReplaceableTextures\\CommandButtons\\BTNScrollOfRegenerationGreen.blp")
    // ----------
    
    // Autoname
    set quest_text = "
Autoname allows you to automatically set your player name as the name of the last unit you selected. Only units with custom user-defined names will be detected by the autoname system. Use the |cffffff00-nameunit|r command to give a unit a custom name.

Commands:
|cffffff00-autoname|r
Toggles autoname on or off.
"
    call CreateQuestBJ(questType, "Autoname", quest_text, "ReplaceableTextures\\CommandButtons\\BTNScrollOfRegenerationGreen.blp")
    // ----------
    
    // SaveNLoad Commands
    set quest_text = "
Commands:
|cffffff00-load center <x,y>|r
Set the center for future save/loads. If no x and y arguments are given, then the save center is set to the position of your currently selected unit or the rally point of your currently selected building.
|cffffff00-save (SaveName)|r
Save all your units (including unselectable and neutral units)
|cffffff00-dsav (SaveName)|r
Save all trees inside the region of your currently selected Rect Generator. (|cffffcc00-rect|r to spawn and |cffffcc00-seln gen|r to select)
|cffffff00-tsav (SaveName)|r
Save terrain inside the region of your currently selected Rect Generator. (|cffffcc00-rect|r to spawn and |cffffcc00-seln gen|r to select)
|cffffff00-request (SaveName)|r
Load a save from your local storage.
|cffffff00-req (SaveName)|r
Send a request to the SaveNLoad program (it must be open) to load a save. This command is used to load legacy saves (before version 1.2.0).
"
    call CreateQuestBJ(questType, "SaveNLoad System", quest_text, "ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp")
    // ----------
    
    // Patrol System Commands
    set quest_text = "
GPS, for short, this system modifies the patrol ability, allowing you to have multiple patrol check points. To set a new checkpoint, simply use the patrol ability again (no shift-click).

Commands:
|cffffff00-patrol clear|r -> Clears all checkpoints for a unit
|cffffff00-patrol resume|r -> Resumes patrolling for a unit

|cff0000ffNote:|r The patrol system does not function when you order multiple units to patrol at once!
|cff0000ffSave System:|r The patrol points of are unit are saved when you save your base!
"
    call CreateQuestBJ(questType, "Guhun's Patrol System", quest_text, "ReplaceableTextures\\CommandButtons\\BTNBoots.blp")
    // ----------
    
    // ====================
    // Credits & Information
    // ====================
    set questType = bj_QUESTTYPE_OPT_DISCOVERED
    
    // Titan Land Creators
    set quest_text = "
- Guhun (Creator & Director)
- King_Katanova (Senior Race Designer)

|cffffcc00Contributers|r
- Aragorns: Ratfolk Race Designer
- Paillan: Assistant Terrainer for 1.3.0
- Lesslife: Assistant Designer for Angel Race in beta
- titans_zealot: Terrainer for 0.9.0
- LichKing76: Contributed with multiple skins for models
- Testers: LichKing76, no_one_only_me, 12tommita, LisPL, hiworm, Gilgo, mattcos, Urain, Frostbiter, Tunshi
"
    call CreateQuestBJ(questType, "|cffff0000LoP Team|r", quest_text, "ReplaceableTextures\\CommandButtons\\BTNReincarnation.blp")
    // ----------
    
    
    // Titan Land Creators
    set quest_text = "
-MetalWarrior (Original Creator)
-Vhalyr and Loganrules (Improved RPE)
-Dhaniels (The Beginning of the End)
-King_Katanova (RoK, FoK, KoT)
-GHH (RoK and RoD)
-THE_DEATH (KoT)
\"If I have seen further, it is by standing on the shoulders of giants.\"
-Isaac Newton
"
    call CreateQuestBJ(questType, "|cff00ff00TL Creators|r", quest_text, "ReplaceableTextures\\CommandButtons\\BTNReincarnation.blp")
    // ----------
    
    // Model Credits 1
    set quest_text = "
|cff00b300The Hive Workshop:|r
Kwaliti, Lord_T, Deolrin, Chilla_killa, Sellenisko, Hellish Hybrid, A Void, Uncle Fester, MassiveMaster, HerrDave, Olofmoleman, Sliph-M, darkdeathknight, evigeorge1617, Hayate, Tranquil, -Grendel, Stefan.K, HappyTauren, donut3.5, Cavman, HateCrew, Expresso, General Frank, YrpoTRIa , KO3bMA , Dixnos, Fingolfin, Mike, ChevronSeven, MatiS, killst4r, Tarrasque, Red XIII, FvckTP, Em!, Misha, Arak1da, Chen, Wandering Soul, kagyun, Hexus, -=Emergenzy=-, Sin'dorei300, PROXY, WebSter, darklord_avalon, eubz, Kitabatake, kellym0, Sunchips, Remixer, Su7VdeR, koondad, Mister_Haudrauf, Daenar7, SinisterX, TiJiL, icewolf055, RightField, UgoUgo, DarkHunter1357, Necromancer_187, alfredx_sotn, Black_Stan, BlinkBoy, NaserKingArthas, bisnar13, InfernalTater, Hueter, ~Nightmare, 67chrome, dickxunder, Elenai, Redstee1, Mr Goblin, Ujimasa Hojo, Happy Tauren, Himperion, Kuhneghetz, Wildfire, Horn, Wisdom

|cffff0000Unity:|r
XiaolianhuaStudio

|cffff0000wc3campaigns:|r
TiJil, unwirklich
"
    call CreateQuestBJ(questType, "|cff0000ffArt 1|r", quest_text, "ReplaceableTextures\\CommandButtons\\BTNTemp.blp")
    // ----------
    
    // Model Credits 2
    set quest_text = "
|cff00b300The Hive Workshop:|r
PrinceYaser, shiik, Dr.Death, Sant, Eagle XI, Afroknight_76, Deleted member 238226 (unknown), GhostThruster, Whitewolf8, WhiteDeath, A.R., Xezko, Deep Sea Kraken, Hellx-Magnus, -Berz-, CRAZYRUSSIAN, HappyCockroach, Tamplier777, Kehel, Radagast, Lordaeron Creator, The D3ath, Gottfrei, bu3ny, CloudWolf, Gyrosphinx, Marenko, Talavaj, !!GORO!!, THE_SILENT, Kenntaur, skrab, simkitty181, olyvian, Darkfang, JollyD, paulH, apaka, Just_Spectating, Leopard

|cffff0000XGM:|r
P4ela, Kolbosa, Wulfrein, DampirTBs, Feleer, Jack Sparrow, DiKey51, Ket, LongbowMan
"
    call CreateQuestBJ(questType, "|cffff0000Art 2|r", quest_text, "ReplaceableTextures\\CommandButtons\\BTNTemp.blp")
    // ----------
    
    // Coding and Tools
    set quest_text = "
MindWorX => Sharpcraft World Editor
Magos => Model Editor
Alexei => Mdlvis
Guesst => MDX squisher
Spec => BLP Laboratory
Vexorian => Map Optimizer, vJass
actboy, sumneko (and contributors) => w3x2lni

Mori => Many coding ideas. A lot of concepts in LoP (like the rect generator) where taken from YARP.
Bribe => GUI Damage Engine, GUI Unit Event, GUI Knockback, Table
Flux => Dummy Recycler
Nestharus => World bounds, many ideas from his code have been incorporated by me (Guhun) elsewhere.
PitzerMike => DestructableLib
Magtheridon96 => GroupTools
feelerly => Id2String
Doomlord => Custom Stat System
"
    call CreateQuestBJ(questType, "|cff00ff00Coding & Tools|r", quest_text, "ReplaceableTextures\\CommandButtons\\BTNEngineeringUpgrade.blp")
    // ----------
    
    // Changelog and Contact
    set quest_text = "
Want to support the project? You can do so at: |cffffcc00ko-fi.com/songuhun|r
    
Link to changelog: |cffffcc00tiny.cc/LoPchangelog|r
LoP Repository: |cffffcc00github.com/Son-Guhun/Titan-Land-Lands-of-Plenty|r
The Hive Workshop: |cffffcc00_Guhun_|r
Discord: |cffffcc00SonGuhun#4510|r
E-mail me at: |cffffcc00songuhun@hotmail.com|r
"
    call CreateQuestBJ(questType, "|cff0000ffChangelog and Contact|r", quest_text, "ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp")
    // ----------
endfunction
endlibrary