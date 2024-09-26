#Hello, Ryan here, adding in my UVMAP Functions and doing some commenting on the code :D
#Hi, Kaiya here, adjusted / cleaned up some of the code and added more comments (off of what Ryan did)

extends Node3D

###Global variables
var landscape = MeshInstance3D.new() #Mesh for the landscape used to place the FastNoiseLite image
var st = SurfaceTool.new()
var image : Image
var quadsHorizontal : int
var quadsVertical : int

func _ready() -> void:
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#This is the settings for the function
	var quadCount : Array[int] = [0]
	#Number of quads to do in the horizontal direction
	quadsHorizontal = 20
	#Num of vertical quads
	quadsVertical = 20
	#Make a quad for each spot
	
	## Creating the Cellular Image below
	## Creates a new "FastNoiseLite" object called cell_noise and defines the shape of the object
	## Then, colors the object - in this case, black and white
	var cell_noise = FastNoiseLite.new()
	cell_noise.set_noise_type(FastNoiseLite.TYPE_CELLULAR)
	cell_noise.noise_type = 4
	cell_noise.fractal_octaves = 6
	cell_noise.frequency = 0.04
	cell_noise.cellular_jitter = 1
	cell_noise.cellular_distance_function = 2
	cell_noise.cellular_return_type = 2
	var image_noise = cell_noise.get_seamless_image(200,200)
	image = Image.create(200, 200, false, Image.FORMAT_RGBA8) #Changed from RGB8 to RGBA8

	for x in range (200):
		for y in range(200):
			#Trying to change the black / white ratio in the image and give highlights
			## Color(r,b,g,a) - r = red, b = blue, g= green, a = alpha
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0) * image_noise.get_pixel(x,y) * image_noise.get_pixel(x,y))
		
	for i in quadsHorizontal:
		for j in quadsVertical:
			_quad(Vector3(i,0,j), quadCount, quadsHorizontal, quadsVertical, i, j)
	
	st.generate_normals()
	var mesh = st.commit()
	landscape.mesh = mesh

	

	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(image)
	landscape.set_surface_override_material(0, mat)
	add_child(landscape)
	
	pass


#More quad generation functions
### Takes in a location (Point), count (For allowing multiple quads), numHorz/Vert (Number of quads in that direction)
### qsHorz/Vert (The current index of the quad.
### All these together allow us to compute which part of the uv to map it to
func _quad(
	point: Vector3, 
	count: Array[int],
	numHorz: int,
	numVert: int,
	qsHorz: int,
	qsVert: int):
		
		#Okay so we need to figure out some stuff to make this work
		#Lets imagine a 2x2, 4 vertexs each
		#[0.0,0.0][0.3,0.0]|[0.6,0.0][1.0,0.0]
		#[0.0,0.3][0.3,0.3]|[0.6,0.3][1.0,0.3]
		#------------------------------------
		#[0.0,0.6][0.3,0.6]|[0.6,0.6][1.0,0.6]
		#[0.0,1.0][0.3,1.0]|[0.6,1.0][1.0,1.0]
		
		#Each of these quads has 4 values, up/down & left/right pairs.
		#The upper values are what percent of the numHorizontal or num Vertical the respective quadsVertical or QuadsHorizontal is
		#The lower values are the values of the upper - 1/numQuadsDirection
		
		#By generating these 4 numbers we can then create the quad with correct uv mapping
		
	var upperHorz = _generateUVSlice(true, qsHorz, numHorz)
	var lowerHorz = _generateUVSlice(false, qsHorz, numHorz)
	var upperVert = _generateUVSlice(true, qsVert, numVert)
	var lowerVert = _generateUVSlice(false, qsVert, numVert)
	
	#Here we are setting the values of the quads corners to match the generated values from the _generateUVSlice
	#What is cool about this is it splits the uv map into sections the size of a quad
	#Imagine having a stencil of a square and putting it over an image, by moving the stencil you can show different things
	
	#Added height to the y axis by using the _getheight function. Had to add 1 to the 2-4th passes to get the corners of quadrent as point only stores 0,0
	#print(point, " : ",  _getheight(point.x,point.y),  " : ",  image.get_pixel(point.x,point.y)," : x,y", point.x,point.y)
	
	st.set_uv(Vector2(lowerHorz,lowerVert))
	st.add_vertex(point + Vector3(0,_getheight(point.x,point.z),0))
	count[0] += 1
	
	st.set_uv(Vector2(upperHorz,lowerVert))
	st.add_vertex(point + Vector3(1,_getheight(point.x+1,point.z),0))
	count[0] += 1
	
	st.set_uv(Vector2(upperHorz,upperVert))
	st.add_vertex(point + Vector3(1,_getheight(point.x+1,point.z+1),1))
	count[0] += 1
	
	st.set_uv(Vector2(lowerHorz,upperVert))
	st.add_vertex(point + Vector3(0,_getheight(point.x,point.z+1),1))
	count[0] += 1
	
	
	#Assemble the quad from the vertexs
	st.add_index(count[0] - 4)
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4)
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)
	
	
### This one is super cool, it is pretty effective at doing it's job
### So it takes in a boolean for whether you're trying to get the upper or lower uv value of the quad
### It also takes in the current index of the quad in the direction were looking at (Horz or Vert)
### Finally it takes in the length(count) of quads that make up that direction
func _generateUVSlice(
	isUpperValue: bool, 
	indexOfQuad: int, 
	sizeOfQuadDirection: int) -> float:
		#The upper values are what percent of the numHorizontal or num Vertical the respective quadsVertical or QuadsHorizontal is
		#The lower values are the values of the upper - 1/numQuadsDirection notice I made it 1.0 to convert to float
		
		#I'm running getPercent at index+1 to account for starting index at 0, when starting at 0 it automatically
		# gives the lower bound as the upperbound due to multiplying by 0. 
		#it's important to note that this function first computes the upper value then finds the size of a quad to subtract back to get lower
	var value : float = _getPercent(indexOfQuad+1, sizeOfQuadDirection)
	#If we need the lower value then do the following to the upper value
	#1.0/sizeOfQuadDirection is the portion of 1.0 that represents the quad's directionalSize
	#So if we have 3 quads each segment works out to 0.33 of 1.0
	if !isUpperValue:
		value = value - (1.0/sizeOfQuadDirection)
	return value
	
#Simple function to return a percentage as a decimal float between 0.0 and 1.0 (Hopefully) Idk what happens to numbers above 1 with this code as it doesn't really come up
func _getPercent(numerator : float, denominator : float) -> float:
	if denominator == 0:
		return 0.0
	var percent : float = (numerator/denominator)
	return percent
#Returns the height of a pixel, from an image, based on its red channel.
#takes the size of the image and divides it by the number of quadrents being generated to get the correct pixel
#multiplies it by the quardrent, from the _quad func, to return the proper x,y height relitive to the quadrent
func _getheight(x : float,y : float) -> float:
	return image.get_pixel(x*(200/quadsHorizontal),y*(200/quadsVertical)).r
