extends Node3D

var st = SurfaceTool.new()

func _ready() -> void:
	var landscape = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.set_uv(Vector2(0,0))
	st.add_vertex(Vector3(0,0,0))
	st.set_uv(Vector2(0,1))
	st.add_vertex(Vector3(0,0,1))
	st.set_uv(Vector2(1,1))
	st.add_vertex(Vector3(1,0,1))
	st.set_uv(Vector2(1,0))
	st.add_vertex(Vector3(1,0,0))
	
	st.add_index(0)
	st.add_index(1)
	st.add_index(2)
	
	st.add_index(0)
	st.add_index(2)
	st.add_index(3)
	
	st.generate_normals()
	var mesh = st.commit()
	landscape.mesh = mesh
	
	#var img = greyscale_image() #Trying to get the image generation from a different function
	
	#Just putting this here until we can figure out how to return the img in a function
	var cell_noise = FastNoiseLite.new()
	cell_noise.set_noise_type(FastNoiseLite.TYPE_CELLULAR)
	cell_noise.noise_type = 4
	cell_noise.fractal_octaves = 6
	cell_noise.frequency = 0.04
	cell_noise.cellular_jitter = 1
	cell_noise.cellular_distance_function = 2
	cell_noise.cellular_return_type = 2
	var image_noise = cell_noise.get_seamless_image(200,200)
	var image = Image.create(200, 200, false, Image.FORMAT_RGB8)
	for x in range (200):
		for y in range(200):
			#Trying to change the black / white ratio in the image and give highlights
			## Color(r,b,g,a) - r = red, b = blue, g= green, a = alpha
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0) * image_noise.get_pixel(x,y) * image_noise.get_pixel(x,y))
	
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(image)
	landscape.set_surface_override_material(0, mat)
	add_child(landscape)
	
	pass

#### Creates a new "FastNoiseLite" object called cell_noise and defines the shape of the object
#### Then, colors the object - in this case, black and white
#### lastly, generates a new 2D sprite in the viewable window


#Ignore this function for now, if we get the rest working, then I'll try to return the image
#through the function
func greyscale_image():
	var cell_noise = FastNoiseLite.new()
	cell_noise.set_noise_type(FastNoiseLite.TYPE_CELLULAR)
	cell_noise.noise_type = 4
	cell_noise.fractal_octaves = 6
	cell_noise.frequency = 0.04
	cell_noise.cellular_jitter = 1
	cell_noise.cellular_distance_function = 2
	cell_noise.cellular_return_type = 2
	
	## "get_seamless_image" - Returns an Image object containing seamless 2D noise values.
	var image_noise = cell_noise.get_seamless_image(200,200)
	
	#### Colors the object - in this case, black and white
	var image = Image.create(200, 200, false, Image.FORMAT_RGB8)
	for x in range (200):
		for y in range(200):
			#Trying to change the black / white ratio in the image and give highlights
			## Color(r,b,g,a) - r = red, b = blue, g= green, a = alpha
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0) * image_noise.get_pixel(x,y) * image_noise.get_pixel(x,y))
	
	
	var texture = ImageTexture.create_from_image(image)
	return texture
	#### Generates a new sprite in the viewable window
	#var sprite = Sprite2D.new()
	#sprite.position = Vector2(600,200)
	#sprite.texture = texture
	#sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	#origin.add_child(sprite)
	
pass
