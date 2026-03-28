extends Node3D

# Map 6: TRAINYARD — "BLOCKCHAIN RAIL"
# Outdoor industrial trainyard with shipping containers, train cars,
# loading docks, and a control tower. Mix of open sightlines and tight cover.

var mat_gravel: StandardMaterial3D
var mat_container_red: StandardMaterial3D
var mat_container_blue: StandardMaterial3D
var mat_container_green: StandardMaterial3D
var mat_container_rust: StandardMaterial3D
var mat_metal: StandardMaterial3D
var mat_concrete: StandardMaterial3D
var mat_wood: StandardMaterial3D
var mat_rail: StandardMaterial3D
var mat_train: StandardMaterial3D

func _ready():
	_create_materials()
	_build_ground()
	_build_perimeter()
	_build_rails()
	_build_train_cars()
	_build_containers()
	_build_loading_dock()
	_build_control_tower()
	_build_cover()
	_build_lighting()
	_build_bitcoin_pickups()

func _create_materials():
	mat_gravel = StandardMaterial3D.new()
	mat_gravel.albedo_color = Color(0.35, 0.33, 0.3)
	mat_gravel.roughness = 0.95
	
	mat_container_red = StandardMaterial3D.new()
	mat_container_red.albedo_color = Color(0.6, 0.15, 0.1)
	mat_container_red.roughness = 0.7
	mat_container_red.metallic = 0.3
	
	mat_container_blue = StandardMaterial3D.new()
	mat_container_blue.albedo_color = Color(0.1, 0.2, 0.5)
	mat_container_blue.roughness = 0.7
	mat_container_blue.metallic = 0.3
	
	mat_container_green = StandardMaterial3D.new()
	mat_container_green.albedo_color = Color(0.15, 0.35, 0.15)
	mat_container_green.roughness = 0.7
	mat_container_green.metallic = 0.3
	
	mat_container_rust = StandardMaterial3D.new()
	mat_container_rust.albedo_color = Color(0.45, 0.28, 0.15)
	mat_container_rust.roughness = 0.85
	mat_container_rust.metallic = 0.2
	
	mat_metal = StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.4, 0.42, 0.45)
	mat_metal.roughness = 0.5
	mat_metal.metallic = 0.6
	
	mat_concrete = StandardMaterial3D.new()
	mat_concrete.albedo_color = Color(0.4, 0.4, 0.42)
	mat_concrete.roughness = 0.9
	
	mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.45, 0.32, 0.18)
	mat_wood.roughness = 0.85
	
	mat_rail = StandardMaterial3D.new()
	mat_rail.albedo_color = Color(0.35, 0.3, 0.28)
	mat_rail.roughness = 0.4
	mat_rail.metallic = 0.7
	
	mat_train = StandardMaterial3D.new()
	mat_train.albedo_color = Color(0.25, 0.25, 0.28)
	mat_train.roughness = 0.6
	mat_train.metallic = 0.5

func _build_ground():
	_add_box(Vector3(0, -0.25, 0), Vector3(44, 0.5, 34), mat_gravel)
	# Concrete platform on east side (loading dock)
	_add_box(Vector3(16, 0.4, 0), Vector3(10, 1.0, 20), mat_concrete)

func _build_perimeter():
	# Chain-link fence (represented by thin walls)
	_add_box(Vector3(0, 1.5, -16.8), Vector3(44, 3, 0.1), mat_metal)
	_add_box(Vector3(0, 1.5, 16.8), Vector3(44, 3, 0.1), mat_metal)
	_add_box(Vector3(-21.8, 1.5, 0), Vector3(0.1, 3, 34), mat_metal)
	_add_box(Vector3(21.8, 1.5, 0), Vector3(0.1, 3, 34), mat_metal)

func _build_rails():
	# 3 parallel rail tracks running east-west
	for track_z in [-8, 0, 8]:
		for i in range(22):
			var x = -21 + i * 2
			# Rail ties (wood planks)
			var tie = MeshInstance3D.new()
			var tbox = BoxMesh.new()
			tbox.size = Vector3(0.15, 0.08, 1.8)
			tie.mesh = tbox
			tie.set_surface_override_material(0, mat_wood)
			tie.position = Vector3(x, 0.04, track_z)
			add_child(tie)
		
		# Rails (two metal bars)
		for offset in [-0.7, 0.7]:
			var rail = MeshInstance3D.new()
			var rbox = BoxMesh.new()
			rbox.size = Vector3(44, 0.06, 0.05)
			rail.mesh = rbox
			rail.set_surface_override_material(0, mat_rail)
			rail.position = Vector3(0, 0.1, track_z + offset)
			add_child(rail)

func _build_train_cars():
	# Boxcar on track 1 (z = -8)
	_build_boxcar(Vector3(-8, 0, -8), mat_container_rust)
	
	# Flatcar with containers on track 2 (z = 0)
	_build_flatcar(Vector3(-5, 0, 0))
	
	# Tank car on track 3 (z = 8)
	_build_tankcar(Vector3(2, 0, 8))
	
	# Another boxcar, open door
	_build_boxcar(Vector3(8, 0, -8), mat_container_blue)

func _build_boxcar(pos: Vector3, container_mat: StandardMaterial3D):
	# Main body
	_add_box(pos + Vector3(0, 1.5, 0), Vector3(6, 2.5, 2.4), container_mat)
	# Roof
	_add_box(pos + Vector3(0, 2.8, 0), Vector3(6.2, 0.1, 2.6), mat_metal)
	# Wheels (simplified)
	for x_off in [-2.0, 2.0]:
		for z_off in [-1.0, 1.0]:
			var wheel = MeshInstance3D.new()
			var wcyl = CylinderMesh.new()
			wcyl.top_radius = 0.25
			wcyl.bottom_radius = 0.25
			wcyl.height = 0.1
			wheel.mesh = wcyl
			wheel.set_surface_override_material(0, mat_metal)
			wheel.rotation.x = PI / 2
			wheel.position = pos + Vector3(x_off, 0.25, z_off)
			add_child(wheel)

func _build_flatcar(pos: Vector3):
	# Flat platform
	_add_box(pos + Vector3(0, 0.5, 0), Vector3(8, 0.3, 2.4), mat_metal)
	# Container on top
	_add_box(pos + Vector3(-1, 1.5, 0), Vector3(3, 1.8, 2.2), mat_container_red)
	# Wheels
	for x_off in [-3.0, 3.0]:
		for z_off in [-1.0, 1.0]:
			var wheel = MeshInstance3D.new()
			var wcyl = CylinderMesh.new()
			wcyl.top_radius = 0.25
			wcyl.bottom_radius = 0.25
			wcyl.height = 0.1
			wheel.mesh = wcyl
			wheel.set_surface_override_material(0, mat_metal)
			wheel.rotation.x = PI / 2
			wheel.position = pos + Vector3(x_off, 0.25, z_off)
			add_child(wheel)

func _build_tankcar(pos: Vector3):
	# Cylindrical tank
	var tank = StaticBody3D.new()
	tank.name = "TankCar"
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 1.1
	cyl.bottom_radius = 1.1
	cyl.height = 5.0
	mesh.mesh = cyl
	mesh.set_surface_override_material(0, mat_metal)
	mesh.rotation.z = PI / 2
	tank.add_child(mesh)
	var col_mesh = CollisionShape3D.new()
	var col_shape = CylinderShape3D.new()
	col_shape.radius = 1.1
	col_shape.height = 5.0
	col_mesh.shape = col_shape
	col_mesh.rotation.z = PI / 2
	tank.add_child(col_mesh)
	tank.position = pos + Vector3(0, 1.5, 0)
	add_child(tank)
	
	# Frame underneath
	_add_box(pos + Vector3(0, 0.3, 0), Vector3(6, 0.2, 2.4), mat_metal)

func _build_containers():
	# Shipping container stacks scattered around yard
	var container_layouts = [
		# [position, stacked?, material]
		[Vector3(-16, 0, -4), false, mat_container_red],
		[Vector3(-16, 0, 4), false, mat_container_blue],
		[Vector3(-16, 1.35, -4), true, mat_container_green],  # Stacked on first
		[Vector3(-12, 0, 12), false, mat_container_rust],
		[Vector3(-12, 0, -12), false, mat_container_red],
		[Vector3(0, 0, 14), false, mat_container_blue],
		[Vector3(4, 0, -14), false, mat_container_green],
		[Vector3(-6, 0, 12), false, mat_container_red],
		[Vector3(-6, 1.35, 12), true, mat_container_blue],  # Stacked
	]
	for cl in container_layouts:
		var y = 0.675 if not cl[1] else cl[0].y + 0.675
		_add_box(Vector3(cl[0].x, y, cl[0].z), Vector3(6, 1.35, 2.2), cl[2])

func _build_loading_dock():
	# East side elevated platform with overhang
	# Already have the concrete platform from _build_ground
	
	# Overhang roof
	_add_box(Vector3(16, 3.5, 0), Vector3(10, 0.15, 12), mat_metal)
	
	# Support pillars for overhang
	for z in [-5, 0, 5]:
		var pillar = StaticBody3D.new()
		var mesh = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.15
		cyl.bottom_radius = 0.15
		cyl.height = 3.5
		mesh.mesh = cyl
		mesh.set_surface_override_material(0, mat_metal)
		pillar.add_child(mesh)
		var col_shape = CollisionShape3D.new()
		var shape = CylinderShape3D.new()
		shape.radius = 0.15
		shape.height = 3.5
		col_shape.shape = shape
		pillar.add_child(col_shape)
		pillar.position = Vector3(11.5, 1.75 + 0.5, z)
		add_child(pillar)
	
	# Loading bay doors (decorative)
	for z in [-4, 0, 4]:
		var door = MeshInstance3D.new()
		var dbox = BoxMesh.new()
		dbox.size = Vector3(0.05, 2.5, 2.5)
		door.mesh = dbox
		door.set_surface_override_material(0, mat_metal)
		door.position = Vector3(20.7, 1.75, z)
		add_child(door)
	
	# Ramp to loading dock
	var ramp = StaticBody3D.new()
	var rmesh = MeshInstance3D.new()
	var rbox = BoxMesh.new()
	rbox.size = Vector3(3, 0.1, 2)
	rmesh.mesh = rbox
	rmesh.set_surface_override_material(0, mat_concrete)
	ramp.add_child(rmesh)
	var rcol = CollisionShape3D.new()
	var rshape = BoxShape3D.new()
	rshape.size = Vector3(3, 0.1, 2)
	rcol.shape = rshape
	ramp.add_child(rcol)
	ramp.position = Vector3(10, 0.5, 8)
	ramp.rotation.z = 0.2
	add_child(ramp)

func _build_control_tower():
	# Small control tower in northwest corner
	var base = Vector3(-18, 0, -13)
	
	# Ground floor
	_add_box(base + Vector3(0, 1.5, 0), Vector3(4, 3, 4), mat_concrete)
	
	# Second floor (glass windows)
	_add_box(base + Vector3(0, 3.5, 0), Vector3(4.2, 0.15, 4.2), mat_concrete)
	
	# Window frames (just walls with gaps implied)
	_add_box(base + Vector3(0, 4.5, -1.9), Vector3(4, 1.8, 0.15), mat_metal)
	_add_box(base + Vector3(0, 4.5, 1.9), Vector3(4, 1.8, 0.15), mat_metal)
	_add_box(base + Vector3(-1.9, 4.5, 0), Vector3(0.15, 1.8, 4), mat_metal)
	_add_box(base + Vector3(1.9, 4.5, 0), Vector3(0.15, 1.8, 4), mat_metal)
	
	# Glass
	for z in [-1.9, 1.9]:
		var glass = MeshInstance3D.new()
		var gbox = BoxMesh.new()
		gbox.size = Vector3(3.6, 1.5, 0.03)
		glass.mesh = gbox
		var gmat = StandardMaterial3D.new()
		gmat.albedo_color = Color(0.3, 0.4, 0.5, 0.3)
		gmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		gmat.roughness = 0.1
		gmat.metallic = 0.7
		glass.set_surface_override_material(0, gmat)
		glass.position = base + Vector3(0, 4.5, z)
		add_child(glass)
	
	# Roof
	_add_box(base + Vector3(0, 5.5, 0), Vector3(4.5, 0.1, 4.5), mat_metal)
	
	# Stairs (ramp)
	var stairs = StaticBody3D.new()
	var smesh = MeshInstance3D.new()
	var sbox = BoxMesh.new()
	sbox.size = Vector3(1.2, 0.1, 5)
	smesh.mesh = sbox
	smesh.set_surface_override_material(0, mat_metal)
	stairs.add_child(smesh)
	var scol = CollisionShape3D.new()
	var sshape = BoxShape3D.new()
	sshape.size = Vector3(1.2, 0.1, 5)
	scol.shape = sshape
	stairs.add_child(scol)
	stairs.position = base + Vector3(3, 1.75, 0)
	stairs.rotation.x = -0.45
	add_child(stairs)
	
	# Interior light
	var ilight = OmniLight3D.new()
	ilight.light_color = Color(0.9, 0.85, 0.7)
	ilight.light_energy = 0.6
	ilight.omni_range = 5.0
	ilight.position = base + Vector3(0, 4.5, 0)
	add_child(ilight)

func _build_cover():
	# Barrels near tracks
	var barrel_positions = [
		Vector3(-4, 0, -4), Vector3(-4, 0, 4), Vector3(6, 0, -12),
		Vector3(-10, 0, 0), Vector3(8, 0, 12),
	]
	for pos in barrel_positions:
		var barrel = StaticBody3D.new()
		var bmesh = MeshInstance3D.new()
		var bcyl = CylinderMesh.new()
		bcyl.top_radius = 0.3
		bcyl.bottom_radius = 0.3
		bcyl.height = 0.9
		bmesh.mesh = bcyl
		bmesh.set_surface_override_material(0, mat_container_rust)
		barrel.add_child(bmesh)
		var bcol = CollisionShape3D.new()
		var bshape = CylinderShape3D.new()
		bshape.radius = 0.3
		bshape.height = 0.9
		bcol.shape = bshape
		barrel.add_child(bcol)
		barrel.position = pos + Vector3(0, 0.45, 0)
		add_child(barrel)
	
	# Wooden crates
	var crate_sizes = [
		[Vector3(-2, 0, 10), Vector3(0.8, 0.8, 0.8)],
		[Vector3(10, 0.9, -6), Vector3(1.0, 0.6, 0.8)],
		[Vector3(-8, 0, -8), Vector3(0.6, 0.6, 0.6)],
	]
	for c in crate_sizes:
		_add_box(c[0] + Vector3(0, c[1].y / 2, 0), c[1], mat_wood)

func _build_lighting():
	# Overcast outdoor lighting
	var env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.45, 0.5, 0.55)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.5, 0.52, 0.55)
	environment.ambient_light_energy = 0.8
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.5, 0.52, 0.55)
	environment.fog_density = 0.004
	environment.tonemap_mode = Environment.TONE_MAP_ACES
	env.environment = environment
	add_child(env)
	
	# Overcast sun (diffused)
	var sun = DirectionalLight3D.new()
	sun.name = "OvercastSun"
	sun.light_color = Color(0.8, 0.82, 0.85)
	sun.light_energy = 0.9
	sun.rotation = Vector3(-0.7, 0.3, 0)
	sun.shadow_enabled = true
	add_child(sun)
	
	# Dock area lights
	for z in [-4, 0, 4]:
		var light = OmniLight3D.new()
		light.light_color = Color(1, 0.9, 0.7)
		light.light_energy = 0.5
		light.omni_range = 6.0
		light.position = Vector3(16, 3.3, z)
		add_child(light)
	
	# Yard flood lights on poles
	var flood_positions = [
		Vector3(-10, 6, -10), Vector3(-10, 6, 10),
		Vector3(5, 6, -10), Vector3(5, 6, 10),
	]
	for fpos in flood_positions:
		var light = OmniLight3D.new()
		light.light_color = Color(0.9, 0.85, 0.7)
		light.light_energy = 0.6
		light.omni_range = 12.0
		light.shadow_enabled = true
		light.position = fpos
		add_child(light)
		
		# Pole
		var pole = MeshInstance3D.new()
		var pcyl = CylinderMesh.new()
		pcyl.top_radius = 0.06
		pcyl.bottom_radius = 0.08
		pcyl.height = 6.0
		pole.mesh = pcyl
		pole.set_surface_override_material(0, mat_metal)
		pole.position = fpos - Vector3(0, 3, 0)
		add_child(pole)

func _build_bitcoin_pickups():
	var positions = [
		Vector3(-16, 2.3, -4),   # On top of stacked container
		Vector3(16, 1.8, 0),     # Loading dock
		Vector3(-18, 4, -13),    # Control tower upper floor
		Vector3(-8, 0.8, -8),    # Track 1 area
		Vector3(2, 2.2, 8),      # On tank car
		Vector3(0, 0.8, 0),      # Center track
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
	mat.emission_energy_multiplier = 0.5
	mat.metallic = 0.8
	mesh.set_surface_override_material(0, mat)
	pickup.add_child(mesh)
	var light = OmniLight3D.new()
	light.light_color = Color(0.97, 0.58, 0.1)
	light.light_energy = 0.4
	light.omni_range = 3.0
	pickup.add_child(light)
	var col_node = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	col_node.shape = shape
	pickup.add_child(col_node)
	pickup.position = pos
	pickup.set_meta("sats", randi_range(2000, 8000))
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
