extends Node3D

# Procedural weapon models — detailed enough to be recognizable
# Each weapon is built from ~30-60 primitives for a chunky low-poly look

var current_model: Node3D = null

var arm_nodes: Array = []
var anim_time: float = 0.0
var anim_state: String = "idle"  # idle, shoot, reload, draw
var anim_timer: float = 0.0

func build_weapon(weapon_name: String) -> Node3D:
	if current_model:
		current_model.queue_free()
	arm_nodes.clear()
	
	match weapon_name:
		"AK-B7":
			current_model = _build_ak_b7()
		"BEAGLE":
			current_model = _build_beagle()
		"SABOT":
			current_model = _build_sabot()
		"M4-SAT":
			current_model = _build_m4_sat()
		"KNIFE":
			current_model = _build_knife_model()
		_:
			current_model = _build_ak_b7()
	
	# Add first-person arms to every weapon
	_add_fps_arms(current_model)
	
	add_child(current_model)
	anim_state = "draw"
	anim_timer = 0.3
	return current_model

func play_anim(anim_name: String):
	anim_state = anim_name
	match anim_name:
		"shoot": anim_timer = 0.12
		"reload": anim_timer = 2.0
		"draw": anim_timer = 0.3
		_: anim_timer = 0.0

func _process(delta):
	if not current_model:
		return
	anim_time += delta
	
	# Animate based on state
	match anim_state:
		"idle":
			_animate_idle(delta)
		"shoot":
			_animate_shoot(delta)
			anim_timer -= delta
			if anim_timer <= 0:
				anim_state = "idle"
		"reload":
			_animate_reload(delta)
			anim_timer -= delta
			if anim_timer <= 0:
				anim_state = "idle"
		"draw":
			_animate_draw(delta)
			anim_timer -= delta
			if anim_timer <= 0:
				anim_state = "idle"

func _animate_idle(delta):
	if not current_model:
		return
	# Subtle breathing sway
	var breath = sin(anim_time * 1.5) * 0.002
	var sway = sin(anim_time * 0.8) * 0.001
	current_model.position.y = lerp(current_model.position.y, breath, delta * 5)
	current_model.position.x = lerp(current_model.position.x, sway, delta * 5)
	current_model.rotation.z = lerp(current_model.rotation.z, sin(anim_time * 1.2) * 0.005, delta * 5)
	
	# Arms subtle movement
	for arm in arm_nodes:
		if is_instance_valid(arm):
			arm.rotation.x = lerp(arm.rotation.x, sin(anim_time * 1.5) * 0.01, delta * 5)

func _animate_shoot(delta):
	if not current_model:
		return
	# Recoil kick back + up
	var kick = anim_timer / 0.12  # 1.0 at start, 0.0 at end
	current_model.position.z += kick * 0.02 * delta * 60
	current_model.rotation.x -= kick * 0.03 * delta * 60
	# Arms tense
	for arm in arm_nodes:
		if is_instance_valid(arm):
			arm.rotation.x = -kick * 0.05

func _animate_reload(delta):
	if not current_model:
		return
	var t = 1.0 - (anim_timer / 2.0)  # 0→1 over reload
	
	if t < 0.3:
		# Tilt gun to side (looking at mag)
		current_model.rotation.z = lerp(current_model.rotation.z, 0.15, delta * 8)
		current_model.position.y = lerp(current_model.position.y, -0.02, delta * 8)
	elif t < 0.5:
		# Pull mag out (gun drops slightly)
		current_model.position.y = lerp(current_model.position.y, -0.04, delta * 10)
		# Left arm reaches down
		if arm_nodes.size() > 0 and is_instance_valid(arm_nodes[0]):
			arm_nodes[0].rotation.x = lerp(arm_nodes[0].rotation.x, -0.3, delta * 8)
	elif t < 0.7:
		# Insert new mag
		current_model.position.y = lerp(current_model.position.y, -0.02, delta * 8)
		if arm_nodes.size() > 0 and is_instance_valid(arm_nodes[0]):
			arm_nodes[0].rotation.x = lerp(arm_nodes[0].rotation.x, 0.1, delta * 10)
	else:
		# Return to position, rack bolt
		current_model.rotation.z = lerp(current_model.rotation.z, 0.0, delta * 6)
		current_model.position.y = lerp(current_model.position.y, 0.0, delta * 6)
		# Right arm pulls bolt
		if arm_nodes.size() > 1 and is_instance_valid(arm_nodes[1]):
			var bolt_pull = sin((t - 0.7) / 0.3 * PI)
			arm_nodes[1].position.z = bolt_pull * 0.02

func _animate_draw(delta):
	if not current_model:
		return
	# Weapon rises from below
	var t = 1.0 - (anim_timer / 0.3)
	current_model.position.y = lerp(-0.15, 0.0, t)
	current_model.rotation.x = lerp(0.2, 0.0, t)

# ============================================================
# AK-B7 — Based on AK-47 silhouette
# Recognizable curved magazine, wooden furniture, long barrel
# ============================================================
func _build_ak_b7() -> Node3D:
	var gun = Node3D.new()
	gun.name = "AK_B7_Model"
	
	var metal_dark = Color(0.18, 0.18, 0.2)
	var metal_mid = Color(0.25, 0.25, 0.28)
	var metal_barrel = Color(0.15, 0.15, 0.17)
	var wood_color = Color(0.45, 0.28, 0.12)
	var wood_dark = Color(0.35, 0.2, 0.08)
	var orange_btc = Color(0.97, 0.58, 0.1)
	
	# --- RECEIVER (main body) ---
	_add_box(gun, Vector3(0, 0, 0), Vector3(0.035, 0.04, 0.22), metal_dark, 0.8, 0.3)
	# Receiver top cover
	_add_box(gun, Vector3(0, 0.022, 0.02), Vector3(0.03, 0.008, 0.18), metal_mid, 0.7, 0.35)
	
	# --- BARREL ---
	_add_cylinder(gun, Vector3(0, 0.005, -0.32), Vector3(0.012, 0.22, 0.012), metal_barrel, 0.9, 0.2, 12)
	# Barrel sleeve / gas tube
	_add_cylinder(gun, Vector3(0, 0.005, -0.2), Vector3(0.016, 0.12, 0.016), metal_dark, 0.8, 0.3, 8)
	# Gas tube above barrel
	_add_cylinder(gun, Vector3(0, 0.025, -0.2), Vector3(0.008, 0.13, 0.008), metal_mid, 0.7, 0.35, 6)
	
	# --- FRONT SIGHT ---
	_add_box(gun, Vector3(0, 0.03, -0.42), Vector3(0.003, 0.025, 0.003), metal_dark, 0.8, 0.3)
	_add_box(gun, Vector3(0, 0.045, -0.42), Vector3(0.008, 0.004, 0.008), metal_dark, 0.8, 0.3)
	# Front sight post
	_add_box(gun, Vector3(0, 0.055, -0.42), Vector3(0.002, 0.012, 0.002), orange_btc, 0.5, 0.5)
	
	# --- REAR SIGHT ---
	_add_box(gun, Vector3(0, 0.035, 0.08), Vector3(0.015, 0.012, 0.006), metal_dark, 0.8, 0.3)
	# Sight notch
	_add_box(gun, Vector3(-0.005, 0.042, 0.08), Vector3(0.002, 0.008, 0.003), metal_dark, 0.8, 0.3)
	_add_box(gun, Vector3(0.005, 0.042, 0.08), Vector3(0.002, 0.008, 0.003), metal_dark, 0.8, 0.3)
	
	# --- HANDGUARD (wood, lower) ---
	_add_box(gun, Vector3(0, -0.01, -0.14), Vector3(0.032, 0.025, 0.12), wood_color, 0.0, 0.85)
	# Handguard upper (wood)
	_add_box(gun, Vector3(0, 0.02, -0.14), Vector3(0.028, 0.012, 0.11), wood_dark, 0.0, 0.85)
	# Ventilation slots on handguard
	for i in range(4):
		var z = -0.1 - i * 0.025
		_add_box(gun, Vector3(0.017, -0.01, z), Vector3(0.002, 0.015, 0.008), metal_dark, 0.8, 0.3)
	
	# --- MAGAZINE (curved, iconic AK shape) ---
	# Main mag body
	_add_box(gun, Vector3(0, -0.06, -0.01), Vector3(0.025, 0.055, 0.07), metal_dark, 0.7, 0.4)
	# Mag curve (lower part angled forward)
	var mag_lower = _add_box(gun, Vector3(0, -0.11, -0.025), Vector3(0.024, 0.045, 0.065), metal_dark, 0.7, 0.4)
	mag_lower.rotation.x = 0.15  # Slight forward curve
	# Mag base plate
	_add_box(gun, Vector3(0, -0.14, -0.03), Vector3(0.026, 0.006, 0.06), metal_mid, 0.8, 0.3)
	# Bitcoin logo on mag (orange accent)
	_add_box(gun, Vector3(0.013, -0.08, -0.01), Vector3(0.001, 0.02, 0.02), orange_btc, 0.3, 0.6)
	
	# --- PISTOL GRIP ---
	var grip = _add_box(gun, Vector3(0, -0.05, 0.06), Vector3(0.022, 0.05, 0.025), wood_color, 0.0, 0.85)
	grip.rotation.x = -0.25
	# Grip base
	_add_box(gun, Vector3(0, -0.09, 0.07), Vector3(0.024, 0.012, 0.028), wood_dark, 0.0, 0.85)
	
	# --- STOCK (wooden, AK style) ---
	_add_box(gun, Vector3(0, -0.005, 0.2), Vector3(0.024, 0.035, 0.14), wood_color, 0.0, 0.85)
	# Stock taper
	_add_box(gun, Vector3(0, -0.008, 0.33), Vector3(0.022, 0.04, 0.06), wood_dark, 0.0, 0.85)
	# Stock butt plate
	_add_box(gun, Vector3(0, -0.008, 0.36), Vector3(0.025, 0.042, 0.005), metal_dark, 0.8, 0.3)
	
	# --- TRIGGER GUARD ---
	_add_box(gun, Vector3(0, -0.035, 0.03), Vector3(0.018, 0.003, 0.04), metal_dark, 0.8, 0.3)
	_add_box(gun, Vector3(0, -0.025, 0.05), Vector3(0.018, 0.003, 0.003), metal_dark, 0.8, 0.3)
	# Trigger
	_add_box(gun, Vector3(0, -0.025, 0.035), Vector3(0.004, 0.012, 0.003), metal_mid, 0.8, 0.3)
	
	# --- MUZZLE BRAKE ---
	_add_cylinder(gun, Vector3(0, 0.005, -0.44), Vector3(0.014, 0.03, 0.014), metal_dark, 0.9, 0.2, 8)
	# Muzzle slots
	_add_box(gun, Vector3(0.015, 0.005, -0.445), Vector3(0.002, 0.008, 0.015), metal_dark, 0.9, 0.2)
	_add_box(gun, Vector3(-0.015, 0.005, -0.445), Vector3(0.002, 0.008, 0.015), metal_dark, 0.9, 0.2)
	
	# --- DUST COVER / SELECTOR ---
	_add_box(gun, Vector3(0.018, 0.01, 0.05), Vector3(0.002, 0.015, 0.025), metal_mid, 0.8, 0.3)
	
	# --- CHARGING HANDLE ---
	_add_box(gun, Vector3(0.02, 0.015, 0.0), Vector3(0.008, 0.006, 0.012), metal_mid, 0.8, 0.3)
	
	# Position for first-person view
	gun.position = Vector3(0, 0, 0)
	gun.rotation.y = 0.0
	
	return gun

# ============================================================
# BEAGLE — Desert Eagle style pistol
# Chunky, angular, intimidating
# ============================================================
func _build_beagle() -> Node3D:
	var gun = Node3D.new()
	gun.name = "Beagle_Model"
	
	var metal_chrome = Color(0.6, 0.6, 0.65)
	var metal_dark = Color(0.12, 0.12, 0.14)
	var grip_color = Color(0.15, 0.15, 0.15)
	var orange_btc = Color(0.97, 0.58, 0.1)
	
	# --- SLIDE (top) ---
	_add_box(gun, Vector3(0, 0.015, -0.02), Vector3(0.028, 0.025, 0.18), metal_chrome, 0.9, 0.15)
	# Slide serrations (rear)
	for i in range(5):
		var z = 0.06 + i * 0.012
		_add_box(gun, Vector3(0, 0.03, z), Vector3(0.029, 0.002, 0.004), metal_dark, 0.9, 0.2)
	
	# --- BARREL ---
	_add_cylinder(gun, Vector3(0, 0.015, -0.16), Vector3(0.01, 0.06, 0.01), metal_dark, 0.9, 0.2, 8)
	
	# --- FRAME (lower) ---
	_add_box(gun, Vector3(0, -0.01, 0.01), Vector3(0.026, 0.02, 0.12), metal_dark, 0.85, 0.25)
	
	# --- TRIGGER GUARD ---
	_add_box(gun, Vector3(0, -0.025, -0.01), Vector3(0.022, 0.003, 0.05), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(0, -0.015, -0.035), Vector3(0.022, 0.003, 0.003), metal_dark, 0.85, 0.25)
	# Trigger
	_add_box(gun, Vector3(0, -0.015, -0.015), Vector3(0.004, 0.012, 0.003), metal_chrome, 0.9, 0.15)
	
	# --- GRIP ---
	var grip = _add_box(gun, Vector3(0, -0.04, 0.05), Vector3(0.024, 0.045, 0.028), grip_color, 0.0, 0.9)
	grip.rotation.x = -0.2
	# Grip texture lines
	for i in range(3):
		var y = -0.025 - i * 0.015
		_add_box(gun, Vector3(0.013, y, 0.05), Vector3(0.001, 0.004, 0.02), metal_dark, 0.5, 0.7)
	# Grip base / magazine well
	_add_box(gun, Vector3(0, -0.075, 0.055), Vector3(0.026, 0.008, 0.03), metal_dark, 0.85, 0.25)
	
	# --- FRONT SIGHT ---
	_add_box(gun, Vector3(0, 0.03, -0.1), Vector3(0.004, 0.008, 0.004), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(0, 0.035, -0.1), Vector3(0.002, 0.003, 0.002), orange_btc, 0.3, 0.6)
	
	# --- REAR SIGHT ---
	_add_box(gun, Vector3(-0.006, 0.03, 0.05), Vector3(0.003, 0.006, 0.006), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(0.006, 0.03, 0.05), Vector3(0.003, 0.006, 0.006), metal_dark, 0.85, 0.25)
	
	# --- HAMMER ---
	_add_box(gun, Vector3(0, 0.025, 0.09), Vector3(0.006, 0.012, 0.005), metal_chrome, 0.9, 0.15)
	
	# Bitcoin engraving on slide
	_add_box(gun, Vector3(0.015, 0.015, -0.02), Vector3(0.001, 0.012, 0.012), orange_btc, 0.3, 0.6)
	
	gun.position = Vector3(0, 0, 0)
	
	return gun

# ============================================================
# SABOT — Sniper rifle, long barrel, scope
# ============================================================
func _build_sabot() -> Node3D:
	var gun = Node3D.new()
	gun.name = "Sabot_Model"
	
	var metal_dark = Color(0.1, 0.1, 0.12)
	var metal_mid = Color(0.2, 0.2, 0.22)
	var stock_color = Color(0.12, 0.15, 0.1)  # OD green-ish
	var scope_color = Color(0.08, 0.08, 0.1)
	var orange_btc = Color(0.97, 0.58, 0.1)
	
	# --- RECEIVER ---
	_add_box(gun, Vector3(0, 0, 0), Vector3(0.03, 0.035, 0.25), metal_dark, 0.85, 0.25)
	
	# --- BARREL (long) ---
	_add_cylinder(gun, Vector3(0, 0, -0.4), Vector3(0.01, 0.35, 0.01), metal_dark, 0.9, 0.2, 10)
	# Barrel fluting (thicker section)
	_add_cylinder(gun, Vector3(0, 0, -0.2), Vector3(0.014, 0.12, 0.014), metal_mid, 0.85, 0.25, 8)
	
	# --- MUZZLE BRAKE ---
	_add_cylinder(gun, Vector3(0, 0, -0.58), Vector3(0.016, 0.04, 0.016), metal_mid, 0.9, 0.2, 8)
	_add_box(gun, Vector3(0.017, 0, -0.58), Vector3(0.002, 0.01, 0.025), metal_mid, 0.9, 0.2)
	_add_box(gun, Vector3(-0.017, 0, -0.58), Vector3(0.002, 0.01, 0.025), metal_mid, 0.9, 0.2)
	
	# --- SCOPE ---
	# Scope tube
	_add_cylinder(gun, Vector3(0, 0.045, -0.05), Vector3(0.016, 0.18, 0.016), scope_color, 0.85, 0.2, 12)
	# Scope front lens (larger)
	_add_cylinder(gun, Vector3(0, 0.045, -0.15), Vector3(0.02, 0.02, 0.02), scope_color, 0.85, 0.2, 12)
	# Scope lens glass
	_add_cylinder(gun, Vector3(0, 0.045, -0.161), Vector3(0.017, 0.003, 0.017), Color(0.3, 0.5, 0.8, 0.6), 0.1, 0.1, 12)
	# Scope rear lens
	_add_cylinder(gun, Vector3(0, 0.045, 0.04), Vector3(0.018, 0.015, 0.018), scope_color, 0.85, 0.2, 12)
	# Scope mount rings
	_add_cylinder(gun, Vector3(0, 0.03, -0.08), Vector3(0.02, 0.015, 0.02), metal_mid, 0.85, 0.25, 8)
	_add_cylinder(gun, Vector3(0, 0.03, 0.02), Vector3(0.02, 0.015, 0.02), metal_mid, 0.85, 0.25, 8)
	# Scope turrets
	_add_cylinder(gun, Vector3(0.02, 0.05, -0.03), Vector3(0.008, 0.012, 0.008), metal_mid, 0.85, 0.25, 6)
	_add_cylinder(gun, Vector3(0, 0.06, -0.03), Vector3(0.008, 0.012, 0.008), metal_mid, 0.85, 0.25, 6)
	
	# --- BOLT ---
	_add_box(gun, Vector3(0.018, 0.005, 0.05), Vector3(0.01, 0.008, 0.015), metal_mid, 0.85, 0.25)
	_add_cylinder(gun, Vector3(0.03, 0.005, 0.05), Vector3(0.004, 0.01, 0.004), metal_mid, 0.85, 0.25, 6)
	
	# --- MAGAZINE ---
	_add_box(gun, Vector3(0, -0.045, 0.02), Vector3(0.022, 0.04, 0.05), metal_dark, 0.8, 0.3)
	_add_box(gun, Vector3(0, -0.08, 0.02), Vector3(0.02, 0.006, 0.048), metal_mid, 0.8, 0.3)
	
	# --- STOCK (adjustable) ---
	_add_box(gun, Vector3(0, -0.005, 0.18), Vector3(0.025, 0.03, 0.1), stock_color, 0.0, 0.9)
	_add_box(gun, Vector3(0, -0.005, 0.3), Vector3(0.025, 0.04, 0.08), stock_color, 0.0, 0.9)
	# Cheek rest
	_add_box(gun, Vector3(0, 0.015, 0.28), Vector3(0.02, 0.01, 0.06), stock_color, 0.0, 0.85)
	# Butt pad
	_add_box(gun, Vector3(0, -0.005, 0.34), Vector3(0.027, 0.045, 0.005), Color(0.15, 0.15, 0.15), 0.0, 0.9)
	
	# --- PISTOL GRIP ---
	var grip = _add_box(gun, Vector3(0, -0.04, 0.08), Vector3(0.02, 0.04, 0.022), stock_color, 0.0, 0.9)
	grip.rotation.x = -0.2
	
	# --- TRIGGER ---
	_add_box(gun, Vector3(0, -0.025, 0.04), Vector3(0.016, 0.003, 0.035), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(0, -0.02, 0.05), Vector3(0.003, 0.01, 0.003), metal_mid, 0.85, 0.25)
	
	# --- BIPOD (folded) ---
	for side in [-1, 1]:
		_add_cylinder(gun, Vector3(side * 0.015, -0.025, -0.15), Vector3(0.003, 0.04, 0.003), metal_dark, 0.85, 0.25, 6)
	
	# Bitcoin accent
	_add_box(gun, Vector3(0.016, 0, 0.15), Vector3(0.001, 0.015, 0.015), orange_btc, 0.3, 0.6)
	
	gun.position = Vector3(0, 0, 0)
	
	return gun

# ============================================================
# M4-SAT — M4A1 style carbine (new weapon!)
# ============================================================
func _build_m4_sat() -> Node3D:
	var gun = Node3D.new()
	gun.name = "M4_SAT_Model"
	
	var metal_dark = Color(0.12, 0.12, 0.14)
	var metal_mid = Color(0.22, 0.22, 0.25)
	var metal_anodized = Color(0.15, 0.15, 0.18)
	var grip_color = Color(0.1, 0.1, 0.1)
	var orange_btc = Color(0.97, 0.58, 0.1)
	
	# --- UPPER RECEIVER ---
	_add_box(gun, Vector3(0, 0.005, 0), Vector3(0.032, 0.03, 0.18), metal_anodized, 0.85, 0.25)
	# Flat top rail
	_add_box(gun, Vector3(0, 0.022, -0.02), Vector3(0.025, 0.005, 0.2), metal_dark, 0.85, 0.3)
	# Rail grooves
	for i in range(8):
		var z = -0.1 + i * 0.025
		_add_box(gun, Vector3(0, 0.026, z), Vector3(0.026, 0.002, 0.008), metal_mid, 0.85, 0.3)
	
	# --- LOWER RECEIVER ---
	_add_box(gun, Vector3(0, -0.015, 0.02), Vector3(0.03, 0.02, 0.1), metal_anodized, 0.85, 0.25)
	# Magazine well
	_add_box(gun, Vector3(0, -0.03, 0.0), Vector3(0.024, 0.015, 0.04), metal_anodized, 0.85, 0.25)
	
	# --- BARREL ---
	_add_cylinder(gun, Vector3(0, 0.005, -0.32), Vector3(0.009, 0.28, 0.009), metal_dark, 0.9, 0.2, 10)
	# Barrel nut
	_add_cylinder(gun, Vector3(0, 0.005, -0.1), Vector3(0.018, 0.015, 0.018), metal_mid, 0.85, 0.25, 8)
	
	# --- HANDGUARD (M-LOK style, quad rail) ---
	# Top rail
	_add_box(gun, Vector3(0, 0.022, -0.22), Vector3(0.025, 0.005, 0.16), metal_dark, 0.85, 0.3)
	# Bottom
	_add_box(gun, Vector3(0, -0.012, -0.22), Vector3(0.025, 0.005, 0.16), metal_dark, 0.85, 0.3)
	# Sides
	_add_box(gun, Vector3(0.016, 0.005, -0.22), Vector3(0.005, 0.025, 0.16), metal_dark, 0.85, 0.3)
	_add_box(gun, Vector3(-0.016, 0.005, -0.22), Vector3(0.005, 0.025, 0.16), metal_dark, 0.85, 0.3)
	# M-LOK slots
	for i in range(3):
		var z2 = -0.16 - i * 0.04
		_add_box(gun, Vector3(0.018, 0.005, z2), Vector3(0.002, 0.012, 0.025), Color(0, 0, 0), 0.0, 1.0)
		_add_box(gun, Vector3(-0.018, 0.005, z2), Vector3(0.002, 0.012, 0.025), Color(0, 0, 0), 0.0, 1.0)
	
	# --- FLASH HIDER ---
	_add_cylinder(gun, Vector3(0, 0.005, -0.47), Vector3(0.012, 0.03, 0.012), metal_dark, 0.9, 0.2, 8)
	# Flash hider prongs
	for angle in [0, 1.57, 3.14, 4.71]:
		var x = cos(angle) * 0.013
		var y = sin(angle) * 0.013 + 0.005
		_add_box(gun, Vector3(x, y, -0.485), Vector3(0.003, 0.003, 0.015), metal_dark, 0.9, 0.2)
	
	# --- FRONT SIGHT (folding, on rail) ---
	_add_box(gun, Vector3(0, 0.028, -0.28), Vector3(0.008, 0.003, 0.008), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(0, 0.04, -0.28), Vector3(0.003, 0.02, 0.003), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(0, 0.052, -0.28), Vector3(0.002, 0.003, 0.002), orange_btc, 0.3, 0.6)
	
	# --- REAR SIGHT (flip up) ---
	_add_box(gun, Vector3(0, 0.028, 0.06), Vector3(0.01, 0.003, 0.01), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(-0.004, 0.04, 0.06), Vector3(0.002, 0.015, 0.004), metal_dark, 0.85, 0.25)
	_add_box(gun, Vector3(0.004, 0.04, 0.06), Vector3(0.002, 0.015, 0.004), metal_dark, 0.85, 0.25)
	
	# --- MAGAZINE (STANAG style, straight) ---
	_add_box(gun, Vector3(0, -0.065, -0.01), Vector3(0.02, 0.05, 0.06), metal_dark, 0.75, 0.35)
	_add_box(gun, Vector3(0, -0.06, -0.015), Vector3(0.021, 0.045, 0.055), Color(0.14, 0.14, 0.16), 0.75, 0.35)
	# Mag base plate
	_add_box(gun, Vector3(0, -0.092, -0.01), Vector3(0.022, 0.005, 0.058), metal_mid, 0.8, 0.3)
	# Bitcoin logo on mag
	_add_box(gun, Vector3(0.011, -0.065, -0.01), Vector3(0.001, 0.018, 0.018), orange_btc, 0.3, 0.6)
	
	# --- PISTOL GRIP (A2 style) ---
	var grip = _add_box(gun, Vector3(0, -0.04, 0.06), Vector3(0.02, 0.04, 0.022), grip_color, 0.0, 0.9)
	grip.rotation.x = -0.25
	# Grip texture
	for i in range(4):
		var y2 = -0.025 - i * 0.01
		_add_box(gun, Vector3(0.011, y2, 0.06), Vector3(0.001, 0.003, 0.015), Color(0.05, 0.05, 0.05), 0.0, 0.95)
	# Grip base
	_add_box(gun, Vector3(0, -0.075, 0.065), Vector3(0.022, 0.008, 0.024), grip_color, 0.0, 0.9)
	
	# --- STOCK (collapsible, M4 style) ---
	# Buffer tube
	_add_cylinder(gun, Vector3(0, 0, 0.15), Vector3(0.012, 0.08, 0.012), metal_anodized, 0.85, 0.25, 8)
	# Stock body
	_add_box(gun, Vector3(0, 0, 0.25), Vector3(0.022, 0.035, 0.1), grip_color, 0.0, 0.9)
	# Butt pad
	_add_box(gun, Vector3(0, 0, 0.3), Vector3(0.024, 0.04, 0.006), Color(0.2, 0.2, 0.2), 0.0, 0.85)
	# Stock latch
	_add_box(gun, Vector3(0, -0.02, 0.22), Vector3(0.008, 0.005, 0.015), metal_mid, 0.85, 0.25)
	
	# --- TRIGGER GUARD ---
	_add_box(gun, Vector3(0, -0.028, 0.02), Vector3(0.018, 0.003, 0.04), metal_anodized, 0.85, 0.25)
	_add_box(gun, Vector3(0, -0.02, 0.0), Vector3(0.018, 0.003, 0.003), metal_anodized, 0.85, 0.25)
	# Trigger
	_add_box(gun, Vector3(0, -0.018, 0.02), Vector3(0.003, 0.01, 0.003), metal_mid, 0.85, 0.25)
	
	# --- FORWARD ASSIST ---
	_add_cylinder(gun, Vector3(0.018, 0.01, 0.06), Vector3(0.005, 0.006, 0.005), metal_mid, 0.85, 0.25, 6)
	
	# --- CHARGING HANDLE ---
	_add_box(gun, Vector3(0, 0.02, 0.1), Vector3(0.006, 0.005, 0.02), metal_mid, 0.85, 0.25)
	# Latch
	_add_box(gun, Vector3(-0.008, 0.02, 0.095), Vector3(0.006, 0.004, 0.01), metal_mid, 0.85, 0.25)
	
	# --- EJECTION PORT COVER ---
	_add_box(gun, Vector3(0.017, 0.005, 0.04), Vector3(0.002, 0.018, 0.03), metal_mid, 0.85, 0.25)
	
	# --- SELECTOR SWITCH ---
	_add_box(gun, Vector3(0.016, -0.01, 0.06), Vector3(0.003, 0.005, 0.012), metal_mid, 0.85, 0.25)
	
	gun.position = Vector3(0, 0, 0)
	
	return gun

# ============================================================
# HELPER FUNCTIONS
# ============================================================
# ============================================================
# KNIFE MODEL
# ============================================================
func _build_knife_model() -> Node3D:
	var knife = Node3D.new()
	knife.name = "Knife_Model"
	
	var blade_color = Color(0.6, 0.6, 0.65)
	var handle_color = Color(0.15, 0.15, 0.15)
	var orange_btc = Color(0.97, 0.58, 0.1)
	
	# Blade
	_add_box(knife, Vector3(0, 0, -0.15), Vector3(0.01, 0.03, 0.15), blade_color, 0.9, 0.15)
	# Blade edge (slightly wider)
	_add_box(knife, Vector3(0, -0.005, -0.15), Vector3(0.015, 0.005, 0.14), blade_color, 0.9, 0.1)
	# Blade tip
	_add_box(knife, Vector3(0, 0, -0.23), Vector3(0.008, 0.02, 0.02), blade_color, 0.9, 0.15)
	
	# Guard
	_add_box(knife, Vector3(0, 0, -0.07), Vector3(0.025, 0.01, 0.01), Color(0.2, 0.2, 0.2), 0.7, 0.3)
	
	# Handle
	_add_box(knife, Vector3(0, 0, 0.0), Vector3(0.018, 0.025, 0.1), handle_color, 0.0, 0.9)
	# Handle grip texture
	for i in range(3):
		_add_box(knife, Vector3(0.01, 0, -0.02 + i * 0.03), Vector3(0.001, 0.02, 0.015), Color(0.1, 0.1, 0.1), 0.0, 0.95)
	
	# Bitcoin logo on blade
	_add_box(knife, Vector3(0.006, 0.005, -0.16), Vector3(0.001, 0.012, 0.012), orange_btc, 0.3, 0.6)
	
	knife.position = Vector3(0.05, 0.02, -0.05)
	return knife

# ============================================================
# FIRST PERSON ARMS
# ============================================================
func _add_fps_arms(gun: Node3D):
	var skin_color = Color(0.72, 0.55, 0.4)
	var sleeve_color = Color(0.15, 0.2, 0.15)  # Dark green tactical
	
	# === LEFT ARM (front grip / support hand) ===
	var left_arm = Node3D.new()
	left_arm.name = "LeftArm"
	
	# Sleeve (upper arm, comes from left side of screen)
	_add_box(left_arm, Vector3(-0.12, -0.08, -0.1), Vector3(0.06, 0.06, 0.18), sleeve_color, 0.0, 0.85)
	# Forearm
	_add_box(left_arm, Vector3(-0.05, -0.06, -0.18), Vector3(0.055, 0.055, 0.14), sleeve_color, 0.0, 0.85)
	# Wrist (skin)
	_add_box(left_arm, Vector3(-0.02, -0.05, -0.22), Vector3(0.045, 0.04, 0.04), skin_color, 0.0, 0.7)
	# Hand (gripping handguard area)
	_add_box(left_arm, Vector3(0.0, -0.04, -0.24), Vector3(0.04, 0.05, 0.06), skin_color, 0.0, 0.7)
	# Fingers wrapped around
	for i in range(4):
		_add_box(left_arm, Vector3(0.0, -0.06 - i * 0.005, -0.22 - i * 0.01), 
			Vector3(0.035, 0.012, 0.015), skin_color, 0.0, 0.7)
	# Thumb on top
	_add_box(left_arm, Vector3(0.015, -0.025, -0.23), Vector3(0.012, 0.015, 0.03), skin_color, 0.0, 0.7)
	
	gun.add_child(left_arm)
	arm_nodes.append(left_arm)
	
	# === RIGHT ARM (trigger hand) ===
	var right_arm = Node3D.new()
	right_arm.name = "RightArm"
	
	# Sleeve (upper, comes from right-bottom)
	_add_box(right_arm, Vector3(0.1, -0.1, 0.06), Vector3(0.06, 0.06, 0.16), sleeve_color, 0.0, 0.85)
	# Forearm
	_add_box(right_arm, Vector3(0.05, -0.08, 0.0), Vector3(0.055, 0.055, 0.12), sleeve_color, 0.0, 0.85)
	# Wrist
	_add_box(right_arm, Vector3(0.02, -0.06, -0.04), Vector3(0.045, 0.04, 0.04), skin_color, 0.0, 0.7)
	# Hand (gripping pistol grip)
	_add_box(right_arm, Vector3(0.0, -0.05, -0.02), Vector3(0.04, 0.05, 0.05), skin_color, 0.0, 0.7)
	# Fingers on grip
	for i in range(4):
		_add_box(right_arm, Vector3(0.0, -0.07 - i * 0.005, 0.0 + i * 0.008), 
			Vector3(0.035, 0.012, 0.015), skin_color, 0.0, 0.7)
	# Trigger finger
	_add_box(right_arm, Vector3(0.0, -0.05, -0.04), Vector3(0.01, 0.012, 0.025), skin_color, 0.0, 0.7)
	# Thumb
	_add_box(right_arm, Vector3(0.015, -0.035, -0.01), Vector3(0.012, 0.015, 0.03), skin_color, 0.0, 0.7)
	
	gun.add_child(right_arm)
	arm_nodes.append(right_arm)

# ============================================================
# HELPER FUNCTIONS
# ============================================================
func _add_box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, metallic: float = 0.0, roughness: float = 0.5) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh_inst.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	if color.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_inst.set_surface_override_material(0, mat)
	mesh_inst.position = pos
	parent.add_child(mesh_inst)
	return mesh_inst

func _add_cylinder(parent: Node3D, pos: Vector3, size: Vector3, color: Color, metallic: float = 0.0, roughness: float = 0.5, segments: int = 12) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = size.x
	cyl.bottom_radius = size.z
	cyl.height = size.y
	cyl.radial_segments = segments
	mesh_inst.mesh = cyl
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	mesh_inst.set_surface_override_material(0, mat)
	mesh_inst.position = pos
	# Rotate cylinder to point forward (Z axis)
	mesh_inst.rotation.x = PI / 2
	parent.add_child(mesh_inst)
	return mesh_inst
