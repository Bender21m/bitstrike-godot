extends Node3D

var enemy_data = {
	"banker": {
		"color": Color(0.4, 0.4, 0.5), "hp": 60, "speed": 3.0, "damage": 12,
		"reward": 5000, "accuracy": 0.5, "can_shoot": true, "burst": 3,
		"detection": 16.0, "attack_range": 10.0
	},
	"shitcoiner": {
		"color": Color(0.6, 0.2, 0.8), "hp": 40, "speed": 4.5, "damage": 8,
		"reward": 3000, "accuracy": 0.35, "can_shoot": true, "burst": 5,
		"detection": 14.0, "attack_range": 8.0
	},
	"bear": {
		"color": Color(0.7, 0.3, 0.3), "hp": 70, "speed": 3.5, "damage": 15,
		"reward": 4000, "accuracy": 0.0, "can_shoot": false, "burst": 0,
		"detection": 12.0, "attack_range": 1.8
	},
	"roger": {
		"color": Color(0.0, 0.5, 0.0), "hp": 45, "speed": 5.0, "damage": 8,
		"reward": 6000, "accuracy": 0.4, "can_shoot": true, "burst": 2,
		"detection": 20.0, "attack_range": 12.0
	},
	"whale": {
		"color": Color(0.27, 0.53, 0.8), "hp": 150, "speed": 2.0, "damage": 20,
		"reward": 8000, "accuracy": 0.6, "can_shoot": true, "burst": 4,
		"detection": 22.0, "attack_range": 14.0
	},
	"fed": {
		"color": Color(0.12, 0.12, 0.2), "hp": 250, "speed": 2.0, "damage": 30,
		"reward": 21000, "accuracy": 0.7, "can_shoot": true, "burst": 6,
		"detection": 24.0, "attack_range": 16.0
	},
}

var map_data = [
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,
	1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,
	1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
]

var enemies: Array = []
var round_num: int = 1
var player: Node3D
var ai_script = preload("res://scripts/enemy_ai.gd")
var satoshi_script = preload("res://scripts/satoshi_boss.gd")
var satoshi_spawned_this_round: bool = false

func _ready():
	player = get_tree().get_first_node_in_group("player")
	# Round 1 starts gentler
	spawn_wave(3)

var carrier_spawned: bool = false

func spawn_wave(count: int):
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies.clear()
	satoshi_spawned_this_round = false
	carrier_spawned = false
	update_round_label()
	
	# Start hack/defuse game mode if available
	if has_node("/root/HackDefuse") and round_num >= 2:
		var hd = $"/root/HackDefuse"
		if round_num == 2 and hd.round_state == 0:
			hd.start_game_mode()
	
	# Chance to spawn Satoshi after round 5
	if round_num >= 5 and randf() < 0.03 * (round_num - 4):
		_spawn_satoshi()
	
	# Gradual type introduction
	var types = ["banker"]
	if round_num >= 2:
		types.append("shitcoiner")
	if round_num >= 3:
		types.append("bear")
	if round_num >= 4:
		types.append("roger")
	if round_num >= 5:
		types.append("whale")
	
	for i in range(count):
		var type = types[randi() % types.size()]
		if round_num >= 5 and randf() < 0.15:
			type = "fed"
		
		var pos = find_spawn_pos()
		var enemy = create_enemy(type, pos)
		add_child(enemy)
		enemies.append(enemy)

func find_spawn_pos() -> Vector3:
	for _attempt in range(50):
		var x = randi_range(2, 21)
		var z = randi_range(2, 21)
		if map_data[z * 24 + x] == 0:
			var pos = Vector3(x + 0.5, 0, z + 0.5)
			if player and pos.distance_to(player.global_position) > 10:
				return pos
	return Vector3(20, 0, 20)

func create_enemy(type: String, pos: Vector3) -> CharacterBody3D:
	var data = enemy_data.get(type, enemy_data["banker"])
	
	var enemy = CharacterBody3D.new()
	enemy.name = "Enemy_%s_%d" % [type, randi()]
	enemy.position = pos
	
	# Collision capsule
	var col = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	col.shape = capsule
	col.position.y = 0.9
	enemy.add_child(col)
	
	# --- BODY ---
	var body_mesh = MeshInstance3D.new()
	body_mesh.name = "Body"
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.25
	capsule_mesh.height = 1.2
	body_mesh.mesh = capsule_mesh
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = data.color
	body_mat.roughness = 0.7
	body_mesh.set_surface_override_material(0, body_mat)
	body_mesh.position.y = 0.8
	enemy.add_child(body_mesh)
	
	# --- HEAD ---
	var head_mesh = MeshInstance3D.new()
	head_mesh.name = "Head"
	var sphere = SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	head_mesh.mesh = sphere
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.8, 0.6, 0.45)
	head_mat.roughness = 0.6
	head_mesh.set_surface_override_material(0, head_mat)
	head_mesh.position.y = 1.6
	enemy.add_child(head_mesh)
	
	# --- EYES (red, emissive) ---
	for side in [-1, 1]:
		var eye = MeshInstance3D.new()
		var eye_sphere = SphereMesh.new()
		eye_sphere.radius = 0.035
		eye_sphere.height = 0.07
		eye.mesh = eye_sphere
		var eye_mat = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1, 0, 0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1, 0, 0)
		eye_mat.emission_energy_multiplier = 2.0
		eye.set_surface_override_material(0, eye_mat)
		eye.position = Vector3(side * 0.06, 1.63, -0.15)
		enemy.add_child(eye)
	
	# --- ARMS (simple boxes for visual bulk) ---
	for side in [-1, 1]:
		var arm = MeshInstance3D.new()
		arm.name = "Arm_L" if side == -1 else "Arm_R"
		var arm_mesh = BoxMesh.new()
		arm_mesh.size = Vector3(0.1, 0.6, 0.1)
		arm.mesh = arm_mesh
		var arm_mat = StandardMaterial3D.new()
		arm_mat.albedo_color = data.color.darkened(0.2)
		arm_mat.roughness = 0.7
		arm.set_surface_override_material(0, arm_mat)
		arm.position = Vector3(side * 0.35, 0.9, 0)
		enemy.add_child(arm)
	
	# --- LEGS ---
	for side in [-1, 1]:
		var leg = MeshInstance3D.new()
		leg.name = "Leg_L" if side == -1 else "Leg_R"
		var leg_mesh = BoxMesh.new()
		leg_mesh.size = Vector3(0.1, 0.5, 0.1)
		leg.mesh = leg_mesh
		var leg_mat = StandardMaterial3D.new()
		leg_mat.albedo_color = data.color.darkened(0.3)
		leg_mat.roughness = 0.8
		leg.set_surface_override_material(0, leg_mat)
		leg.position = Vector3(side * 0.12, 0.25, 0)
		enemy.add_child(leg)
	
	# --- TYPE-SPECIFIC VISUALS ---
	if type == "banker":
		# Red tie
		var tie = MeshInstance3D.new()
		var tie_mesh = BoxMesh.new()
		tie_mesh.size = Vector3(0.04, 0.3, 0.015)
		tie.mesh = tie_mesh
		var tie_mat = StandardMaterial3D.new()
		tie_mat.albedo_color = Color(0.8, 0.1, 0.1)
		tie.set_surface_override_material(0, tie_mat)
		tie.position = Vector3(0, 0.9, -0.22)
		enemy.add_child(tie)
	
	elif type == "shitcoiner":
		# Purple glow aura
		var glow = OmniLight3D.new()
		glow.light_color = Color(0.6, 0.2, 0.8)
		glow.light_energy = 0.5
		glow.omni_range = 3.0
		glow.position.y = 0.8
		enemy.add_child(glow)
	
	elif type == "bear":
		# Bigger, no ranged
		body_mesh.scale = Vector3(1.3, 1.1, 1.3)
		head_mesh.scale = Vector3(1.2, 1.2, 1.2)
	
	elif type == "fed":
		# Dark hat
		var hat = MeshInstance3D.new()
		var hat_mesh = CylinderMesh.new()
		hat_mesh.top_radius = 0.15
		hat_mesh.bottom_radius = 0.18
		hat_mesh.height = 0.08
		hat.mesh = hat_mesh
		var hat_mat = StandardMaterial3D.new()
		hat_mat.albedo_color = Color(0.05, 0.05, 0.1)
		hat.set_surface_override_material(0, hat_mat)
		hat.position.y = 1.85
		enemy.add_child(hat)
		# Sunglasses
		var glasses = MeshInstance3D.new()
		var gl_mesh = BoxMesh.new()
		gl_mesh.size = Vector3(0.25, 0.06, 0.02)
		glasses.mesh = gl_mesh
		var gl_mat = StandardMaterial3D.new()
		gl_mat.albedo_color = Color(0.02, 0.02, 0.02)
		gl_mat.metallic = 0.9
		glasses.set_surface_override_material(0, gl_mat)
		glasses.position = Vector3(0, 1.64, -0.18)
		enemy.add_child(glasses)
	
	elif type == "whale":
		# Big and bulky
		body_mesh.scale = Vector3(1.5, 1.2, 1.5)
		head_mesh.scale = Vector3(1.3, 1.3, 1.3)
		# Blue glow
		var glow = OmniLight3D.new()
		glow.light_color = Color(0.2, 0.4, 0.8)
		glow.light_energy = 0.4
		glow.omni_range = 4.0
		glow.position.y = 1.0
		enemy.add_child(glow)
	
	# --- HEALTH BAR (floating above head) ---
	var health_bar = MeshInstance3D.new()
	health_bar.name = "HealthBar"
	var bar_mesh = BoxMesh.new()
	bar_mesh.size = Vector3(0.5, 0.04, 0.02)
	health_bar.mesh = bar_mesh
	var bar_mat = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0, 0.8, 0)
	bar_mat.emission_enabled = true
	bar_mat.emission = Color(0, 0.6, 0)
	bar_mat.emission_energy_multiplier = 0.5
	health_bar.set_surface_override_material(0, bar_mat)
	health_bar.position = Vector3(0, 2.0, 0)
	enemy.add_child(health_bar)
	
	# Background bar
	var bg_bar = MeshInstance3D.new()
	bg_bar.name = "HealthBarBG"
	var bg_mesh = BoxMesh.new()
	bg_mesh.size = Vector3(0.52, 0.05, 0.01)
	bg_bar.mesh = bg_mesh
	var bg_mat = StandardMaterial3D.new()
	bg_mat.albedo_color = Color(0.2, 0, 0)
	bg_bar.set_surface_override_material(0, bg_mat)
	bg_bar.position = Vector3(0, 2.0, 0.01)
	enemy.add_child(bg_bar)
	
	# Assign AI script
	enemy.set_script(ai_script)
	enemy.add_to_group("enemies")
	
	# Call setup after adding to tree (deferred)
	enemy.call_deferred("setup", type, data)
	
	return enemy

func _process(_delta):
	# Update health bars to face camera
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var hb = enemy.find_child("HealthBar", false, false)
		var hbbg = enemy.find_child("HealthBarBG", false, false)
		if not hb:
			continue
		
		# Billboard health bar toward camera
		var cam_pos = camera.global_position
		var bar_pos = hb.global_position
		hb.look_at(cam_pos)
		if hbbg:
			hbbg.look_at(cam_pos)
		
		# Scale health bar based on current hp
		if enemy.has_method("_ready"):  # Has AI script
			var hp_ratio = clamp(enemy.health / enemy.max_health, 0.0, 1.0)
			hb.scale.x = hp_ratio
			# Color: green -> yellow -> red
			var mat = hb.get_surface_override_material(0)
			if mat:
				if hp_ratio > 0.5:
					mat.albedo_color = Color(0, 0.8, 0)
					mat.emission = Color(0, 0.6, 0)
				elif hp_ratio > 0.25:
					mat.albedo_color = Color(0.9, 0.7, 0)
					mat.emission = Color(0.7, 0.5, 0)
				else:
					mat.albedo_color = Color(0.9, 0.1, 0)
					mat.emission = Color(0.7, 0, 0)

var waiting_for_buy_phase: bool = false
var round_cleared: bool = false

func _physics_process(_delta):
	if not player:
		return
	
	var gs = $"/root/GameState" if has_node("/root/GameState") else null
	
	# Don't check enemies during buy phase
	if gs and gs.buy_phase:
		if not waiting_for_buy_phase:
			waiting_for_buy_phase = true
		return
	
	# Buy phase just ended — spawn next wave
	if waiting_for_buy_phase and gs and not gs.buy_phase:
		waiting_for_buy_phase = false
		round_cleared = false
		var count = _get_wave_count(round_num)
		spawn_wave(count)
		# Play round start sound
		if has_node("/root/AudioManager"):
			$"/root/AudioManager".play("round_start")
		return
	
	var alive_count = 0
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.health > 0:
			alive_count += 1
	
	if alive_count == 0 and enemies.size() > 0 and not round_cleared:
		round_cleared = true
		round_num += 1
		var bonus = 3000 + round_num * 500
		if player:
			player.sats += bonus
		
		# Show round clear message
		_show_round_clear(bonus)
		
		# Start buy phase after short delay
		get_tree().create_timer(2.0).timeout.connect(func():
			if gs:
				gs.next_round()
			else:
				spawn_wave(_get_wave_count(round_num))
		)

func _get_wave_count(rnd: int) -> int:
	# Gentler ramp: R1=3, R2=4, R3=5, R4=6, R5=7, then +1 per round
	# Caps at 15 to keep it playable
	return min(2 + rnd, 15)

func _spawn_satoshi():
	if satoshi_spawned_this_round:
		return
	satoshi_spawned_this_round = true
	
	var pos = find_spawn_pos()
	var satoshi = CharacterBody3D.new()
	satoshi.name = "Satoshi_Nakamoto"
	satoshi.position = pos
	satoshi.set_script(satoshi_script)
	add_child(satoshi)
	enemies.append(satoshi)

func _show_round_clear(bonus: int):
	var p = get_tree().get_first_node_in_group("player")
	if p and p.has_method("add_kill_feed"):
		p.add_kill_feed("ROUND CLEAR! +%d sats" % bonus)
		p.add_kill_feed("Buy phase — press B to shop!")

func update_round_label():
	var round_names = ["HODL OR DIE", "STACK SATS", "NO RETREAT", "BUY THE DIP",
		"DIAMOND HANDS", "WHOLE COINER", "SATOSHI LEVEL", "CITADEL BUILDER"]
	var rname = round_names[min(round_num - 1, round_names.size() - 1)]
	var label = get_tree().root.find_child("RoundLabel", true, false)
	if label:
		label.text = "ROUND %d — %s" % [round_num, rname]
	
	# Big center announcement
	if has_node("/root/RoundAnnouncer"):
		$"/root/RoundAnnouncer".announce_round(round_num, rname)
