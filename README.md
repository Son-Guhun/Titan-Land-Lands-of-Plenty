[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/F1F61117L) <a href='https://discord.gg/FDAMDBS' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://i.imgur.com/YNyTNuw.png' border='0' alt='Join us on Discord' /></a> <a href='https://github.com/Son-Guhun/Titan-Land-Lands-of-Plenty/releases' target='_blank'><img height='36' style='border:0px;height:36px;' src='http://www.pngall.com/wp-content/uploads/2/Download-Button-PNG-Download-Image.png' border='0' alt='Download map' /></a>
# Titan Land: Lands of Plenty (TL: LoP)

[![Version](https://img.shields.io/github/v/release/Son-Guhun/Titan-Land-Lands-Of-Plenty?label=version)](https://github.com/Son-Guhun/Titan-Land-Lands-Of-Plenty/releases)
[![Downloads](https://img.shields.io/github/downloads/Son-Guhun/Titan-Land-Lands-Of-Plenty/total.svg)](https://github.com/Son-Guhun/Titan-Land-Lands-Of-Plenty/releases)
[![commit-monthly](https://img.shields.io/github/commit-activity/m/Son-Guhun/Titan-Land-Lands-of-Plenty?color=purple)](https://github.com/Son-Guhun/Titan-Land-Lands-of-Plenty/pulse)
[![commit-yearly](https://img.shields.io/github/commit-activity/y/Son-Guhun/Titan-Land-Lands-of-Plenty?color=purple&label=%20)](https://github.com/Son-Guhun/Titan-Land-Lands-of-Plenty/pulse)
[![Donate](https://img.shields.io/badge/donate-$$$-yellow.svg)](https://ko-fi.com/F1F61117L)

A WC3 sandbox roleplaying map inspired by those that came before. The main aim of the map is to bridge the gap that has always existed between Titan Land maps and MRP-style maps. In other words, **LoP** aims to provide most of the flexibility os MRP maps, while maintaing the user-friendliness and structure of Titan Land maps. In the future, more elements of MRP-style maps may be added, such as spawners.

## What is Roleplaying?
```
role play
/ˈrōl ˌplā/
verb
gerund or present participle: roleplaying

    1.
    act out or perform the part of a person or character.
```
This is a map about imagining your own characters and playing them out in an interactive and free-form world with other players. To achieve this, the map not only offers a large amount of custom models, but it also provides functionalities to edit units and decorations to fit your needs, such as adjusting their size, color, rotation and more.

## For Developers:

If you are a map developer, and are interested in building or extending **Titan Land: Lands of Plenty**, you can follow the steps below. Alternatively, if you want to create your own map, you can just grab the latest unprotected version from the releases page.

### What you will need:
- [W3x2Lni](https://www.hiveworkshop.com/threads/w3x2lni-v2-5-2.305201/)
- [WEX](https://www.hiveworkshop.com/threads/sharpcraft-world-editor-extended-bundle.292127/)
- Warcraft III version that works with WEX
- Python 3

### Builder Script:

Titan Land LoP is developed using both external tools and the World Editor. Having a huge amount of imported files in a map can cause the creation of the MPQ file to be pretty slow, and thus cause testing to be pretty slow as well (both with the editor and external tools).

Because of this, a Python 3 builder script is used to facilitate the saving and testing process of development. The builder script copies all files from the 'release' folder into a folder called 'development'. It does not, however, copy resource files. This development folder, therefore, is also a LNI map, and can be converted into OBJ or SLK as such. This conversion is much faster than converting the release folder.

### Setting up:
- Clone the repository to your computer.
- Execute the builder script using an interactive python console and then call the following function: **generate_config()**.
- A file called config.ini will be created in the directory. Set the following values:
```
    [paths]
    w2l = path_to_w2l.exe (in your w3x2lni folder)
    war3 = path to Warcraft III.exe (in your current patch's Warcraft III directory)
    worldedit = path to World Editor Extended.exe (in your Sharpcraft World Editor Extended folder)
```
- Restart the builder script in interactive mode. Type **pull()** to populate your development folder.
- Type **build('development')** to create the development.w3x map.
- Type **open_with_editor()** to open the map in your Sharpcraft editor.
- Done!

### Editing Routine

pull() => Creates the development folder (or updates it, if you have directly made changes in the release folder)

build('development') = > Creates the OBJ file of the development folder.

open_with_editor() => Opens the OBJ development map in the World Editor.

// Do stuff on the testmap. Don't forget to save.

commit(DEVELOPMENT) = > Creates the LNI folder of the development OBJ file, overwriting the development folder.

push_all() => Updates the release folder with all the changes made to the development folder.



### Testing
To test the map, using the button in the World Editor is much slower then building the SLK map and running it. Therefore, there are commands to test the map.

#### High-level commands
test_full() => Builds a SLK version of the development OBJ map. Then opens the map in Warcraft III.

build('release') => Builds OBJ version of the release LNI map.

test_full(RELEASE) => Builds SLK version of the release OBJ map. Then opens the map in Warcraft III.


#### Low-level commands

test(version='',build='development') => Version can be an empty string or 'slk'. Build can be 'development' or 'release'.
test_map(path='development_slk.w3x') => Opens a map using the current Warcraft III version.

## Credits
[Eqilux-](https://www.reddit.com/user/Eqilux-/): Join discord button.
