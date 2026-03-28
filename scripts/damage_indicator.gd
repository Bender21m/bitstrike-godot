extends CanvasLayer

# Damage Direction Indicator — CS-style
# Red wedge on screen edge showing where damage came from
# Fades over time

var indicators: Array = []
var indicator_container: Control

func _ready():
	layer = 13
	indicator_container = Control.new()
	indicator_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	indicator_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(indicator_container)

func show_damage_from(attacker_pos: Vector3):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Calculate angle from player to attacker
	var to_attacker = attacker_pos - player.global_position
	to_attacker.y = 0
	var angle = atan2(to_attacker.x, to_attacker.z)
	# Adjust for player rotation
	angle -= player.rotation.y
	
	# Create indicator
	var indicator = ColorRect.new()
	indicator.color = Color(1, 0, 0, 0.6)
	indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Position on screen edge based on angle
	var screen_size = get_viewport().get_visible_rect().size
	var center = screen_size / 2
	var radius = min(screen_size.x, screen_size.y) * 0.35
	
	var ix = center.x + sin(angle) * radius
	var iy = center.y + cos(angle) * radius
	
	# Rotate indicator to point inward
	indicator.size = Vector2(8, 40)
	indicator.position = Vector2(ix - 4, iy - 20)
	indicator.rotation = -angle
	
	indicator_container.add_child(indicator)
	
	# Fade out
	var tween = get_tree().create_tween()
	tween.tween_property(indicator, "color:a", 0.0, 1.5)
	tween.tween_callback(indicator.queue_free)

func _process(_delta):
	pass
