#Jannine was here! 
extends Node2D

func _ready() -> void:
	await origin.ready
	greyscale_image()
	pass


@onready var origin : Node2D = $".."

func greyscale_image():
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
			image.set_pixel(x, y, Color(1.0,1.0,1.0,1.0) * image_noise.get_pixel(x,y) * image_noise.get_pixel(x,y))
	var texture = ImageTexture.create_from_image(image)
	var sprite = Sprite2D.new()
	sprite.position = Vector2(600,200)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	origin.add_child(sprite)
	
	pass
