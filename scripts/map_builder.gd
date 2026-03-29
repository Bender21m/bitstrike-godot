extends Node3D

# Map Builder v2 — Bitcoin Mining Facility
# Larger, more intricate, with elevation, tunnels, and textures

# Material cache
var mat_concrete_floor: StandardMaterial3D
var mat_concrete_wall: StandardMaterial3D
var mat_metal_wall: StandardMaterial3D
var mat_metal_dark: StandardMaterial3D
var mat_metal_grate: StandardMaterial3D
var mat_warning_stripe: StandardMaterial3D
var mat_wood_crate: StandardMaterial3D
var mat_barrel: StandardMaterial3D

func _ready():
	_create_materials()
	_build_main_facility()
	_build_server_rooms()
	_build_catwalks()
	_build_tunnel_system()
	_build_crates_and_cover()
	_build_lighting()
	_build_bitcoin_pickups()

func _create_materials():
	# Load texture generator
	var tex_gen_script = load("res://scripts/texture_generator.gd")
	var tex_gen = null
	if tex_gen_script:
		tex_gen = Node.new()
		tex_gen.set_script(tex_gen_script)
	
	# Concrete floor — dark industrial with tile pattern
	mat_concrete_floor = StandardMaterial3D.new()
	mat_concrete_floor.albedo_color = Color(0.22, 0.22, 0.24)
	mat_concrete_floor.roughness = 0.95
	mat_concrete_floor.metallic = 0.0
	if tex_gen:
		var floor_tex = tex_gen.create_floor_tile_texture(128, Color(0.24, 0.24, 0.26), Color(0.18, 0.18, 0.2))
		tex_gen.apply_texture_to_material(mat_concrete_floor, floor_tex, 6.0)
	
	# Concrete wall with brick pattern
	mat_concrete_wall = StandardMaterial3D.new()
	mat_concrete_wall.albedo_color = Color(0.3, 0.3, 0.32)
	mat_concrete_wall.roughness = 0.9
	mat_concrete_wall.metallic = 0.05
	if tex_gen:
		var wall_tex = tex_gen.create_brick_texture(128, Color(0.25, 0.25, 0.27), Color(0.33, 0.31, 0.29))
		tex_gen.apply_texture_to_material(mat_concrete_wall, wall_tex, 4.0)
	
	# Metal wall panels with rivets
	mat_metal_wall = StandardMaterial3D.new()
	mat_metal_wall.albedo_color = Color(0.25, 0.28, 0.3)
	mat_metal_wall.roughness = 0.6
	mat_metal_wall.metallic = 0.4
	if tex_gen:
		var panel_tex = tex_gen.create_metal_panel_texture(128, Color(0.28, 0.3, 0.32))
		tex_gen.apply_texture_to_material(mat_metal_wall, panel_tex, 3.0)
	
	# Dark metal
	mat_metal_dark = StandardMaterial3D.new()
	mat_metal_dark.albedo_color = Color(0.12, 0.12, 0.14)
	mat_metal_dark.roughness = 0.5
	mat_metal_dark.metallic = 0.6
	
	# Metal grate (for catwalks) with grid pattern
	mat_metal_grate = StandardMaterial3D.new()
	mat_metal_grate.albedo_color = Color(0.2, 0.2, 0.22)
	mat_metal_grate.roughness = 0.7
	mat_metal_grate.metallic = 0.5
	if tex_gen:
		var grate_tex = tex_gen.create_grid_texture(64, Color(0.25, 0.25, 0.27), Color(0.15, 0.15, 0.17), 1, 8)
		tex_gen.apply_texture_to_material(mat_metal_grate, grate_tex, 8.0)
	
	# Warning stripe (yellow/black)
	mat_warning_stripe = StandardMaterial3D.new()
	mat_warning_stripe.albedo_color = Color(0.9, 0.7, 0.0)
	mat_warning_stripe.roughness = 0.8
	mat_warning_stripe.emission_enabled = true
	mat_warning_stripe.emission = Color(0.9, 0.7, 0.0)
	mat_warning_stripe.emission_energy_multiplier = 0.1
	
	# Wood crate with grain
	mat_wood_crate = StandardMaterial3D.new()
	mat_wood_crate.albedo_color = Color(0.45, 0.35, 0.2)
	mat_wood_crate.roughness = 0.9
	
	# Barrel
	mat_barrel = StandardMaterial3D.new()
	mat_barrel.albedo_color = Color(0.2, 0.3, 0.25)
	mat_barrel.roughness = 0.6
	mat_barrel.metallic = 0.4
	
	# Cleanup
	if tex_gen:
		tex_gen.queue_free()

func _build_main_facility():
	var parent = get_parent()
	
	# === SERVER RACK ROWS (main hall, both sides) ===
	# Left row
	for i in range(8):
		_add_server_rack(parent, Vector3(4, 0, 4 + i * 2.5))
	# Right row
	for i in range(8):
		_add_server_rack(parent, Vector3(20, 0, 4 + i * 2.5))
	
	# === CENTER AISLE SERVER ISLANDS ===
	for i in range(3):
		_add_server_rack(parent, Vector3(10, 0, 6 + i * 6))
		_add_server_rack(parent, Vector3(14, 0, 6 + i * 6))
	
	# === CONTROL ROOM (back left corner) ===
	# Walls
	_add_wall_segment(parent, Vector3(2, 0, 18), Vector3(4, 3, 0.2), mat_metal_wall)
	_add_wall_segment(parent, Vector3(5, 0, 20), Vector3(0.2, 3, 4), mat_metal_wall)
	# Window slit in control room wall
	_add_wall_segment(parent, Vector3(2, 0, 18), Vector3(4, 0.8, 0.2), mat_metal_wall)
	_add_wall_segment(parent, Vector3(2, 2.2, 18), Vector3(4, 0.8, 0.2), mat_metal_wall)
	# Desk
	_add_static_box(parent, Vector3(3, 0.4, 19.5), Vector3(2, 0.8, 0.6), mat_metal_dark)
	# Monitor glow
	var monitor_light = OmniLight3D.new()
	monitor_light.light_color = Color(0.3, 0.8, 0.3)
	monitor_light.light_energy = 0.3
	monitor_light.omni_range = 2.0
	monitor_light.position = Vector3(3, 1.2, 19.5)
	parent.add_child(monitor_light)
	
	# === GENERATOR ROOM (back right) ===
	_add_wall_segment(parent, Vector3(19, 0, 18), Vector3(4, 3, 0.2), mat_concrete_wall)
	_add_wall_segment(parent, Vector3(19, 0, 20), Vector3(0.2, 3, 4), mat_concrete_wall)
	# Generator units
	_add_static_box(parent, Vector3(20.5, 0.6, 20), Vector3(1.5, 1.2, 1.5), mat_metal_dark)
	_add_static_box(parent, Vector3(22, 0.6, 20), Vector3(1.5, 1.2, 1.5), mat_metal_dark)
	
	# === ENTRANCE AREA (near player spawn) ===
	# Reception desk / sandbags
	_add_static_box(parent, Vector3(4, 0.3, 2), Vector3(2, 0.6, 0.8), mat_concrete_wall)
	_add_static_box(parent, Vector3(7, 0.3, 3), Vector3(1.5, 0.6, 0.8), mat_concrete_wall)

func _build_server_rooms():
	var parent = get_parent()
	
	# === SIDE ROOMS (accessible from main hall) ===
	
	# Left side room 1 (cooling room)
	_add_wall_segment(parent, Vector3(1.5, 0, 8), Vector3(2, 3, 0.2), mat_metal_wall)
	_add_wall_segment(parent, Vector3(1.5, 0, 12), Vector3(2, 3, 0.2), mat_metal_wall)
	# Cooling units
	_add_static_box(parent, Vector3(1.5, 0.8, 10), Vector3(1.2, 1.6, 1.5), mat_metal_dark)
	# Cool blue light
	var cool_light = OmniLight3D.new()
	cool_light.light_color = Color(0.3, 0.5, 0.9)
	cool_light.light_energy = 0.5
	cool_light.omni_range = 4.0
	cool_light.position = Vector3(1.5, 3, 10)
	parent.add_child(cool_light)
	
	# Right side room (electrical)
	_add_wall_segment(parent, Vector3(22.5, 0, 8), Vector3(1.2, 3, 0.2), mat_metal_wall)
	_add_wall_segment(parent, Vector3(22.5, 0, 12), Vector3(1.2, 3, 0.2), mat_metal_wall)
	# Electrical panels
	_add_static_box(parent, Vector3(22.5, 0.8, 9), Vector3(0.3, 1.6, 0.8), mat_metal_dark)
	_add_static_box(parent, Vector3(22.5, 0.8, 11), Vector3(0.3, 1.6, 0.8), mat_metal_dark)
	# Sparky light
	var elec_light = OmniLight3D.new()
	elec_light.light_color = Color(0.9, 0.8, 0.3)
	elec_light.light_energy = 0.4
	elec_light.omni_range = 3.0
	elec_light.position = Vector3(22.5, 2.5, 10)
	parent.add_child(elec_light)

func _build_catwalks():
	var parent = get_parent()
	
	# === ELEVATED CATWALKS (height 2.5m) ===
	# Accessible via ramp
	
	# Left catwalk running along the wall
	_add_catwalk(parent, Vector3(2, 2.5, 8), Vector3(1.5, 0.05, 8))
	# Railing
	_add_railing(parent, Vector3(2.75, 2.5, 8), 8.0, true)
	
	# Right catwalk
	_add_catwalk(parent, Vector3(22, 2.5, 8), Vector3(1.5, 0.05, 8))
	_add_railing(parent, Vector3(21.25, 2.5, 8), 8.0, true)
	
	# Cross catwalk (connecting left and right)
	_add_catwalk(parent, Vector3(12, 2.5, 15), Vector3(10, 0.05, 1.2))
	_add_railing(parent, Vector3(12, 2.5, 14.4), 10.0, false)
	_add_railing(parent, Vector3(12, 2.5, 15.6), 10.0, false)
	
	# === RAMPS (to get up to catwalks) ===
	# Left ramp
	_add_ramp(parent, Vector3(2, 0, 5), Vector3(1.5, 0.1, 3), 2.5, true)
	# Right ramp
	_add_ramp(parent, Vector3(22, 0, 5), Vector3(1.5, 0.1, 3), 2.5, true)

func _build_tunnel_system():
	var parent = get_parent()
	
	# === UNDERGROUND TUNNEL (accessible via stairs) ===
	# The tunnel runs under the center of the facility
	
	# Tunnel entrance (left side, stairs down)
	# Step blocks going down
	for i in range(5):
		var step_y = -0.4 * (i + 1)
		var step_z = 14 + i * 0.8
		_add_static_box(parent, Vector3(7, step_y, step_z), Vector3(1.5, 0.4, 0.8), mat_concrete_wall)
	
	# Tunnel floor (below ground level)
	_add_static_box(parent, Vector3(12, -2.2, 16), Vector3(10, 0.2, 2), mat_concrete_floor)
	
	# Tunnel walls
	_add_wall_segment(parent, Vector3(12, -2, 15), Vector3(10, 2, 0.2), mat_concrete_wall)
	_add_wall_segment(parent, Vector3(12, -2, 17), Vector3(10, 2, 0.2), mat_concrete_wall)
	
	# Tunnel ceiling
	_add_static_box(parent, Vector3(12, -0.1, 16), Vector3(10, 0.2, 2.2), mat_concrete_wall)
	
	# Tunnel exit (right side, stairs up)
	for i in range(5):
		var step_y2 = -0.4 * (5 - i)
		var step_z2 = 14 + i * 0.8
		_add_static_box(parent, Vector3(17, step_y2, step_z2), Vector3(1.5, 0.4, 0.8), mat_concrete_wall)
	
	# Tunnel lighting (red emergency)
	var t_light1 = OmniLight3D.new()
	t_light1.light_color = Color(0.8, 0.2, 0.1)
	t_light1.light_energy = 0.6
	t_light1.omni_range = 5.0
	t_light1.position = Vector3(10, -0.5, 16)
	parent.add_child(t_light1)
	
	var t_light2 = OmniLight3D.new()
	t_light2.light_color = Color(0.8, 0.2, 0.1)
	t_light2.light_energy = 0.6
	t_light2.omni_range = 5.0
	t_light2.position = Vector3(14, -0.5, 16)
	parent.add_child(t_light2)

func _build_crates_and_cover():
	var parent = get_parent()
	
	# === STRATEGIC COVER POSITIONS ===
	
	# Near entrance — sandbag-style low cover
	_add_static_box(parent, Vector3(6, 0.25, 4), Vector3(1.0, 0.5, 0.6), mat_wood_crate)
	_add_static_box(parent, Vector3(10, 0.25, 3), Vector3(0.8, 0.5, 0.8), mat_wood_crate)
	
	# Mid-field cover clusters
	_add_crate_cluster(parent, Vector3(8, 0, 8))
	_add_crate_cluster(parent, Vector3(16, 0, 10))
	_add_crate_cluster(parent, Vector3(12, 0, 6))
	
	# Near server rooms
	_add_static_box(parent, Vector3(6, 0.3, 12), Vector3(0.8, 0.6, 0.6), mat_wood_crate)
	_add_static_box(parent, Vector3(18, 0.3, 12), Vector3(0.8, 0.6, 0.6), mat_wood_crate)
	
	# Barrels (coolant/fuel)
	_add_barrel(parent, Vector3(15, 0, 5))
	_add_barrel(parent, Vector3(3, 0, 15))
	_add_barrel(parent, Vector3(21, 0, 15))
	_add_barrel(parent, Vector3(9, 0, 20))
	
	# Back area cover
	_add_static_box(parent, Vector3(12, 0.4, 20), Vector3(1.5, 0.8, 0.6), mat_concrete_wall)
	_add_static_box(parent, Vector3(8, 0.4, 18), Vector3(0.8, 0.8, 1.0), mat_wood_crate)
	_add_static_box(parent, Vector3(16, 0.4, 18), Vector3(0.8, 0.8, 1.0), mat_wood_crate)
	
	# === WARNING STRIPES (at tunnel entrances, danger zones) ===
	_add_static_box(parent, Vector3(7, 0.01, 14), Vector3(1.5, 0.02, 0.15), mat_warning_stripe)
	_add_static_box(parent, Vector3(17, 0.01, 14), Vector3(1.5, 0.02, 0.15), mat_warning_stripe)

func _build_lighting():
	var parent = get_parent()
	
	# Overhead fluorescent lights with visible fixtures
	var overhead = [
		Vector3(6, 4.5, 6), Vector3(12, 4.5, 6), Vector3(18, 4.5, 6),
		Vector3(6, 4.5, 12), Vector3(12, 4.5, 12), Vector3(18, 4.5, 12),
		Vector3(6, 4.5, 18), Vector3(12, 4.5, 18), Vector3(18, 4.5, 18),
	]
	for pos in overhead:
		var ol = OmniLight3D.new()
		ol.light_color = Color(0.85, 0.9, 1.0)
		ol.light_energy = 0.6
		ol.omni_range = 7.0
		ol.shadow_enabled = true
		ol.position = pos
		parent.add_child(ol)
		# Light fixture
		var fx = MeshInstance3D.new()
		var fm = BoxMesh.new()
		fm.size = Vector3(0.6, 0.03, 0.15)
		fx.mesh = fm
		var fmat = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.9, 0.95, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(0.9, 0.95, 1.0)
		fmat.emission_energy_multiplier = 2.0
		fx.set_surface_override_material(0, fmat)
		fx.position = pos + Vector3(0, 0.3, 0)
		parent.add_child(fx)
	
	# Bitcoin orange accent lights
	for bpos in [Vector3(4, 2.5, 8), Vector3(4, 2.5, 14), Vector3(20, 2.5, 8), Vector3(20, 2.5, 14)]:
		var bl = OmniLight3D.new()
		bl.light_color = Color(0.97, 0.58, 0.1)
		bl.light_energy = 0.4
		bl.omni_range = 3.5
		bl.position = bpos
		parent.add_child(bl)
	
	# Red emergency lights near tunnels
	for epos in [Vector3(7, 2, 14), Vector3(17, 2, 14)]:
		var el = OmniLight3D.new()
		el.light_color = Color(0.9, 0.15, 0.1)
		el.light_energy = 0.5
		el.omni_range = 4.0
		el.position = epos
		parent.add_child(el)

func _build_bitcoin_pickups():
	var parent = get_parent()
	# Scatter pickups in interesting spots
	var pickup_positions = [
		Vector3(12, 0.8, 12),   # Center
		Vector3(3, 0.8, 19),    # Control room
		Vector3(22, 0.8, 20),   # Generator room
		Vector3(2, 3.3, 10),    # Left catwalk
		Vector3(22, 3.3, 10),   # Right catwalk
		Vector3(12, 3.3, 15),   # Cross catwalk
		Vector3(12, -1.5, 16),  # Tunnel (high risk, high reward)
	]
	for pos in pickup_positions:
		_add_bitcoin_pickup(parent, pos)

# === BUILDER HELPERS ===

func _add_server_rack(parent: Node, pos: Vector3):
	var body = StaticBody3D.new()
	body.name = "ServerRack"
	
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
	
	# LED lights
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
	
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.6, 2.0, 0.8)
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, 1.0, 0)
	parent.add_child(body)

func _add_wall_segment(parent: Node, pos: Vector3, size: Vector3, material: StandardMaterial3D):
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

func _add_static_box(parent: Node, pos: Vector3, size: Vector3, material: StandardMaterial3D):
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

func _add_catwalk(parent: Node, center: Vector3, size: Vector3):
	var body = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.set_surface_override_material(0, mat_metal_grate)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	body.position = center
	parent.add_child(body)

func _add_railing(parent: Node, pos: Vector3, length: float, along_z: bool):
	var rail = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	if along_z:
		box.size = Vector3(0.05, 1.0, length)
	else:
		box.size = Vector3(length, 1.0, 0.05)
	mesh.mesh = box
	mesh.set_surface_override_material(0, mat_metal_dark)
	rail.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	rail.add_child(col)
	rail.position = pos + Vector3(0, 0.5, 0)
	parent.add_child(rail)

func _add_ramp(parent: Node, pos: Vector3, size: Vector3, height: float, going_forward: bool):
	# Simple ramp using a rotated box
	var body = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var ramp_length = sqrt(size.z * size.z + height * height)
	var box = BoxMesh.new()
	box.size = Vector3(size.x, 0.15, ramp_length)
	mesh.mesh = box
	mesh.set_surface_override_material(0, mat_metal_grate)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	body.add_child(col)
	
	var angle = atan2(height, size.z)
	body.rotation.x = -angle if going_forward else angle
	body.position = pos + Vector3(0, height / 2, size.z / 2)
	parent.add_child(body)

func _add_crate_cluster(parent: Node, pos: Vector3):
	# 2-3 crates of varying sizes
	_add_static_box(parent, pos, Vector3(0.8, 0.8, 0.8), mat_wood_crate)
	_add_static_box(parent, pos + Vector3(0.7, 0, 0.3), Vector3(0.6, 0.6, 0.6), mat_wood_crate)
	if randf() > 0.4:
		_add_static_box(parent, pos + Vector3(0.2, 0.8, 0), Vector3(0.5, 0.5, 0.5), mat_wood_crate)

func _add_barrel(parent: Node, pos: Vector3):
	var body = StaticBody3D.new()
	body.name = "Barrel"
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.3
	cyl.bottom_radius = 0.3
	cyl.height = 0.9
	cyl.radial_segments = 16
	mesh.mesh = cyl
	mesh.set_surface_override_material(0, mat_barrel)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 0.9
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, 0.45, 0)
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
	parent.add_child(pickup)

func _process(delta):
	# Spin and bob bitcoin pickups
	for child in get_parent().get_children():
		if child.name == "BitcoinPickup":
			child.rotation.y += delta * 2
			child.position.y = child.get_meta("_base_y", child.position.y) + sin(Time.get_ticks_msec() * 0.003) * 0.1
			if not child.has_meta("_base_y"):
				child.set_meta("_base_y", child.position.y)
