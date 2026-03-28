extends Node

# Weapon Drop/Pickup System
# Q key = drop current weapon
# Walk over dropped weapon = auto pickup (if you have room)

var dropped_weapons: Array = []

func drop_weapon(player: Node3D, weapon_data: Dictionary):
	if not player:
		return
	
	var drop = _create_drop(weapon_data)
	drop.global_position = player.global_position + Vector3(0, 0.5, 0)
	
	# Toss it forward slightly
	var cam = player.find_child("Camera3D", true, false)
	if cam:
		var forward = -cam.global_transform.basis.z
		drop.linear_velocity = forward * 5.0 + Vector3(0, 2, 0)
	
	get_tree().root.add_child(drop)
	dropped_weapons.append(drop)

func _create_drop(weapon_data: Dictionary) -> RigidBody3D:
	var body = RigidBody3D.new()
	body.mass = 2.0
	body.name = "WeaponDrop_%s" % weapon_data.name
	
	# Collision
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.1, 0.08, 0.4)
	col.shape = shape
	body.add_child(col)
	
	# Visual (simple box representing weapon)
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.08, 0.06, 0.35)
	mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.22)
	mat.metallic = 0.7
	mat.roughness = 0.3
	mesh.set_surface_override_material(0, mat)
	body.add_child(mesh)
	
	# Name label glow
	var light = OmniLight3D.new()
	light.light_color = Color(0.97, 0.58, 0.1)
	light.light_energy = 0.3
	light.omni_range = 2.0
	light.position.y = 0.3
	body.add_child(light)
	
	# Store weapon data
	body.set_meta("weapon_data", weapon_data)
	body.set_meta("weapon_name", weapon_data.name)
	
	# Pickup area
	var area = Area3D.new()
	area.name = "PickupArea"
	var area_col = CollisionShape3D.new()
	var area_shape = SphereShape3D.new()
	area_shape.radius = 1.0
	area_col.shape = area_shape
	area.add_child(area_col)
	area.body_entered.connect(_on_pickup_area_entered.bind(body))
	body.add_child(area)
	
	# Auto-despawn after 30 seconds
	get_tree().create_timer(30.0).timeout.connect(func():
		if is_instance_valid(body):
			dropped_weapons.erase(body)
			body.queue_free()
	)
	
	return body

func _on_pickup_area_entered(picker: Node, weapon_body: RigidBody3D):
	if not picker.is_in_group("player"):
		return
	if not is_instance_valid(weapon_body):
		return
	
	var data = weapon_body.get_meta("weapon_data", null)
	if not data:
		return
	
	# Add to player's weapons or swap
	# For now, just refill ammo if player has same weapon
	var player = picker
	var weapon_name = data.get("name", "")
	
	for i in range(player.weapons.size()):
		if player.weapons[i].name == weapon_name:
			# Refill ammo
			player.weapons[i].ammo = player.weapons[i].max_ammo
			player.weapons[i].reserve += data.get("reserve", 30)
			
			if player.has_method("add_kill_feed"):
				player.add_kill_feed("Picked up %s" % weapon_name)
			
			dropped_weapons.erase(weapon_body)
			weapon_body.queue_free()
			return
	
	# If player doesn't have this weapon type, could add swap logic later
	if player.has_method("add_kill_feed"):
		player.add_kill_feed("Picked up %s ammo" % weapon_name)
	
	dropped_weapons.erase(weapon_body)
	weapon_body.queue_free()
