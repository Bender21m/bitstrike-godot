extends Node3D

# Called by enemy_spawner or main scene to set up the world
# This adds visual polish - textured walls, floor details, lighting

func _ready():
	# Apply textures to existing walls
	for child in get_parent().get_children():
		if child is StaticBody3D and child.name.begins_with("Wall"):
			for mesh_child in child.get_children():
				if mesh_child is MeshInstance3D:
					var mat = StandardMaterial3D.new()
					mat.albedo_color = Color(0.55, 0.32, 0.08)
					mat.roughness = 0.85
					mat.metallic = 0.1
					# Fake brick pattern via UV
					mat.uv1_scale = Vector3(2, 2, 2)
					mesh_child.set_surface_override_material(0, mat)
	
	# Add some crates for cover
	_add_crate(Vector3(5, 0, 5), Vector3(0.8, 0.8, 0.8))
	_add_crate(Vector3(18, 0, 18), Vector3(1.0, 0.6, 0.6))
	_add_crate(Vector3(12, 0, 8), Vector3(0.6, 1.2, 0.6))
	_add_crate(Vector3(8, 0, 15), Vector3(0.8, 0.8, 0.8))
	_add_crate(Vector3(16, 0, 10), Vector3(1.0, 0.5, 0.8))
	
	# Add some barrels
	_add_barrel(Vector3(10, 0, 5))
	_add_barrel(Vector3(15, 0, 20))
	_add_barrel(Vector3(4, 0, 12))
	
	# Add bitcoin pickup markers (glowing orange)
	for i in range(5):
		var pos = Vector3(randf_range(3, 21), 0.5, randf_range(3, 21))
		_add_bitcoin_pickup(pos)

func _add_crate(pos: Vector3, size: Vector3):
	var body = StaticBody3D.new()
	body.name = "Crate"
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.35, 0.2)
	mat.roughness = 0.9
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, size.y / 2, 0)
	get_parent().add_child(body)

func _add_barrel(pos: Vector3):
	var body = StaticBody3D.new()
	body.name = "Barrel"
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.3
	cyl.bottom_radius = 0.3
	cyl.height = 0.9
	cyl.radial_segments = 16
	mesh.mesh = cyl
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.35, 0.3)
	mat.metallic = 0.4
	mat.roughness = 0.6
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 0.9
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, 0.45, 0)
	get_parent().add_child(body)

func _add_bitcoin_pickup(pos: Vector3):
	var pickup = Area3D.new()
	pickup.name = "BitcoinPickup"
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.2
	cyl.bottom_radius = 0.2
	cyl.height = 0.04
	cyl.radial_segments = 24
	mesh.mesh = cyl
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.97, 0.58, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(0.97, 0.58, 0.1)
	mat.emission_energy_multiplier = 0.5
	mat.metallic = 0.8
	mat.roughness = 0.3
	mesh.set_surface_override_material(0, mat)
	pickup.add_child(mesh)
	
	# Glow light
	var light = OmniLight3D.new()
	light.light_color = Color(0.97, 0.58, 0.1)
	light.light_energy = 0.4
	light.omni_range = 3.0
	pickup.add_child(light)
	
	# Collision for pickup detection
	var col = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	col.shape = shape
	pickup.add_child(col)
	
	pickup.position = pos
	pickup.set_meta("sats", randi_range(1000, 5000))
	get_parent().add_child(pickup)

func _process(delta):
	# Rotate bitcoin pickups
	for child in get_parent().get_children():
		if child.name == "BitcoinPickup":
			child.rotation.y += delta * 2
			child.position.y = 0.5 + sin(Time.get_ticks_msec() * 0.003) * 0.1
