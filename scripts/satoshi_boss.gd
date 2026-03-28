extends CharacterBody3D

# SATOSHI NAKAMOTO — Secret Boss
# Cloaked like Predator. Teleports. One-shots if you're not paying attention.
# Appears randomly after round 5. 210,000 sats reward.
# "If you don't believe me or don't understand, I don't have time to try to convince you."

var health: float = 1000.0
var max_health: float = 1000.0
var move_speed: float = 6.0
var attack_damage: int = 50
var sats_reward: int = 210000
var accuracy: float = 0.9

enum Phase { CLOAKED, REVEALED, ATTACKING, TELEPORTING, DYING, DEAD }
var phase: int = Phase.CLOAKED

var player: Node3D
var cloak_opacity: float = 0.05  # Nearly invisible
var reveal_timer: float = 0.0
var teleport_cooldown: float = 0.0
var attack_cooldown: float = 0.0
var phase_timer: float = 0.0
var shimmer_time: float = 0.0

# Visual nodes
var body_mesh: MeshInstance3D
var head_mesh: MeshInstance3D
var cloak_material: StandardMaterial3D
var glow_light: OmniLight3D

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	_build_visual()
	
	# Announce arrival
	if player and player.has_method("add_kill_feed"):
		player.add_kill_feed("⚠ SATOSHI HAS APPEARED")
		player.add_kill_feed("\"You will not find a solution to political problems in cryptography.\"")

func _build_visual():
	# Collision
	var col = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	col.shape = capsule
	col.position.y = 0.9
	add_child(col)
	
	# Body — dark, translucent
	body_mesh = MeshInstance3D.new()
	body_mesh.name = "Body"
	var body_capsule = CapsuleMesh.new()
	body_capsule.radius = 0.25
	body_capsule.height = 1.2
	body_mesh.mesh = body_capsule
	cloak_material = StandardMaterial3D.new()
	cloak_material.albedo_color = Color(0.97, 0.58, 0.1, cloak_opacity)
	cloak_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloak_material.emission_enabled = true
	cloak_material.emission = Color(0.97, 0.58, 0.1)
	cloak_material.emission_energy_multiplier = 0.1
	cloak_material.metallic = 0.9
	cloak_material.roughness = 0.1
	body_mesh.set_surface_override_material(0, cloak_material)
	body_mesh.position.y = 0.8
	add_child(body_mesh)
	
	# Head — hooded figure
	head_mesh = MeshInstance3D.new()
	head_mesh.name = "Head"
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	sphere.height = 0.4
	head_mesh.mesh = sphere
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.05, 0.05, 0.08, cloak_opacity)
	head_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	head_mat.emission_enabled = true
	head_mat.emission = Color(0.97, 0.58, 0.1)
	head_mat.emission_energy_multiplier = 0.05
	head_mesh.set_surface_override_material(0, head_mat)
	head_mesh.position.y = 1.6
	add_child(head_mesh)
	
	# Hood
	var hood = MeshInstance3D.new()
	var hood_mesh = CylinderMesh.new()
	hood_mesh.top_radius = 0.12
	hood_mesh.bottom_radius = 0.22
	hood_mesh.height = 0.2
	hood.mesh = hood_mesh
	var hood_mat = StandardMaterial3D.new()
	hood_mat.albedo_color = Color(0.08, 0.08, 0.1, cloak_opacity * 1.5)
	hood_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hood.set_surface_override_material(0, hood_mat)
	hood.position.y = 1.75
	add_child(hood)
	
	# Question mark above head (who is Satoshi?)
	var question = MeshInstance3D.new()
	var q_mesh = BoxMesh.new()
	q_mesh.size = Vector3(0.06, 0.15, 0.02)
	question.mesh = q_mesh
	var q_mat = StandardMaterial3D.new()
	q_mat.albedo_color = Color(0.97, 0.58, 0.1)
	q_mat.emission_enabled = true
	q_mat.emission = Color(0.97, 0.58, 0.1)
	q_mat.emission_energy_multiplier = 3.0
	question.set_surface_override_material(0, q_mat)
	question.position = Vector3(0, 2.2, 0)
	add_child(question)
	
	# Dot under question mark
	var dot = MeshInstance3D.new()
	var dot_mesh = BoxMesh.new()
	dot_mesh.size = Vector3(0.04, 0.04, 0.02)
	dot.mesh = dot_mesh
	dot.set_surface_override_material(0, q_mat)
	dot.position = Vector3(0, 2.0, 0)
	add_child(dot)
	
	# Subtle glow
	glow_light = OmniLight3D.new()
	glow_light.light_color = Color(0.97, 0.58, 0.1)
	glow_light.light_energy = 0.1
	glow_light.omni_range = 3.0
	glow_light.position.y = 1.0
	add_child(glow_light)
	
	# Health bar
	var health_bar = MeshInstance3D.new()
	health_bar.name = "HealthBar"
	var bar_mesh = BoxMesh.new()
	bar_mesh.size = Vector3(0.8, 0.04, 0.02)
	health_bar.mesh = bar_mesh
	var bar_mat = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.97, 0.58, 0.1)
	bar_mat.emission_enabled = true
	bar_mat.emission = Color(0.97, 0.58, 0.1)
	bar_mat.emission_energy_multiplier = 1.0
	health_bar.set_surface_override_material(0, bar_mat)
	health_bar.position = Vector3(0, 2.5, 0)
	add_child(health_bar)
	
	var bg_bar = MeshInstance3D.new()
	bg_bar.name = "HealthBarBG"
	var bg_mesh = BoxMesh.new()
	bg_mesh.size = Vector3(0.82, 0.05, 0.01)
	bg_bar.mesh = bg_mesh
	var bg_mat = StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.2, 0, 0)
	bg_bar.set_surface_override_material(0, bg_mat)
	bg_bar.position = Vector3(0, 2.5, 0.01)
	add_child(bg_bar)

func _physics_process(delta):
	if phase == Phase.DEAD:
		return
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	if not player or not is_instance_valid(player):
		return
	
	phase_timer += delta
	shimmer_time += delta
	attack_cooldown -= delta
	teleport_cooldown -= delta
	
	var to_player = player.global_position - global_position
	to_player.y = 0
	var dist = to_player.length()
	var dir = to_player.normalized()
	
	match phase:
		Phase.CLOAKED:
			_phase_cloaked(delta, dist, dir)
		Phase.REVEALED:
			_phase_revealed(delta, dist, dir)
		Phase.ATTACKING:
			_phase_attacking(delta, dist, dir)
		Phase.TELEPORTING:
			_phase_teleporting(delta)
		Phase.DYING:
			_phase_dying(delta)
	
	# Shimmer effect — Predator-style visual distortion
	_update_shimmer(delta)
	
	move_and_slide()

func _phase_cloaked(delta, dist, dir):
	# Stalk the player while nearly invisible
	cloak_opacity = 0.03 + sin(shimmer_time * 3.0) * 0.02
	
	# Move toward player slowly
	var spd = move_speed * 0.4
	velocity.x = dir.x * spd
	velocity.z = dir.z * spd
	_face_direction(dir)
	
	# Get close then reveal
	if dist < 8.0:
		_switch_phase(Phase.REVEALED)
	
	# Random teleport while stalking
	if teleport_cooldown <= 0 and randf() < 0.005:
		_start_teleport()

func _phase_revealed(delta, dist, dir):
	# Becoming visible — dramatic reveal
	reveal_timer += delta
	cloak_opacity = min(reveal_timer / 1.5, 0.7)
	glow_light.light_energy = cloak_opacity * 2.0
	
	# Move toward player
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	_face_direction(dir)
	
	if reveal_timer > 1.5:
		_switch_phase(Phase.ATTACKING)

func _phase_attacking(delta, dist, dir):
	cloak_opacity = 0.6 + sin(shimmer_time * 5.0) * 0.1
	_face_direction(dir)
	
	if dist > 20.0:
		# Teleport closer
		if teleport_cooldown <= 0:
			_start_teleport()
	elif dist > 5.0:
		# Strafe and shoot
		var strafe = dir.cross(Vector3.UP) * sin(shimmer_time * 2.0) * move_speed * 0.5
		velocity.x = dir.x * move_speed * 0.3 + strafe.x
		velocity.z = dir.z * move_speed * 0.3 + strafe.z
		
		if attack_cooldown <= 0:
			_fire_at_player()
			attack_cooldown = 1.5 + randf() * 0.5
	else:
		# Close range — melee with massive damage
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		if attack_cooldown <= 0 and dist < 2.0:
			if player.has_method("take_damage"):
				player.take_damage(attack_damage)
				if player.has_method("add_kill_feed"):
					player.add_kill_feed("Satoshi strikes from the shadows!")
			attack_cooldown = 2.0
	
	# Randomly re-cloak
	if phase_timer > 8.0 and randf() < 0.01:
		_switch_phase(Phase.CLOAKED)
	
	# Teleport when hurt
	if teleport_cooldown <= 0 and health < max_health * 0.5 and randf() < 0.02:
		_start_teleport()

func _phase_teleporting(delta):
	# Fade out, move, fade in
	cloak_opacity = max(cloak_opacity - delta * 3.0, 0.0)
	velocity = Vector3.ZERO
	
	if phase_timer > 0.5:
		# Teleport to random position
		var new_pos = _find_teleport_pos()
		global_position = new_pos
		_switch_phase(Phase.CLOAKED)
		teleport_cooldown = 5.0

func _phase_dying(delta):
	cloak_opacity = max(cloak_opacity - delta * 0.5, 0.0)
	velocity = Vector3.ZERO
	
	# Glitch effect — flicker visibility
	if fmod(phase_timer, 0.1) < 0.05:
		cloak_opacity = 0.8
	else:
		cloak_opacity = 0.1
	
	glow_light.light_energy = 5.0 * (1.0 - phase_timer / 3.0)
	
	if phase_timer > 3.0:
		phase = Phase.DEAD
		if player and player.has_method("add_kill_feed"):
			player.add_kill_feed("SATOSHI DEFEATED! +210,000 sats!")
			player.add_kill_feed("\"I've moved on to other things.\"")
		queue_free()

func _fire_at_player():
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	var hit_chance = accuracy * (1.0 - dist / 60.0)
	hit_chance = clamp(hit_chance, 0.3, 0.95)
	
	if randf() < hit_chance:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
			if has_node("/root/AudioManager"):
				$"/root/AudioManager".play("hurt")
	
	# Orange muzzle flash
	var flash = OmniLight3D.new()
	flash.light_color = Color(0.97, 0.58, 0.1)
	flash.light_energy = 3.0
	flash.omni_range = 5.0
	flash.position = Vector3(0, 1.2, -0.4)
	add_child(flash)
	get_tree().create_timer(0.08).timeout.connect(func():
		if is_instance_valid(flash): flash.queue_free()
	)

func _start_teleport():
	_switch_phase(Phase.TELEPORTING)

func _find_teleport_pos() -> Vector3:
	if not player:
		return global_position
	# Teleport to a position near-ish the player but not too close
	for _i in range(20):
		var angle = randf() * TAU
		var dist = randf_range(8.0, 18.0)
		var pos = player.global_position + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		pos.x = clamp(pos.x, 2.0, 22.0)
		pos.z = clamp(pos.z, 2.0, 22.0)
		return pos
	return global_position

func take_damage(amount: float, headshot: bool = false):
	if phase == Phase.DEAD or phase == Phase.DYING:
		return
	
	var final_damage = amount
	if headshot:
		final_damage *= 1.5  # Reduced headshot multiplier — he's wearing a hood
	
	health -= final_damage
	
	# Taking damage reveals Satoshi temporarily
	if phase == Phase.CLOAKED:
		cloak_opacity = 0.5
		reveal_timer = 0.0
		_switch_phase(Phase.REVEALED)
	
	# Flash
	cloak_material.emission_energy_multiplier = 3.0
	get_tree().create_timer(0.1).timeout.connect(func():
		if is_instance_valid(self):
			cloak_material.emission_energy_multiplier = 0.3
	)
	
	# Blood effect (orange sparks instead of red blood)
	_spawn_sparks(global_position + Vector3(0, 1.0, 0))
	
	if health <= 0:
		_start_death()
	elif teleport_cooldown <= 0 and randf() < 0.3:
		# 30% chance to teleport when hit
		_start_teleport()

func _start_death():
	phase = Phase.DYING
	phase_timer = 0.0
	health = 0
	
	# Reward player
	if player:
		player.sats += sats_reward
		player.kills += 1
	
	# Disable collision
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", true)
	
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play("kill")

func _update_shimmer(delta):
	# Update all mesh transparencies
	if cloak_material:
		cloak_material.albedo_color.a = cloak_opacity
	
	for child in get_children():
		if child is MeshInstance3D and child != body_mesh:
			var mat = child.get_surface_override_material(0)
			if mat and mat is StandardMaterial3D and mat.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA:
				mat.albedo_color.a = cloak_opacity

func _spawn_sparks(pos: Vector3):
	for i in range(5):
		var spark = MeshInstance3D.new()
		var mesh = SphereMesh.new()
		mesh.radius = 0.03
		mesh.height = 0.06
		spark.mesh = mesh
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.97, 0.58, 0.1)
		mat.emission_enabled = true
		mat.emission = Color(0.97, 0.58, 0.1)
		mat.emission_energy_multiplier = 3.0
		spark.set_surface_override_material(0, mat)
		spark.global_position = pos + Vector3(randf_range(-0.3, 0.3), randf_range(-0.2, 0.2), randf_range(-0.3, 0.3))
		get_tree().root.add_child(spark)
		
		var dir = Vector3(randf_range(-1, 1), randf_range(0.5, 2), randf_range(-1, 1)).normalized()
		var tween = get_tree().create_tween()
		tween.tween_property(spark, "global_position", spark.global_position + dir * 1.0, 0.4)
		tween.parallel().tween_property(spark, "scale", Vector3.ZERO, 0.4)
		tween.tween_callback(spark.queue_free)

func _face_direction(dir: Vector3):
	if dir.length() < 0.01:
		return
	var target = global_position + dir
	look_at(Vector3(target.x, global_position.y, target.z))

func _switch_phase(new_phase: int):
	phase = new_phase
	phase_timer = 0.0
	reveal_timer = 0.0
