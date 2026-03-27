@tool
extends SceneTree

func _init():
	# Load the existing scene and enhance it
	var packed = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	
	# Add HUD (CanvasLayer + Labels)
	var hud = CanvasLayer.new()
	hud.name = "HUD"
	
	# Crosshair
	var cross = Control.new()
	cross.name = "Crosshair"
	cross.set_anchors_preset(Control.PRESET_CENTER)
	
	var cross_h = ColorRect.new()
	cross_h.color = Color(0, 1, 0, 0.8)
	cross_h.size = Vector2(20, 2)
	cross_h.position = Vector2(-10, -1)
	cross.add_child(cross_h)
	cross_h.owner = main
	
	var cross_v = ColorRect.new()
	cross_v.color = Color(0, 1, 0, 0.8)
	cross_v.size = Vector2(2, 20)
	cross_v.position = Vector2(-1, -10)
	cross.add_child(cross_v)
	cross_v.owner = main
	
	hud.add_child(cross)
	cross.owner = main
	
	# Health label
	var health_label = Label.new()
	health_label.name = "HealthLabel"
	health_label.text = "HP: 100"
	health_label.add_theme_font_size_override("font_size", 24)
	health_label.add_theme_color_override("font_color", Color(0, 1, 0))
	health_label.position = Vector2(20, 20)
	hud.add_child(health_label)
	health_label.owner = main
	
	# Sats label
	var sats_label = Label.new()
	sats_label.name = "SatsLabel"
	sats_label.text = "₿ 16,000"
	sats_label.add_theme_font_size_override("font_size", 24)
	sats_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	sats_label.position = Vector2(20, 50)
	hud.add_child(sats_label)
	sats_label.owner = main
	
	# Ammo label
	var ammo_label = Label.new()
	ammo_label.name = "AmmoLabel"
	ammo_label.text = "30 / 90"
	ammo_label.add_theme_font_size_override("font_size", 24)
	ammo_label.add_theme_color_override("font_color", Color(1, 1, 1))
	ammo_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	ammo_label.position = Vector2(-120, -50)
	hud.add_child(ammo_label)
	ammo_label.owner = main
	
	# Weapon name
	var weapon_label = Label.new()
	weapon_label.name = "WeaponLabel"
	weapon_label.text = "AK-₿7"
	weapon_label.add_theme_font_size_override("font_size", 18)
	weapon_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	weapon_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	weapon_label.position = Vector2(-120, -80)
	hud.add_child(weapon_label)
	weapon_label.owner = main
	
	# Round info
	var round_label = Label.new()
	round_label.name = "RoundLabel"
	round_label.text = "ROUND 1 — HODL OR DIE"
	round_label.add_theme_font_size_override("font_size", 18)
	round_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	round_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	round_label.position = Vector2(-100, 10)
	hud.add_child(round_label)
	round_label.owner = main
	
	# Kill feed
	var kill_feed = VBoxContainer.new()
	kill_feed.name = "KillFeed"
	kill_feed.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	kill_feed.position = Vector2(-300, 10)
	kill_feed.size = Vector2(280, 200)
	hud.add_child(kill_feed)
	kill_feed.owner = main
	
	# Damage overlay
	var dmg_overlay = ColorRect.new()
	dmg_overlay.name = "DamageOverlay"
	dmg_overlay.color = Color(1, 0, 0, 0)
	dmg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	dmg_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(dmg_overlay)
	dmg_overlay.owner = main
	
	main.add_child(hud)
	hud.owner = main
	
	# Add a basic weapon model (CSG for now)
	var player = main.get_node("Player")
	if player:
		var weapon_holder = player.get_node("Camera3D/WeaponHolder")
		if weapon_holder:
			# AK-47 style weapon from CSG
			var gun_body = CSGBox3D.new()
			gun_body.name = "GunBody"
			gun_body.size = Vector3(0.04, 0.05, 0.3)
			var gun_mat = StandardMaterial3D.new()
			gun_mat.albedo_color = Color(0.2, 0.2, 0.2)
			gun_mat.metallic = 0.8
			gun_mat.roughness = 0.3
			gun_body.material = gun_mat
			weapon_holder.add_child(gun_body)
			gun_body.owner = main
			
			# Barrel
			var barrel = CSGCylinder3D.new()
			barrel.name = "Barrel"
			barrel.radius = 0.008
			barrel.height = 0.35
			barrel.sides = 16
			barrel.rotation.x = PI / 2
			barrel.position = Vector3(0, 0.01, -0.3)
			var barrel_mat = StandardMaterial3D.new()
			barrel_mat.albedo_color = Color(0.1, 0.1, 0.1)
			barrel_mat.metallic = 0.9
			barrel_mat.roughness = 0.2
			barrel.material = barrel_mat
			weapon_holder.add_child(barrel)
			barrel.owner = main
			
			# Magazine
			var mag = CSGBox3D.new()
			mag.name = "Magazine"
			mag.size = Vector3(0.03, 0.1, 0.02)
			mag.position = Vector3(0, -0.06, -0.05)
			mag.rotation.x = 0.15
			var mag_mat = StandardMaterial3D.new()
			mag_mat.albedo_color = Color(0.25, 0.18, 0.1)
			mag_mat.roughness = 0.7
			mag.material = mag_mat
			weapon_holder.add_child(mag)
			mag.owner = main
			
			# Stock (wood)
			var stock = CSGBox3D.new()
			stock.name = "Stock"
			stock.size = Vector3(0.03, 0.04, 0.15)
			stock.position = Vector3(0, -0.005, 0.15)
			var stock_mat = StandardMaterial3D.new()
			stock_mat.albedo_color = Color(0.5, 0.3, 0.15)
			stock_mat.roughness = 0.8
			stock.material = stock_mat
			weapon_holder.add_child(stock)
			stock.owner = main
			
			# Grip
			var grip = CSGBox3D.new()
			grip.name = "Grip"
			grip.size = Vector3(0.025, 0.05, 0.02)
			grip.position = Vector3(0, -0.04, 0.0)
			var grip_mat = StandardMaterial3D.new()
			grip_mat.albedo_color = Color(0.08, 0.08, 0.08)
			grip_mat.roughness = 0.9
			grip.material = grip_mat
			weapon_holder.add_child(grip)
			grip.owner = main
			
			# Muzzle flash light (starts off)
			var muzzle_light = OmniLight3D.new()
			muzzle_light.name = "MuzzleFlash"
			muzzle_light.light_color = Color(1, 0.7, 0.2)
			muzzle_light.light_energy = 0
			muzzle_light.omni_range = 5
			muzzle_light.position = Vector3(0, 0.01, -0.5)
			weapon_holder.add_child(muzzle_light)
			muzzle_light.owner = main
	
	# Add some point lights for atmosphere (bitcoin orange)
	var light1 = OmniLight3D.new()
	light1.name = "BitcoinLight1"
	light1.light_color = Color(0.97, 0.58, 0.1)
	light1.light_energy = 0.8
	light1.omni_range = 12
	light1.position = Vector3(12, 2, 12)
	main.add_child(light1)
	light1.owner = main
	
	var light2 = OmniLight3D.new()
	light2.name = "BitcoinLight2"
	light2.light_color = Color(0.97, 0.58, 0.1)
	light2.light_energy = 0.5
	light2.omni_range = 10
	light2.position = Vector3(5, 2, 18)
	main.add_child(light2)
	light2.owner = main
	
	# Add ceiling
	var ceiling = StaticBody3D.new()
	ceiling.name = "Ceiling"
	var ceil_mesh = MeshInstance3D.new()
	var ceil_geo = PlaneMesh.new()
	ceil_geo.size = Vector2(24, 24)
	ceil_mesh.mesh = ceil_geo
	ceil_mesh.rotation.x = PI
	var ceil_mat = StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.08, 0.08, 0.08)
	ceil_mesh.set_surface_override_material(0, ceil_mat)
	ceiling.add_child(ceil_mesh)
	ceil_mesh.owner = main
	ceiling.position = Vector3(12, 2.5, 12)
	main.add_child(ceiling)
	ceiling.owner = main
	
	# Save
	var packed_out = PackedScene.new()
	packed_out.pack(main)
	ResourceSaver.save(packed_out, "res://scenes/main.tscn")
	print("Game scene built with HUD, weapon, lights, ceiling!")
	
	quit()
