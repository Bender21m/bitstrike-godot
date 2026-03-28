extends Node

# Map Manager — Handles map rotation, selection, and loading
# Maps rotate every 5 rounds or can be voted on

var maps = [
	{
		"name": "MINING FACILITY",
		"script": "res://scripts/map_builder.gd",
		"description": "Indoor bitcoin mining operation. Server racks, tunnels, catwalks.",
		"icon": "⛏️",
		"spawn_offset": Vector3(12, 1, 12),
		"map_size": 24,
	},
	{
		"name": "SILK ROAD",
		"script": "res://scripts/map_desert.gd",
		"description": "Desert compound. Sniper towers, market stalls, open courtyard.",
		"icon": "🏜️",
		"spawn_offset": Vector3(0, 1, 0),
		"map_size": 40,
	},
	{
		"name": "CITADEL",
		"script": "res://scripts/map_rooftop.gd",
		"description": "Night rooftops. Jump gaps, AC cover, helipad, city skyline.",
		"icon": "🌃",
		"spawn_offset": Vector3(0, 1, 0),
		"map_size": 30,
	},
	{
		"name": "OFFSHORE",
		"script": "res://scripts/map_island.gd",
		"description": "Tropical island compound. Beach, palm trees, villa, dock.",
		"icon": "🏝️",
		"spawn_offset": Vector3(0, 1, 0),
		"map_size": 40,
	},
	{
		"name": "THE VAULT",
		"script": "res://scripts/map_vault.gd",
		"description": "Underground bank vault. Gold bars, security office, tight corridors.",
		"icon": "🏦",
		"spawn_offset": Vector3(-6, 1, 0),
		"map_size": 30,
	},
]

var current_map_index: int = 0
var current_map_node: Node3D = null
var rounds_on_map: int = 0
var rounds_per_map: int = 5

signal map_changed(map_name: String)

func get_current_map() -> Dictionary:
	return maps[current_map_index]

func get_map_name() -> String:
	return maps[current_map_index].name

func should_rotate() -> bool:
	return rounds_on_map >= rounds_per_map

func next_map():
	current_map_index = (current_map_index + 1) % maps.size()
	rounds_on_map = 0

func set_map(index: int):
	current_map_index = clamp(index, 0, maps.size() - 1)
	rounds_on_map = 0

func on_round_complete():
	rounds_on_map += 1

func load_map(parent: Node) -> Node3D:
	# Remove old map
	if current_map_node and is_instance_valid(current_map_node):
		current_map_node.queue_free()
		current_map_node = null
	
	var map_data = maps[current_map_index]
	var script = load(map_data.script)
	if not script:
		push_error("Failed to load map script: " + map_data.script)
		return null
	
	current_map_node = Node3D.new()
	current_map_node.set_script(script)
	current_map_node.name = "MapGeometry"
	parent.add_child(current_map_node)
	
	emit_signal("map_changed", map_data.name)
	return current_map_node

func get_spawn_position() -> Vector3:
	var map = maps[current_map_index]
	var offset = map.spawn_offset
	var size = map.map_size * 0.3
	return offset + Vector3(randf_range(-size, size), 0, randf_range(-size, size))

func get_enemy_spawn_position(player_pos: Vector3) -> Vector3:
	var map = maps[current_map_index]
	var half = map.map_size * 0.4
	for _i in range(50):
		var pos = Vector3(randf_range(-half, half), 0, randf_range(-half, half))
		pos += map.spawn_offset
		pos.y = 0
		if pos.distance_to(player_pos) > 6.0:
			return pos
	return map.spawn_offset + Vector3(half * 0.8, 0, half * 0.8)
