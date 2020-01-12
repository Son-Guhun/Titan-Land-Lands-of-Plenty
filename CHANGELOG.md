# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

- Major versions are created arbitrarily.
- Minor versions indicate addition of a very important new feature, a new race or a new deco builder.
	- *Exception:* Racial deco builders can be added in a patch version for existing races.
	- *Exception:* Extended deco builders (numbered from 2 onwards) can be added in a patch version for existing deco builders.
- Patch versions indicate bugfixes. 
	- Some commands, command aliases or command arguments may be added in a patch version. 
	- New units for an existing race can be added in a patch version. 
	- New decorations for an existing deco builder can be added in a patch version.

## [v1.4.1] - 2020-01-11

### Added
- New anti-griefing system:
	- Players can only damage units owned by players that are unallied to them.
	- Players can use the **-war** command to allow other players to damage their units, without having to unally them.
- New commands:
	- **-war**
	- **-give all:** Gives all units of the owner of your selected unit to another player. If you are not the titan, you can only use this on your own units. This command replaces the old Mind Titan Power, which is being removed.
	- **-share (player) (player):** The Titan can use this new syntax of the -share command in order to force a player to share their units with another. You cannot use colors with spaces when using this form of the command (so you must use darkgreen instead of dark green, for example).
- New Night Elf Units:
  - Elf
  - Sage
  - Strider
  - Druid Apprentice
  - Veteran Archer
  - Elune's Disciple
  - Spearthrower
  - Druidess
  - Seedmother
  - Grove Archer
  - Autumn Mage
- Added -give all, -freecam and new -share to F9, along with new credit

### Fixed
- Fixed an issue that caused generators loaded from old saves to have a "Total Darkness" lighting value by default, instead of "Lordaeron" lighting.
- Fixed an issue that made the Show/Hide ability of Rect Generators  non-functional.
- Fixed a lighting issue with both Mansion Wall decorations.
- Internal changes that may reduce desyncs.
- Waygates and Patrol Points will now be correctly loaded for builts which were requested at a location different from their original. Waygates that were pointing to a location which was outside the saved Rect will still point to that original location.
- Fixed portrait and voice sounds for many Forest Elf units.
- Fixed a small invisible hill in the Titan Palace.

### Changed
- You can now use modification commands on units of player that have shared control with you. This does not apply to forced shares caused by the Titan.
- Renamed Deco Builder Creep to Deco Builder Creeps (to match race selector name).
- Many deco builders now use unique icons, in order to make browser the Deco tents more convenient: Norse, Runes, Huts, Flags, Gurubashi, Celtic, Elves Blood, Runic, Draenei, Webs, Rostrodle, Gravestones, Effects, Ice, Norse, Drow, Elves Forest, Icecrown, Wintergarde, Creeps, Elves Forest, Columns, Flowers, Tableware, S&S (Manor, Kingdom & Shire), Crops, Castle, Gate, Archways, Village, Seats, Games, Floors, Mansion, Walls, Medieval, Ruined, Blocks, Fences, Furniture, Rohan

### Removed
- Removed Power: Mind from the Titan Palace.
- Deprecated -mind command and 'mind command. An error message will show when trying to use them.


## [v1.4.0] - 2020-01-08

### Added
- Save System improvements:
  - Saves made with Rect Generators (-tsav, -dsav, -usav) will now spawn a special Rect Generator when loaded into the game. This Rect Generator can be used to move the save around, so it can be loaded anywhere on the map.
  - If you want to automatically load a Rect save at its original location, use the **-req** instead of **-request**.
- New commands:
  - **-usav:** This command can be used to save all your units inside of a Rect Generator, but not any unit outside of it..
  - **-compat:** This command must be used to load old saves (made between 1.2.1 and 1.3.0) instead of the -request command.
  - **-freecam:** This command allows players to use a new controllable camera. The camera works as a 3rd person camera, but it can be a first person camera by setting zoom to 0.
    - **Hotkeys**:
	  - **WASD:** Moves the camera North/West/South/East
	  - **IJKL:** Rotates the camera.
	  - **SPACE:** Moves the camera up.
	  - **CTRL+SPACE:** Moves the camera down.
	  - **NUMPAD 4 and 6:** Adjusts the speed of movement.
	  - **NUMPAD 2 and 8:** Slightly adjusts the speed of movement.
- New Deco Builders:
  - Deco Builder Columns
  - Deco Builder Creep
  - Deco Builder Elves Night
  - Deco Builder Human
  - Deco Builder Icecrown
  - Deco Builder Orc Fort
  - Deco Builder Pirate
  - Deco Builder Rohan
  - Deco Builder Underwater
  - Deco Builder Vanilla Naga
  - Deco Builder Wintergarde
- New Races:
  - Lordaeron (separated from human)
  - Stormwind (separated from human)
  - Stromgarde
  - Kul Tiras
  - Scarlet Crusade
  - Celtic
  - Imperials (Warhammer)
  - Free Men (Middle Earth)
  - Gnolls
- New Heroes:
  - Pirate:
    - Cursed Pirate Captain
	- Spell Captain
  - Middle Earth
    - Gandalf the White
	- Gandalf the Gray
	- Aragorn
	- King Aragorn
	- Théoden
	- Ekenbrand
- New Units:
  - Norse War Wolf
  - Norse Wolf
  - Norse Thane
  - Fel Shivarra
- **Rect Generators** now have a new ability which allows players to control the environment lighting inside of them. Along with decrations that emit light (such as lanterns), this can be used for better dynamic lighting.
- New animals: Dolphin, Shark and Manta Ray.
- Many commands now accept mathematical expressions. For example, you can type **'fly 2^5** instead of **'fly 32**. Supports addition, subtraction, multiplication, division, exponentiation and modulo (%).
- Riderless Horses and Pack Horses now have a **Pick Up Rider** ability, allowing them to be ridden by a unit.
- New tip/hint for the **-count** command.
- Save Files now have integrity checks. If a file is missing or can not be read, the game will now warn the player. If a single unit's data is corrupted, the game will also warn the player.
- The **-time** command now accepts AM/PM. For example, **-time 10am** or **-time 10 PM**.

### Fixed
- Fixed an issue that caused unselectable non-decoration units to be loaded incorrectly.
- Fixed a crash that could occur when converting certain orc spellcasters into heroes.
- Fixed an issue that would cause Ancients to always face the defeault angle when loaded from a save.
- Strange behaviour of inverting a rect's size when making it smaller than minimum size has been removed.
- Fixed a crash that could occur when using Staff of Mimic.
- Fixed a crash that could occur when removing units from the game.
- Fixed an issue where a command could run twice. This was especially harmful when loading saves.
- Fixed an issue that caused abilities to be inaccessible when switching selection using the **-select no** command. This fix may cause unit training for any selected structures to be canceled for the currently trained unit when using this command.
- Fixed hotkeys and tooltips for many units.

### Changed
- Changed commands:
  - **-req:** This command is no longer used to load old saves. Instead, it is used to automatically load saves made with Rect Generators at their original position, instead of choosing a new position.
- Players can now load simultaneously without affecting performance. Players will take turns loading pieces of their saves, which means if two players are loading, they will take twice as long (until one of them finishes loading.)
- Saves will now be located in the folder: **Documents\Warcraft III\CustomMapData\TLLoP\Saves**
- Ancients' rooted/unrooted status is now saved by the Save System.
- Neutral units are now also loaded as neutral units.
- Improved Rect Generator behaviour near map borders:
  - Rect Generator lightning indicators will no longer behave strangely when near a map border.
  - Rect Generator will now remember its old size when leaving a map border.
  - You can now expand a Rect Generator when it is near a map border.
- Vastly improved loading performance:
  - Loading will no longer cause largely disproportionate frame losses for the requesting player.
  - Improved performance when loading terrain.
  - A message is now shown to the loading player when finished.
  - Warnings will now show for corrupted units or files.
- Vastly improved saving perfomance:
  - Players can now save the entire map's terrain and trees without causing the game to freeze for many seconds.
- When setting a save center while selecting a unit, a message will now pop up with the new coords.
- Added colored text to -count command.
- Trees no longer play their birth animation when being created or revived.

### Removed
- The external SaveNLoad program is no longer supported. Old saves from before 1.2.1 can no longer be loaded into the game, and must be converted in a version that supports both systems (1.2.1 to 1.3.5).
- All units that had been deprecated after version 1.3.0 have been removed, which means their IDs may be overwritten by new units. To transfer saves that used this units, they must be loaded and saved in 1.3.5 first.
- The map no longer uses the UnitEvent library. This may avoid crashes when removing a unit from the game.
- Gnoll units in the Titan Palace, and the Fel Shivarra hero, have been removed. This is because they have been implemented into the game and are now trainable.


## [v1.3.5] - 2019-10-18

### Added
- New command:
	- -count: Counts all selectable units currently in the map. Maximum recommended is 1500. Also shows individual count for player who used the command and for the player with most units. Individual counts include unselectable decorations that block pathing, unselecatble waygates, unselectable units and hidden deco builder, but does not count most unselectable decorations.
- New decorations:
	- Deco Builder Games (old Deco Builder Chess):
		- 3 new chess piece variations
		- Trading Cards
		- Die
		- Backgammon Piece
		- Checker Piece and Queen
- New heroes:
	- Emperor of Mankind
	- Nihonjin Wanderer
- New units:
	- Haradrim Assassin Female
	- Night Elf Runner
	- Night Elf Sentry
	- Night Elf Warden
- Added quest in F9 manual explaining the controller system and listing commands.
- New Decoration abilities:
	- **Next Variation**
	- **Previous Variation**
	- These abilities replace the old method of using upgrades to cycle between variations.

### Fixed
- Fixed a crash that could occur when a hero cast Mirror Image after having used Metamorph (heroes with Metamorph can no longer use Mirror Image).
- Fixed issue where moving a Deco Modifier Controller with its aligned move ability would cause an invisble unit to appear and the Controller to not move at all.
- Units with only a single patrol point will now resume their patrol as normal when loaded.
- Fixed an issue where a unit with a custom color (*'color* command) would not keep the correct color when given to another player.
- *-sele* and *-seln* commands will no longer sometimes select non-deco builders.
- Cosmosis and Angel of Creation can no longer use Staff of Mimic. Even if they somehow use it, the game should no longer crash.
- Hero Towers and Titan Powers can no longer have their owner changed.
- Fixed names for Gate Icecrown and Gate Ice Rock.
- Added arabian gate to Deco Builder Arabian 2.
- Fixed a small issue that did not allow w3x2lni's variable name confusion to be used, which made the map a little slower.


### Changed
- Deco Builder Chess has been renamed to Deco Builder Games.
- Decorations will now float on water, making their behaviour when selectable the same as their behaviour when unselectable.
- Improved controller system. When using modification commands (such as 'face and 'size) while selecting a controller, the command will apply to all controlled units.
- Non-decorations can now also be made unselectable. To make them unselectable, use *-select no f*.
- The Make Selectable ability of Deco Modifier Special will now scale with the value set by the *-val* command.
- Decorations with a square pathing map (such as rocks or wall connectors) can now use the Facing ability.
- Hotkeys and position for **Open/Close Gate** and **Enable/Disable Flight** have been changed to accomodate the new variation abilities.
- Open gates can now use movement abilities.
- Deco Builders now use QWER hotkeys when building decorations.
- Changed Basic Deco Builders:
	- New basic decos:
		- Blacksmith
		- Fence
		- Flags
		- Flowers
		- Gravestones
		- Market
		- NPC
		- Obelisks
		- Ruined
		- Trees
	- No longer basic:
		- Walls 1
		- Walls 2
- Cosmosis and Angel of Creation can no longer have their abilities altered. (safety measure)

### Removed
- Removed Statue, Lamp and Bonfire decorations from the top of the Dirt Peaks.
- Removed selection argument from *-fix* command. It did not work.


## [v1.3.4] - 2019-09-30

### Added
- Added new heroes:
	- Nihonjin Blademaster
	- Pandaren Bamboo-master
	- Rostrodle General
- Added new units:
	- Siege units for some human races (Black Legion, Templar, Norse):
		- Ballista
		- Ballista Catapult
		- Ballista Scorpion
		- Catapult
		- Organ Cannon
		- Wheeled Bombard
		- Wheeled Trebuchet
	- Rostrodle Soldier

### Fixed
- Fixed an issue where decorations would gain the move and attack abilities when they were upgraded.
- Fixed an issue where the copy of a decoration with pitch, roll, dimensional scale and/or negative height would play its birth animation upon being created and not keep animation tags.
- Way Gates will no longer stop functioning after having been made unselectable.
- Fixed an issue where decorations with pitch, roll, dimensional scale and/or negative height would have the wrong color after changing player ownership.

### Changed
- Improved efficiency of the Save System when saving units.
- Made additional small performance upgrades related to creating large regions in the map.

## [v1.3.3] - 2019-09-28

### Added
- -size command will now also accept 3 arguments, just as the 'size command.
- Added Deco Builder Murloc.

### Fixed
- Decorations will no longer have the wrong player color after having been made unselectable.
- Pitch, roll, dimensional scale and/or negative height are now correctly transferred when copying a unit.
- Decorations with pitch, roll, dimensional scale and/or negative height can now be upgraded correctly.
- Gates with pitch, roll, dimensional scale and/or negative height now operate correctly.
- Pitch, roll, dimensional scale and/or negative height are no longer lost when a decoration is made selectable.
- Fixed an issue where unit custom names were not being saved and/or where being lost when the unit was made a hero.

### Changed
- When copying a hero, its abilities will now also be copied.
- Made small performance upgrades related to creating large regions in the map.
- Adjusted hotkeys for production buildings of all races. Mundane troop production buildings will generally use the B hotkey, while magical troop buildings will use the N hotkey.


## [v1.3.2] - 2019-09-26

### Added
- New commands: 'yaw and 'roll. These commands can change the facing of decorations in the x and y axes.
- Command improvements:
	- The 'size command now accepts 3 arguments, allowing decorations to have a different scale for each dimension (x, y, z).
	- The -fly and 'fly commands now accept negative arguments. This will only function for decorations.
- New Dragon Aspect heroes:
	- Alextraza
	- Deathwing
	- Kalecgos
	- Malygos
	- Nozdormu
	- Ysera
- Added Altar of Storms to Deco Builder Vanilla Orc
- New hero tower: Tauren

### Fixed
- Human Town Hall decoration no langer trains peasants and militia.
- Removed an unintended debug message that would sometimes occur when casting certain abilities.
- Fixed some small bugs that could lead to the map crashing in certain situations:
	- Casting a builder's Fly and Teleport abilities simultaneously.
	- Removing a unit from the game while it was stunned/silenced or otherwise disabled.
	- Removing a unit from the game while it was buffed by certain abilities.
- Human Altar & Arcane Vault no longer become invisible after having been made unselectable.

### Changed
- Reduced training time of workers from 3 seconds to 1 second.
- Reduced training time of army units from 5 seconds to 2 seconds.
- Added abilities to many heroes which had been implemented in 1.3.0.
- Barracks now trains Human Militia.
- Removed flying movement type from Incorporeal heroes.
- Renamed Sword of Destruction 1 to Sword of Creation and also renamed the Angel of Creation's passive to Hands of Creation.
- Fixed icons for Sword of Destruction and Sword of Creation and also the Angel of Creation's passive.
- Arcane Sanctum renamed to Blood Elf Arcane Sanctum.
- Adjusted hotkeys for units in production buildings of many races:
	- Flesh
	- Fleshless
	- Incorporeal
	- Orcs
	- Tauren
	- Dwarves
	- Blood Elves
	- Night Elves
	- Naga
	- Murlocs
	- Forest Dwellers

### Deprecated
- Orc structures have been deprecated and will automatically load into the game as their decoration counterparts (except production buildings).
- The following deprecated units will no longer be loaded into the game. Instead, they will be replaced by an equivalent unit (in parenthesis). When they are eventually removed, this automatic replacement will no longer occur and they may be loaded as different units:
	- Fel Stronghold (Orc Great Hall with "first" tag)
	- Fel Fortress (Orc Great Hall with "second" tag)


## [v1.3.1] - 2019-09-19

### Added
- Added a new ability to Waygates that allows the player to fix them after having moved them with decoration abilities.
- Created new multishot ability and added it to the Drow Archer Elite unit.
- New hero ability: Breat of Frost. This ability has been added to the following heroes:
  - Fleshless Forgotten Wyrm
  - Icecrown Lich
  - Lord of Blue Scales
  - Lord of Frost
- Added a new deco builder (Deco Builder Plants) which creates some plant decorations that had been left in the Titan Palace. This was added as an exception to the general rule of no new deco builders in a patch version, as the decorations that it creates were already in the map.

### Fixed
- Fixed a bug which would cause copies of units to lose not keep the original's animation tags.
- Fixed an issue that could cause units to become unable to move if they were close to two structures which were given or loaded with a flying height.
- Fixed an issue where decorations would change height slightly when they were made unselectable/selectable near a cliff.
- S&S Shire Tree 1 (Autumnal) will now upgrade correctly, instead of upgrading to itself.
- Fixed models for:
	- Embalmed Tomb Knight
	- Fel Ent
	- Blacksmith Table
	- Blacksmith Forge
- Removed food cost from units:
	- Wraith
	- Flesh Dire Wolf
	- Flesh Dog
- Fixed special case for "rect" argument in -seln command.
- Reduced build time of Flesh builder from 5 seconds to 3 seconds.
- Fixed soundset for the Ancient of Anarachy.
- Fixed tooltips for S&S Shire deco builders.
- Fixed damage value in Greater Shockwave tooltip.
- Fixed error in Greater Spirit Link tooltip.
- Fixed soundset for Expert Assassin human hero.
- Fixed an issue where selecting Drow Blade-Princess would show her level on top of other nearby heroes.
- Fixed Wood Elf Rider name.
- Adjusted default scale for some Norse units:
	- Speaman
	- Footman
	- Elite
	- Cavalier
	- Valkdottir
- Fixed icons for:
	- Norse Berserker
	- Norse Elite
	- Norse Veteran
	- City Lamp and Lantern
	- Block decorations
	- Effect decortions
	- Runic Decorations
	- Tableware Decorations
- Fixed teleportation for Deco Modifier Controller.
- Fixed tooltip for Ruined Rowboat.
- Fixed units that would not decay into skeletons persisting as corpses:
	- Norse Elite
	- Norse Berserker
	- Drow Shadow Witch
- Added a hero glow to the heroes that were missing one:
	- Everchief
	- Legendary Thief
- Changed primary attribute of Goblin Trade prince hero to Intelligence (from Agility).

### Changed
- Deco Builder Nordic has been renamed to Deco Builder Norse.
- Deco Builder Medieval 1 has been renamed to Deco Builder Feudal (along with the old Medieval decorations).
- Feudal Decorations have been renamed as follows (respectively):
	- Workshop, Market, Armory, Stables -> Workshop 1,2,3,4
	- House, Tavern, Lumber Mill -> House 1,2,3
	- Barracks, Academy, Archery, Town Center -> Barracks 1,2,3,4
	- Watch Tower, Guard Tower, Wizardry Tower -> Tower 1,2,3
	- Arcane Sanctum, Castle -> Palace 1,2
- The following heroes are now available at hero Towers:
	- Paladin
	- Goblin Alchemist
	- Goblin Tinker
	- Pit Lord
	- Dark Ranger
- The -setcolor command will no longer affect the Titan Powers.
- Removed proper names from Tavern neutral heroes.
- Incorporeal units no longer have the flying movement type (except the Wyvern).
- Changed armor sounds of Incorporeal units to etheral sounds.
- Added village decorations that were in the Titan Palace to Deco Builder Village.
- Gave splash damage to Drow Shadow Witch.
- Gave bouncing attack to Drow Witcher.
- The Spirit Touch unit ability will no longer target the caster.
- Improved the Battle Priest's  Purge ability.
- Fleshless ancient boneyard now trains Skeletal Raptors.
- Added attack values to incorporeal sorcerer and wyvern.
- Added spells to units of the races added in 1.3.0.
- Changed the Lord of Green Scale's primary attribute to Agility and gave him appropriate (non-dreadlord) abilities.
- Norse Wizard's Tower no longer trains human casters.
- Added documentation in quests that the 'anim command does not take into account animation tags previously set.
- Draenei Relic Vault has been renamed to Draenei Vault 1 and now upgrades into the old Draenei Vault (now numbered 2).
- Renamed Draenei Pylon to Draenei Tower 1 (and the old tower to Tower 2).
- Pandaren Statue is now Statue Pandaren and thus is now built by Deco Builder Statues 2.
- Norse Tavern is now Feudal House 4.
- The following buildings have been converted to decorations:
	- Bandit Hideout (Ruined Cathedral)
	- Black Legion Castle (Medieval Castle)
	- Dark Human Stronghold (Chaos Stronghold)
	- Draenei Metropolis
	- Drow Dark Hall
	- Elven Citadel (Dalaran Town Hall 2)
	- Fleshless Great Crypt (Gravestone Graveyard)
	- Forest Elf Hall of Nature (Forest Elf Town Hall)
	- Goblin Center
	- Haradrim Palace (Arabian Palace)
	- High Elven Castle (High Elf Castle)
	- Norse Hall
	- Pandaren City Hall
	- Pirate Tower (Ruined Dalaran Citadel)
	- Ratfolk Nest (Medieval Mine)
	- Rostrodle Castle
	- Runic Town Hall
	- Templar Cathedral (Medieval Church)
	- (Human) Altar
	- (Human) Arcane Vault
	- (Human) Blacksmith
	- (Human) Farm
	- (Human) Lumber Mill
	- (Human) Tower
	- (Human) Town Hall
- Faceless Ziggurat has been renamed to Faceless Spire and uses the old Faceless Aspirant Spire model.
- Small terrain changes to the Titan Palace.

### Deprecated
- The following deprecated units will no longer be loaded into the game. Instead, they will be replaced by an equivalent unit (in parenthesis). When they are eventually removed, this automatic replacement will no longer occur and they may be loaded as different units:
	- FantEnv Rock Small 2 (FantEnv Rock 2)
	- FantEnv Rock Small 2 (FantEnv Rock 3)
	- Keep (Human Town Hall with "first" tag)
	- Castle (Human Town Hall with "second" tag)
	- Guard Tower (Human Tower with "first" tag)
	- Cannon Tower (Human Tower with "second" tag)
	- Arcane Tower (Human Tower with "third" tag)
	- Great Hall (Vanilla Great Hall)
	- Stronghold (Vanilla Great Hall with "first" tag)
	- Fortress (Vanilla Great Hall with "second" tag)
	- Temple of Tides  (Naga Temple of Tides with "first" tag)
	- Lizardman Village (Medieval Mine)
	- Centaur Main Hut (Hut Centaur 2)
	- Troll Main Hut (Vanilla Voodoo Lounge)
	- Great Hall (Vanilla Great Hall)
	- Dwarven Temple (Human Blacksmith)
	- Fel Great Hall (Vanilla Great Hall)
	- Tauren Main Hut (Vanilla Great Hall)
	- Cultist Necropolis (Vanilla Necropolis)
	- Worgen Manor (Human Town Hall)
	- Faceless Aspirant Spire (Faceless Spire)

### Removed
- Removed all partially implemented decorations from the Titan Palace, since they are now fully implemented.
- Removed Skeletal Raptor from Titan Palace, since it can now be produce by the Fleshless.
- The Tavern no longer sells heroes. The heroes that used to be sold there can now be bought at the Hero Towers.


## [v1.3.0] - 2019-09-14

### Added
- New Races:
	- Cultists
	- Dark Dwarves
	- Embalmed
	- Heretics
	- Incorporeal
	- Faceless
	- Fel Elves
	- Fel Troll
	- Flesh
	- Vampires
- New Deco Builders (272 total decorations):
	- Deco Builder Black Empire (10 total)
	- Deco Builder Dalaran Modular 1&2 (60 total)
	- Deco Builder Hellfire Citadel (9 total)
	- Deco Builder NPC (6 total)
	- Deco Builder S&S Shire 1&2 (187 total)
	- Deco Builder Vanilla Orc (11 total)
	- Deco Builder Vanilla Undead (11 total)
- New Hero Towers (40 new heroes):
	- Cultists (5 total)
	- Dark Dwarves (3 total)
	- Embalmed (5 total)
	- Gray Elves
	- Heretics (4 total)
	- Incorporeal (5 total)
	- Fel Elves (4 total)
	- Fel Troll (5 total)
	- Flesh (3 total)
	- Vampires (6 total)
	- Worgen
- New Heroes:
	- Human:
		- Dark Enchantress
	- Drow:
		- Drow Prince
		- Drow Master Sorceress
	- Lizardmen:
		- Lizardman Archdruidess
		- Serpent Temple Champion
	- Night Elf:
		- Druid of Autumn
	- Ratfolk:
		- Nillish Fril, the White Death
		- Kobold Overlord
		- Kobold Trailblazer
	- Norse:
		- Norse Drott
		- Yaene Ebenherzen, Lady of Baronstead
	- Faceless:
		- Faceless King
		- Faceless Myrmidon
		- Faceless Reaper
		- Overseer of Oblivion
	- Fleshless:
		- Celsius
- New Units:
	- Black Legion:
		- Black Legion Sacred Maiden
	- Lizardmen:
		- Lizardman Druidess
		- Lizardman Priest
		- Serpent Temple Disciple
		- Serpent Temple Guardian
	- Norse:
		- Norse Knight
		- Norse Valkdottir
	- Templar:
		- Templar Saint
- New Decorations:
	- Misc Generators (2 variations)
	- Nihonjin Dojo (4 variations)
	- Village Houses
	- Water Ripples (2 variations)
- New Hero Abilities:
	- Greater Spirit Link
	- Raise Flesh Golem
	- Raise Skeleton Legion
	- Summon Angels
	- Summon Elemental: Void
	- Summoning Ritual: Black Legion
	- Summoning Ritual: Black Legion
- Added new argument to -camera command: *zoffset*
- Added suitable models for some workers:
	- Bandit
	- Blood Elf
	- Fleshless
	- Forest Elf
	- Gray Elf
	- Haradrim
	- Murloc
	- Norse
	- Night Elf
	- Pandaren
	- Son'gar
	- Tauren
- Improved documentation in the F9 manual:
	- Created two new quests to document animations and animation commands
	- Added -nameunit command to Unit Modification Commands quest
	- Documented -give and -rotate commands in Unit Commands 2 quest
	- Documented -setcolor and -roll commands in Player Commands quest
	- Now correctly shows 7 instead of 4 in limit of addable abilities

### Fixed
- Fixed a bug that would cause neutral units to not be saved.
- Selection commands (-sele/-seln) will now correctly recognize names with capital letters in the middle.
- Added hero glow to many heroes that were missing it.
- Removed food cost from Gnolls (in the Titan Palace) and militia.
- Fixed wrong tooltips:
	- Units: Fleshless Serpent and Lesser Lich, Militia
	- Abilities: Holy Inspiration, Sword Throw and Mass Rejuvenation
- Fixed hotkeys for terrain abilities and documented them in tooltips.
- Fixed models for some units:
	- Pandaren Priest
	- Pandaren Shaman
	- Pandaren Wanderer
- Fixed selection scale for many heroes (like Fel Lord and Sally)
- Highborne decorations now upgrade into their high elf counterparts
- Fixed tooltip for High Elf Altar
- Standardized Siphon Mana ability

### Changed
- Units in production buildings are now hotkeyed (QWERASDFZXC).
- Race Selector now trains workers instead of upgrading into main building (except for angels). Workers are now hotkeyed.
- Default load limit is now 1 billion
- Huge terrain overhaul:
	- Slightly expanded west camera bounds border.
	- Northwest Snow Lands has become a more diverse environment:
		- Barrens-like North.
		- A small scorched island.
		- Canyon-like south.
		- Long lava river splitting it.
		- Surrounded by mountains and a snowy path.
	- Scorched Lands have been removed. Instead we now have:
		- New LoP-original island.
		- New island ported from KoT.
	- Snow Peaks:
		- Snow peaks have been unified, there is no longer a river splitting them.
		- Huge waterfall now flows from the peaks into the part of the river that was maintained.
	- Snow Lands has been split into two environments, and has been covered with gray rocks:
		- East icy-grass environment.
		- West snowy environemnt.
	- A Blighted Forest has appeared to the north of the Summer forest.
- Misc Dummy and Misc Target no longer have shadows. Units no longer emit sounds when hitting these decorations. Misc Dummy now has default RGB when created.
- Added Multitile to every terrain spellbook in Deco Modifier Terrain.
- Added a helpful description to the Water Square decoration.
- Polished stats for Lizardmen and Ratfolk units.
- Lizardman Juggernaut now starts with 200 mana.
- Unit abilities that a unit possesses by default will no longer be lost when loading that unit as a hero.
- All structures will now upgrade instantly, instead of only decorations.
- Fixed soundsets for Ratfolk heroes.
- Added new hero abilities to some heroes:
  - Kel'thuzad: Raise Flesh Golem
  - Skeleton King: Raise Skeletal Legion
  - Elven High Conjurer: Summon Elemental:Void & Greater Spirit Link
  - Sally Whitemane: Summon Angels
  - Yaerius: Summoning Ritual: Angels
  - Gaufridos: Summoning Ritual: Black Legion
- Reduced animation time for Deco Modifier Special and Deco Modifier Terrain (will increase shift-click speeds).
- Way Gate is now a unit and no longer has to be aligned to the 64x64 grid.
- Rally ability icon will no longer show up in production structures.

### Deprecated (will be fully removed in 1.4.0)
- Deprecated many old wall decorations. They can no longer be built from deco builders.
	- Deco Builder Wall (Wood) has become Deco Builder Wall (Original).
	- Deco Builder Wall (Ruins) and Deco Builder Wall (Stone) have been converted into Deco Builder Dalaran Modular 1&2
	- Deco Builder Wall (Icecrown) reanmed to UNUSED

### Removed
- Removed limit system and -limit command for the Titan
- Terrain Editor has been disabled (suspected of causing loading screen crashes).
- Greatly reduced the number of abilities in the map by leveraging the power of the new patch 1.31 instance API added by Blizzard. This should somewhat reduce loading time at the end of the loading bar.


## [v1.2.3] - 2019-08-08

### Fixed
- Horizontal logs will now load correctly, instead of becoming vertical.
- Fixed crashes that would occur when some caster units were converted to heroes.
- Fixed an issue that would cause decorations to lose the *alternate* tag when made unselectable.
- Fixed an issue that made players other than the Titan unable to use the **-makehero** command.
- Fixed a small issue that could cause bugs when two players loaded builds which had the same name.
- Fixed models for:
	- Fleshless Lesser Lich
	- Blood Elf Phoenix Crusader
	- Tree Nordrassil decoration (no longer bugs near transparent models)

### Changed
- Many of the Titan Palace buildings (such as the hero towers and item shops) no longer display on the minimap. This should reduce clutter in the area. The Titan Powers still display, and they can be used to identify the player who is the Titan from the minimap.
- Divine Shield has been rebalanced. Duration is now 5 seconds, cooldown is now 15 seconds.
- Made more abilities compatible with the **-ability** command. **Note:** heroes saved in older versions may lose these abilities when being loaded into the map. 
	- Divine Shield
	- Black Arrow
	- Charm
	- Cleaving Attack
	- Cluster Rockets
	- Drain Life
	- Drunken Brawler
	- Forked Lightning
	- Frost Arrows
	- Healing Spray
	- Howl of Terror
	- Mana Shield
	- Storm, Earth and Fire
- Standardized tooltip and hotkey for some of the new compatible abilities.


## [v1.2.2] - 2019-07-31

### Fixed
- Arin's and Blood Elf Elite Strider's models are no longer missing.
- Female Blood Elf Lieutenants no longer spawn with size 1000.
- Fixed buff name of Greater Bloodlust.
- Fixed an issue where removing a togglable aura which was active would cause the aura effect to persist on the hero.
- Units converted to heroes with **-makehero** will now maintain their visual values (such as custom name, flying height, rgb color and player color).

### Changed
- The number of abilities that can be added to a hero has been increased from 4 to 7.
- **-makehero** was turned into a player command. Players are now limited to 12 heroic units per player, though the Titan can bypass this limit for any player. *Developer comments: Having the -makehero command as a player command was always the intention, however, a lot of testing had to be done to ensure the command would not cause any issues.*
- Units that were turned into heroes with **-makehero** are now saved and loaded as heroes.
- Heroes are now saved with the abilities they currently possess. When loaded, all their removeable abilities will be removed, and their ability list will be restored. In the future, when new abilities are made removeable, some heroes may be loaded without these new abilities, as they will have become removeable, but would not have been saved along with the hero.
- Rect Generators' terrain fog settings will now be saved and loaded.
- Units that are converted into heroes will no longer be able to cast Mirror Image. Casting this ability used to remove these units.
- Tooltips of Cosmic Essence and Mirror Image have been updated to reflect the fact they don't function with converted heroes.
- Greater Bloodlust can now affect units.

### Removed
- The First Person Camera documentation has been removed from the F9 manual while the system is not enabled.


## [v1.2.1] - 2019-07-24

### Added
- New version of the Save system. The external SaveNLoad program is no longer required, saving and loading is done entirely using Warcraft III's functionalities. To transfer old saves to the new system, they must be loaded using the new **-req** command. Using SaveNLoad.exe will be required for this. After loading the old save, it can be saved using the save commands and afterwards it can be loaded with the **-request** command.
- Created a new ingame Terrain Editor, that works similarly to the World Editor's Terrain Editor. Currently, it is a very simple tool, but it will be greatly expanded upon in the furute. It will be the most supported form of terrain editing going foward, so try and ditch the Deco Modifier Terrain, if you can.
- New Commands:
	- -collision (on/off): allows you to turn collison on/off for units. This allows naval units to go onto land and ground units to walk through cliffs.
    - -editor (terrain/none): Allows you to enter/exit the new ingame Terrain Editor.
	- -ability (add/remove/clear): Use the new ability system to manipulate which abilities a hero has. Read F9 menu in-game for more details.
	- -fix (darkness/selection): New (probably temporary) command to fix issues some players have been experiecing.
- New Races:
	- Worgen
	- Ratfolk
	- Lizardmen
- New Deco Builders:
	- [Stone & Sword](https://www.hiveworkshop.com/threads/hybrisfactory-terraining-and-mapping-resources.238310/) builders:
		- **Deco Builder S&S Manor 1 and 2:** These are two new deco builders with 89 new decorations in total. These decorations are modular, allowing you to build pretty much any medieval building your imagination can come up with!
		- **Deco Builder S&S Kingdom 1 and 2:** There are two new deco builders that add a total of 54 new decorations. These decorations are pretty useful for creating interiors, villages or markets.
	- **Deco Builder Mushrooms:** Builds mushrooms that used to be built by Deco Builder Crops. Also added new mushrooms:
		- Giant Mushrooms (and Red variations)
		- White Spotted Mushrooms
	- **Deco Builder Tableware:** Builds things that you can put on top of tables.
		- Mug
		- Bread
		- Plate, Plate with Meat
		- Candelabra, Candelabra (Off)
	- **Deco Builder Castle:** Creates interior decorations for castles, including walls (with arches/doors/windows), pillars and banners.
	- **Deco Builder Naga 2:** Contains a few new naga structures.
	- **Deco Builder Gurubashi:** Contains Gurubashi buildings with Sunken Ruins textures made by THW user Ujimasa Hojo.
	- **Deco Builder Huts:** Builds creep huts that used to be located in the Titan's Palace.
- New Decorations:
	- Deco Builder Fire:
		- Flame Grate (round and rectangular)
	- Deco Builder Misc:
		- Magical Pen (can be activated and deactivated)
	- Deco Builder Misc:
		- Animal Spawner 3: Pig, Red Fox, Horses and Belf Wagon (not an animal, but who cares?)
	- Deco Builder Naga:
		- A few new naga structures.
	- Deco Builder Water:
		- New Water Square decoration that uses an HD water model.
- Critters will no longer wander around aimlessly by default. An ability has been added to them which allows the wandering behaviour to be enabled or disabled.
- New Critter: Fox.

#### Minor Additions:
- Cosmosis now possesses the Obliterate spell to remove unselectable decorations.
- Readded the Noldor elven units to a new Barracks that can be built by the High Elf Architect.
- New tips have been added for the ability system and the Terrain Editor.


### Fixed
- Many changes have been made in order to make the map more stable. Desyncs and crashes seems to have been mitigated, though they are not yet completely gone.
- Certain models (such as City Buildings) should no longer become partly invisible when they receive an RGB value. They will still become partly invisible if they receive an alpha value.
- Tooltips for High Elf and Highborne decorations are now correct.
- Ressurection stone has been correctly added to Deco Builder Rocks (it was missing before).
- Dragonspawn Cavern can now be built normally.
- **Possibly** fixed some desyncs that could **possibly** happen at the start of the game. *It's hard to mod Warcraft 3*.
- **Possibly** fixed some desyncs that could **possibly** be caused by the camera system and RectGenerator system. *Really hard*.
- Fixed an issue where sometimes Rect Generators with sides greater than 2048x2048 would not perform correctly.
- Young King's Mount Up ability now has the L hotkey and will no longer conflict with his Charge ability.
- Greater Bloodlust will now work in patch 1.31.
- Giving a unit to neutral will no longer cause it to lose it's custom color (given with the -color command).
- Fixed an issue where the original unit would be given to Red when its mimic died (Staff of Mimic).

### Changed
- The map now requires patch 1.31 or greater.
- The maximum number of players in the map has been reduced to 12, in an attempt to mitigate desyncs. In the future, the limit may be increased to 24 again, if it is found that it was not a cause for desyncs.
- Rect Generators' Toggle Terrain Fog ability is now functional. By default, fogs are disabled.
- The Titan can now make any player's decorations unselectable, in order to avoid lag.
- Terrain:
	- Added a secondary entrance to the Dirt Peaks (connected to the Blighted Lands).
- Decorations will now maintain their flying height when upgraded.
- Load limit increased from 9999 to 2147483647.
- Rect Generators and Animal/Villager Spawners cano no longer be made unselectable.
- Blizzard and Rain of Fire will no longer damage the casting hero. Only applies for the heroic versions of these abilities.
- Drow Dark Hall can now train Deco Builder Drow.

#### Minor Changes:
- Unselectable decorations are now Special Effects instead of units with the Locust ability. This SHOULD increase performance, and in the future it will allow for more flexiblity with unit visuals (negative flying height and rotations along the x and y axes). Even though this is a minor change for the end user, this is the part of the update which took the longest to properly finish.
- Custom heroes created with -makehero will now have the Hero armor type.
- Fire Campfire (with Pig) has been removed from Deco Builder Fire's build menu. It is now an upgrade of Fire Campfire.
- Double quotes (") will be converted to two single quotes ('') when saving unit names.
- Cenarius has had his stats rebalanced, he should now be one of the most tanky Intelligence heroes.
- Made unit sizes more consistent for High Elves and Blood Elves.

### Removed
- Removed glowing mushrooms from the Scorched Lands. This part of the terrain is going to see a massive overhaul, probably in 1.3.0. Removing these mushrooms should reduce FPS lag that some people experience in LoP.
- Removed creep huts from the Titan Palace, since they now have a deco builder.


## [v1.2.0] - 2019-07-24

Skipped in order to avoid confusion due to there being multiple beta versions of this release.


## [v1.1.6] - 2019-05-31

### Fixed
- Most of the models in the map have been sanitzed, using https://viewer.hiveworkshop.com/check/ and hard work.
- Some models (like the Blood Elf Phoenix Crusader) will no longer crash the game in patch 1.31.0.
- Spell damage will now kill units in patch 1.31.0.

## [v1.1.5] - 2019-05-24

### Added
- New tips system to give new players useful information regarding Lands of Plenty (intended for players who already played Titan Land).
- New commands:
	- tips
		- off: Disables periodic tips.
		- on: Enables periodic tips.
		- (empty): toggles tips on/off, depending on current setting.
	- hints: An alias for -tips.
- New Deco Builder:
	- Deco Builder Elves High:
		- High Elf decorations
		- Highborne decorations
- New Decorations:
	- Deco Builder Furniture:
		- Windows
		- Curtains
- New heroes:
	- Goblin Trade Prince
- New units:
	- Goblin:
		- Goblin Siege Walker
	- New Elven units:
		- Blood Elf: Archer, Battle-cleric, Battle-priestess, Cleric, Elite Strider, Footman, Guard, Hawk Knight, Hawkstrider Rider, Huntress, Lieutenant Female, Magister, Novice Mage, Phoenix Archer, Phoenix Crusader, Royal Mage, Spellbane, Strider, Thaumaturge
		- Gray Elf: Battle-priestess, Caladrius Crusader, Elite Strider, Guard, Magister, Priest, Royal Mage, Spellbane, Strider
		- High Elf: Anarchist, Assassin, Battle-cleric, Footman, Hawk Knight, Militia, Priest, Sacntum Archer, Sanctum Warrior, Sorceress, Warmage
		- Wood Elf: Spearthrower


### Fixed
- Fixed an issue where the game would crash if a very big rect generator was being expanded.
- The following units now have weapons:
	- Gray Elf Solider (renamed from Gray Elf Guardian)
	- Gray Elf Pikeman
- Fixed an issue where a debug message would occur when using certain abilities.
- Icons adjusted for many decorations, units and heroes. Most towers and buildings no longer have units with duplicate icons.
- Astrologer no longer doubles his attack when transforming back from his alternate form.

### Changed
- Heroes can now turn some auras (Brilliance, Command, Devotion, Endurance, Thorns, Trueshot, Unholy and Vampiric) off, by clicking on them in the Command Card. By default the auras are disabled, so people can notice the feature. In the future, they may be enabled by default.
- Adjusted size for FantEnv Rocks and Statues. If you were using them before, you might have to resize them.
- Structure decorations (such as walls and gates) will no longer lose their abilities when their flight is enabled.
- The High Elf race has been overhauled. Their units now belong to the Noldor race. Their buildings now produce Warcraft High Elf units.
- The Elves races has been converted to Blood Elves. The high elven units in that race have been moved to the new High Elf race.
- Polished the goblin race, diversifying many of their units and improving their stats:
	- Goblin Flamethrowers now deal AoE damage.
	- Goblin Flameshooters now have a bouncing attack.
	- Goblin Sniper now has the correct range of 1000, up from 600.
- Polished the Wood Elf units, diversifying many of their units and improving their stats.
- Terrain Updates:
	- Added more trees to the small blighted area between the dirt mountain passage and the southwest forest.
	- Added more trees in the transitionary region between the west forest and the northwest cold lands.
	- Fixed many tiles that had been incorrectly placed.
- Deco Builder Elves renamed to Deco Builder Elves blood.
- Added, fixed or changed tooltip descriptions for many deco builders.


### Removed
- Noldor (old High Elf) units can no longer be produced. A new production building will be added for them in a future version. For now, you can create them by loading old saves and copying the units to get as many as you need.


## [v1.1.4] - 2019-05-18

### Added
- New (Warcraft) High Elf Heroes:
	- Vereesa Windrunner
	- Paladin
	- Warden
	- Impaler
- New Decorations:
	- Deco Builder Statues 2:
		- Fantasy Environment Statues
	- Deco Builder Rocks:
		- Fantasy Environment Rocks
		- Ressurection Stone
	- Deco Builder Fire:
		- Torch
		- Wall Torch
- New Deco Builders:
	- Deco Builder Ruined 2:
		- Dalaran ruined buildings
		- Night Elf Ruined Buildings
		- Ruined Ships and Rowboat
- New Units:
	- Many new Fleshless casters (still a work in progress).
	- Wood Elf Units. They are currently a subrace of the Forest Elves and can be trained in the Wood Elf Hall of Warriors.

### Fixed
- Fixed a major crash that would occur whenver the Tinker hero cast Pocket Factory.
- Cenarius is no longer puny and small. Scale has been restored to 140%.
- Fixed tooltip conflicts in a few heroes. No more tooltip conflicts should exist.
- Night Elf Lunar mage has decided that he did not like his female voice, and thus went through a few acting classes.
- Lord of Black scales will now correctly display his level above him when hovered over with the mouse.
- The goblin Tinker now has an inventory to hold all his tools. He had previously lost his bag in an explosion.

### Changed
- Sylvanas's Undead incarnation now uses a custom model.
- The High Elf race has been renamed to Noldor.
- Nightmare (Legends Tower) now has more fitting abilities.


## [v1.1.3] - 2019-05-15

### Added:
- A few multitiles have been replaced by tiles that are present in *Titan Land Kingdoms of Terfall*. A transparent tile has also been added.
- To support the transparent tile, dirt will no longer overlap multitile tiles, which can cause their interaction to be a bit unelegant.
- New heroes:
	- Expert Assasin (Human Tower 3)
	- Ashun (Worgen Champion)
	- Lord of Black Scales
	- Lord of Green Scales
	- Lord of Bronze Scales
	- Lord of Blue Scales


### Fixed
- Fixed a major crash that would happen whenever an attempt was made to reset a unit's name (using *-nameunit* with no arguments) and that unit did not already have a custom name.
- Fixed a leak that would happen whenever a unit that was using Guhun's Patrol System was removed from the game or had its patrol points cleared.
- Fixed a leak that would happen with some abilities that applied numeric bonuses to units.
- The game will no longer crash when Polymorph or Hex is cast on a unit.
- Units that attack ground units can now become heroes again (applies to the *-makehero* command and to the *Staff of Mimic*).
- The radius of the terrain abilities related to blight has been increased to match the radius used by other terrain abilities. This radius is not accurate when using *-val 2*.

### Changed
- Artillery units can now become heroes again. Testing has determined that orb abilities now longer cause crashes when used by an artillery unit.
- Terrain has been changed in the snow mountains on the southwest. Icy cliffs have been added.
- Dragonspawn Flamebalde hero has been renamed to Lord of Red Scales.


## [v1.1.2] - 2019-05-14

## Skipped
	**Please see changes for version 1.1.3 insead.**


## [v1.1.1] - 2019-05-06

### Added:
- The Goblin Merchant now has many kinds of Orbs in stock.

### Fixed:
- Minor issues that could cause handle reference leaks.
- Fixed a major leak that would occur whenever a unit was issued a point order (like Move or Build).
- The game clock is no longer off by 1 second for each minute that has passed.
- Staff of Mimic can now be used on heroes again.
- Locusts swarm no longer lasts 5 seconds, it has been restored to the normal 30 second duration.
- The following units are no longer missing a tooltip:
	- Water Elemental
	- Berserk Quillbeast
	- Fel Orc Warchief (also renamed from Orc Warchief)
	- Orc Warlock
	- Piratess
- Tooltips fixed for the following units:
	- Forest Elf Ranger
	- Forest Elf Archer
	- Forest Elf Claw Druid
	- Gray Elf Guardian
	- Gray Elf Architect
	- Gray Elf Archer
- Small tooltip changes to make tooltips more consistent across more units.
- The Drow Dark Princess's Raven Form now actually flies (at a height of 200).


## [v1.1.0] - 2019-05-05

### Added:
- New terrain:
	- Mountainous terrain from the KoT desert has been ported and converted into a canyon.
	- Added rocks to the blighted terrain cliffs to make it more visually appealing.
	- Made desert islands in the northeast connected through shallow water instead of deep water. *Developer comments: In KoT, the most used islands are the ones that are connected by shallow water, since they can also be used as a single, larger, island. This update should make the islands attractive to a larger group of players.*
	- Southwest desert has been completed turned into a lushous forest with many good spots for simple bases.
	- Parts of the Southeast that were not converted into canyon have been converted into desert.
	- Added more trees in the middle forest. *Developer comments: This should make the place feel less empty, and shoul allow for better spots for simple, quickly-built, bases.*
- New commands:
	- -time => Allows the Titan to change the in-game time of day.
	- -rotate => Allows you to set the angle of rotation for the Rotate ability of decorations.
	- -controller => Allows you to spawn a Controller deco (was removed from -decos command in version 1.0.0). This deco allows you to control units and move them using the QoL decoration abilities. All controllers of the same player control the same group of units. To add or remove units from your controller group, use the -control and -uncontrol commands.
	- -roll => Allows players to generate random numbers in certain ranges. You can use a tabletop (2d6) notation or a range notation ((number) (min) (max) => 2 1 6).
- New command arguments:
	- -seln/sele rect => Will now select your Rect Generators.
	- 'mind (number/color) => Will now work as if you had ordered the Power: Mind unit to right-click your selected units.
- Improved -makehero command. 
	- Now simulates an EXP bar.
	- Now gives hero-like stats to the unit.
	- Now shows the unit's main stat in a special item in its inventory. Currently only strength is supported.
- New hero abilities:
	- New unique hero abilities for casters: Arcane Ward, Extraplanar Body, Nature's Wrath. *Developer comment: Intelligence heroes felt a lot weaker then strength and agility heroes. These new abilities should bring them up to the correct power level. Some intelligence heroes that were already pretty strong have not been given these abilities.*
	- Comet: A comet falls down from the sky, dealing damage and stunning enemy units. Ability has a 1-second cast time and a small delay happens before the comet falls. This ability can even stun magic-immune units. Additionally, a successful hit resets the cooldown for other specific hero abilities. 
	- Searing Hatred (Sargeras only): a SFX-intensive ability (as the hero deserves) that makes Sargeras more effective at regaining mana and destroying armies. Inspired by his ability to burn things for miles in the WoW RPG.
	- Energy Surge: Similar to Power Surge, but with a lower cooldown while restoring a smaller amount of mana. Also restores hit points.
- New heroes:
	- Vampire Ranger (Request by tommita12)
	- Drow Dark Princess (Request by LichKing76)
	- Drow Queen (Request by LichKing76)
	- Master of the Talon
	- Tichondrius (custom model with flight)
	- Balnazzar (custom model)
	- Varimathras
	- Black Legion Baroness
	- Dark Huntress (Human Tower 3)
	- Bandit Boss
	- Bandit Master Poacher
	- Marauder King
	- Bandit Leader
	- Haradrim Legendary Thief
	- Divine Champion of the Order (Templar Tower)
	- Demonic Torturer of Souls (female)
	- Gray Elf Ranger
	- Forest Elf Queen
- New units:
	- Stormwind units for default humans. Can be built in the Stormwind barracks.
	- Lordaeron units for default humans. Can be built in the Lordaeron barracks.
	- Haradrim units: Armored Archer, Elite Archer, Guard, Magician, Infantry
	- White Order unit: White Order Captain
	- Human caster units: Human Incantatrix, Lordaeron Royal Cleric 
	- Bandit units: Bandit Rifleman, Marauder Conjurer
	- Night Elf units: Night Elf Priest, Highbourne Priest
- New Races (still works in progress):
	- Forest Elves
	- Gray Elves
- New decorations:
	- Deco Builder Gates:
		- Ruins Gates (including diagonal and massive)
		- Diagonal Gates (Normal, Dungeon and Demon gates)
		- Iron Gates (including diagonal)
		- Castle Iron Gate (diagonal only)
		- Wooden Gate
	- Deco Builder Archways:
		- Wooden Archway (3 variations)
	- Deco Builder Water:
		- Sunwell (upgrades from the fountain)
	- Deco Builder City 3:
		- Ironforge exterior structures (includes gate and 9 other variations)
- New deco builders:
	- Deco Builder Drow (Adv Deco): 
		- Altar, Dungeon, Houses (Large and Small), Smith, Temple, Wormhole and Ziggurat (4 variations).
	- Deco Builder Elf Forest
- New items:
	- **Staff of Mimic**: Allows a hero to copy a unit's appearance and abilities.
	- **Diamond of Mass Teleportation**: Allows a hero to use the Archmage's ultimate ability: Mass Teleportation.

### Fixed
- A hostile 'Give Unit To' circle is no longer created at coordinates (0, 0).
- -control/uncontrol commands are now easier to use again, since you can more easily spawn a Controller deco.
- Non-decoration structures loaded with a flying height will no longer keep the Enable/Disable Flight ability.
- Adding animation tags to units that have animation tags by default (like Castles or Guard Towers) with the -tag command now works correctly. These units are now also correctly loaded with the Save System.
- All decorations now have the L hotkey instead of the F hotkey. This avoids any hotkey conflicts with decoration QoL abilities.
- Some hero abilities no longer deal double damage. To compensate, Carrion Burst and Will of the Tribunal have been buffed.
- Angel of Creation can no longer be loaded into the game.
- Removing a unit from the game no longer causes a small lag spike.
- Fixed an issue when saving terrain that would save all tiles as grass.

### Changed
- Structures can now have their flying height set with commands. Decorations will automatically cast Enable Flight when their flying height is changed.
- Dark Summoning (from the item in the Titan Teleportation Solutions shop) no longer clusters units.
- Heroes no longer have to learn default wc3 hero abilities. All heroes spawn with their hero abilities automatically learned.
- Overhauled hotkeys for hero abilties. Ability hotkeys are not separated by their targeting type (target, point, circle), functionality (instant, buff, debuff) and casting form (instant, channeled, delayed). Hero abilities now consistenly show their hotkey between brackets after the ability name. Hopefully this will make it so creating heroes is more streamlined and allow for more fun to use heroes.
- Added many custom icons for abilities. *Developer comments: while I personally am against adding icons, I can understant that they add value to many users, and can help immersion. To this crowd, I consider that the most valuable icons to add would be ability and hero icons. For now, only ability icons will be added, and only to avoid icon conflicts for generic abilities. For unique hero abilities (such as Tyral's WotT), the icons shall either be already imported for other custom abilities or default wc3 icons.*
- Improved icons for many decorations and units. Imported custom icons for hero attributes (mainly for the -makehero command).
- Changed Sargeras's animation names to make more animations available. Check out his tooltip!
- Artillery units can no longer become heroes.
- Improved decoration rotate by angle ability tooltip (in light of the new *-rotate* command).

### Removed
- Removed vertical versions of gates that had a horizontal and vertical version. They have been replaced by the diagonal version of the gate.


## [1.0.3] - 2019-04-18

### Fixed
- Improved icons for: 
	- Ruined Inn
	- Ruined Tower
	- Ruined Town Hall
	
- Fixed tooltip/name text for:
	- Mansion Walls
	- Ice Rock Gate
	- Armchairs
	
- Fixed animation tag for Magical Butterflies decoration

- Fixed Nihonjin Ninja model and re-enabled it

- Fixed stock replenishment times for Air Barge and Zeppelin

- Fixed Tyrael's Will of the Tribunal CD not being reduceable

- Fixed crashes:
	- When Treant Bird was selected with 1 or more other units
	- When Cosmis summoned a Titan Tower before any structure was built (removed the ability)


## [1.0.2] - 2019-04-12

### Added
- Improved icons for: 
	- Elven Citadel
	- Fortress (Orc)
	- Gateway to Heaven and Tyrael
	- Drow Dark Hall
	- Draenei Metropolis
	- Nihonjin Town Hall
	- Elemental Demiplane
	- Dragonspawn Cavern
	- Razormane Hall
	
### Fixed
- Fixed default RGB values for: 
	- Nihonjin Town Hall

- Fixed crashes:
	- When certain abilities were cast (raise skeleton and similar; Storm, Earth and Fire; and Chemical Rage)

### Removed
- Temporarily removed unsafe models: 
	- Nihonjin Ninja


## [1.0.1] - 2019-04-12
First version that is not a pre-release. Also, start of the changelog.
