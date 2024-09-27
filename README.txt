Kaiya Wangler (MidnightWolfe): Created greyscale image used for imaging in landscape and material / mesh. Put greyscale image into a 3D space as one square (1 quad) using 2 triangles, and is able to be displayed.
			       Created repo and Kanban board. Created some global variables, added additional comments, cleaned up code (deleted unused code).
Liam / Markus 		     : Created pixel color to height convertion function and implemented inside existing code. 
			       moved some vars to global for access in function. Moved loop implementing _quad to be after the loop where image is 
                               created as it needed the image file to get the pixels for the height.
			     
			     
Ryan			     : Quad function and UV-slice function, some scene changes to camera as well.
Jannine Gemmell 	     : Changed the layout of the code for better readablity.
			       Created the global variable IMAGE_SIZE_X and IMAGE_SIZE_Y for declaring the size of the image (makes it easier to change image size now)
			       Fixed bug in the _GetHeight() function involving the get_pixel function trying to colour "outside the lines"
