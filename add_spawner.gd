@tool
extends SceneTree

func _init():
	var packed = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	
	# Add enemy spawner
	var spawner = Node3D.new()
	spawner.name = "EnemySpawner"
	var script = load("res://scripts/enemy_spawner.gd")
	if script:
		spawner.set_script(script)
		print("Spawner script attached!")
	main.add_child(spawner)
	spawner.owner = main
	
	# Save
	var packed_out = PackedScene.new()
	packed_out.pack(main)
	ResourceSaver.save(packed_out, "res://scenes/main.tscn")
	print("Spawner added to scene!")
	quit()
