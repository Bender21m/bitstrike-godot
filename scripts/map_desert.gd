extends Node3D

# Desert Compound Map — "SILK ROAD"
# Open courtyard with buildings, market stalls, and sniper perches
# Sandy terrain, warm lighting, Middle-Eastern inspired architecture

var mat_sand: StandardMaterial3D
var mat_sandstone: StandardMaterial3D
var mat_sandstone_dark: StandardMaterial3D
var mat_wood: StandardMaterial3D
var mat_fabric: StandardMaterial3D
var mat_metal: StandardMaterial3D
var mat_concrete: StandardMaterial3D

func _ready():
	_create_materials()
	_build_terrain()
	_build_perimeter_walls()
	_build_buildings()
	_build_market_stalls()
	_build_sniper_towers()
	_build_cover()
	_build_lighting()
	_build_bitcoin_pickups()

func _create_materials():
	mat_sand = StandardMaterial3D.new()
	mat_sand.albedo_color = Color(0.76, 0.65, 0.45)
	mat_sand.roughness = 0.95
	
	mat_sandstone = StandardMaterial3D.new()
	mat_sandstone.albedo_color = Color(0.82, 0.72, 0.55)
	mat_sandstone.roughness = 0.85
	
	mat_sandstone_dark = StandardMaterial3D.new()
	mat_sandstone_dark.albedo_color = Color(0.6, 0.5, 0.35)
	mat_sandstone_dark.roughness = 0.9
	
	mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.5, 0.35, 0.2)
	mat_wood.roughness = 0.85
	
	mat_fabric = StandardMaterial3D.new()
	mat_fabric.albedo_color = Color(0.7, 0.2, 0.15)
	mat_fabric.roughness = 0.95
	
	mat_metal = StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.4, 0.38, 0.35)
	mat_metal.roughness = 0.6
	mat_metal.metallic = 0.5
	
	mat_concrete = StandardMaterial3D.new()
	mat_concrete.albedo_color = Color(0.55, 0.52, 0.45)
	mat_concrete.roughness = 0.9

func _build_terrain():
	# Sand floor — slightly larger than mining facility
	var floor = StaticBody3D.new()
	floor.name = "SandFloor"
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(40, 0.5, 40)
	mesh.mesh = box
	mesh.set_surface_override_material(0, mat_sand)
	mesh.position.y = -0.25
	floor.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(40, 0.5, 40)
	col.shape = shape
	col.position.y = -0.25
	floor.add_child(col)
	add_child(floor)
	
	# Slight elevation changes — sand dunes
	for i in range(5):
		var dune = StaticBody3D.new()
		var dmesh = MeshInstance3D.new()
		var dbox = BoxMesh.new()
		var w = randf_range(3, 6)
		var h = randf_range(0.2, 0.5)
		var d = randf_range(3, 6)
		dbox.size = Vector3(w, h, d)
		dmesh.mesh = dbox
		dmesh.set_surface_override_material(0, mat_sand)
		dune.add_child(dmesh)
		var dcol = CollisionShape3D.new()
		var dshape = BoxShape3D.new()
		dshape.size = Vector3(w, h, d)
		dcol.shape = dshape
		dune.add_child(dcol)
		dune.position = Vector3(randf_range(-12, 12), h / 2, randf_range(-12, 12))
		add_child(dune)

func _build_perimeter_walls():
	# Compound walls — thick sandstone, 4m tall
	var wall_data = [
		[Vector3(0, 2, -19), Vector3(40, 4, 1)],   # North
		[Vector3(0, 2, 19), Vector3(40, 4, 1)],    # South
		[Vector3(-19, 2, 0), Vector3(1, 4, 40)],   # West
		[Vector3(19, 2, 0), Vector3(1, 4, 40)],    # East
	]
	for w in wall_data:
		_add_wall(w[0], w[1])
	
	# Gate openings — cut gaps in north and south walls
	# North gate
	_add_wall(Vector3(-5, 2, -19), Vector3(8, 4, 1.2))
	_add_wall(Vector3(5, 2, -19), Vector3(8, 4, 1.2))
	# Archway top
	_add_wall(Vector3(0, 3.5, -19), Vector3(4, 1, 1.2))

func _add_wall(pos: Vector3, size: Vector3):
	var body = StaticBody3D.new()
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.set_surface_override_material(0, mat_sandstone)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	body.position = pos
	add_child(body)

func _build_buildings():
	# Building A — two-story on west side (sniper nest upstairs)
	_build_box_building(Vector3(-12, 0, -8), Vector3(6, 3, 8), true)
	
	# Building B — single story east side
	_build_box_building(Vector3(10, 0, 5), Vector3(7, 3, 5), false)
	
	# Building C — L-shaped south
	_build_box_building(Vector3(-5, 0, 12), Vector3(5, 3, 4), false)
	_build_box_building(Vector3(-7, 0, 10), Vector3(3, 3, 4), false)
	
	# Central market building — open sides
	_build_market_building(Vector3(0, 0, 0), Vector3(8, 3.5, 6))

func _build_box_building(pos: Vector3, size: Vector3, two_story: bool):
	# Walls
	var walls = [
		[Vector3(0, size.y / 2, -size.z / 2), Vector3(size.x, size.y, 0.3)],
		[Vector3(0, size.y / 2, size.z / 2), Vector3(size.x, size.y, 0.3)],
		[Vector3(-size.x / 2, size.y / 2, 0), Vector3(0.3, size.y, size.z)],
		[Vector3(size.x / 2, size.y / 2, 0), Vector3(0.3, size.y, size.z)],
	]
	for w in walls:
		var body = StaticBody3D.new()
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = w[1]
		mesh.mesh = box
		mesh.set_surface_override_material(0, mat_sandstone)
		body.add_child(mesh)
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = w[1]
		col.shape = shape
		body.add_child(col)
		body.position = pos + w[0]
		add_child(body)
	
	# Roof/floor
	var roof = StaticBody3D.new()
	var rmesh = MeshInstance3D.new()
	var rbox = BoxMesh.new()
	rbox.size = Vector3(size.x + 0.4, 0.2, size.z + 0.4)
	rmesh.mesh = rbox
	rmesh.set_surface_override_material(0, mat_sandstone_dark)
	roof.add_child(rmesh)
	var rcol = CollisionShape3D.new()
	var rshape = BoxShape3D.new()
	rshape.size = Vector3(size.x + 0.4, 0.2, size.z + 0.4)
	rcol.shape = rshape
	roof.add_child(rcol)
	roof.position = pos + Vector3(0, size.y, 0)
	add_child(roof)
	
	# Door opening (remove front wall section) — approximated by adding a doorway
	var door_light = OmniLight3D.new()
	door_light.light_color = Color(0.9, 0.8, 0.6)
	door_light.light_energy = 0.4
	door_light.omni_range = 4.0
	door_light.position = pos + Vector3(0, 2, -size.z / 2)
	add_child(door_light)
	
	if two_story:
		# Second floor platform
		var floor2 = StaticBody3D.new()
		var f2mesh = MeshInstance3D.new()
		var f2box = BoxMesh.new()
		f2box.size = Vector3(size.x - 0.6, 0.15, size.z - 0.6)
		f2mesh.mesh = f2box
		f2mesh.set_surface_override_material(0, mat_concrete)
		floor2.add_child(f2mesh)
		var f2col = CollisionShape3D.new()
		var f2shape = BoxShape3D.new()
		f2shape.size = Vector3(size.x - 0.6, 0.15, size.z - 0.6)
		f2col.shape = f2shape
		floor2.add_child(f2col)
		floor2.position = pos + Vector3(0, size.y, 0)
		add_child(floor2)
		
		# Second floor walls (shorter, 2m)
		for w in walls:
			var body = StaticBody3D.new()
			var mesh = MeshInstance3D.new()
			var box = BoxMesh.new()
			var s2 = Vector3(w[1].x, 2.0, w[1].z)
			if w[1].x > w[1].z:
				s2 = Vector3(w[1].x, 2.0, w[1].z)
			else:
				s2 = Vector3(w[1].x, 2.0, w[1].z)
			box.size = s2
			mesh.mesh = box
			mesh.set_surface_override_material(0, mat_sandstone_dark)
			body.add_child(mesh)
			var col = CollisionShape3D.new()
			var shape = BoxShape3D.new()
			shape.size = s2
			col.shape = shape
			body.add_child(col)
			body.position = pos + Vector3(w[0].x, size.y + 1.0, w[0].z)
			add_child(body)
		
		# Roof for second story
		var roof2 = StaticBody3D.new()
		var r2mesh = MeshInstance3D.new()
		var r2box = BoxMesh.new()
		r2box.size = Vector3(size.x + 0.4, 0.15, size.z + 0.4)
		r2mesh.mesh = r2box
		r2mesh.set_surface_override_material(0, mat_sandstone_dark)
		roof2.add_child(r2mesh)
		var r2col = CollisionShape3D.new()
		var r2shape = BoxShape3D.new()
		r2shape.size = Vector3(size.x + 0.4, 0.15, size.z + 0.4)
		r2col.shape = r2shape
		roof2.add_child(r2col)
		roof2.position = pos + Vector3(0, size.y + 2.0, 0)
		add_child(roof2)
		
		# Stairs (ramp)
		var stairs = StaticBody3D.new()
		var smesh = MeshInstance3D.new()
		var sbox = BoxMesh.new()
		sbox.size = Vector3(1.2, 0.1, 4.0)
		smesh.mesh = sbox
		smesh.set_surface_override_material(0, mat_concrete)
		stairs.add_child(smesh)
		var scol = CollisionShape3D.new()
		var sshape = BoxShape3D.new()
		sshape.size = Vector3(1.2, 0.1, 4.0)
		scol.shape = sshape
		stairs.add_child(scol)
		stairs.position = pos + Vector3(size.x / 2 + 1.0, size.y / 2, 0)
		stairs.rotation.x = -0.38  # ~22 degree ramp
		add_child(stairs)

func _build_market_building(pos: Vector3, size: Vector3):
	# Open market — pillars + roof, no walls
	var pillar_positions = [
		Vector3(-size.x / 2, 0, -size.z / 2),
		Vector3(size.x / 2, 0, -size.z / 2),
		Vector3(-size.x / 2, 0, size.z / 2),
		Vector3(size.x / 2, 0, size.z / 2),
		Vector3(0, 0, -size.z / 2),
		Vector3(0, 0, size.z / 2),
	]
	for pp in pillar_positions:
		var pillar = StaticBody3D.new()
		var pmesh = MeshInstance3D.new()
		var pcyl = CylinderMesh.new()
		pcyl.top_radius = 0.2
		pcyl.bottom_radius = 0.25
		pcyl.height = size.y
		pmesh.mesh = pcyl
		pmesh.set_surface_override_material(0, mat_sandstone_dark)
		pillar.add_child(pmesh)
		var pcol = CollisionShape3D.new()
		var pshape = CylinderShape3D.new()
		pshape.radius = 0.25
		pshape.height = size.y
		pcol.shape = pshape
		pillar.add_child(pcol)
		pillar.position = pos + pp + Vector3(0, size.y / 2, 0)
		add_child(pillar)
	
	# Roof
	var roof = StaticBody3D.new()
	var rmesh = MeshInstance3D.new()
	var rbox = BoxMesh.new()
	rbox.size = Vector3(size.x + 1.0, 0.15, size.z + 1.0)
	rmesh.mesh = rbox
	rmesh.set_surface_override_material(0, mat_sandstone_dark)
	roof.add_child(rmesh)
	var rcol = CollisionShape3D.new()
	var rshape = BoxShape3D.new()
	rshape.size = Vector3(size.x + 1.0, 0.15, size.z + 1.0)
	rcol.shape = rshape
	roof.add_child(rcol)
	roof.position = pos + Vector3(0, size.y, 0)
	add_child(roof)

func _build_market_stalls():
	# Scattered stalls with fabric awnings
	var stall_positions = [
		Vector3(-3, 0, -5), Vector3(5, 0, -8), Vector3(-8, 0, 3),
		Vector3(7, 0, 10), Vector3(2, 0, 7), Vector3(-10, 0, -12),
	]
	for pos in stall_positions:
		_build_stall(pos)

func _build_stall(pos: Vector3):
	# Table
	var table = StaticBody3D.new()
	var tmesh = MeshInstance3D.new()
	var tbox = BoxMesh.new()
	tbox.size = Vector3(1.5, 0.8, 0.8)
	tmesh.mesh = tbox
	tmesh.set_surface_override_material(0, mat_wood)
	table.add_child(tmesh)
	var tcol = CollisionShape3D.new()
	var tshape = BoxShape3D.new()
	tshape.size = Vector3(1.5, 0.8, 0.8)
	tcol.shape = tshape
	table.add_child(tcol)
	table.position = pos + Vector3(0, 0.4, 0)
	add_child(table)
	
	# Awning (angled plane above)
	var awning = MeshInstance3D.new()
	var abox = BoxMesh.new()
	abox.size = Vector3(2.0, 0.03, 1.2)
	awning.mesh = abox
	var fabric_color = [Color(0.7, 0.2, 0.15), Color(0.15, 0.3, 0.6), Color(0.2, 0.5, 0.2), Color(0.6, 0.5, 0.1)].pick_random()
	var fmat = StandardMaterial3D.new()
	fmat.albedo_color = fabric_color
	fmat.roughness = 0.95
	awning.set_surface_override_material(0, fmat)
	awning.position = pos + Vector3(0, 2.0, 0)
	awning.rotation.x = -0.15
	add_child(awning)

func _build_sniper_towers():
	# Two watchtowers at diagonal corners
	_build_tower(Vector3(-16, 0, -16))
	_build_tower(Vector3(16, 0, 16))

func _build_tower(pos: Vector3):
	# Platform on stilts
	for corner in [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]:
		var leg = StaticBody3D.new()
		var lmesh = MeshInstance3D.new()
		var lcyl = CylinderMesh.new()
		lcyl.top_radius = 0.1
		lcyl.bottom_radius = 0.12
		lcyl.height = 5.0
		lmesh.mesh = lcyl
		lmesh.set_surface_override_material(0, mat_wood)
		leg.add_child(lmesh)
		var lcol = CollisionShape3D.new()
		var lshape = CylinderShape3D.new()
		lshape.radius = 0.12
		lshape.height = 5.0
		lcol.shape = lshape
		leg.add_child(lcol)
		leg.position = pos + corner + Vector3(0, 2.5, 0)
		add_child(leg)
	
	# Platform
	var plat = StaticBody3D.new()
	var pmesh = MeshInstance3D.new()
	var pbox = BoxMesh.new()
	pbox.size = Vector3(3, 0.15, 3)
	pmesh.mesh = pbox
	pmesh.set_surface_override_material(0, mat_wood)
	plat.add_child(pmesh)
	var pcol = CollisionShape3D.new()
	var pshape = BoxShape3D.new()
	pshape.size = Vector3(3, 0.15, 3)
	pcol.shape = pshape
	plat.add_child(pcol)
	plat.position = pos + Vector3(0, 5.0, 0)
	add_child(plat)
	
	# Railing (low walls)
	for side in [Vector3(0, 0.4, -1.4), Vector3(0, 0.4, 1.4), Vector3(-1.4, 0.4, 0), Vector3(1.4, 0.4, 0)]:
		var rail = MeshInstance3D.new()
		var rbox = BoxMesh.new()
		if abs(side.z) > abs(side.x):
			rbox.size = Vector3(3, 0.8, 0.08)
		else:
			rbox.size = Vector3(0.08, 0.8, 3)
		rail.mesh = rbox
		rail.set_surface_override_material(0, mat_wood)
		rail.position = pos + Vector3(0, 5.0, 0) + side
		add_child(rail)
	
	# Ladder (ramp)
	var ladder = StaticBody3D.new()
	var lmesh = MeshInstance3D.new()
	var lbox = BoxMesh.new()
	lbox.size = Vector3(0.8, 0.1, 6.0)
	lmesh.mesh = lbox
	lmesh.set_surface_override_material(0, mat_wood)
	ladder.add_child(lmesh)
	var lcol = CollisionShape3D.new()
	var lshape = BoxShape3D.new()
	lshape.size = Vector3(0.8, 0.1, 6.0)
	lcol.shape = lshape
	ladder.add_child(lcol)
	ladder.position = pos + Vector3(2.5, 2.5, 0)
	ladder.rotation.x = -0.7  # Steep ramp
	add_child(ladder)

func _build_cover():
	# Sandbag walls
	var sandbag_positions = [
		[Vector3(4, 0, 3), Vector3(2.0, 0.6, 0.5)],
		[Vector3(-6, 0, -3), Vector3(0.5, 0.6, 2.0)],
		[Vector3(0, 0, -10), Vector3(2.5, 0.6, 0.5)],
		[Vector3(8, 0, -5), Vector3(0.5, 0.6, 1.5)],
		[Vector3(-3, 0, 8), Vector3(1.5, 0.6, 0.5)],
		[Vector3(12, 0, 0), Vector3(0.5, 0.6, 2.0)],
	]
	for sb in sandbag_positions:
		var body = StaticBody3D.new()
		body.name = "Sandbags"
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = sb[1]
		mesh.mesh = box
		var sbmat = StandardMaterial3D.new()
		sbmat.albedo_color = Color(0.55, 0.5, 0.35)
		sbmat.roughness = 0.95
		mesh.set_surface_override_material(0, sbmat)
		body.add_child(mesh)
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = sb[1]
		col.shape = shape
		body.add_child(col)
		body.position = sb[0] + Vector3(0, sb[1].y / 2, 0)
		add_child(body)
	
	# Barrels scattered
	for i in range(6):
		var barrel = StaticBody3D.new()
		var bmesh = MeshInstance3D.new()
		var bcyl = CylinderMesh.new()
		bcyl.top_radius = 0.3
		bcyl.bottom_radius = 0.3
		bcyl.height = 0.9
		bmesh.mesh = bcyl
		var bmat = StandardMaterial3D.new()
		bmat.albedo_color = [Color(0.4, 0.25, 0.1), Color(0.3, 0.35, 0.25), Color(0.5, 0.15, 0.1)].pick_random()
		bmat.metallic = 0.3
		bmesh.set_surface_override_material(0, bmat)
		barrel.add_child(bmesh)
		var bcol = CollisionShape3D.new()
		var bshape = CylinderShape3D.new()
		bshape.radius = 0.3
		bshape.height = 0.9
		bcol.shape = bshape
		barrel.add_child(bcol)
		barrel.position = Vector3(randf_range(-15, 15), 0.45, randf_range(-15, 15))
		add_child(barrel)

func _build_lighting():
	# Warm desert sun
	var sun = DirectionalLight3D.new()
	sun.name = "DesertSun"
	sun.light_color = Color(1.0, 0.92, 0.75)
	sun.light_energy = 1.4
	sun.rotation = Vector3(-0.8, 0.4, 0)
	sun.shadow_enabled = true
	add_child(sun)
	
	# Warm ambient
	var env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.6, 0.75, 0.95)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.85, 0.75, 0.6)
	environment.ambient_light_energy = 1.0
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.8, 0.75, 0.6)
	environment.fog_density = 0.003
	environment.tonemap_mode = Environment.TONE_MAP_ACES
	env.environment = environment
	add_child(env)
	
	# Point lights in buildings
	var indoor_lights = [
		Vector3(-12, 2.5, -8),  # Building A
		Vector3(10, 2.5, 5),    # Building B
		Vector3(-5, 2.5, 12),   # Building C
		Vector3(0, 3, 0),       # Market center
	]
	for lpos in indoor_lights:
		var light = OmniLight3D.new()
		light.light_color = Color(0.9, 0.8, 0.6)
		light.light_energy = 0.6
		light.omni_range = 6.0
		light.position = lpos
		add_child(light)

func _build_bitcoin_pickups():
	var pickup_positions = [
		Vector3(0, 0.8, 0),      # Market center
		Vector3(-12, 3.8, -8),   # Building A upper floor
		Vector3(10, 0.8, 5),     # Building B
		Vector3(-16, 5.5, -16),  # Tower 1
		Vector3(16, 5.5, 16),    # Tower 2
		Vector3(5, 0.8, -8),     # Courtyard
		Vector3(-8, 0.8, 8),     # Near stall
	]
	for pos in pickup_positions:
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
	var col = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	col.shape = shape
	pickup.add_child(col)
	pickup.position = pos
	pickup.set_meta("sats", randi_range(2000, 8000))
	add_child(pickup)
