# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Major versions are created arbitrarily.
Minor versions indicate addition of a very important new feature or a new race or a new deco builder.
Patch versions indicate bugfixes. Some command aliases or arguments may be added in a patch version. New units for an existing race can be adde in a patch version.

## [Unreleased]

### Added:
- New commands:
	- -time => Allows the Titan to change the in-game time of day.
	- -rotate => Allows you to set the angle of rotation for the Rotate ability of decorations.
	- -controller => Allows you to spawn a Controller deco (was removed from -decos command in version 1.0.0).
- New command arguments:
	- -seln/sele rect => Will now select your Rect Generators.
	- 'mind (number/color) => Will now work as if you had ordered the Power: Mind unit to right-click your selected units.

### Fixed
	- A hostile 'Give Unit To' circle is no longer created at coordinates (0, 0).
	- -control/uncontrol commands are now easier to use again, since you can more easily spawn a Controller deco.
	- Non-decoration structures loaded with a flying height will no longer keep the Enable/Disable Flight ability.
	- Adding animation tags to units that have animation tags by default (like Castles or Guard Towers) with the -tag command now works correctly. These units are now also correctly loaded with the Save System.

### Changed
	- Structures can now have their flying height set with commands. Decorations will automatically cast Enable Flight when their flying height is changed.


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
