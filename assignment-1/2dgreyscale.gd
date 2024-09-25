extends Node3D


var st = SurfaceTool.new()


func _ready():
	var land = MeshInstance3D.new()
	
	# start of making geometry
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var count : Array[int] = [0]
	
	_quad(count)
	
	st.generate_normals()
	var mesh = st.commit()
	land.mesh = mesh
	var material = StandardMaterial3D.new()
	var noise = FastNoiseLite.new()
	var img = noise.get_image(256, 256)
	material.albedo_texture = ImageTexture.create_from_image(img)
	land.set_surface_override_material(0, material)
	add_child(land)
	pass


func _quad(count : Array[int]):
	# surface coordinate UVs have v-axis (y-axis) positive in down direction
	# must match each UV coordinate in order with vertex coordinates
	st.set_uv( Vector2(0, 1) )
	st.add_vertex( Vector3(0, 0, 0) )
	count[0] += 1
	st.set_uv( Vector2(1, 1) )
	st.add_vertex( Vector3(1, 0, 0) )
	count[0] += 1
	st.set_uv( Vector2(1, 0) )
	st.add_vertex( Vector3(1, 0, 1) )
	count[0] += 1
	st.set_uv( Vector2(0, 0) )
	st.add_vertex( Vector3(0, 0, 1) )
	count[0] += 1
	
	# list triangle vertex indices with the trianlge 
	#   facing toward camera so that it has vertices labeled here given in clockwise order
	st.add_index(count[0] - 4)
	st.add_index(count[0] - 3)
	st.add_index(count[0] - 2)
	
	st.add_index(count[0] - 4)
	st.add_index(count[0] - 2)
	st.add_index(count[0] - 1)
	
	pass
