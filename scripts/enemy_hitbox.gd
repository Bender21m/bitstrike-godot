extends CharacterBody3D
# This script is attached to each enemy to handle damage

func take_damage(amount: int, is_headshot: bool = false):
	var hp = get_meta("health", 0)
	hp -= amount
	set_meta("health", hp)
	
	# Flash red
	for child in get_children():
		if child is MeshInstance3D and child.name == "Body":
			var mat = child.get_surface_override_material(0)
			if mat:
				var original_color = mat.albedo_color
				mat.albedo_color = Color(1, 0.2, 0.2)
				get_tree().create_timer(0.1).timeout.connect(func(): mat.albedo_color = original_color)
	
	if hp <= 0:
		die()

func die():
	# Award player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.sats += get_meta("reward", 5000)
		player.kills += 1
		if player.has_method("add_kill_feed"):
			var type = get_meta("type", "enemy")
			player.add_kill_feed("%s eliminated! +%d sats" % [type.to_upper(), get_meta("reward", 5000)])
	
	# Death animation - fall over
	var tween = create_tween()
	tween.tween_property(self, "rotation:x", PI / 2, 0.5)
	tween.parallel().tween_property(self, "position:y", -0.5, 0.8)
	tween.tween_callback(queue_free).set_delay(1.0)
	
	# Disable collision
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = true
