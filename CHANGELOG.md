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

## [v1.1.5]

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

## [v1.1.4]

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

## [v1.1.3]

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


## [v1.1.2]

## Skipped
	**Please see changes for version 1.1.3 insead.**


## [v1.1.1]

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


## [v1.1.0]

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
