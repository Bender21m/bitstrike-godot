extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const MOUSE_SENSITIVITY = 0.002

@onready var camera: Camera3D = $"Camera3D"
@onready var raycast: RayCast3D = $"Camera3D/RayCast3D"

var health: int = 100
var armor: int = 0
var sats: int = 16000
var kills: int = 0
var current_weapon: int = 0
var recoil: float = 0.0
var last_shot_time: float = 0.0
var mouse_captured: bool = false

var weapons = [
	{"name": "AK-B7", "ammo": 30, "max_ammo": 30, "reserve": 90,
	 "damage": 25, "fire_rate": 0.1, "recoil": 0.06},
	{"name": "BEAGLE", "ammo": 7, "max_ammo": 7, "reserve": 35,
	 "damage": 55, "fire_rate": 0.4, "recoil": 0.1},
	{"name": "SABOT", "ammo": 5, "max_ammo": 5, "reserve": 20,
	 "damage": 120, "fire_rate": 0.8, "recoil": 0.15}
]

func _ready():
	add_to_group("player")
	# Don't capture mouse here - wait for first click

func _input(event):
	# Capture mouse on first click
	if event is InputEventMouseButton and event.pressed and not mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true
		return
	
	if not mouse_captured:
		return
	
	# Block mouse input while buy menu is open
	var buy_menu = get_tree().root.find_child("BuyMenu", true, false)
	if buy_menu and buy_menu.is_open:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		shoot()
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_B:
				var buy_menu = get_tree().root.find_child("BuyMenu", true, false)
				if buy_menu and buy_menu.has_method("toggle_menu"):
					buy_menu.toggle_menu()
				return
			KEY_R: reload_weapon()
			KEY_1: switch_weapon(0)
			KEY_2: switch_weapon(1)
			KEY_3: switch_weapon(2)
			KEY_ESCAPE:
				# Close buy menu first if open
				var bm = get_tree().root.find_child("BuyMenu", true, false)
				if bm and bm.is_open:
					bm.close_menu()
					return
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouse_captured = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	var spd = SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		spd = SPRINT_SPEED
	
	var input_x = 0.0
	var input_z = 0.0
	if Input.is_key_pressed(KEY_W): input_z -= 1
	if Input.is_key_pressed(KEY_S): input_z += 1
	if Input.is_key_pressed(KEY_A): input_x -= 1
	if Input.is_key_pressed(KEY_D): input_x += 1
	
	var dir = (transform.basis * Vector3(input_x, 0, input_z)).normalized()
	
	if dir:
		velocity.x = dir.x * spd
		velocity.z = dir.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd * delta * 10)
		velocity.z = move_toward(velocity.z, 0, spd * delta * 10)
	
	if recoil != 0:
		camera.rotation.x += recoil * delta
		recoil *= 0.85
		if abs(recoil) < 0.001:
			recoil = 0
	
	move_and_slide()
	update_hud()

func shoot():
	var w = weapons[current_weapon]
	var now = Time.get_ticks_msec() / 1000.0
	if w.ammo <= 0 or now - last_shot_time < w.fire_rate:
		return
	
	last_shot_time = now
	w.ammo -= 1
	recoil = -w.recoil
	if has_node("/root/AudioManager"): $"/root/AudioManager".play("shoot")
	
	# Muzzle flash
	var mf = find_child("MuzzleFlash", true, false)
	if mf:
		mf.light_energy = 3.0
		get_tree().create_timer(0.05).timeout.connect(func(): 
			if is_instance_valid(mf): mf.light_energy = 0)
	
	# Raycast hit
	if raycast and raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.has_method("take_damage"):
			var hit_pos = raycast.get_collision_point()
			var is_headshot = hit_pos.y > target.global_position.y + 1.3
			var damage = w.damage * (2 if is_headshot else 1)
			target.take_damage(damage, is_headshot)
			if is_headshot:
				add_kill_feed("HEADSHOT!")

func reload_weapon():
	var w = weapons[current_weapon]
	if w.ammo >= w.max_ammo or w.reserve <= 0:
		return
	var give = min(w.max_ammo - w.ammo, w.reserve)
	w.ammo += give
	w.reserve -= give

func switch_weapon(idx: int):
	current_weapon = idx

func take_damage(amount: int):
	var dmg = amount
	if armor > 0:
		var absorbed = dmg * 0.5
		armor = max(0, armor - absorbed)
		dmg -= absorbed
	health -= int(dmg)
	# Flash damage overlay
	var overlay = get_tree().root.find_child("DamageOverlay", true, false)
	if overlay:
		overlay.color = Color(1, 0, 0, 0.3)
		get_tree().create_timer(0.15).timeout.connect(func(): 
			if is_instance_valid(overlay): overlay.color = Color(1, 0, 0, 0))
	if health <= 0:
		die()

func die():
	print("REKT - ", sats, " sats lost")

func add_kill_feed(text: String):
	var feed = get_tree().root.find_child("KillFeed", true, false)
	if feed:
		var label = Label.new()
		label.text = text
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
		feed.add_child(label)
		get_tree().create_timer(5.0).timeout.connect(func(): 
			if is_instance_valid(label): label.queue_free())

func update_hud():
	var w = weapons[current_weapon]
	var hp = get_tree().root.find_child("HealthLabel", true, false)
	if hp: hp.text = "HP: %d" % health
	var sl = get_tree().root.find_child("SatsLabel", true, false)
	if sl: sl.text = "₿ %s" % str(sats)
	var al = get_tree().root.find_child("AmmoLabel", true, false)
	if al: al.text = "%d / %d" % [w.ammo, w.reserve]
	var wl = get_tree().root.find_child("WeaponLabel", true, false)
	if wl: wl.text = w.name
