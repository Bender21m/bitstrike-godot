extends Node3D

func _ready():
	# Add server racks (mining rigs)
	var rack_positions = [
		Vector3(4, 0, 6), Vector3(4, 0, 8), Vector3(4, 0, 10),
		Vector3(20, 0, 6), Vector3(20, 0, 8), Vector3(20, 0, 10),
		Vector3(10, 0, 16), Vector3(12, 0, 16), Vector3(14, 0, 16),
	]
	for pos in rack_positions:
		_add_server_rack(pos)
	
	# Crates (equipment)
	_add_crate(Vector3(5, 0, 5), Vector3(0.8, 0.8, 0.8))
	_add_crate(Vector3(18, 0, 18), Vector3(1.0, 0.6, 0.6))
	_add_crate(Vector3(12, 0, 3), Vector3(0.6, 0.8, 0.6))
	_add_crate(Vector3(8, 0, 20), Vector3(0.8, 0.5, 0.8))
	
	# Barrels (coolant?)
	_add_barrel(Vector3(15, 0, 5))
	_add_barrel(Vector3(3, 0, 15))
	
	# Bitcoin pickups
	for i in range(5):
		_add_bitcoin_pickup(Vector3(randf_range(3, 21), 0.8, randf_range(3, 21)))

func _add_server_rack(pos: Vector3):
	var body = StaticBody3D.new()
	body.name = "ServerRack"
	# Main rack body
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.6, 2.0, 0.8)
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.15, 0.18)
	mat.metallic = 0.6
	mat.roughness = 0.4
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	
	# LED lights on front (green = mining)
	for i in range(4):
		var led = MeshInstance3D.new()
		var led_mesh = BoxMesh.new()
		led_mesh.size = Vector3(0.02, 0.02, 0.001)
		led.mesh = led_mesh
		var led_mat = StandardMaterial3D.new()
		led_mat.albedo_color = Color(0, 1, 0)
		led_mat.emission_enabled = true
		led_mat.emission = Color(0, 1, 0)
		led_mat.emission_energy_multiplier = 2.0
		led.set_surface_override_material(0, led_mat)
		led.position = Vector3(-0.15 + i * 0.1, 0.3 + randf() * 0.4, -0.41)
		body.add_child(led)
	
	# Small orange light (status)
	var status_light = OmniLight3D.new()
	status_light.light_color = Color(0, 0.8, 0)
	status_light.light_energy = 0.15
	status_light.omni_range = 1.5
	status_light.position = Vector3(0, 0.5, -0.5)
	body.add_child(status_light)
	
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.6, 2.0, 0.8)
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, 1.0, 0)
	get_parent().add_child(body)

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
	mat.albedo_color = Color(0.2, 0.3, 0.25)
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
	var light = OmniLight3D.new()
	light.light_color = Color(0.97, 0.58, 0.1)
	light.light_energy = 0.4
	light.omni_range = 3.0
	pickup.add_child(light)
	var col = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	col.shape = shape
	pickup.add_child(col)
	pickup.position = pos
	pickup.set_meta("sats", randi_range(1000, 5000))
	get_parent().add_child(pickup)

func _process(delta):
	for child in get_parent().get_children():
		if child.name == "BitcoinPickup":
			child.rotation.y += delta * 2
			child.position.y = 0.8 + sin(Time.get_ticks_msec() * 0.003) * 0.1
