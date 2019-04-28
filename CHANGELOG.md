# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Major versions are created arbitrarily.
Minor versions indicate addition of a very important new feature or a new race or a new deco builder.
Patch versions indicate bugfixes. Some command aliases or arguments may be added in a patch version. New units for an existing race can be adde in a patch version.

## [Unreleased]

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
- New heroes:
	- Vampire Ranger (Request by 11tommita)
	- Drow Dark Princess (Request by LichKing76)
	- Drow Queen (Request by LichKing76)
	- Master of the Talon
- New units:
	- Stormwind units for default humans. Can be built in the Stormwind barracks.
	- Lordaeron units for default humans. Can be built in the Lordaeron barracks.
	- Haradrim units: Armored Archer, Elite Archer, Guard, Magician, Infantry
- New decorations:
	- Deco Builder Gates:
		- Ruins Gates (including diagonal and massive), Diagonal Gates (Normal, Dungeon and Demon gates)
- New deco builders:
	- Deco Builder Drow (Adv Deco): 
		- Altar, Dungeon, Houses (Large and Small), Smith, Temple, Wormhole and Ziggurat (4 variations).

### Fixed
- A hostile 'Give Unit To' circle is no longer created at coordinates (0, 0).
- -control/uncontrol commands are now easier to use again, since you can more easily spawn a Controller deco.
- Non-decoration structures loaded with a flying height will no longer keep the Enable/Disable Flight ability.
- Adding animation tags to units that have animation tags by default (like Castles or Guard Towers) with the -tag command now works correctly. These units are now also correctly loaded with the Save System.
- All decorations now have the L hotkey instead of the F hotkey. This avoids any hotkey conflicts with decoration QoL abilities.
- Some hero abilities no longer deal double damage. To compensate, Carrion Burst and Will of the Tribunal have been buffed.
- Angel of Creation can no longer be loaded into the game.

### Changed
- Structures can now have their flying height set with commands. Decorations will automatically cast Enable Flight when their flying height is changed.
- Dark Summoning (from the item in the Titan Teleportation Solutions shop) no longer clusters units.
- Heroes no longer have to learn default wc3 hero abilities. All heroes spawn with their hero abilities automatically learned.
- Overhauled hotkeys for hero abilties. Ability hotkeys are not separated by their targeting type (target, point, circle), functionality (instant, buff, debuff) and casting form (instant, channeled, delayed). Hero abilities now consistenly show their hotkey between brackets after the ability name. Hopefully this will make it so creating heroes is more streamlined and allow for more fun to use heroes.
- Added many custom icons for abilities. *Developer comments: while I personally am against adding icons, I can understant that they add value to many users, and can help immersion. To this crowd, I consider that the most valuable icons to add would be ability and hero icons. For now, only ability icons will be added, and only to avoid icon conflicts for generic abilities. For unique hero abilities (such as Tyral's WotT), the icons shall either be already imported for other custom abilities or default wc3 icons.*
- Improved icons for many decorations and units. Imported custom icons for hero attributes (mainly for the -makehero command).
- Changed Sargera's animation names to make more animations available. Check out his tooltip!

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
