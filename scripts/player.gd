extends CharacterBody3D

# === MOVEMENT ===
const SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 2.5
const MOUSE_SENSITIVITY = 0.002
const GRAVITY = 9.8

# === CAMERA ===
@onready var camera: Camera3D = $"Camera3D"
@onready var raycast: RayCast3D = $"Camera3D/RayCast3D"

# === STATE ===
var health: int = 100
var armor: int = 0
var sats: int = 16000
var kills: int = 0
var current_weapon: int = 0
var recoil_vertical: float = 0.0
var recoil_horizontal: float = 0.0
var recoil_recovery: float = 0.0
var last_shot_time: float = 0.0
var mouse_captured: bool = false
var is_crouching: bool = false
var is_sprinting: bool = false
var is_reloading: bool = false
var reload_timer: float = 0.0
var shots_fired: int = 0  # For recoil pattern
var mouse_held: bool = false  # For full-auto fire
var footstep_timer: float = 0.0
var footstep_interval: float = 0.45

# === WEAPON BOB ===
var bob_time: float = 0.0
var bob_amount: float = 0.0
var weapon_sway_x: float = 0.0
var weapon_sway_y: float = 0.0

# === WEAPON MODEL ===
var weapon_model_builder: Node3D
var fps_model: Node3D  # GLB model instance
var fps_anim_player: AnimationPlayer
var current_anim: String = ""

# === MOVEMENT ACCURACY MODIFIERS (CS 1.6 style) ===
# Standing still = base accuracy
# Crouching = much tighter
# Walking = moderate penalty
# Running = huge penalty
# Jumping/airborne = basically useless
# Spraying = gets progressively worse

var weapons = [
	{"name": "AK-B7", "ammo": 30, "max_ammo": 30, "reserve": 90,
	 "damage": 25, "fire_rate": 0.1, "auto": true,
	 "recoil": 0.09, "recoil_h": 0.035,
	 "spread_base": 0.008, "spread_move": 0.045, "spread_run": 0.09,
	 "spread_jump": 0.25, "spread_crouch": 0.004, "spread_spray": 0.005,
	 "reload_time": 2.2, "recoil_pattern": "ak"},
	{"name": "BEAGLE", "ammo": 7, "max_ammo": 7, "reserve": 35,
	 "damage": 55, "fire_rate": 0.4, "auto": false,
	 "recoil": 0.15, "recoil_h": 0.06,
	 "spread_base": 0.012, "spread_move": 0.035, "spread_run": 0.07,
	 "spread_jump": 0.2, "spread_crouch": 0.008, "spread_spray": 0.008,
	 "reload_time": 1.8, "recoil_pattern": "pistol"},
	{"name": "SABOT", "ammo": 5, "max_ammo": 5, "reserve": 20,
	 "damage": 120, "fire_rate": 0.8, "auto": false,
	 "recoil": 0.3, "recoil_h": 0.02,
	 "spread_base": 0.001, "spread_move": 0.06, "spread_run": 0.15,
	 "spread_jump": 0.35, "spread_crouch": 0.0005, "spread_spray": 0.002,
	 "reload_time": 3.0, "recoil_pattern": "sniper"},
	{"name": "M4-SAT", "ammo": 25, "max_ammo": 25, "reserve": 75,
	 "damage": 28, "fire_rate": 0.09, "auto": true,
	 "recoil": 0.065, "recoil_h": 0.025,
	 "spread_base": 0.006, "spread_move": 0.035, "spread_run": 0.07,
	 "spread_jump": 0.22, "spread_crouch": 0.003, "spread_spray": 0.004,
	 "reload_time": 2.0, "recoil_pattern": "m4"}
]

# CS-style recoil patterns (vertical, horizontal offsets per shot)
var recoil_patterns = {
	"ak": [
		Vector2(0, -1.0), Vector2(0, -1.2), Vector2(0, -1.5),
		Vector2(-0.3, -1.8), Vector2(-0.5, -2.0), Vector2(0.2, -1.6),
		Vector2(0.6, -1.3), Vector2(0.8, -1.0), Vector2(-0.4, -1.5),
		Vector2(-0.7, -1.8), Vector2(0.3, -1.2), Vector2(0.5, -0.8),
		Vector2(-0.2, -1.4), Vector2(-0.6, -1.6), Vector2(0.4, -1.0),
		Vector2(0.7, -0.7), Vector2(-0.3, -1.2), Vector2(-0.5, -1.4),
		Vector2(0.2, -0.9), Vector2(0.4, -0.6), Vector2(-0.2, -1.0),
		Vector2(-0.4, -1.2), Vector2(0.3, -0.8), Vector2(0.5, -0.5),
		Vector2(-0.1, -0.9), Vector2(-0.3, -1.1), Vector2(0.2, -0.7),
		Vector2(0.4, -0.4), Vector2(-0.2, -0.8), Vector2(-0.3, -1.0),
	],
	"m4": [
		Vector2(0, -0.8), Vector2(0, -1.0), Vector2(0, -1.2),
		Vector2(-0.2, -1.4), Vector2(-0.4, -1.5), Vector2(0.1, -1.2),
		Vector2(0.4, -1.0), Vector2(0.6, -0.8), Vector2(-0.3, -1.2),
		Vector2(-0.5, -1.4), Vector2(0.2, -1.0), Vector2(0.4, -0.7),
		Vector2(-0.1, -1.1), Vector2(-0.4, -1.3), Vector2(0.3, -0.8),
		Vector2(0.5, -0.5), Vector2(-0.2, -1.0), Vector2(-0.4, -1.2),
		Vector2(0.1, -0.7), Vector2(0.3, -0.4), Vector2(-0.1, -0.8),
		Vector2(-0.3, -1.0), Vector2(0.2, -0.6), Vector2(0.4, -0.3),
		Vector2(-0.1, -0.7),
	],
	"pistol": [
		Vector2(0, -2.0), Vector2(0.2, -1.5), Vector2(-0.2, -1.0),
		Vector2(0.1, -1.8), Vector2(-0.1, -1.2), Vector2(0.15, -0.8),
		Vector2(-0.15, -1.5),
	],
	"sniper": [
		Vector2(0, -4.0), Vector2(0, -2.0), Vector2(0, -1.5),
		Vector2(0, -3.5), Vector2(0, -1.8),
	],
}

func _ready():
	add_to_group("player")
	_setup_weapon_model()

func _setup_weapon_model():
	# Try to load GLB model first
	var ak_model_path = "res://assets/models/weapons/ak74m/scene.gltf"
	if ResourceLoader.exists(ak_model_path):
		var scene = load(ak_model_path)
		if scene and scene is PackedScene:
			fps_model = scene.instantiate()
			fps_model.name = "FPSModel"
			# CS 1.6 style viewmodel positioning:
			# Model from Sketchfab has internal 100x scale (Blender cm → m)
			# and -90° X rotation. We scale down and position to lower-right.
			# Tweak these values to get the classic CS 1.6 look:
			#   - Arms enter from bottom-right
			#   - Barrel points roughly at crosshair
			#   - Gun fills lower-right quadrant
			fps_model.scale = Vector3(0.007, 0.007, 0.007)
			fps_model.position = Vector3(0.22, -0.35, -0.3)
			# Rotate to face forward: model faces +Y in Blender,
			# Godot camera looks -Z, so rotate 180° on Y
			fps_model.rotation_degrees = Vector3(0, 180, 0)
			
			var holder = find_child("WeaponHolder", true, false)
			if holder:
				# Hide old static meshes
				for child in holder.get_children():
					if child is MeshInstance3D or child is OmniLight3D:
						child.visible = false
				holder.add_child(fps_model)
			else:
				camera.add_child(fps_model)
			
			# Find animation player
			fps_anim_player = _find_anim_player(fps_model)
			if fps_anim_player:
				_play_anim("Rig|AK_Idle")
			return
	
	# Fallback: procedural weapon models
	var weapon_script = load("res://scripts/weapon_models.gd")
	if weapon_script:
		weapon_model_builder = Node3D.new()
		weapon_model_builder.set_script(weapon_script)
		weapon_model_builder.name = "WeaponModels"
		var holder = find_child("WeaponHolder", true, false)
		if holder:
			for child in holder.get_children():
				if child is MeshInstance3D:
					child.visible = false
			holder.add_child(weapon_model_builder)
		else:
			camera.add_child(weapon_model_builder)
		_update_weapon_model()

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = _find_anim_player(child)
		if result:
			return result
	return null

func _play_anim(anim_name: String, speed: float = 1.0):
	if not fps_anim_player:
		return
	if not fps_anim_player.has_animation(anim_name):
		return
	if current_anim == anim_name and fps_anim_player.is_playing():
		return
	current_anim = anim_name
	fps_anim_player.play(anim_name, -1, speed)

func _input(event):
	# Capture mouse on first click
	if event is InputEventMouseButton and event.pressed and not mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true
		return
	
	if not mouse_captured:
		return
	
	# Block mouse input while menus are open
	var buy_menu = get_tree().root.find_child("BuyMenu", true, false)
	if buy_menu and buy_menu.is_open:
		return
	if has_node("/root/SettingsMenu") and $"/root/SettingsMenu".is_open:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		# Weapon sway from mouse movement
		weapon_sway_x -= event.relative.x * 0.0003
		weapon_sway_y -= event.relative.y * 0.0003
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_held = event.pressed
		if event.pressed:
			shoot()  # First shot on click
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_B:
				var bm_toggle = get_tree().root.find_child("BuyMenu", true, false)
				if bm_toggle and bm_toggle.has_method("toggle_menu"):
					bm_toggle.toggle_menu()
				return
			KEY_R: reload_weapon()
			KEY_1: switch_weapon(0)
			KEY_2: switch_weapon(1)
			KEY_3: switch_weapon(2)
			KEY_4: switch_weapon(3)
			KEY_C: toggle_crouch()
			KEY_CTRL: toggle_crouch()
			KEY_E: _interact_hack_site()
			KEY_G:
				if has_node("/root/Grenades"):
					$"/root/Grenades".throw_grenade()
			KEY_Q:
				_drop_current_weapon()
			KEY_ESCAPE:
				var bm = get_tree().root.find_child("BuyMenu", true, false)
				if bm and bm.is_open:
					bm.close_menu()
					return
				if has_node("/root/SettingsMenu"):
					$"/root/SettingsMenu".toggle()
					return
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_captured = false

func _physics_process(delta):
	# Gravity + Jump
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_key_pressed(KEY_SPACE):
		velocity.y = 4.5  # Jump force
	
	# Determine speed
	is_sprinting = Input.is_key_pressed(KEY_SHIFT) and not is_crouching
	var spd = SPEED
	if is_sprinting:
		spd = SPRINT_SPEED
	elif is_crouching:
		spd = CROUCH_SPEED
	
	# Movement input
	var input_x = 0.0
	var input_z = 0.0
	if Input.is_key_pressed(KEY_W): input_z -= 1
	if Input.is_key_pressed(KEY_S): input_z += 1
	if Input.is_key_pressed(KEY_A): input_x -= 1
	if Input.is_key_pressed(KEY_D): input_x += 1
	
	var dir = (transform.basis * Vector3(input_x, 0, input_z)).normalized()
	var is_moving = dir.length() > 0.1
	
	if dir:
		velocity.x = dir.x * spd
		velocity.z = dir.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd * delta * 10)
		velocity.z = move_toward(velocity.z, 0, spd * delta * 10)
	
	# === RECOIL RECOVERY (CS 1.6: slow recovery, punishes spraying) ===
	# Vertical recoil recovery — slower than application, so spraying pulls up
	if recoil_vertical != 0:
		var recovery_speed = 2.5  # Slow recovery = have to pull down manually
		var recovery = recoil_vertical * recovery_speed * delta
		camera.rotation.x -= recovery
		recoil_vertical *= (1.0 - recovery_speed * delta)
		if abs(recoil_vertical) < 0.0005:
			recoil_vertical = 0
	
	# Horizontal recoil recovery — also slow
	if recoil_horizontal != 0:
		var h_recovery = recoil_horizontal * 3.0 * delta
		rotate_y(-h_recovery)
		recoil_horizontal *= (1.0 - 3.0 * delta)
		if abs(recoil_horizontal) < 0.0005:
			recoil_horizontal = 0
	
	# Reset shots_fired when not shooting
	var now = Time.get_ticks_msec() / 1000.0
	var w = weapons[current_weapon]
	if now - last_shot_time > w.fire_rate * 2.5:
		shots_fired = max(0, shots_fired - 1)
	if now - last_shot_time > w.fire_rate * 5.0:
		shots_fired = 0
	
	# === CROUCH INTERPOLATION ===
	var target_y = 0.3 if is_crouching else 0.6
	camera.position.y = lerp(camera.position.y, target_y, delta * 10.0)
	
	# === WEAPON BOB ===
	_update_weapon_bob(delta, is_moving)
	
	# === RELOAD TIMER ===
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			_finish_reload()
	
	# === FPS ANIMATION STATE ===
	_update_fps_animation(is_moving)
	
	# Footstep sounds
	if is_moving and is_on_floor():
		var step_speed = 0.45
		if is_sprinting: step_speed = 0.3
		elif is_crouching: step_speed = 0.65
		footstep_timer -= delta
		if footstep_timer <= 0:
			footstep_timer = step_speed
			if has_node("/root/AudioManager"):
				$"/root/AudioManager".play("footstep")
	else:
		footstep_timer = 0.0
	
	# Full-auto fire when holding mouse (only for auto weapons like AK, M4)
	var current_w = weapons[current_weapon]
	if mouse_held and mouse_captured and current_w.get("auto", false):
		var bm = get_tree().root.find_child("BuyMenu", true, false)
		if not (bm and bm.is_open):
			shoot()
	
	# Hack/defuse interaction check
	_physics_process_hack_interaction()
	
	move_and_slide()
	update_hud()

func _update_weapon_bob(delta: float, is_moving: bool):
	var holder = find_child("WeaponHolder", true, false)
	if not holder:
		return
	
	if is_moving and not is_reloading:
		var bob_speed = 8.0
		var bob_h = 0.003
		var bob_v = 0.004
		if is_sprinting:
			bob_speed = 12.0
			bob_h = 0.005
			bob_v = 0.007
		elif is_crouching:
			bob_speed = 5.0
			bob_h = 0.002
			bob_v = 0.003
		
		bob_time += delta * bob_speed
		holder.position.x = 0.0 + sin(bob_time) * bob_h
		holder.position.y = 0.0 + abs(sin(bob_time)) * bob_v
	else:
		# Idle breathing
		bob_time += delta * 1.5
		holder.position.x = lerp(holder.position.x, sin(bob_time * 0.5) * 0.001, delta * 3.0)
		holder.position.y = lerp(holder.position.y, sin(bob_time) * 0.001, delta * 3.0)
	
	# Weapon sway (from mouse movement)
	weapon_sway_x = lerp(weapon_sway_x, 0.0, delta * 8.0)
	weapon_sway_y = lerp(weapon_sway_y, 0.0, delta * 8.0)
	holder.position.x += clamp(weapon_sway_x, -0.02, 0.02)
	holder.position.y += clamp(weapon_sway_y, -0.015, 0.015)

func _update_fps_animation(is_moving: bool):
	if not fps_anim_player:
		return
	if is_reloading:
		return  # Don't interrupt reload
	
	if is_moving:
		if is_sprinting:
			_play_anim("Rig|AK_Run")
		else:
			_play_anim("Rig|AK_Walk")
	else:
		_play_anim("Rig|AK_Idle")

func toggle_crouch():
	is_crouching = not is_crouching

func shoot():
	if is_reloading:
		return
	var w = weapons[current_weapon]
	var now = Time.get_ticks_msec() / 1000.0
	if w.ammo <= 0 or now - last_shot_time < w.fire_rate:
		return
	
	last_shot_time = now
	w.ammo -= 1
	
	# === CS-STYLE RECOIL ===
	var pattern_name = w.get("recoil_pattern", "ak")
	var pattern = recoil_patterns.get(pattern_name, recoil_patterns["ak"])
	var pattern_idx = min(shots_fired, pattern.size() - 1)
	var recoil_offset = pattern[pattern_idx]
	
	# Apply recoil to camera — CS 1.6 style (strong, need to counter-strafe)
	var v_recoil = recoil_offset.y * w.recoil
	var h_recoil = recoil_offset.x * w.get("recoil_h", 0.02)
	
	# Stance modifiers for recoil
	if is_crouching:
		v_recoil *= 0.55  # Crouching helps a lot
		h_recoil *= 0.55
	elif not is_on_floor():
		v_recoil *= 1.8  # Jumping makes recoil way worse
		h_recoil *= 2.0
	elif is_sprinting:
		v_recoil *= 1.4  # Running increases recoil
		h_recoil *= 1.5
	
	camera.rotation.x += v_recoil
	rotate_y(h_recoil)
	recoil_vertical += v_recoil
	recoil_horizontal += h_recoil
	
	shots_fired += 1
	
	# === CS 1.6 ACCURACY MODEL ===
	# Base spread depends on stance + movement
	var spread = w.get("spread_base", 0.008)
	
	# Movement state penalties (these stack logically)
	var vel_h = Vector2(velocity.x, velocity.z).length()
	if not is_on_floor():
		# Airborne — nearly useless accuracy
		spread = w.get("spread_jump", 0.25)
	elif is_sprinting or vel_h > SPRINT_SPEED * 0.8:
		# Running — very inaccurate
		spread = w.get("spread_run", 0.09)
	elif vel_h > SPEED * 0.3:
		# Walking — moderate penalty
		spread = w.get("spread_move", 0.045)
	elif is_crouching:
		# Crouching + still = best accuracy
		spread = w.get("spread_crouch", 0.004)
	
	# Spray penalty — gets worse with sustained fire (CS 1.6 core mechanic)
	var spray_penalty = shots_fired * w.get("spread_spray", 0.005)
	spread += spray_penalty
	
	# Sound
	if has_node("/root/AudioManager"):
		match w.name:
			"BEAGLE": $"/root/AudioManager".play("shoot_pistol")
			"SABOT": $"/root/AudioManager".play("shoot_sniper")
			_: $"/root/AudioManager".play("shoot")
	
	# Muzzle flash
	var mf = find_child("MuzzleFlash", true, false)
	if mf:
		mf.light_energy = 3.0
		get_tree().create_timer(0.05).timeout.connect(func(): 
			if is_instance_valid(mf): mf.light_energy = 0)
	
	# Play shot animation
	if fps_anim_player and fps_anim_player.has_animation("Rig|AK_Shot"):
		fps_anim_player.play("Rig|AK_Shot", -1, 2.0)
		current_anim = "Rig|AK_Shot"
	
	# === RAYCAST HIT (with spread) ===
	if raycast:
		# Apply spread to raycast direction
		var spread_x = randf_range(-spread, spread)
		var spread_y = randf_range(-spread, spread)
		raycast.target_position = Vector3(spread_x, spread_y, -100)
		raycast.force_raycast_update()
		
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target and target.has_method("take_damage"):
				var hit_pos = raycast.get_collision_point()
				var is_headshot = hit_pos.y > target.global_position.y + 1.3
				var damage = w.damage * (2 if is_headshot else 1)
				target.take_damage(damage, is_headshot)
				if is_headshot:
					add_kill_feed("HEADSHOT!")
					if has_node("/root/AudioManager"):
						$"/root/AudioManager".play("headshot")
				else:
					if has_node("/root/AudioManager"):
						$"/root/AudioManager".play("hit")
		
		# Reset raycast
		raycast.target_position = Vector3(0, 0, -100)

func reload_weapon():
	if is_reloading:
		return
	var w = weapons[current_weapon]
	if w.ammo >= w.max_ammo or w.reserve <= 0:
		return
	
	is_reloading = true
	reload_timer = w.get("reload_time", 2.0)
	
	# Play reload animation
	if fps_anim_player:
		if fps_anim_player.has_animation("Rig|AK_Reload"):
			fps_anim_player.play("Rig|AK_Reload")
			current_anim = "Rig|AK_Reload"
	
	# Sound
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play("reload")

func _finish_reload():
	is_reloading = false
	var w = weapons[current_weapon]
	var give = min(w.max_ammo - w.ammo, w.reserve)
	w.ammo += give
	w.reserve -= give
	shots_fired = 0

func switch_weapon(idx: int):
	if idx >= weapons.size():
		return
	if is_reloading:
		is_reloading = false  # Cancel reload on weapon switch
	current_weapon = idx
	shots_fired = 0
	_update_weapon_model()
	
	# Play draw animation
	if fps_anim_player and fps_anim_player.has_animation("Rig|AK_Draw"):
		fps_anim_player.play("Rig|AK_Draw")
		current_anim = "Rig|AK_Draw"

func _update_weapon_model():
	if weapon_model_builder and weapon_model_builder.has_method("build_weapon"):
		weapon_model_builder.build_weapon(weapons[current_weapon].name)

func _drop_current_weapon():
	if has_node("/root/WeaponDrops"):
		var w = weapons[current_weapon].duplicate()
		$"/root/WeaponDrops".drop_weapon(self, w)
		add_kill_feed("Dropped %s" % w.name)

func _interact_hack_site():
	if not has_node("/root/HackDefuse"):
		return
	var hd = $"/root/HackDefuse"
	
	# Check if near a hack site
	var nearest = hd.get_nearest_site(global_position)
	if nearest.distance > 3.0:
		add_kill_feed("No hack site nearby")
		return
	
	# If device is planted, try to defuse
	if hd.device_planted:
		if not hd.is_defusing:
			hd.try_defuse()
			add_kill_feed("Defusing 51%% attack at Site %s..." % nearest.site)
	else:
		# In single-player, enemies plant. Player defuses.
		# For now, allow player to "test plant" 
		pass

func _physics_process_hack_interaction():
	# Cancel plant/defuse if player moves or shoots
	if has_node("/root/HackDefuse"):
		var hd = $"/root/HackDefuse"
		if hd.is_defusing:
			var vel_h = Vector2(velocity.x, velocity.z).length()
			if vel_h > 0.5:
				hd.cancel_defuse()

func take_damage(amount: int):
	var dmg = amount
	if armor > 0:
		var absorbed = dmg * 0.5
		armor = max(0, armor - absorbed)
		dmg -= absorbed
	health -= int(dmg)
	# Flash damage overlay
	var overlay = get_tree().root.find_child("DamageOverlay", true, false)
	if overlay:
		overlay.color = Color(1, 0, 0, 0.3)
		get_tree().create_timer(0.15).timeout.connect(func(): 
			if is_instance_valid(overlay): overlay.color = Color(1, 0, 0, 0))
	if health <= 0:
		die()

func die():
	# Track death
	if has_node("/root/Scoreboard"):
		$"/root/Scoreboard".register_death()
	# Show death screen
	var death_screen = get_tree().root.find_child("DeathScreen", true, false)
	if death_screen and death_screen.has_method("show_death"):
		var round_num = 1
		var spawner = get_tree().root.find_child("EnemySpawner", true, false)
		if spawner:
			round_num = spawner.round_num
		var sats_lost = death_screen.show_death(kills, sats, round_num)
		if sats_lost:
			sats -= sats_lost
	else:
		# Fallback: just reload
		get_tree().reload_current_scene()

func add_kill_feed(text: String):
	var feed = get_tree().root.find_child("KillFeed", true, false)
	if feed:
		var label = Label.new()
		label.text = text
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
		feed.add_child(label)
		get_tree().create_timer(5.0).timeout.connect(func(): 
			if is_instance_valid(label): label.queue_free())

func update_hud():
	var w = weapons[current_weapon]
	var hp = get_tree().root.find_child("HealthLabel", true, false)
	if hp: hp.text = "HP: %d" % health
	var ar = get_tree().root.find_child("ArmorLabel", true, false)
	if ar: ar.text = "🛡 %d" % armor if armor > 0 else ""
	var sl = get_tree().root.find_child("SatsLabel", true, false)
	if sl: sl.text = "₿ %s" % str(sats)
	var al = get_tree().root.find_child("AmmoLabel", true, false)
	if al: al.text = "%d / %d" % [w.ammo, w.reserve]
	var wl = get_tree().root.find_child("WeaponLabel", true, false)
	if wl: wl.text = w.name
	
	# Stance indicator
	var stance = get_tree().root.find_child("StanceLabel", true, false)
	if stance:
		if is_crouching:
			stance.text = "CROUCHING"
		elif is_sprinting:
			stance.text = "SPRINTING"
		elif is_reloading:
			stance.text = "RELOADING..."
		else:
			stance.text = ""
	
	# Crosshair spread indicator
	_update_crosshair()

func _update_crosshair():
	var w = weapons[current_weapon]
	# Calculate current spread the same way as shoot()
	var spread = w.get("spread_base", 0.008)
	var vel_h = Vector2(velocity.x, velocity.z).length()
	if not is_on_floor():
		spread = w.get("spread_jump", 0.25)
	elif is_sprinting or vel_h > SPRINT_SPEED * 0.8:
		spread = w.get("spread_run", 0.09)
	elif vel_h > SPEED * 0.3:
		spread = w.get("spread_move", 0.045)
	elif is_crouching:
		spread = w.get("spread_crouch", 0.004)
	spread += shots_fired * w.get("spread_spray", 0.005)
	
	# Dynamic crosshair — wider = less accurate
	var cross_size = clamp(spread * 600.0, 4.0, 40.0)
	
	var ch = get_tree().root.find_child("CrosshairH", true, false)
	var cv = get_tree().root.find_child("CrosshairV", true, false)
	if ch:
		ch.offset_left = -cross_size
		ch.offset_right = cross_size
	if cv:
		cv.offset_top = -cross_size
		cv.offset_bottom = cross_size
