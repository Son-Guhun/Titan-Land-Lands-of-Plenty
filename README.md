# Titan Land: Lands of Plenty (TL: LoP)
A WC3 sandbox roleplaying map inspired by those that came before.


Using the builder:



Titan Land LoP is developed using both external tools and the World Editor. Having a huge amount of imported files in a map can cause the creation of the MPQ file to be pretty slow, and thus cause testing to be pretty slow as well (both with the editor and external tools).

Because of this, the builder script copies all files from the 'release' folder into a folder called 'development'. It does not, however, copy resource files. This development folder, therefore, is also a LNI map, and can be converted into OBJ or SLK as such. This conversion is much faster than converting the release folder.


## Editing Routine

pull() => Creates the development folder (or updates it, if you have directly made changes in the release folder)

build('development') = > Creates the OBJ file of the development folder.

open_with_editor() => Opens the OBJ development map in the World Editor.

// Do stuff on the testmap. Don't forget to save.

commit(DEVELOPMENT) = > Creates the LNI folder of the development OBJ file, overwriting the development folder.

push() => Updates the release folder with all the changes made to the development folder.



## Testing
To test the map, using the button in the World Editor is much slower then building the SLK map and running it. Therefore, there are commands to test the map.

### High-level commands
test_full() => Builds a SLK version of the development OBJ map. Then opens the map in Warcraft III.

build('release') => Builds OBJ version of the release LNI map.

test_full(RELEASE) => Builds SLK version of the release OBJ map. Then opens the map in Warcraft III.


### Low-level commands

test(version='',build='development') => Version can be an empty string or 'slk'. Build can be 'development' or 'release'.
