extends Node

# Grenade System — throwable projectiles
# G key = throw current grenade
# Grenade types bought from buy menu

enum GrenadeType { FLASHBANG, BCASH, SMOKE }

var player_grenades: Array = []  # Array of GrenadeType
var max_grenades: int = 4
var throw_cooldown: float = 0.0
var throw_force: float = 15.0

func _ready():
	pass

func _process(delta):
	if throw_cooldown > 0:
		throw_cooldown -= delta

func add_grenade(type: int):
	if player_grenades.size() < max_grenades:
		player_grenades.append(type)
		return true
	return false

func throw_grenade():
	if player_grenades.is_empty():
		return
	if throw_cooldown > 0:
		return
	
	throw_cooldown = 0.5
	var type = player_grenades.pop_front()
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var camera = player.find_child("Camera3D", true, false)
	if not camera:
		return
	
	# Spawn grenade projectile
	var grenade = _create_grenade_body(type)
	get_tree().root.add_child(grenade)
	grenade.global_position = camera.global_position + camera.global_transform.basis.z * -0.5
	
	# Throw forward + slightly up
	var throw_dir = -camera.global_transform.basis.z + Vector3(0, 0.3, 0)
	grenade.linear_velocity = throw_dir.normalized() * throw_force
	
	# Sound
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play("shoot_pistol")  # Placeholder throw sound

func _create_grenade_body(type: int) -> RigidBody3D:
	var body = RigidBody3D.new()
	body.mass = 0.5
	body.gravity_scale = 1.5
	
	# Collision
	var col = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.08
	col.shape = shape
	body.add_child(col)
	
	# Visual
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.08
	sphere.height = 0.16
	mesh.mesh = sphere
	var mat = StandardMaterial3D.new()
	
	match type:
		GrenadeType.FLASHBANG:
			body.name = "Flashbang"
			mat.albedo_color = Color(0.7, 0.7, 0.7)
			mat.metallic = 0.6
		GrenadeType.BCASH:
			body.name = "BCashGrenade"
			mat.albedo_color = Color(0.1, 0.6, 0.1)
			mat.emission_enabled = true
			mat.emission = Color(0.1, 0.6, 0.1)
			mat.emission_energy_multiplier = 0.3
		GrenadeType.SMOKE:
			body.name = "SmokeGrenade"
			mat.albedo_color = Color(0.4, 0.4, 0.4)
	
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	
	# Trail light
	var light = OmniLight3D.new()
	light.omni_range = 2.0
	light.light_energy = 0.5
	match type:
		GrenadeType.FLASHBANG:
			light.light_color = Color(1, 1, 0.8)
		GrenadeType.BCASH:
			light.light_color = Color(0.1, 0.8, 0.1)
		GrenadeType.SMOKE:
			light.light_color = Color(0.5, 0.5, 0.5)
	body.add_child(light)
	
	# Fuse timer
	var fuse = 1.5 if type == GrenadeType.FLASHBANG else 2.0
	body.set_meta("grenade_type", type)
	body.set_meta("fuse", fuse)
	body.set_meta("spawn_time", Time.get_ticks_msec() / 1000.0)
	
	# Add processing script
	var script = GDScript.new()
	script.source_code = _get_grenade_script()
	# Can't attach inline scripts easily, use timer instead
	_setup_fuse_timer(body, type, fuse)
	
	return body

func _setup_fuse_timer(body: RigidBody3D, type: int, fuse: float):
	get_tree().create_timer(fuse).timeout.connect(func():
		if not is_instance_valid(body):
			return
		match type:
			GrenadeType.FLASHBANG:
				_explode_flashbang(body.global_position)
			GrenadeType.BCASH:
				_explode_bcash(body.global_position)
			GrenadeType.SMOKE:
				_spawn_smoke(body.global_position)
		body.queue_free()
	)

func _explode_flashbang(pos: Vector3):
	# Bright flash that blinds nearby players/enemies
	var player = get_tree().get_first_node_in_group("player")
	
	# Flash light
	var flash = OmniLight3D.new()
	flash.light_color = Color(1, 1, 1)
	flash.light_energy = 15.0
	flash.omni_range = 20.0
	flash.position = pos
	get_tree().root.add_child(flash)
	
	# Fade out flash
	var tween = get_tree().create_tween()
	tween.tween_property(flash, "light_energy", 0.0, 1.5)
	tween.tween_callback(flash.queue_free)
	
	# Screen flash for player if in range and facing it
	if player:
		var dist = player.global_position.distance_to(pos)
		if dist < 15.0:
			# Check if player is roughly facing the flash
			var to_flash = (pos - player.global_position).normalized()
			var cam = player.find_child("Camera3D", true, false)
			if cam:
				var facing = -cam.global_transform.basis.z
				var dot = facing.dot(to_flash)
				if dot > 0.2:  # Facing toward flash
					var intensity = clamp(1.0 - dist / 15.0, 0.2, 1.0)
					if dot > 0.7:
						intensity *= 1.5  # Looking directly at it
					_flash_player_screen(intensity)
	
	# Stun enemies in range
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var dist = enemy.global_position.distance_to(pos)
		if dist < 12.0 and enemy.has_method("_apply_flinch"):
			var stun_time = clamp(2.0 - dist / 8.0, 0.5, 2.0)
			enemy._apply_flinch(stun_time)

func _flash_player_screen(intensity: float):
	var overlay = get_tree().root.find_child("DamageOverlay", true, false)
	if overlay:
		overlay.color = Color(1, 1, 1, min(intensity, 0.95))
		# Fade out over time based on intensity
		var fade_time = intensity * 3.0
		var tween = get_tree().create_tween()
		tween.tween_property(overlay, "color", Color(1, 1, 1, 0), fade_time)

func _explode_bcash(pos: Vector3):
	# BCash Grenade — explosion that damages enemies
	# "Roger's revenge" — deals damage in radius
	
	# Explosion light
	var light = OmniLight3D.new()
	light.light_color = Color(0.1, 0.8, 0.1)
	light.light_energy = 8.0
	light.omni_range = 10.0
	light.position = pos
	get_tree().root.add_child(light)
	
	var tween = get_tree().create_tween()
	tween.tween_property(light, "light_energy", 0.0, 0.5)
	tween.tween_callback(light.queue_free)
	
	# Spawn explosion particles
	for i in range(12):
		var particle = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.08
		sphere.height = 0.16
		particle.mesh = sphere
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.8, 0.1)
		mat.emission_enabled = true
		mat.emission = Color(0.2, 1.0, 0.2)
		mat.emission_energy_multiplier = 2.0
		particle.set_surface_override_material(0, mat)
		particle.global_position = pos + Vector3(randf_range(-0.3, 0.3), randf_range(0, 0.5), randf_range(-0.3, 0.3))
		get_tree().root.add_child(particle)
		
		var dir = Vector3(randf_range(-1, 1), randf_range(0.5, 2), randf_range(-1, 1)).normalized()
		var pt = get_tree().create_tween()
		pt.tween_property(particle, "global_position", particle.global_position + dir * 3.0, 0.6)
		pt.parallel().tween_property(particle, "scale", Vector3.ZERO, 0.6)
		pt.tween_callback(particle.queue_free)
	
	# Damage enemies in radius
	var damage_radius = 8.0
	var max_damage = 80
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if not enemy.has_method("take_damage"):
			continue
		var dist = enemy.global_position.distance_to(pos)
		if dist < damage_radius:
			var dmg = max_damage * (1.0 - dist / damage_radius)
			enemy.take_damage(dmg, false)
	
	# Damage player too if too close (like CS)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = player.global_position.distance_to(pos)
		if dist < damage_radius:
			var dmg = int(max_damage * 0.6 * (1.0 - dist / damage_radius))
			if dmg > 0 and player.has_method("take_damage"):
				player.take_damage(dmg)

func _spawn_smoke(pos: Vector3):
	# Smoke grenade — creates visual obstruction
	# In Godot without particles, use fog-like meshes
	var smoke_root = Node3D.new()
	smoke_root.name = "SmokeCloud"
	smoke_root.position = pos
	get_tree().root.add_child(smoke_root)
	
	# Multiple smoke spheres
	for i in range(8):
		var cloud = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = randf_range(1.0, 2.0)
		sphere.height = sphere.radius * 2
		cloud.mesh = sphere
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.6, 0.6, 0.6, 0.4)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 1.0
		cloud.set_surface_override_material(0, mat)
		cloud.position = Vector3(randf_range(-1, 1), randf_range(0, 2), randf_range(-1, 1))
		smoke_root.add_child(cloud)
	
	# Smoke lasts 15 seconds, then fades
	get_tree().create_timer(12.0).timeout.connect(func():
		if is_instance_valid(smoke_root):
			var tween = get_tree().create_tween()
			for child in smoke_root.get_children():
				if child is MeshInstance3D:
					var mat = child.get_surface_override_material(0)
					if mat:
						tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 3.0)
			tween.tween_callback(smoke_root.queue_free)
	)

func _get_grenade_script() -> String:
	return ""  # Unused, keeping for potential future inline scripts
