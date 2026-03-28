extends Node3D

# Rooftop Map — "CITADEL"
# High-rise rooftops with gaps to jump, AC units for cover,
# helipads, antenna towers, and city skyline backdrop

var mat_roof_dark: StandardMaterial3D
var mat_roof_light: StandardMaterial3D
var mat_metal: StandardMaterial3D
var mat_metal_vent: StandardMaterial3D
var mat_concrete: StandardMaterial3D
var mat_glass: StandardMaterial3D
var mat_helipad: StandardMaterial3D
var mat_neon: StandardMaterial3D

func _ready():
	_create_materials()
	_build_main_rooftop()
	_build_adjacent_rooftops()
	_build_bridges()
	_build_cover_objects()
	_build_antenna_tower()
	_build_helipad()
	_build_skyline()
	_build_lighting()
	_build_bitcoin_pickups()

func _create_materials():
	mat_roof_dark = StandardMaterial3D.new()
	mat_roof_dark.albedo_color = Color(0.2, 0.2, 0.22)
	mat_roof_dark.roughness = 0.85
	
	mat_roof_light = StandardMaterial3D.new()
	mat_roof_light.albedo_color = Color(0.35, 0.35, 0.38)
	mat_roof_light.roughness = 0.8
	
	mat_metal = StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.4, 0.42, 0.45)
	mat_metal.roughness = 0.5
	mat_metal.metallic = 0.6
	
	mat_metal_vent = StandardMaterial3D.new()
	mat_metal_vent.albedo_color = Color(0.5, 0.52, 0.48)
	mat_metal_vent.roughness = 0.6
	mat_metal_vent.metallic = 0.4
	
	mat_concrete = StandardMaterial3D.new()
	mat_concrete.albedo_color = Color(0.45, 0.45, 0.47)
	mat_concrete.roughness = 0.9
	
	mat_glass = StandardMaterial3D.new()
	mat_glass.albedo_color = Color(0.3, 0.5, 0.7, 0.4)
	mat_glass.roughness = 0.1
	mat_glass.metallic = 0.8
	mat_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	mat_helipad = StandardMaterial3D.new()
	mat_helipad.albedo_color = Color(0.25, 0.25, 0.28)
	mat_helipad.roughness = 0.7
	
	mat_neon = StandardMaterial3D.new()
	mat_neon.albedo_color = Color(0.97, 0.58, 0.1)
	mat_neon.emission_enabled = true
	mat_neon.emission = Color(0.97, 0.58, 0.1)
	mat_neon.emission_energy_multiplier = 2.0

func _build_main_rooftop():
	# Central building roof — large, primary play area
	var floor_body = StaticBody3D.new()
	floor_body.name = "MainRoof"
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(24, 0.5, 20)
	mesh.mesh = box
	mesh.set_surface_override_material(0, mat_roof_dark)
	mesh.position.y = -0.25
	floor_body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(24, 0.5, 20)
	col.shape = shape
	col.position.y = -0.25
	floor_body.add_child(col)
	add_child(floor_body)
	
	# Raised section in center (stairwell access)
	_add_box(Vector3(0, 1.5, 0), Vector3(5, 3, 4), mat_concrete)
	# Door opening (just skip one face — implied by light)
	var door_light = OmniLight3D.new()
	door_light.light_color = Color(0.9, 0.85, 0.7)
	door_light.light_energy = 0.5
	door_light.omni_range = 4.0
	door_light.position = Vector3(0, 1.5, -2.1)
	add_child(door_light)
	
	# Low parapet walls around edge
	_add_box(Vector3(0, 0.5, -9.8), Vector3(24, 1.0, 0.4), mat_concrete)
	_add_box(Vector3(0, 0.5, 9.8), Vector3(24, 1.0, 0.4), mat_concrete)
	_add_box(Vector3(-11.8, 0.5, 0), Vector3(0.4, 1.0, 20), mat_concrete)
	_add_box(Vector3(11.8, 0.5, 0), Vector3(0.4, 1.0, 20), mat_concrete)

func _build_adjacent_rooftops():
	# West building — lower, jump gap
	var west_roof = StaticBody3D.new()
	west_roof.name = "WestRoof"
	var wmesh = MeshInstance3D.new()
	var wbox = BoxMesh.new()
	wbox.size = Vector3(10, 0.5, 14)
	wmesh.mesh = wbox
	wmesh.set_surface_override_material(0, mat_roof_light)
	west_roof.add_child(wmesh)
	var wcol = CollisionShape3D.new()
	var wshape = BoxShape3D.new()
	wshape.size = Vector3(10, 0.5, 14)
	wcol.shape = wshape
	west_roof.add_child(wcol)
	west_roof.position = Vector3(-20, -1.0, 0)
	add_child(west_roof)
	
	# Parapets for west
	_add_box(Vector3(-20, -0.25, -6.8), Vector3(10, 0.8, 0.4), mat_concrete)
	_add_box(Vector3(-20, -0.25, 6.8), Vector3(10, 0.8, 0.4), mat_concrete)
	_add_box(Vector3(-24.8, -0.25, 0), Vector3(0.4, 0.8, 14), mat_concrete)
	
	# East building — higher, need to climb
	var east_roof = StaticBody3D.new()
	east_roof.name = "EastRoof"
	var emesh = MeshInstance3D.new()
	var ebox = BoxMesh.new()
	ebox.size = Vector3(8, 0.5, 12)
	emesh.mesh = ebox
	emesh.set_surface_override_material(0, mat_roof_light)
	east_roof.add_child(emesh)
	var ecol = CollisionShape3D.new()
	var eshape = BoxShape3D.new()
	eshape.size = Vector3(8, 0.5, 12)
	ecol.shape = eshape
	east_roof.add_child(ecol)
	east_roof.position = Vector3(18, 1.5, 2)
	add_child(east_roof)
	
	# Parapets for east
	_add_box(Vector3(18, 2.25, -3.8), Vector3(8, 0.8, 0.4), mat_concrete)
	_add_box(Vector3(18, 2.25, 7.8), Vector3(8, 0.8, 0.4), mat_concrete)
	_add_box(Vector3(21.8, 2.25, 2), Vector3(0.4, 0.8, 12), mat_concrete)

func _build_bridges():
	# Metal walkway to west building (jump gap alternative)
	var bridge1 = StaticBody3D.new()
	bridge1.name = "WestBridge"
	var bmesh = MeshInstance3D.new()
	var bbox = BoxMesh.new()
	bbox.size = Vector3(4, 0.08, 1.5)
	bmesh.mesh = bbox
	bmesh.set_surface_override_material(0, mat_metal)
	bridge1.add_child(bmesh)
	var bcol = CollisionShape3D.new()
	var bshape = BoxShape3D.new()
	bshape.size = Vector3(4, 0.08, 1.5)
	bcol.shape = bshape
	bridge1.add_child(bcol)
	bridge1.position = Vector3(-14, -0.5, 0)
	add_child(bridge1)
	
	# Railings
	for z_off in [-0.7, 0.7]:
		var rail = MeshInstance3D.new()
		var rbox = BoxMesh.new()
		rbox.size = Vector3(4, 0.8, 0.04)
		rail.mesh = rbox
		rail.set_surface_override_material(0, mat_metal)
		rail.position = Vector3(-14, -0.1, z_off)
		add_child(rail)
	
	# Ramp up to east building
	var ramp = StaticBody3D.new()
	ramp.name = "EastRamp"
	var rmesh = MeshInstance3D.new()
	var rbox = BoxMesh.new()
	rbox.size = Vector3(3, 0.1, 1.5)
	rmesh.mesh = rbox
	rmesh.set_surface_override_material(0, mat_metal)
	ramp.add_child(rmesh)
	var rcol = CollisionShape3D.new()
	var rshape = BoxShape3D.new()
	rshape.size = Vector3(3, 0.1, 1.5)
	rcol.shape = rshape
	ramp.add_child(rcol)
	ramp.position = Vector3(13, 0.75, 2)
	ramp.rotation.z = 0.35
	add_child(ramp)

func _build_cover_objects():
	# AC Units — large boxy cover
	var ac_positions = [
		Vector3(-6, 0.6, -5), Vector3(-4, 0.6, 4), Vector3(6, 0.6, -7),
		Vector3(8, 0.6, 3), Vector3(-8, 0.6, 7), Vector3(3, 0.6, 6),
	]
	for pos in ac_positions:
		_build_ac_unit(pos)
	
	# Vent pipes
	var pipe_positions = [
		Vector3(-3, 0, -8), Vector3(5, 0, 8), Vector3(-9, 0, 0),
		Vector3(10, 0, -3),
	]
	for pos in pipe_positions:
		var pipe = StaticBody3D.new()
		var pmesh = MeshInstance3D.new()
		var pcyl = CylinderMesh.new()
		pcyl.top_radius = 0.25
		pcyl.bottom_radius = 0.25
		pcyl.height = 1.5
		pmesh.mesh = pcyl
		pmesh.set_surface_override_material(0, mat_metal_vent)
		pipe.add_child(pmesh)
		var pcol = CollisionShape3D.new()
		var pshape = CylinderShape3D.new()
		pshape.radius = 0.25
		pshape.height = 1.5
		pcol.shape = pshape
		pipe.add_child(pcol)
		pipe.position = pos + Vector3(0, 0.75, 0)
		add_child(pipe)
	
	# Water tanks
	_build_water_tank(Vector3(-10, 0, -7))
	_build_water_tank(Vector3(9, 0, 7))

func _build_ac_unit(pos: Vector3):
	var body = StaticBody3D.new()
	body.name = "ACUnit"
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	var w = randf_range(1.2, 2.0)
	var h = randf_range(0.8, 1.2)
	var d = randf_range(0.8, 1.5)
	box.size = Vector3(w, h, d)
	mesh.mesh = box
	mesh.set_surface_override_material(0, mat_metal_vent)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(w, h, d)
	col.shape = shape
	body.add_child(col)
	body.position = pos
	add_child(body)
	
	# Fan grill on top
	var fan = MeshInstance3D.new()
	var fcyl = CylinderMesh.new()
	fcyl.top_radius = min(w, d) * 0.35
	fcyl.bottom_radius = min(w, d) * 0.35
	fcyl.height = 0.05
	fan.mesh = fcyl
	fan.set_surface_override_material(0, mat_metal)
	fan.position = pos + Vector3(0, h / 2 + 0.03, 0)
	add_child(fan)

func _build_water_tank(pos: Vector3):
	var body = StaticBody3D.new()
	body.name = "WaterTank"
	var mesh = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = 2.0
	mesh.mesh = cyl
	mesh.set_surface_override_material(0, mat_metal)
	body.add_child(mesh)
	var col = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 1.0
	shape.height = 2.0
	col.shape = shape
	body.add_child(col)
	body.position = pos + Vector3(0, 1.0, 0)
	add_child(body)

func _build_antenna_tower():
	# Radio tower in corner — tall, climbable
	var base_pos = Vector3(-10, 0, 8)
	
	# Main pole
	var pole = StaticBody3D.new()
	var pmesh = MeshInstance3D.new()
	var pcyl = CylinderMesh.new()
	pcyl.top_radius = 0.08
	pcyl.bottom_radius = 0.15
	pcyl.height = 8.0
	pmesh.mesh = pcyl
	pmesh.set_surface_override_material(0, mat_metal)
	pole.add_child(pmesh)
	var pcol = CollisionShape3D.new()
	var pshape = CylinderShape3D.new()
	pshape.radius = 0.15
	pshape.height = 8.0
	pcol.shape = pshape
	pole.add_child(pcol)
	pole.position = base_pos + Vector3(0, 4, 0)
	add_child(pole)
	
	# Dish
	var dish = MeshInstance3D.new()
	var dsphere = SphereMesh.new()
	dsphere.radius = 0.5
	dsphere.height = 0.3
	dish.mesh = dsphere
	dish.set_surface_override_material(0, mat_metal)
	dish.position = base_pos + Vector3(0.3, 6, 0)
	dish.rotation.z = -0.3
	add_child(dish)
	
	# Blinking red light at top
	var blink = OmniLight3D.new()
	blink.name = "AntennaLight"
	blink.light_color = Color(1, 0, 0)
	blink.light_energy = 0.8
	blink.omni_range = 5.0
	blink.position = base_pos + Vector3(0, 8.2, 0)
	add_child(blink)
	
	# Red sphere at top
	var red_orb = MeshInstance3D.new()
	var orb = SphereMesh.new()
	orb.radius = 0.06
	red_orb.mesh = orb
	var orb_mat = StandardMaterial3D.new()
	orb_mat.albedo_color = Color(1, 0, 0)
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(1, 0, 0)
	orb_mat.emission_energy_multiplier = 3.0
	red_orb.set_surface_override_material(0, orb_mat)
	red_orb.position = base_pos + Vector3(0, 8.1, 0)
	add_child(red_orb)

func _build_helipad():
	# Helipad on east building roof
	var pad_pos = Vector3(18, 1.8, 2)
	
	# Circle pad
	var pad = MeshInstance3D.new()
	var pcyl = CylinderMesh.new()
	pcyl.top_radius = 3.0
	pcyl.bottom_radius = 3.0
	pcyl.height = 0.02
	pad.mesh = pcyl
	pad.set_surface_override_material(0, mat_helipad)
	pad.position = pad_pos
	add_child(pad)
	
	# H marking (two vertical bars + crossbar)
	for x_off in [-0.6, 0.6]:
		var bar = MeshInstance3D.new()
		var bbox = BoxMesh.new()
		bbox.size = Vector3(0.15, 0.01, 1.5)
		bar.mesh = bbox
		var hmat = StandardMaterial3D.new()
		hmat.albedo_color = Color(1, 1, 1, 0.8)
		hmat.emission_enabled = true
		hmat.emission = Color(1, 1, 1)
		hmat.emission_energy_multiplier = 0.5
		bar.set_surface_override_material(0, hmat)
		bar.position = pad_pos + Vector3(x_off, 0.02, 0)
		add_child(bar)
	
	var cross = MeshInstance3D.new()
	var cbox = BoxMesh.new()
	cbox.size = Vector3(1.2, 0.01, 0.15)
	cross.mesh = cbox
	var cmat = StandardMaterial3D.new()
	cmat.albedo_color = Color(1, 1, 1, 0.8)
	cmat.emission_enabled = true
	cmat.emission = Color(1, 1, 1)
	cmat.emission_energy_multiplier = 0.5
	cross.set_surface_override_material(0, cmat)
	cross.position = pad_pos + Vector3(0, 0.02, 0)
	add_child(cross)
	
	# Landing lights (circle of orange)
	for i in range(8):
		var angle = i * TAU / 8
		var lpos = pad_pos + Vector3(cos(angle) * 2.8, 0.03, sin(angle) * 2.8)
		var led = MeshInstance3D.new()
		var lsphere = SphereMesh.new()
		lsphere.radius = 0.06
		led.mesh = lsphere
		led.set_surface_override_material(0, mat_neon)
		led.position = lpos
		add_child(led)

func _build_skyline():
	# Distant city buildings (non-collidable, just visual)
	var buildings = [
		[Vector3(-40, 15, -50), Vector3(8, 30, 8)],
		[Vector3(-25, 20, -55), Vector3(6, 40, 6)],
		[Vector3(-10, 12, -60), Vector3(10, 24, 10)],
		[Vector3(5, 25, -52), Vector3(7, 50, 7)],
		[Vector3(20, 18, -58), Vector3(9, 36, 9)],
		[Vector3(35, 14, -48), Vector3(8, 28, 8)],
		[Vector3(50, 22, -55), Vector3(6, 44, 6)],
		[Vector3(-50, 10, -45), Vector3(12, 20, 12)],
		[Vector3(45, 16, -60), Vector3(10, 32, 10)],
	]
	for b in buildings:
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = b[1]
		mesh.mesh = box
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.12, 0.12, 0.15)
		mat.roughness = 0.7
		mesh.set_surface_override_material(0, mat)
		mesh.position = b[0]
		add_child(mesh)
		
		# Random lit windows
		for _w in range(randi_range(3, 8)):
			var win = MeshInstance3D.new()
			var wbox = BoxMesh.new()
			wbox.size = Vector3(0.8, 0.5, 0.01)
			win.mesh = wbox
			var wmat = StandardMaterial3D.new()
			var brightness = randf_range(0.3, 0.8)
			wmat.albedo_color = Color(brightness, brightness * 0.9, brightness * 0.7)
			wmat.emission_enabled = true
			wmat.emission = wmat.albedo_color
			wmat.emission_energy_multiplier = 1.0
			win.set_surface_override_material(0, wmat)
			win.position = b[0] + Vector3(
				randf_range(-b[1].x / 3, b[1].x / 3),
				randf_range(-b[1].y / 3, b[1].y / 3),
				-b[1].z / 2 - 0.01
			)
			add_child(win)

func _build_lighting():
	# Night sky with city glow
	var env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.03, 0.06)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.15, 0.18, 0.25)
	environment.ambient_light_energy = 0.6
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.08, 0.1, 0.15)
	environment.fog_density = 0.005
	environment.tonemap_mode = 2
	environment.glow_enabled = true
	environment.glow_intensity = 0.3
	env.environment = environment
	add_child(env)
	
	# Moon
	var moon = DirectionalLight3D.new()
	moon.name = "Moonlight"
	moon.light_color = Color(0.6, 0.65, 0.8)
	moon.light_energy = 0.4
	moon.rotation = Vector3(-0.6, 0.8, 0)
	moon.shadow_enabled = true
	add_child(moon)
	
	# Rooftop flood lights
	var flood_positions = [
		Vector3(-8, 3.5, -8), Vector3(8, 3.5, -8),
		Vector3(-8, 3.5, 8), Vector3(8, 3.5, 8),
		Vector3(0, 4, 0),
	]
	for fpos in flood_positions:
		var light = OmniLight3D.new()
		light.light_color = Color(0.9, 0.85, 0.7)
		light.light_energy = 1.0
		light.omni_range = 12.0
		light.shadow_enabled = true
		light.position = fpos
		add_child(light)
	
	# Neon Bitcoin sign on stairwell
	var neon_sign = MeshInstance3D.new()
	var nbox = BoxMesh.new()
	nbox.size = Vector3(2.5, 0.8, 0.05)
	neon_sign.mesh = nbox
	neon_sign.set_surface_override_material(0, mat_neon)
	neon_sign.position = Vector3(0, 2.5, -2.05)
	add_child(neon_sign)
	
	# Bitcoin light glow
	var btc_light = OmniLight3D.new()
	btc_light.light_color = Color(0.97, 0.58, 0.1)
	btc_light.light_energy = 0.8
	btc_light.omni_range = 5.0
	btc_light.position = Vector3(0, 2.5, -2.5)
	add_child(btc_light)

func _build_bitcoin_pickups():
	var pickup_positions = [
		Vector3(0, 3.5, 0),       # On stairwell roof
		Vector3(-20, -0.2, 0),    # West roof
		Vector3(18, 2.3, 2),      # Helipad center
		Vector3(-10, 8.5, 8),     # Antenna top (reward)
		Vector3(6, 0.8, -7),      # Behind AC unit
		Vector3(-6, 0.8, 4),      # Main roof
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
	pickup.set_meta("sats", randi_range(3000, 10000))
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
