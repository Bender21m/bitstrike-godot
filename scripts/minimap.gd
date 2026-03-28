extends CanvasLayer

# Minimap / Radar — shows player position, enemies (when detected), and pickups
# Top-right corner, circular radar style

var radar_size: float = 120.0
var radar_range: float = 20.0  # World units visible on radar
var radar_center: Vector2
var radar_bg: ColorRect
var radar_canvas: Control
var player: Node3D

func _ready():
	layer = 5
	_build_radar()

func _build_radar():
	# Container
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	container.offset_left = -radar_size - 20
	container.offset_top = 50
	container.offset_right = -20
	container.offset_bottom = 50 + radar_size
	add_child(container)
	
	# Background circle (dark)
	radar_bg = ColorRect.new()
	radar_bg.color = Color(0.05, 0.05, 0.08, 0.7)
	radar_bg.size = Vector2(radar_size, radar_size)
	container.add_child(radar_bg)
	
	# Border
	var border = ColorRect.new()
	border.color = Color(0.97, 0.58, 0.1, 0.5)
	border.size = Vector2(radar_size, 2)
	border.position = Vector2(0, 0)
	container.add_child(border)
	var border2 = ColorRect.new()
	border2.color = Color(0.97, 0.58, 0.1, 0.5)
	border2.size = Vector2(radar_size, 2)
	border2.position = Vector2(0, radar_size - 2)
	container.add_child(border2)
	var border3 = ColorRect.new()
	border3.color = Color(0.97, 0.58, 0.1, 0.5)
	border3.size = Vector2(2, radar_size)
	border3.position = Vector2(0, 0)
	container.add_child(border3)
	var border4 = ColorRect.new()
	border4.color = Color(0.97, 0.58, 0.1, 0.5)
	border4.size = Vector2(2, radar_size)
	border4.position = Vector2(radar_size - 2, 0)
	container.add_child(border4)
	
	# Drawing canvas
	radar_canvas = Control.new()
	radar_canvas.size = Vector2(radar_size, radar_size)
	radar_canvas.draw.connect(_draw_radar)
	container.add_child(radar_canvas)
	
	radar_center = Vector2(radar_size / 2, radar_size / 2)

func _process(_delta):
	player = get_tree().get_first_node_in_group("player")
	radar_canvas.queue_redraw()

func _draw_radar():
	if not player:
		return
	
	var player_pos = player.global_position
	var player_rot = player.rotation.y
	
	# Draw player (center, green triangle)
	_draw_triangle(radar_canvas, radar_center, 4, -player_rot, Color(0, 1, 0))
	
	# Draw hack sites
	if has_node("/root/HackDefuse"):
		var hd = $"/root/HackDefuse"
		for site_id in hd.hack_sites:
			var site = hd.hack_sites[site_id]
			var offset = site.position - player_pos
			var rotated = Vector2(offset.x, offset.z).rotated(-player_rot)
			var radar_pos = radar_center + rotated * (radar_size / 2.0 / radar_range)
			radar_pos.x = clamp(radar_pos.x, 6, radar_size - 6)
			radar_pos.y = clamp(radar_pos.y, 6, radar_size - 6)
			var site_color = Color(1, 0.3, 0.1) if site_id == "A" else Color(0.1, 0.5, 1)
			if site.planted:
				# Pulse if planted
				var pulse = 0.5 + sin(Time.get_ticks_msec() * 0.01) * 0.5
				site_color.a = pulse
			radar_canvas.draw_rect(Rect2(radar_pos - Vector2(4, 4), Vector2(8, 8)), site_color)
	
	# Draw enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("_ready") and enemy.get("health") != null and enemy.health <= 0:
			continue
		
		var offset = enemy.global_position - player_pos
		var rotated = Vector2(offset.x, offset.z).rotated(-player_rot)
		var radar_pos = radar_center + rotated * (radar_size / 2.0 / radar_range)
		
		# Clamp to radar bounds
		radar_pos.x = clamp(radar_pos.x, 4, radar_size - 4)
		radar_pos.y = clamp(radar_pos.y, 4, radar_size - 4)
		
		# Only show if within range
		var dist = offset.length()
		if dist < radar_range:
			var alpha = 1.0 - (dist / radar_range) * 0.5
			radar_canvas.draw_circle(radar_pos, 3, Color(1, 0.2, 0.2, alpha))

func _draw_triangle(canvas: Control, pos: Vector2, size: float, angle: float, color: Color):
	var points = PackedVector2Array()
	for i in range(3):
		var a = angle + i * TAU / 3 - PI / 2
		points.append(pos + Vector2(cos(a), sin(a)) * size)
	canvas.draw_polygon(points, PackedColorArray([color, color, color]))
