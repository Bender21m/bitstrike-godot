extends Node3D

# Map 5: THE VAULT — Underground bank vault / bunker
# Tight corridors, heavy doors, gold/bitcoin stacks, laser grids (visual),
# Security office with monitors, emergency lighting

var mat_steel: StandardMaterial3D
var mat_steel_dark: StandardMaterial3D
var mat_floor_tile: StandardMaterial3D
var mat_concrete: StandardMaterial3D
var mat_gold: StandardMaterial3D
var mat_glass: StandardMaterial3D
var mat_emergency: StandardMaterial3D
var mat_door: StandardMaterial3D

func _ready():
	_create_materials()
	_build_floor_ceiling()
	_build_outer_walls()
	_build_corridors()
	_build_vault_room()
	_build_security_office()
	_build_server_room()
	_build_cover()
	_build_lighting()
	_build_bitcoin_pickups()

func _create_materials():
	mat_steel = StandardMaterial3D.new()
	mat_steel.albedo_color = Color(0.5, 0.52, 0.55)
	mat_steel.roughness = 0.4
	mat_steel.metallic = 0.7
	
	mat_steel_dark = StandardMaterial3D.new()
	mat_steel_dark.albedo_color = Color(0.2, 0.22, 0.25)
	mat_steel_dark.roughness = 0.5
	mat_steel_dark.metallic = 0.6
	
	mat_floor_tile = StandardMaterial3D.new()
	mat_floor_tile.albedo_color = Color(0.25, 0.25, 0.28)
	mat_floor_tile.roughness = 0.7
	mat_floor_tile.metallic = 0.1
	
	mat_concrete = StandardMaterial3D.new()
	mat_concrete.albedo_color = Color(0.35, 0.35, 0.38)
	mat_concrete.roughness = 0.9
	
	mat_gold = StandardMaterial3D.new()
	mat_gold.albedo_color = Color(0.85, 0.65, 0.13)
	mat_gold.roughness = 0.3
	mat_gold.metallic = 0.9
	
	mat_glass = StandardMaterial3D.new()
	mat_glass.albedo_color = Color(0.3, 0.5, 0.6, 0.3)
	mat_glass.roughness = 0.05
	mat_glass.metallic = 0.9
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	mat_emergency = StandardMaterial3D.new()
	mat_emergency.albedo_color = Color(0.8, 0.1, 0.1)
	mat_emergency.emission_enabled = true
	mat_emergency.emission = Color(0.8, 0.1, 0.1)
	mat_emergency.emission_energy_multiplier = 1.5
	
	mat_door = StandardMaterial3D.new()
	mat_door.albedo_color = Color(0.3, 0.32, 0.35)
	mat_door.roughness = 0.3
	mat_door.metallic = 0.8

func _build_floor_ceiling():
	# Floor
	_add_box(Vector3(0, -0.25, 0), Vector3(30, 0.5, 30), mat_floor_tile)
	# Ceiling (low — 3m for claustrophobic bunker feel)
	_add_box(Vector3(0, 3.0, 0), Vector3(30, 0.3, 30), mat_concrete)

func _build_outer_walls():
	_add_box(Vector3(0, 1.5, -14.85), Vector3(30, 3, 0.3), mat_concrete)
	_add_box(Vector3(0, 1.5, 14.85), Vector3(30, 3, 0.3), mat_concrete)
	_add_box(Vector3(-14.85, 1.5, 0), Vector3(0.3, 3, 30), mat_concrete)
	_add_box(Vector3(14.85, 1.5, 0), Vector3(0.3, 3, 30), mat_concrete)

func _build_corridors():
	# Main corridor running north-south
	# East wall of main corridor
	_add_box(Vector3(-4, 1.5, 0), Vector3(0.2, 3, 20), mat_steel)
	# West wall (with gaps for rooms)
	_add_box(Vector3(-4, 1.5, -12), Vector3(0.2, 3, 6), mat_steel)
	_add_box(Vector3(-4, 1.5, 12), Vector3(0.2, 3, 6), mat_steel)
	
	# Cross corridor east-west
	_add_box(Vector3(4, 1.5, -3), Vector3(16, 3, 0.2), mat_steel)
	_add_box(Vector3(4, 1.5, 3), Vector3(16, 3, 0.2), mat_steel)
	# Leave gaps for doorways
	
	# T-junction walls
	_add_box(Vector3(8, 1.5, -8), Vector3(0.2, 3, 10), mat_steel)
	_add_box(Vector3(8, 1.5, 8), Vector3(0.2, 3, 10), mat_steel)

func _build_vault_room():
	# The main vault — center-right area
	# Vault door (massive circular)
	var door_frame = StaticBody3D.new()
	door_frame.name = "VaultDoor"
	# Circular door rep (cylinder on its side)
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 1.2
	cyl.bottom_radius = 1.2
	cyl.height = 0.3
	mesh.mesh = cyl
	mesh.set_surface_override_material(0, mat_door)
	mesh.rotation.x = PI / 2
	door_frame.add_child(mesh)
	# No collision (door is "open")
	door_frame.position = Vector3(8, 1.2, 0)
	add_child(door_frame)
	
	# Door frame
	_add_box(Vector3(8, 2.6, 0), Vector3(0.4, 0.8, 3), mat_steel_dark)
	_add_box(Vector3(8, 0, -1.3), Vector3(0.4, 2.6, 0.4), mat_steel_dark)
	_add_box(Vector3(8, 0, 1.3), Vector3(0.4, 2.6, 0.4), mat_steel_dark)
	
	# Gold bars inside vault
	for i in range(4):
		for j in range(3):
			_add_gold_bar(Vector3(11 + i * 0.6, 0.05 + j * 0.12, -1.5 + randf() * 3))
	
	# Bitcoin hardware wallets (small boxes with orange LED)
	for i in range(3):
		var wallet = MeshInstance3D.new()
		var wbox = BoxMesh.new()
		wbox.size = Vector3(0.15, 0.08, 0.08)
		wallet.mesh = wbox
		var wmat = StandardMaterial3D.new()
		wmat.albedo_color = Color(0.1, 0.1, 0.12)
		wmat.metallic = 0.5
		wallet.set_surface_override_material(0, wmat)
		wallet.position = Vector3(12, 0.8 + i * 0.3, 2)
		add_child(wallet)
		
		# Orange LED
		var led = MeshInstance3D.new()
		var lsphere = SphereMesh.new()
		lsphere.radius = 0.01
		led.mesh = lsphere
		var led_mat = StandardMaterial3D.new()
		led_mat.albedo_color = Color(0.97, 0.58, 0.1)
		led_mat.emission_enabled = true
		led_mat.emission = Color(0.97, 0.58, 0.1)
		led_mat.emission_energy_multiplier = 3.0
		led.set_surface_override_material(0, led_mat)
		led.position = Vector3(12.08, 0.82 + i * 0.3, 2)
		add_child(led)
	
	# Vault shelf
	_add_box(Vector3(12, 0.4, 2), Vector3(1.5, 0.05, 0.4), mat_steel)
	_add_box(Vector3(12, 0.7, 2), Vector3(1.5, 0.05, 0.4), mat_steel)
	_add_box(Vector3(12, 1.0, 2), Vector3(1.5, 0.05, 0.4), mat_steel)

func _add_gold_bar(pos: Vector3):
	var bar = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.2, 0.1, 0.08)
	bar.mesh = box
	bar.set_surface_override_material(0, mat_gold)
	bar.position = pos
	bar.rotation.y = randf() * 0.3
	add_child(bar)
	
	# Subtle gold glow
	if randf() < 0.3:
		var glow = OmniLight3D.new()
		glow.light_color = Color(0.85, 0.65, 0.13)
		glow.light_energy = 0.1
		glow.omni_range = 1.0
		glow.position = pos + Vector3(0, 0.1, 0)
		add_child(glow)

func _build_security_office():
	# Top-left room — security monitors
	# Walls
	_add_box(Vector3(-10, 1.5, -10), Vector3(6, 3, 0.2), mat_steel)
	_add_box(Vector3(-10, 1.5, -7), Vector3(6, 3, 0.2), mat_steel)
	_add_box(Vector3(-12.9, 1.5, -8.5), Vector3(0.2, 3, 3), mat_steel)
	# Window (glass)
	var glass = MeshInstance3D.new()
	var gbox = BoxMesh.new()
	gbox.size = Vector3(3, 1.5, 0.05)
	glass.mesh = gbox
	glass.set_surface_override_material(0, mat_glass)
	glass.position = Vector3(-9, 1.8, -7)
	add_child(glass)
	
	# Monitor desk
	_add_box(Vector3(-10.5, 0.4, -9), Vector3(2, 0.8, 0.6), mat_steel_dark)
	
	# Monitor screens (emissive)
	for i in range(3):
		var screen = MeshInstance3D.new()
		var sbox = BoxMesh.new()
		sbox.size = Vector3(0.5, 0.35, 0.03)
		screen.mesh = sbox
		var smat = StandardMaterial3D.new()
		smat.albedo_color = Color(0.1, 0.2, 0.3)
		smat.emission_enabled = true
		smat.emission = Color(0.15, 0.25, 0.4)
		smat.emission_energy_multiplier = 1.5
		screen.set_surface_override_material(0, smat)
		screen.position = Vector3(-11.2 + i * 0.6, 1.0, -9.2)
		add_child(screen)

func _build_server_room():
	# Bottom-right — server racks (bitcoin mining in a vault, classic)
	for row in range(3):
		for col in range(2):
			var rack = StaticBody3D.new()
			rack.name = "ServerRack"
			var mesh = MeshInstance3D.new()
			var box = BoxMesh.new()
			box.size = Vector3(0.6, 2.0, 0.8)
			mesh.mesh = box
			mesh.set_surface_override_material(0, mat_steel_dark)
			rack.add_child(mesh)
			var col_shape = CollisionShape3D.new()
			var shape = BoxShape3D.new()
			shape.size = Vector3(0.6, 2.0, 0.8)
			col_shape.shape = shape
			rack.add_child(col_shape)
			rack.position = Vector3(10 + col * 1.5, 1.0, 8 + row * 1.5)
			add_child(rack)
			
			# Green LEDs
			for led_i in range(4):
				var led = MeshInstance3D.new()
				var lbox = BoxMesh.new()
				lbox.size = Vector3(0.02, 0.02, 0.001)
				led.mesh = lbox
				var led_mat = StandardMaterial3D.new()
				led_mat.albedo_color = Color(0, 1, 0)
				led_mat.emission_enabled = true
				led_mat.emission = Color(0, 1, 0)
				led_mat.emission_energy_multiplier = 2.0
				led.set_surface_override_material(0, led_mat)
				led.position = Vector3(10 + col * 1.5 - 0.15 + led_i * 0.1,
					0.5 + randf() * 0.8, 8 + row * 1.5 - 0.41)
				add_child(led)

func _build_cover():
	# Crates in corridors
	var crate_positions = [
		[Vector3(-2, 0.3, -6), Vector3(0.6, 0.6, 0.6)],
		[Vector3(-2, 0.3, 5), Vector3(0.8, 0.6, 0.6)],
		[Vector3(3, 0.25, -1), Vector3(0.5, 0.5, 0.5)],
		[Vector3(6, 0.3, 6), Vector3(0.7, 0.6, 0.5)],
		[Vector3(-8, 0.3, 3), Vector3(0.6, 0.6, 0.8)],
		[Vector3(13, 0.25, -5), Vector3(0.5, 0.5, 0.5)],
	]
	for c in crate_positions:
		_add_box(c[0] + Vector3(0, c[1].y / 2, 0), c[1], mat_steel_dark)
	
	# Emergency pillars
	for pos in [Vector3(-6, 1.5, 0), Vector3(0, 1.5, -6), Vector3(0, 1.5, 6)]:
		var pillar = StaticBody3D.new()
		var mesh = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.3
		cyl.bottom_radius = 0.35
		cyl.height = 3.0
		mesh.mesh = cyl
		mesh.set_surface_override_material(0, mat_concrete)
		pillar.add_child(mesh)
		var col_shape = CollisionShape3D.new()
		var shape = CylinderShape3D.new()
		shape.radius = 0.35
		shape.height = 3.0
		col_shape.shape = shape
		pillar.add_child(col_shape)
		pillar.position = pos
		add_child(pillar)

func _build_lighting():
	# Environment — underground, no natural light
	var env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.02, 0.03)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.1, 0.12, 0.15)
	environment.ambient_light_energy = 0.4
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.05, 0.05, 0.08)
	environment.fog_density = 0.012
	environment.tonemap_mode = Environment.TONE_MAP_ACES
	env.environment = environment
	add_child(env)
	
	# Corridor fluorescent lights (white, harsh)
	var corridor_lights = [
		Vector3(-6, 2.7, -10), Vector3(-6, 2.7, -5), Vector3(-6, 2.7, 0),
		Vector3(-6, 2.7, 5), Vector3(-6, 2.7, 10),
		Vector3(2, 2.7, 0), Vector3(6, 2.7, 0),
	]
	for lpos in corridor_lights:
		var light = OmniLight3D.new()
		light.light_color = Color(0.85, 0.9, 1.0)
		light.light_energy = 0.8
		light.omni_range = 6.0
		light.shadow_enabled = true
		light.position = lpos
		add_child(light)
		
		# Light fixture mesh
		var fixture = MeshInstance3D.new()
		var fbox = BoxMesh.new()
		fbox.size = Vector3(0.8, 0.04, 0.15)
		fixture.mesh = fbox
		var fmat = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.9, 0.92, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(0.9, 0.92, 1.0)
		fmat.emission_energy_multiplier = 1.0
		fixture.set_surface_override_material(0, fmat)
		fixture.position = lpos + Vector3(0, 0.15, 0)
		add_child(fixture)
	
	# Emergency red lights
	var emergency_positions = [
		Vector3(-2, 2.5, -12), Vector3(10, 2.5, -12),
		Vector3(-2, 2.5, 12), Vector3(10, 2.5, 12),
	]
	for epos in emergency_positions:
		var elight = OmniLight3D.new()
		elight.light_color = Color(0.8, 0.1, 0.1)
		elight.light_energy = 0.4
		elight.omni_range = 4.0
		elight.position = epos
		add_child(elight)
		
		var eled = MeshInstance3D.new()
		var elbox = BoxMesh.new()
		elbox.size = Vector3(0.1, 0.1, 0.1)
		eled.mesh = elbox
		eled.set_surface_override_material(0, mat_emergency)
		eled.position = epos
		add_child(eled)
	
	# Vault room — warm gold light
	var vault_light = OmniLight3D.new()
	vault_light.light_color = Color(0.9, 0.75, 0.4)
	vault_light.light_energy = 1.0
	vault_light.omni_range = 8.0
	vault_light.shadow_enabled = true
	vault_light.position = Vector3(11, 2.7, 0)
	add_child(vault_light)
	
	# Security office — blue screen glow
	var sec_light = OmniLight3D.new()
	sec_light.light_color = Color(0.2, 0.3, 0.5)
	sec_light.light_energy = 0.6
	sec_light.omni_range = 4.0
	sec_light.position = Vector3(-10.5, 1.5, -8.5)
	add_child(sec_light)

func _build_bitcoin_pickups():
	var positions = [
		Vector3(11, 0.8, 0),      # Vault center
		Vector3(-10, 0.8, -8.5),  # Security office
		Vector3(-6, 0.8, 10),     # South corridor
		Vector3(10, 0.8, 10),     # Server room
		Vector3(0, 0.8, 0),       # Junction
	]
	for pos in positions:
		_add_bitcoin(pos)

func _add_bitcoin(pos: Vector3):
	var pickup = Area3D.new()
	pickup.name = "BitcoinPickup"
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.2
	cyl.bottom_radius = 0.2
	cyl.height = 0.04
	mesh.mesh = cyl
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.97, 0.58, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(0.97, 0.58, 0.1)
	mat.emission_energy_multiplier = 0.8
	mat.metallic = 0.8
	mesh.set_surface_override_material(0, mat)
	pickup.add_child(mesh)
	var light = OmniLight3D.new()
	light.light_color = Color(0.97, 0.58, 0.1)
	light.light_energy = 0.5
	light.omni_range = 3.0
	pickup.add_child(light)
	var col = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	col.shape = shape
	pickup.add_child(col)
	pickup.position = pos
	pickup.set_meta("sats", randi_range(5000, 15000))
	add_child(pickup)

func _add_box(pos: Vector3, size: Vector3, material: StandardMaterial3D):
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
	body.position = pos
	add_child(body)
