# Titan Land: Lands of Plenty (TL: LoP)
A WC3 sandbox roleplaying map inspired by those that came before.


Using the builder:



Titan Land LoP is developed using both external tools and the World Editor. Having a huge amount of imported files in a map can cause the creation of the MPQ file to be pretty slow, and thus cause testing to be pretty slow as well (both with the editor and external tools).

Because of this, the builder script copies all files from the 'release' folder into a folder called 'development'. It does not, however, copy resource files. This development folder, therefore, is also a LNI map, and can be converted into OBJ or SLK as such. This conversion is much faster than converting the release folder.


Command routine:

pull() => Creates the development folder (or updates it, if you have directly made changes in the release folder)

build(DEVELOPMENT) = > Creates the obj file of the development folder.

// Do stuff on the testmap

commit(DEVELOPMENT) = > Creates the slk file of the development OBJ file, overwriting the development folder.

push() => Updates the release folder with all the changes made to the development folder.
