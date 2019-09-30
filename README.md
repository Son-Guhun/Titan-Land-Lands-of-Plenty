[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/F1F61117L) <a href='https://github.com/Son-Guhun/Titan-Land-Lands-of-Plenty/releases' target='_blank'><img height='36' style='border:0px;height:36px;' src='http://www.pngall.com/wp-content/uploads/2/Download-Button-PNG-Download-Image.png' border='0' alt='Download map' /></a>
# Titan Land: Lands of Plenty (TL: LoP)
A WC3 sandbox roleplaying map inspired by those that came before. The main aim of the map is to bridge the gap that has always existed between Titan Land maps and MRP-style maps. In other words, **LoP** aims to provide most of the flexibility os MRP maps, while maintaing the user-friendliness and structure of Titan Land maps. In the future, more elements of MRP-style maps may be added, such as spawners.

## What is Roleplaying?
```
role play
/ˈrōl ˌplā/
verb
gerund or present participle: roleplaying

    1.
    act out or perform the part of a person or character, for example as a technique in training or psychotherapy.
```
This is a map about imagining your own characters and playing them out in an interactive and free-form world with other players. To achieve this, the map not only offers a large amount of custom models, but it also provides functionalities to edit units and decorations to fit your needs, such as adjusting their size, color, rotation and more.

## For Developers:

If you are a map developer, and are interested in building or extending **Titan Land: Lands of Plenty**, you can follow the steps below.

### Builder Script:

Titan Land LoP is developed using both external tools and the World Editor. Having a huge amount of imported files in a map can cause the creation of the MPQ file to be pretty slow, and thus cause testing to be pretty slow as well (both with the editor and external tools).

Because of this, a Python 3 builder script is used to facilitate the saving and testing process of development. The builder script copies all files from the 'release' folder into a folder called 'development'. It does not, however, copy resource files. This development folder, therefore, is also a LNI map, and can be converted into OBJ or SLK as such. This conversion is much faster than converting the release folder.


### Editing Routine

pull() => Creates the development folder (or updates it, if you have directly made changes in the release folder)

build('development') = > Creates the OBJ file of the development folder.

open_with_editor() => Opens the OBJ development map in the World Editor.

// Do stuff on the testmap. Don't forget to save.

commit(DEVELOPMENT) = > Creates the LNI folder of the development OBJ file, overwriting the development folder.

push() => Updates the release folder with all the changes made to the development folder.



### Testing
To test the map, using the button in the World Editor is much slower then building the SLK map and running it. Therefore, there are commands to test the map.

#### High-level commands
test_full() => Builds a SLK version of the development OBJ map. Then opens the map in Warcraft III.

build('release') => Builds OBJ version of the release LNI map.

test_full(RELEASE) => Builds SLK version of the release OBJ map. Then opens the map in Warcraft III.


#### Low-level commands

test(version='',build='development') => Version can be an empty string or 'slk'. Build can be 'development' or 'release'.
