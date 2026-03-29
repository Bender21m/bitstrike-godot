extends Node

# Enemy Model Loader — tries to load GLB mannequin, falls back to capsules
# Colors the model based on enemy type

var mannequin_scene: PackedScene = null
var mannequin_loaded: bool = false
var load_attempted: bool = false

func _ready():
	_try_load_mannequin()

func _try_load_mannequin():
	if load_attempted:
		return
	load_attempted = true
	var path = "res://assets/models/characters/mannequin.glb"
	if ResourceLoader.exists(path):
		mannequin_scene = load(path)
		if mannequin_scene:
			mannequin_loaded = true
			print("[EnemyModels] Mannequin model loaded!")
		else:
			print("[EnemyModels] Failed to load mannequin, using capsules")
	else:
		print("[EnemyModels] Mannequin not found, using capsules")

func create_enemy_visual(enemy: Node3D, enemy_type: String, color: Color) -> bool:
	if not mannequin_loaded or not mannequin_scene:
		return false  # Caller should use capsule fallback
	
	var model = mannequin_scene.instantiate()
	model.name = "CharModel"
	
	# Scale to match our enemy collision size
	model.scale = Vector3(0.5, 0.5, 0.5)
	model.position.y = 0.0
	
	# Color the model based on enemy type
	_color_model(model, color, enemy_type)
	
	enemy.add_child(model)
	return true

func _color_model(model: Node3D, color: Color, enemy_type: String):
	# Find all MeshInstance3D children and override their material
	for child in _get_all_children(model):
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = color
			mat.roughness = 0.7
			mat.metallic = 0.1
			
			# Type-specific material adjustments
			match enemy_type:
				"shitcoiner":
					mat.emission_enabled = true
					mat.emission = Color(0.6, 0.2, 0.8)
					mat.emission_energy_multiplier = 0.3
				"fed":
					mat.metallic = 0.3
					mat.roughness = 0.5
				"whale":
					mat.emission_enabled = true
					mat.emission = Color(0.2, 0.4, 0.8)
					mat.emission_energy_multiplier = 0.2
				"bear":
					mat.roughness = 0.9
			
			# Apply to all surfaces
			for surface_idx in range(child.mesh.get_surface_count() if child.mesh else 0):
				child.set_surface_override_material(surface_idx, mat)

func _get_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_get_all_children(child))
	return result
