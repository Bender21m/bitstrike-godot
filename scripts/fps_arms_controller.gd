extends Node3D

# FPS Arms Controller — loads GLB arms and plays animations
# Handles: idle sway, walk bob, shoot recoil, reload sequence

var anim_player: AnimationPlayer
var is_loaded: bool = false

# Sway
var sway_amount: float = 0.0
var sway_target: Vector3 = Vector3.ZERO
var bob_time: float = 0.0

func _ready():
	# Find AnimationPlayer in the imported GLB
	call_deferred("_find_animations")

func _find_animations():
	anim_player = _find_node_of_type(self, "AnimationPlayer")
	if anim_player:
		is_loaded = true
		play_idle()
		print("[FPSArms] Loaded with animations: ", anim_player.get_animation_list())
	else:
		print("[FPSArms] No AnimationPlayer found in arms model")

func _find_node_of_type(node: Node, type_name: String) -> Node:
	if node.get_class() == type_name:
		return node
	for child in node.get_children():
		var result = _find_node_of_type(child, type_name)
		if result:
			return result
	return null

func play_idle():
	if not anim_player:
		return
	if anim_player.has_animation("Idle"):
		anim_player.play("Idle")

func play_walk():
	if not anim_player:
		return
	if anim_player.has_animation("Walk"):
		anim_player.play("Walk")

func play_fire():
	if not anim_player:
		return
	# Look for fire/shoot animation names
	for anim_name in ["Fire", "Shoot", "Shot"]:
		if anim_player.has_animation(anim_name):
			anim_player.play(anim_name)
			return
	# Fallback: just do a quick position kick
	var tween = create_tween()
	tween.tween_property(self, "position:z", position.z + 0.03, 0.05)
	tween.tween_property(self, "position:z", position.z, 0.1)

func play_reload():
	if not anim_player:
		return
	for anim_name in ["Reload", "ReloadMag"]:
		if anim_player.has_animation(anim_name):
			anim_player.play(anim_name)
			return

func set_walking(is_walking: bool):
	if not is_loaded:
		return
	if is_walking:
		play_walk()
	else:
		play_idle()

func _process(delta):
	# Smooth sway back to center
	position = position.lerp(sway_target + Vector3(0.05, -0.1, -0.15), delta * 5.0)
	sway_target = sway_target.lerp(Vector3.ZERO, delta * 8.0)

func apply_sway(mouse_delta: Vector2):
	sway_target.x -= mouse_delta.x * 0.0002
	sway_target.y -= mouse_delta.y * 0.0002
	sway_target.x = clamp(sway_target.x, -0.03, 0.03)
	sway_target.y = clamp(sway_target.y, -0.02, 0.02)
