extends Node3D

# Map 2: Tropical Island Compound
# Inspired by: private island, shady dealings, offshore exchange
# Larger than mining facility, outdoor/indoor mix
# 40x40 grid (vs 24x24 mining facility)

var mat_sand: StandardMaterial3D
var mat_concrete: StandardMaterial3D
var mat_wood: StandardMaterial3D
var mat_metal: StandardMaterial3D
var mat_palm_trunk: StandardMaterial3D
var mat_palm_leaf: StandardMaterial3D
var mat_water: StandardMaterial3D
var mat_tile: StandardMaterial3D
var mat_glass: StandardMaterial3D

func _ready():
	_create_materials()
	_build_terrain()
	_build_main_compound()
	_build_dock_area()
	_build_server_bunker()
	_build_watchtowers()
	_build_palm_trees()
	_build_cover()
	_build_lighting()
	_build_bitcoin_pickups()

func _create_materials():
	mat_sand = StandardMaterial3D.new()
	mat_sand.albedo_color = Color(0.76, 0.7, 0.5)
	mat_sand.roughness = 0.95
	
	mat_concrete = StandardMaterial3D.new()
	mat_concrete.albedo_color = Color(0.75, 0.72, 0.68)
	mat_concrete.roughness = 0.85
	
	mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.5, 0.35, 0.2)
	mat_wood.roughness = 0.9
	
	mat_metal = StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.3, 0.32, 0.35)
	mat_metal.roughness = 0.5
	mat_metal.metallic = 0.5
	
	mat_palm_trunk = StandardMaterial3D.new()
	mat_palm_trunk.albedo_color = Color(0.45, 0.35, 0.2)
	mat_palm_trunk.roughness = 0.9
	
	mat_palm_leaf = StandardMaterial3D.new()
	mat_palm_leaf.albedo_color = Color(0.15, 0.45, 0.1)
	mat_palm_leaf.roughness = 0.8
	
	mat_water = StandardMaterial3D.new()
	mat_water.albedo_color = Color(0.1, 0.3, 0.5, 0.7)
	mat_water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_water.roughness = 0.1
	mat_water.metallic = 0.3
	
	mat_tile = StandardMaterial3D.new()
	mat_tile.albedo_color = Color(0.8, 0.78, 0.7)
	mat_tile.roughness = 0.6
	
	mat_glass = StandardMaterial3D.new()
	mat_glass.albedo_color = Color(0.5, 0.7, 0.9, 0.3)
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_glass.metallic = 0.2
	mat_glass.roughness = 0.1

func _build_terrain():
	var parent = get_parent()
	
	# Sand beach (outer ring, lower)
	_add_static(parent, Vector3(20, -0.3, 20), Vector3(44, 0.1, 44), mat_sand)
	
	# Main island platform (raised)
	_add_static(parent, Vector3(20, 0, 20), Vector3(32, 0.6, 32), mat_sand)
	
	# Water plane surrounding
	var water = MeshInstance3D.new()
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(60, 60)
	water.mesh = water_mesh
	water.set_surface_override_material(0, mat_water)
	water.position = Vector3(20, -0.5, 20)
	parent.add_child(water)

func _build_main_compound():
	var parent = get_parent()
	# Central villa / exchange building
	
	# Main building shell
	# Front wall
	_add_wall(parent, Vector3(20, 0, 12), Vector3(12, 4, 0.3), mat_concrete)
	# Back wall
	_add_wall(parent, Vector3(20, 0, 22), Vector3(12, 4, 0.3), mat_concrete)
	# Left wall
	_add_wall(parent, Vector3(14, 0, 17), Vector3(0.3, 4, 10), mat_concrete)
	# Right wall
	_add_wall(parent, Vector3(26, 0, 17), Vector3(0.3, 4, 10), mat_concrete)
	
	# Interior walls (creating rooms)
	# Reception/lobby divider
	_add_wall(parent, Vector3(20, 0, 15), Vector3(8, 3, 0.2), mat_concrete)
	# Side office left
	_add_wall(parent, Vector3(17, 0, 18.5), Vector3(0.2, 3, 5), mat_concrete)
	# Side office right
	_add_wall(parent, Vector3(23, 0, 18.5), Vector3(0.2, 3, 5), mat_concrete)
	
	# Floor (tiled)
	_add_static(parent, Vector3(20, 0.3, 17), Vector3(12, 0.05, 10), mat_tile)
	
	# Roof
	_add_static(parent, Vector3(20, 4, 17), Vector3(13, 0.15, 11), mat_concrete)
	
	# Desks / furniture
	_add_static(parent, Vector3(16, 0.5, 14), Vector3(1.5, 0.8, 0.6), mat_wood)
	_add_static(parent, Vector3(24, 0.5, 14), Vector3(1.5, 0.8, 0.6), mat_wood)
	_add_static(parent, Vector3(20, 0.5, 20), Vector3(2, 0.8, 0.8), mat_wood)
	
	# Exchange trading screens (back room)
	for i in range(4):
		var screen = MeshInstance3D.new()
		var sm = BoxMesh.new()
		sm.size = Vector3(0.8, 0.5, 0.05)
		screen.mesh = sm
		var smat = StandardMaterial3D.new()
		smat.albedo_color = Color(0.05, 0.15, 0.05)
		smat.emission_enabled = true
		smat.emission = Color(0, 0.6, 0)
		smat.emission_energy_multiplier = 0.5
		screen.set_surface_override_material(0, smat)
		screen.position = Vector3(15.5 + i * 3, 1.8, 21.8)
		parent.add_child(screen)

func _build_dock_area():
	var parent = get_parent()
	
	# Wooden dock extending into water
	_add_static(parent, Vector3(8, -0.1, 20), Vector3(6, 0.15, 3), mat_wood)
	_add_static(parent, Vector3(5, -0.1, 20), Vector3(2, 0.15, 4), mat_wood)
	
	# Dock posts
	for i in range(4):
		_add_cylinder(parent, Vector3(5 + i * 2, -1, 18.5), 0.1, 2.0, mat_wood)
		_add_cylinder(parent, Vector3(5 + i * 2, -1, 21.5), 0.1, 2.0, mat_wood)
	
	# Cargo containers on dock
	_add_static(parent, Vector3(7, 0.6, 19), Vector3(2, 1.2, 1), mat_metal)
	_add_static(parent, Vector3(7, 0.6, 21), Vector3(2, 1.2, 1), mat_metal)
	
	# Boat (simple box shape)
	_add_static(parent, Vector3(3, -0.2, 20), Vector3(3, 0.8, 1.5), mat_wood)

func _build_server_bunker():
	var parent = get_parent()
	
	# Underground bunker — hack site B
	# Entrance stairs
	for i in range(4):
		_add_static(parent, Vector3(30, -0.5 * (i + 1), 20 + i * 0.8), Vector3(2, 0.5, 0.8), mat_concrete)
	
	# Bunker room (underground)
	_add_static(parent, Vector3(32, -2.5, 24), Vector3(6, 0.15, 6), mat_concrete)  # Floor
	_add_wall(parent, Vector3(32, -2.3, 21), Vector3(6, 2.5, 0.3), mat_concrete)  # Front wall
	_add_wall(parent, Vector3(32, -2.3, 27), Vector3(6, 2.5, 0.3), mat_concrete)  # Back wall
	_add_wall(parent, Vector3(29, -2.3, 24), Vector3(0.3, 2.5, 6), mat_concrete)  # Left
	_add_wall(parent, Vector3(35, -2.3, 24), Vector3(0.3, 2.5, 6), mat_concrete)  # Right
	_add_static(parent, Vector3(32, -0.1, 24), Vector3(6.3, 0.15, 6.3), mat_concrete)  # Ceiling
	
	# Server racks in bunker
	for i in range(3):
		_add_server_rack(parent, Vector3(31 + i * 2, -2.35, 25))
	
	# Red emergency lights
	var red1 = OmniLight3D.new()
	red1.light_color = Color(0.8, 0.1, 0.05)
	red1.light_energy = 0.6
	red1.omni_range = 5.0
	red1.position = Vector3(32, -0.5, 24)
	parent.add_child(red1)

func _build_watchtowers():
	var parent = get_parent()
	
	# Two watchtowers — sniper positions
	for pos in [Vector3(10, 0, 10), Vector3(30, 0, 30)]:
		# Tower legs
		for offset in [Vector3(-0.5, 0, -0.5), Vector3(0.5, 0, -0.5), Vector3(-0.5, 0, 0.5), Vector3(0.5, 0, 0.5)]:
			_add_cylinder(parent, pos + offset + Vector3(0, 2, 0), 0.08, 4.0, mat_wood)
		
		# Platform
		_add_static(parent, pos + Vector3(0, 4, 0), Vector3(2, 0.1, 2), mat_wood)
		
		# Railing
		for side_offset in [Vector3(-1, 4.5, 0), Vector3(1, 4.5, 0), Vector3(0, 4.5, -1), Vector3(0, 4.5, 1)]:
			var rail_size = Vector3(2, 0.8, 0.05) if abs(side_offset.x) > 0.5 else Vector3(0.05, 0.8, 2)
			_add_static(parent, pos + side_offset, rail_size, mat_wood)
		
		# Ladder
		_add_static(parent, pos + Vector3(0.6, 2, -1.1), Vector3(0.5, 4, 0.05), mat_metal)
		for i in range(8):
			_add_static(parent, pos + Vector3(0.6, 0.5 + i * 0.5, -1.1), Vector3(0.4, 0.04, 0.08), mat_metal)

func _build_palm_trees():
	var parent = get_parent()
	
	var positions = [
		Vector3(6, 0, 8), Vector3(8, 0, 30), Vector3(34, 0, 8),
		Vector3(32, 0, 14), Vector3(12, 0, 28), Vector3(28, 0, 28),
		Vector3(6, 0, 16), Vector3(36, 0, 20), Vector3(16, 0, 8),
	]
	
	for pos in positions:
		_add_palm_tree(parent, pos)

func _add_palm_tree(parent: Node, pos: Vector3):
	# Trunk (slightly curved cylinder)
	_add_cylinder(parent, pos + Vector3(0, 2.5, 0), 0.15, 5.0, mat_palm_trunk)
	# Slight lean
	var trunk_lean = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
	
	# Leaf canopy (flat boxes radiating out)
	var top = pos + Vector3(0, 5.2, 0) + trunk_lean
	for i in range(6):
		var angle = i * TAU / 6 + randf() * 0.3
		var leaf = MeshInstance3D.new()
		var leaf_mesh = BoxMesh.new()
		leaf_mesh.size = Vector3(0.4, 0.03, 2.0)
		leaf.mesh = leaf_mesh
		leaf.set_surface_override_material(0, mat_palm_leaf)
		leaf.position = top + Vector3(cos(angle) * 1.0, -0.3, sin(angle) * 1.0)
		leaf.rotation.y = angle
		leaf.rotation.x = 0.3  # Droop
		parent.add_child(leaf)

func _build_cover():
	var parent = get_parent()
	
	# Sandbag positions
	_add_static(parent, Vector3(18, 0.3, 10), Vector3(1.5, 0.6, 0.6), mat_sand)
	_add_static(parent, Vector3(22, 0.3, 10), Vector3(1.5, 0.6, 0.6), mat_sand)
	_add_static(parent, Vector3(12, 0.3, 17), Vector3(0.6, 0.6, 1.2), mat_sand)
	_add_static(parent, Vector3(28, 0.3, 17), Vector3(0.6, 0.6, 1.2), mat_sand)
	
	# Crates near dock
	_add_static(parent, Vector3(9, 0.4, 18), Vector3(0.8, 0.8, 0.8), mat_wood)
	_add_static(parent, Vector3(9.6, 0.3, 19), Vector3(0.6, 0.6, 0.6), mat_wood)
	
	# Wall segments for cover
	_add_static(parent, Vector3(15, 0.5, 25), Vector3(2, 1, 0.3), mat_concrete)
	_add_static(parent, Vector3(25, 0.5, 25), Vector3(2, 1, 0.3), mat_concrete)
	
	# Oil drums near compound
	for pos in [Vector3(13, 0, 13), Vector3(27, 0, 13), Vector3(20, 0, 26)]:
		_add_barrel(parent, pos)

func _build_lighting():
	var parent = get_parent()
	
	# Bright sunny feel
	var sun = DirectionalLight3D.new()
	sun.light_color = Color(1, 0.95, 0.85)
	sun.light_energy = 1.0
	sun.rotation_degrees = Vector3(-45, 30, 0)
	sun.shadow_enabled = true
	parent.add_child(sun)
	
	# Compound interior lights
	for pos in [Vector3(17, 3.5, 14), Vector3(23, 3.5, 14), Vector3(20, 3.5, 19)]:
		var light = OmniLight3D.new()
		light.light_color = Color(1, 0.9, 0.7)
		light.light_energy = 0.8
		light.omni_range = 8.0
		light.position = pos
		parent.add_child(light)
	
	# Dock area lanterns
	var dock_light = OmniLight3D.new()
	dock_light.light_color = Color(0.9, 0.7, 0.3)
	dock_light.light_energy = 0.5
	dock_light.omni_range = 8.0
	dock_light.position = Vector3(7, 3, 20)
	parent.add_child(dock_light)

func _build_bitcoin_pickups():
	var parent = get_parent()
	var positions = [
		Vector3(20, 1.0, 17),    # Compound center
		Vector3(7, 0.5, 20),     # Dock
		Vector3(32, -2.0, 24),   # Bunker (risky)
		Vector3(10, 4.5, 10),    # Watchtower 1
		Vector3(30, 4.5, 30),    # Watchtower 2
	]
	for pos in positions:
		_add_bitcoin_pickup(parent, pos)

# === HELPERS ===

func _add_static(parent: Node, pos: Vector3, size: Vector3, material: StandardMaterial3D):
	var body = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.set_surface_override_material(0, material)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, size.y / 2, 0)
	parent.add_child(body)

func _add_wall(parent: Node, pos: Vector3, size: Vector3, material: StandardMaterial3D):
	_add_static(parent, pos, size, material)

func _add_cylinder(parent: Node, pos: Vector3, radius: float, height: float, material: StandardMaterial3D):
	var body = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = height
	cyl.radial_segments = 8
	mesh.mesh = cyl
	mesh.set_surface_override_material(0, material)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	col.shape = shape
	body.add_child(col)
	body.position = pos
	parent.add_child(body)

func _add_barrel(parent: Node, pos: Vector3):
	var body = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.3
	cyl.bottom_radius = 0.3
	cyl.height = 0.9
	mesh.mesh = cyl
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.15, 0.1)
	mat.roughness = 0.7
	mat.metallic = 0.3
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 0.9
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, 0.45, 0)
	parent.add_child(body)

func _add_server_rack(parent: Node, pos: Vector3):
	var body = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.6, 2.0, 0.8)
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.12, 0.15)
	mat.metallic = 0.6
	mat.roughness = 0.4
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	for i in range(3):
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
		led.position = Vector3(-0.1 + i * 0.1, 0.3 + randf() * 0.3, -0.41)
		body.add_child(led)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.6, 2.0, 0.8)
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, 1.0, 0)
	parent.add_child(body)

func _add_bitcoin_pickup(parent: Node, pos: Vector3):
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
	pickup.set_meta("sats", randi_range(2000, 8000))
	parent.add_child(pickup)

func _process(delta):
	for child in get_parent().get_children():
		if child.name == "BitcoinPickup":
			child.rotation.y += delta * 2
			if not child.has_meta("_base_y"):
				child.set_meta("_base_y", child.position.y)
			child.position.y = child.get_meta("_base_y") + sin(Time.get_ticks_msec() * 0.003) * 0.1
