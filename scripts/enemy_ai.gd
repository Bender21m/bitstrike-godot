extends CharacterBody3D

# --- Stats ---
var enemy_type: String = "banker"
var health: float = 60.0
var max_health: float = 60.0
var move_speed: float = 3.0
var attack_damage: int = 12
var sats_reward: int = 5000
var accuracy: float = 0.6

# --- AI State Machine ---
enum State { IDLE, PATROL, CHASE, ATTACK, COVER, FLANK, FLINCH, DYING, DEAD, PLANTING }
var state: int = State.PATROL
var previous_state: int = State.IDLE

# --- Bomb Carrier ---
var is_carrier: bool = false
var target_site: String = ""
var plant_progress: float = 0.0
var plant_time: float = 3.0

# --- References ---
var player: Node3D
var nav_target: Vector3 = Vector3.ZERO
var patrol_points: Array = []
var patrol_index: int = 0
var cover_point: Vector3 = Vector3.ZERO

# --- Timers ---
var state_timer: float = 0.0
var attack_cooldown: float = 0.0
var flinch_timer: float = 0.0
var last_seen_player: float = 0.0
var wander_timer: float = 0.0

# --- Visual ---
var head_node: MeshInstance3D
var body_node: MeshInstance3D
var original_body_color: Color
var bob_time: float = 0.0
var is_moving: bool = false

# --- Combat ---
var detection_range: float = 18.0
var attack_range: float = 12.0
var melee_range: float = 1.8
var can_shoot: bool = true  # ranged enemies
var bullets_fired: int = 0
var burst_count: int = 3
var burst_timer: float = 0.0

# --- Wound system ---
var wound_count: int = 0
var limping: bool = false
var bleeding: bool = false
var bleed_timer: float = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemies")
	
	# Generate patrol points near spawn
	var origin = global_position
	for i in range(4):
		var angle = i * PI / 2 + randf() * 0.5
		var dist = randf_range(3.0, 8.0)
		patrol_points.append(origin + Vector3(cos(angle) * dist, 0, sin(angle) * dist))
	
	# Clamp patrol points to map bounds
	for i in range(patrol_points.size()):
		patrol_points[i].x = clamp(patrol_points[i].x, 2.0, 22.0)
		patrol_points[i].z = clamp(patrol_points[i].z, 2.0, 22.0)
	
	nav_target = patrol_points[0]
	
	# Randomize start so not all enemies sync
	state_timer = randf() * 2.0
	bob_time = randf() * TAU

func setup(type: String, data: Dictionary):
	enemy_type = type
	health = data.get("hp", 60)
	max_health = health
	move_speed = data.get("speed", 3.0)
	attack_damage = data.get("damage", 12)
	sats_reward = data.get("reward", 5000)
	accuracy = data.get("accuracy", 0.6)
	can_shoot = data.get("can_shoot", true)
	burst_count = data.get("burst", 3)
	detection_range = data.get("detection", 18.0)
	attack_range = data.get("attack_range", 12.0)
	
	# Find visual nodes
	head_node = find_child("Head", true, false) as MeshInstance3D
	body_node = find_child("Body", true, false) as MeshInstance3D
	if body_node and body_node.get_surface_override_material(0):
		original_body_color = body_node.get_surface_override_material(0).albedo_color

func _physics_process(delta):
	if state == State.DEAD:
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# Bleed damage
	if bleeding:
		bleed_timer -= delta
		if bleed_timer <= 0:
			bleed_timer = 1.0
			health -= 2.0
			_flash_damage()
			if health <= 0:
				_start_death()
				return
	
	# Flinch override
	if state == State.FLINCH:
		flinch_timer -= delta
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		if flinch_timer <= 0:
			state = previous_state
		return
	
	# Dying animation
	if state == State.DYING:
		_process_death(delta)
		return
	
	# Update timers
	state_timer += delta
	attack_cooldown -= delta
	
	# Detect player
	var can_see_player = _can_see_player()
	if can_see_player:
		last_seen_player = 0.0
	else:
		last_seen_player += delta
	
	# State machine
	match state:
		State.IDLE:
			_state_idle(delta)
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase(delta)
		State.ATTACK:
			_state_attack(delta)
		State.COVER:
			_state_cover(delta)
		State.FLANK:
			_state_flank(delta)
		State.PLANTING:
			_state_planting(delta)
	
	# Carrier AI: if no one is engaging me, head to site
	if is_carrier and state in [State.PATROL, State.IDLE] and not _can_see_player():
		_carrier_move_to_site(delta)
	
	# Animation (procedural)
	_animate(delta)
	
	move_and_slide()

# --- STATE HANDLERS ---

func _state_idle(delta):
	velocity.x = 0
	velocity.z = 0
	is_moving = false
	if _can_see_player():
		# Reaction delay — don't instantly aggro (0.3-0.8s delay)
		if state_timer > randf_range(0.3, 0.8):
			_switch_state(State.CHASE)
	elif state_timer > randf_range(2.0, 5.0):
		_switch_state(State.PATROL)

func _state_patrol(delta):
	var dir = (nav_target - global_position)
	dir.y = 0
	var dist = dir.length()
	
	if dist < 1.0:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		nav_target = patrol_points[patrol_index]
		_switch_state(State.IDLE)
		return
	
	var spd = move_speed * 0.5  # Patrol at half speed
	if limping:
		spd *= 0.6
	velocity.x = dir.normalized().x * spd
	velocity.z = dir.normalized().z * spd
	is_moving = true
	_face_direction(dir.normalized())
	
	# Detect player during patrol — slight reaction delay
	if _can_see_player() and state_timer > 0.5:
		_switch_state(State.CHASE)

func _state_chase(delta):
	if not player or not is_instance_valid(player):
		_switch_state(State.PATROL)
		return
	
	var to_player = player.global_position - global_position
	to_player.y = 0
	var dist = to_player.length()
	var dir = to_player.normalized()
	
	_face_direction(dir)
	
	# Close enough to attack? Need to see player AND be in range for a moment
	if can_shoot and dist < attack_range and _can_see_player():
		# Don't instantly attack — pause briefly to "aim"
		if state_timer > 0.4:
			_switch_state(State.ATTACK)
		return
	elif not can_shoot and dist < melee_range:
		_switch_state(State.ATTACK)
		return
	
	# Lost sight for too long?
	if last_seen_player > 4.0:
		_switch_state(State.PATROL)
		return
	
	# Move toward player
	var spd = move_speed
	if limping:
		spd *= 0.6
	
	# Some enemies strafe while approaching
	var strafe = Vector3.ZERO
	if enemy_type in ["roger", "shitcoiner"] and dist < 10.0:
		var strafe_dir = dir.cross(Vector3.UP)
		strafe = strafe_dir * sin(Time.get_ticks_msec() * 0.003) * spd * 0.4
	
	velocity.x = dir.x * spd + strafe.x
	velocity.z = dir.z * spd + strafe.z
	is_moving = true
	
	# Randomly decide to flank
	if randf() < 0.002 and dist < 12.0 and dist > 5.0:
		_switch_state(State.FLANK)

func _state_attack(delta):
	if not player or not is_instance_valid(player):
		_switch_state(State.PATROL)
		return
	
	var to_player = player.global_position - global_position
	to_player.y = 0
	var dist = to_player.length()
	
	_face_direction(to_player.normalized())
	
	# Slow movement during attack
	velocity.x = 0
	velocity.z = 0
	is_moving = false
	
	# Slight strafe during ranged combat
	if can_shoot and dist > melee_range:
		var strafe_dir = to_player.normalized().cross(Vector3.UP)
		var strafe_spd = move_speed * 0.3
		velocity.x = strafe_dir.x * sin(Time.get_ticks_msec() * 0.002) * strafe_spd
		velocity.z = strafe_dir.z * sin(Time.get_ticks_msec() * 0.002) * strafe_spd
		is_moving = true
	
	if can_shoot:
		# Ranged attack — with proper LOS check and realistic timing
		if attack_cooldown <= 0 and _can_see_player():
			_fire_at_player()
			bullets_fired += 1
			attack_cooldown = 0.25 + randf() * 0.2  # Slower burst fire
			
			if bullets_fired >= burst_count:
				bullets_fired = 0
				# Longer pause between bursts — gives player time to react
				attack_cooldown = 1.2 + randf() * 1.0
				
				
				# Chance to take cover after burst
				if randf() < 0.3 and health < max_health * 0.6:
					_switch_state(State.COVER)
		
		if dist > attack_range * 1.2 or last_seen_player > 2.0:
			_switch_state(State.CHASE)
	else:
		# Melee attack
		if dist < melee_range:
			if attack_cooldown <= 0:
				if player.has_method("take_damage"):
					player.take_damage(attack_damage)
					if has_node("/root/AudioManager"):
						$"/root/AudioManager".play("hurt")
				attack_cooldown = 0.8
		else:
			_switch_state(State.CHASE)

func _state_cover(delta):
	# Move away from player to cover_point
	if cover_point == Vector3.ZERO:
		# Find cover: move perpendicular to player direction
		var to_player = (player.global_position - global_position).normalized()
		to_player.y = 0
		var perp = to_player.cross(Vector3.UP) * (1 if randf() > 0.5 else -1)
		cover_point = global_position + perp * 4.0 - to_player * 3.0
		cover_point.x = clamp(cover_point.x, 2.0, 22.0)
		cover_point.z = clamp(cover_point.z, 2.0, 22.0)
	
	var dir = (cover_point - global_position)
	dir.y = 0
	var dist = dir.length()
	
	if dist < 1.0 or state_timer > 3.0:
		cover_point = Vector3.ZERO
		_switch_state(State.CHASE)
		return
	
	var spd = move_speed * 1.2  # Run to cover
	if limping:
		spd *= 0.6
	velocity.x = dir.normalized().x * spd
	velocity.z = dir.normalized().z * spd
	is_moving = true
	_face_direction(dir.normalized())

func _state_flank(delta):
	if not player or not is_instance_valid(player):
		_switch_state(State.PATROL)
		return
	
	var to_player = (player.global_position - global_position)
	to_player.y = 0
	var perp = to_player.normalized().cross(Vector3.UP) * (1 if fmod(bob_time, 2.0) > 1.0 else -1)
	
	var flank_target = player.global_position + perp * 5.0
	flank_target.x = clamp(flank_target.x, 2.0, 22.0)
	flank_target.z = clamp(flank_target.z, 2.0, 22.0)
	
	var dir = (flank_target - global_position)
	dir.y = 0
	
	var spd = move_speed * 0.9
	if limping:
		spd *= 0.6
	velocity.x = dir.normalized().x * spd
	velocity.z = dir.normalized().z * spd
	is_moving = true
	_face_direction(dir.normalized())
	
	if state_timer > 2.5 or to_player.length() < melee_range:
		_switch_state(State.ATTACK)

# --- COMBAT ---

# --- CARRIER / PLANTING ---

func set_as_carrier(site: String):
	is_carrier = true
	target_site = site
	# Visual indicator — make carrier glow red
	var glow = OmniLight3D.new()
	glow.name = "CarrierGlow"
	glow.light_color = Color(1, 0.2, 0.1)
	glow.light_energy = 0.4
	glow.omni_range = 2.5
	glow.position.y = 1.0
	add_child(glow)

func _carrier_move_to_site(delta):
	if not has_node("/root/HackDefuse"):
		return
	var hd = $"/root/HackDefuse"
	if hd.device_planted or hd.round_state != 1:  # Only during ACTIVE
		return
	
	var site_data = hd.hack_sites.get(target_site, null)
	if not site_data:
		return
	
	var target_pos = site_data.position
	var dir = (target_pos - global_position)
	dir.y = 0
	var dist = dir.length()
	
	if dist < 1.5:
		# At the site — start planting
		_switch_state(State.PLANTING)
		return
	
	# Move toward site
	var spd = move_speed * 0.8
	if limping:
		spd *= 0.6
	velocity.x = dir.normalized().x * spd
	velocity.z = dir.normalized().z * spd
	is_moving = true
	_face_direction(dir.normalized())

func _state_planting(delta):
	# Stand still and plant
	velocity.x = 0
	velocity.z = 0
	is_moving = false
	
	plant_progress += delta
	
	# If player gets close, stop planting and fight
	if player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist < 8.0 and _can_see_player():
			plant_progress = 0.0
			_switch_state(State.ATTACK)
			return
	
	if plant_progress >= plant_time:
		# Successfully planted!
		if has_node("/root/HackDefuse"):
			var hd = $"/root/HackDefuse"
			hd.try_plant(target_site)
			# After planting, become a regular fighter
			is_carrier = false
			plant_progress = 0.0
			_switch_state(State.PATROL)
		
		# Notify kill feed
		var p = get_tree().get_first_node_in_group("player")
		if p and p.has_method("add_kill_feed"):
			p.add_kill_feed("⚠ ENEMY PLANTED AT SITE %s!" % target_site)

func _fire_at_player():
	if not player:
		return
	
	# Must have LOS to actually hit
	if not _can_see_player():
		return
	
	# Accuracy with steep distance falloff — harder to hit at range
	var dist = global_position.distance_to(player.global_position)
	var hit_chance = accuracy * (1.0 - dist / (attack_range * 1.5))
	hit_chance = clamp(hit_chance, 0.05, 0.7)  # Max 70% hit chance (was 90%)
	
	# Wounded enemies much less accurate
	if wound_count > 0:
		hit_chance *= 0.5
	
	# Moving enemies are less accurate
	if is_moving:
		hit_chance *= 0.6
	
	# First shot of burst is less accurate (reaction time)
	if bullets_fired == 0:
		hit_chance *= 0.7
	
	if randf() < hit_chance:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
			if has_node("/root/AudioManager"):
				$"/root/AudioManager".play("hurt")
	
	# Muzzle flash on enemy
	var flash = _create_muzzle_flash()
	if flash:
		add_child(flash)

func _create_muzzle_flash() -> OmniLight3D:
	var light = OmniLight3D.new()
	light.light_color = Color(1.0, 0.8, 0.3)
	light.light_energy = 2.0
	light.omni_range = 3.0
	light.position = Vector3(0, 1.2, -0.4)
	get_tree().create_timer(0.06).timeout.connect(func():
		if is_instance_valid(light):
			light.queue_free()
	)
	return light

func _can_see_player() -> bool:
	if not player or not is_instance_valid(player):
		return false
	var dist = global_position.distance_to(player.global_position)
	if dist > detection_range:
		return false
	
	# Proper line-of-sight check using raycast — no more shooting through walls
	var space_state = get_world_3d().direct_space_state
	if not space_state:
		return false
	
	var from = global_position + Vector3(0, 1.2, 0)  # Eye height
	var to = player.global_position + Vector3(0, 0.8, 0)  # Player center mass
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]  # Don't hit self
	query.collision_mask = 1  # Only check against world geometry (layer 1)
	
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		# Nothing blocking — can see player
		return true
	
	# Check if what we hit is the player (or player's collision)
	var hit = result.get("collider", null)
	if hit and hit.is_in_group("player"):
		return true
	
	# Hit a wall or object — can't see player
	return false

# --- DAMAGE & WOUNDS ---

func take_damage(amount: float, headshot: bool = false):
	if state == State.DEAD or state == State.DYING:
		return
	
	var final_damage = amount
	var hit_zone = "body"
	
	if headshot:
		final_damage *= 2.0
		hit_zone = "head"
		# Head flinch is longer
		_apply_flinch(0.4)
		_spawn_hit_effect(Color(1, 0.2, 0.2), head_node.global_position if head_node else global_position + Vector3(0, 1.6, 0))
		# Notify player HUD
		var p = get_tree().get_first_node_in_group("player")
		if p and p.has_method("add_kill_feed"):
			p.add_kill_feed("HEADSHOT!")
	else:
		_apply_flinch(0.15)
		_spawn_hit_effect(Color(0.8, 0.1, 0.1), global_position + Vector3(0, 0.9, 0))
	
	# Wound accumulation
	wound_count += 1
	
	# Limp after enough wounds or leg shots
	if wound_count >= 3 and not limping:
		limping = true
		move_speed *= 0.6
	
	# Start bleeding at low health
	if not bleeding and health < max_health * 0.3:
		bleeding = true
		bleed_timer = 1.0
	
	health -= final_damage
	
	# Flash body red
	_flash_damage()
	
	if health <= 0:
		_start_death()
	else:
		# Getting hit switches to chase/attack
		if state == State.PATROL or state == State.IDLE:
			_switch_state(State.CHASE)

func _apply_flinch(duration: float):
	if state == State.DYING or state == State.DEAD:
		return
	previous_state = state
	state = State.FLINCH
	flinch_timer = duration
	
	# Visual flinch — jerk backward
	var knockback_dir = -global_transform.basis.z.normalized()
	velocity = knockback_dir * 2.0
	velocity.y = 0

func _flash_damage():
	if body_node and body_node.get_surface_override_material(0):
		var mat = body_node.get_surface_override_material(0)
		mat.albedo_color = Color(1, 0.2, 0.2)
		get_tree().create_timer(0.1).timeout.connect(func():
			if is_instance_valid(body_node) and mat:
				mat.albedo_color = original_body_color
		)

func _spawn_hit_effect(color: Color, pos: Vector3):
	# Blood splatter particles (simplified — mesh-based)
	for i in range(3):
		var particle = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.04
		sphere.height = 0.08
		particle.mesh = sphere
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 1.0
		particle.set_surface_override_material(0, mat)
		particle.global_position = pos + Vector3(randf_range(-0.2, 0.2), randf_range(-0.1, 0.1), randf_range(-0.2, 0.2))
		get_tree().root.add_child(particle)
		
		# Animate outward and fade
		var dir = Vector3(randf_range(-1, 1), randf_range(0.5, 1.5), randf_range(-1, 1)).normalized()
		var tween = get_tree().create_tween()
		tween.tween_property(particle, "global_position", particle.global_position + dir * 0.5, 0.3)
		tween.parallel().tween_property(particle, "scale", Vector3.ZERO, 0.3)
		tween.tween_callback(particle.queue_free)

# --- DEATH ---

func _start_death():
	state = State.DYING
	state_timer = 0.0
	health = 0
	
	# Reward player
	var p = get_tree().get_first_node_in_group("player")
	if p:
		p.sats += sats_reward
		p.kills += 1
	
	# Register kill streak
	if has_node("/root/KillStreaks"):
		$"/root/KillStreaks".register_kill()
	
	# Register scoreboard stats
	if has_node("/root/Scoreboard"):
		$"/root/Scoreboard".register_kill(false)
	
	# Show sats popup
	if has_node("/root/SatsPopup"):
		$"/root/SatsPopup".show_sats(sats_reward, enemy_type.to_upper())
	
	# Disable collision
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", true)
	
	# Death sound placeholder
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play("kill")
	
	# Determine death type based on last hit
	velocity = Vector3.ZERO

func _process_death(delta):
	state_timer += delta
	
	# Phase 1: Collapse (0-0.5s)
	if state_timer < 0.5:
		# Tilt forward/backward
		rotation.x = lerp(rotation.x, PI / 2.2, delta * 6.0)
		# Sink slightly
		position.y = lerp(position.y, -0.3, delta * 2.0)
	
	# Phase 2: Settle (0.5-1.5s)
	elif state_timer < 1.5:
		rotation.x = lerp(rotation.x, PI / 2.0, delta * 3.0)
		position.y = lerp(position.y, -0.5, delta)
	
	# Phase 3: Fade and remove (1.5-3s)
	elif state_timer < 3.0:
		# Fade out all mesh materials
		for child in get_children():
			if child is MeshInstance3D:
				var mat = child.get_surface_override_material(0)
				if mat:
					mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					mat.albedo_color.a = lerp(mat.albedo_color.a, 0.0, delta * 2.0)
	else:
		state = State.DEAD
		queue_free()

# --- ANIMATION ---

func _animate(delta):
	if state == State.DYING or state == State.DEAD:
		return
	
	bob_time += delta
	
	if is_moving:
		# Running bob — head and body move up/down
		var bob_speed = 10.0 if not limping else 6.0
		var bob_amount = 0.05
		
		if head_node:
			head_node.position.y = 1.6 + sin(bob_time * bob_speed) * bob_amount
		if body_node:
			body_node.position.y = 0.8 + sin(bob_time * bob_speed) * bob_amount * 0.5
			# Slight body lean in movement direction
			body_node.rotation.z = sin(bob_time * bob_speed * 0.5) * 0.03
		
		# Limping effect
		if limping:
			if body_node:
				body_node.rotation.x = sin(bob_time * bob_speed) * 0.08
	else:
		# Idle breathing
		if body_node:
			body_node.position.y = 0.8 + sin(bob_time * 2.0) * 0.01
			body_node.rotation.z = 0.0
			body_node.rotation.x = 0.0
		if head_node:
			head_node.position.y = 1.6 + sin(bob_time * 2.0) * 0.01
	
	is_moving = false

func _face_direction(dir: Vector3):
	if dir.length() < 0.01:
		return
	var target = global_position + dir
	look_at(Vector3(target.x, global_position.y, target.z))

func _switch_state(new_state: int):
	previous_state = state
	state = new_state
	state_timer = 0.0
	bullets_fired = 0
