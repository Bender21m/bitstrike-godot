extends Node

# Knife — always available as weapon 0 (slot 1 in CS)
# Fast, melee range, right-click for heavy stab
# Free, can't be dropped, 1-hit backstab

const KNIFE_RANGE: float = 2.0
const SLASH_DAMAGE: int = 40
const STAB_DAMAGE: int = 65
const BACKSTAB_DAMAGE: int = 180  # Instakill most enemies
const SLASH_RATE: float = 0.4
const STAB_RATE: float = 1.0

var last_attack_time: float = 0.0

func try_slash(player: Node3D) -> Dictionary:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_attack_time < SLASH_RATE:
		return {"hit": false}
	last_attack_time = now
	return _do_attack(player, SLASH_DAMAGE, false)

func try_stab(player: Node3D) -> Dictionary:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_attack_time < STAB_RATE:
		return {"hit": false}
	last_attack_time = now
	return _do_attack(player, STAB_DAMAGE, true)

func _do_attack(player: Node3D, base_damage: int, is_stab: bool) -> Dictionary:
	var camera = player.find_child("Camera3D", true, false)
	if not camera:
		return {"hit": false}
	
	# Raycast for melee hit
	var space_state = player.get_world_3d().direct_space_state
	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	var to = from + forward * KNIFE_RANGE
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [player.get_rid()]
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return {"hit": false}
	
	var target = result.get("collider", null)
	if not target or not target.has_method("take_damage"):
		return {"hit": false}
	
	# Check for backstab — if enemy is facing away from us
	var damage = base_damage
	var is_backstab = false
	if target.has_method("_face_direction"):
		var enemy_forward = -target.global_transform.basis.z
		var to_enemy = (target.global_position - player.global_position).normalized()
		var dot = enemy_forward.dot(to_enemy)
		if dot > 0.3:  # Enemy facing same direction as us (back to us)
			damage = BACKSTAB_DAMAGE
			is_backstab = true
	
	target.take_damage(damage, false)
	
	return {"hit": true, "damage": damage, "backstab": is_backstab, "target": target}
