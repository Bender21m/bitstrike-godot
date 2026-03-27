extends Node3D

var enemy_scene_data = {
	"banker": {"color": Color(0.4, 0.4, 0.5), "hp": 60, "speed": 3.0, "damage": 12, "reward": 5000},
	"shitcoiner": {"color": Color(0.6, 0.2, 0.8), "hp": 40, "speed": 4.5, "damage": 8, "reward": 3000},
	"bear": {"color": Color(0.7, 0.3, 0.3), "hp": 50, "speed": 3.5, "damage": 10, "reward": 4000},
	"roger": {"color": Color(0.0, 0.5, 0.0), "hp": 45, "speed": 5.0, "damage": 8, "reward": 6000},
	"adam": {"color": Color(0.27, 0.53, 0.8), "hp": 120, "speed": 2.0, "damage": 18, "reward": 8000},
	"fed": {"color": Color(0.12, 0.12, 0.2), "hp": 200, "speed": 2.0, "damage": 25, "reward": 21000},
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

func _ready():
	player = get_tree().get_first_node_in_group("player")
	spawn_wave(5)

func spawn_wave(count: int):
	# Clear old enemies
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies.clear()
	update_round_label()
	
	var types = ["banker", "shitcoiner", "bear", "roger", "adam"]
	
	for i in range(count):
		var type = types[randi() % types.size()]
		if round_num >= 5 and randf() < 0.15:
			type = "fed"
		
		var pos = find_spawn_pos()
		var enemy = create_enemy(type, pos)
		add_child(enemy)
		enemies.append(enemy)

func find_spawn_pos() -> Vector3:
	var pos = Vector3.ZERO
	for _attempt in range(50):
		var x = randi_range(2, 21)
		var z = randi_range(2, 21)
		if map_data[z * 24 + x] == 0:
			pos = Vector3(x + 0.5, 0, z + 0.5)
			if player and pos.distance_to(player.global_position) > 5:
				return pos
	return Vector3(20, 0, 20)

func create_enemy(type: String, pos: Vector3) -> CharacterBody3D:
	var data = enemy_scene_data.get(type, enemy_scene_data["banker"])
	
	var enemy = CharacterBody3D.new()
	enemy.name = "Enemy_%s_%d" % [type, randi()]
	enemy.position = pos
	
	# Collision
	var col = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.8
	col.shape = capsule
	col.position.y = 0.9
	enemy.add_child(col)
	
	# Body mesh (capsule)
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
	
	# Head (sphere)
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
	
	# Eyes (red, emissive)
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
	
	# Type-specific features
	if type == "banker":
		var tie = MeshInstance3D.new()
		var tie_mesh = BoxMesh.new()
		tie_mesh.size = Vector3(0.04, 0.3, 0.015)
		tie.mesh = tie_mesh
		var tie_mat = StandardMaterial3D.new()
		tie_mat.albedo_color = Color(0.8, 0.1, 0.1)
		tie.set_surface_override_material(0, tie_mat)
		tie.position = Vector3(0, 0.9, -0.2)
		enemy.add_child(tie)
	
	if type == "shitcoiner":
		var glow = OmniLight3D.new()
		glow.light_color = Color(0.6, 0.2, 0.8)
		glow.light_energy = 0.5
		glow.omni_range = 3.0
		glow.position.y = 0.8
		enemy.add_child(glow)
	
	if type == "fed":
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
	
	# Set metadata
	enemy.set_meta("type", type)
	enemy.set_meta("health", data.hp)
	enemy.set_meta("max_health", data.hp)
	enemy.set_meta("speed", data.speed)
	enemy.set_meta("damage", data.damage)
	enemy.set_meta("reward", data.reward)
	enemy.set_meta("last_attack", 0.0)
	
	# Add to enemies group
	enemy.set_script(load("res://scripts/enemy_hitbox.gd"))
	enemy.add_to_group("enemies")
	
	return enemy

func _physics_process(delta):
	if not player:
		return
	
	var alive_count = 0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var hp = enemy.get_meta("health", 0)
		if hp <= 0:
			continue
		
		alive_count += 1
		var spd = enemy.get_meta("speed", 3.0)
		var dmg = enemy.get_meta("damage", 10)
		var type = enemy.get_meta("type", "banker")
		
		var dir = (player.global_position - enemy.global_position)
		dir.y = 0
		var dist = dir.length()
		dir = dir.normalized()
		
		# Face player
		if dist > 0.1:
			enemy.look_at(Vector3(player.global_position.x, enemy.global_position.y, player.global_position.z))
		
		# Move toward player
		if dist > 1.5:
			var vel = dir * spd
			# Roger Ver sometimes runs away
			if type == "roger" and sin(Time.get_ticks_msec() * 0.001) > 0.7:
				vel = -dir * spd * 0.5
			vel.y = -9.8 * delta
			enemy.velocity = vel
			enemy.move_and_slide()
		else:
			# Attack
			var now = Time.get_ticks_msec() / 1000.0
			var last = enemy.get_meta("last_attack", 0.0)
			if now - last > 1.0:
				enemy.set_meta("last_attack", now)
				if player.has_method("take_damage"):
					player.take_damage(dmg)
	
	# Check round completion
	if alive_count == 0 and enemies.size() > 0:
		round_num += 1
		var bonus = 3000 + round_num * 500
		if player:
			player.sats += bonus
		# Next wave after delay
		get_tree().create_timer(2.0).timeout.connect(func(): spawn_wave(4 + round_num * 2))

func update_round_label():
	var round_names = ["HODL OR DIE", "STACK SATS", "NO RETREAT", "BUY THE DIP",
		"DIAMOND HANDS", "WHOLE COINER", "SATOSHI LEVEL", "CITADEL BUILDER"]
	var rname = round_names[min(round_num - 1, round_names.size() - 1)]
	var label = get_tree().root.find_child("RoundLabel", true, false)
	if label:
		label.text = "ROUND %d — %s" % [round_num, rname]
