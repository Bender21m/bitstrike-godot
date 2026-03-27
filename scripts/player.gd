extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const MOUSE_SENSITIVITY = 0.002

@onready var camera = $"Camera3D"
@onready var raycast = $"Camera3D/RayCast3D"
@onready var muzzle_flash = $"Camera3D/WeaponHolder/MuzzleFlash"

var health: int = 100
var armor: int = 0
var sats: int = 16000
var kills: int = 0
var current_weapon: int = 0
var recoil: float = 0.0
var can_shoot: bool = true
var last_shot_time: float = 0.0

var weapons = [
	{"name": "AK-B7", "ammo": 30, "max_ammo": 30, "reserve": 90,
	 "damage": 25, "fire_rate": 0.1, "auto": true, "recoil": 0.06},
	{"name": "BEAGLE", "ammo": 7, "max_ammo": 7, "reserve": 35,
	 "damage": 55, "fire_rate": 0.4, "auto": false, "recoil": 0.1},
	{"name": "SABOT", "ammo": 5, "max_ammo": 5, "reserve": 20,
	 "damage": 120, "fire_rate": 0.8, "auto": false, "recoil": 0.15}
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("shoot"):
		shoot()
	if event.is_action_pressed("reload"):
		reload_weapon()
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1: switch_weapon(0)
		if event.keycode == KEY_2: switch_weapon(1)
		if event.keycode == KEY_3: switch_weapon(2)
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	var spd = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	
	if dir:
		velocity.x = dir.x * spd
		velocity.z = dir.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd * delta * 10)
		velocity.z = move_toward(velocity.z, 0, spd * delta * 10)
	
	if recoil > 0:
		camera.rotation.x += recoil * delta
		recoil *= 0.85
	
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
	
	# Muzzle flash
	if muzzle_flash:
		muzzle_flash.light_energy = 3.0
		get_tree().create_timer(0.05).timeout.connect(func(): muzzle_flash.light_energy = 0)
	
	# Raycast hit
	if raycast and raycast.is_colliding():
		var target = raycast.get_collider()
		if target.has_method("take_damage"):
			var hit_pos = raycast.get_collision_point()
			var is_headshot = hit_pos.y > target.global_position.y + 1.2
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
		get_tree().create_timer(0.15).timeout.connect(func(): overlay.color = Color(1, 0, 0, 0))
	if health <= 0:
		die()

func die():
	print("REKT - ", sats, " sats lost")

func add_kill_feed(text: String):
	var feed = get_tree().root.find_child("KillFeed", true, false)
	if feed:
		var label = Label.new()
		label.text = text
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
		feed.add_child(label)
		get_tree().create_timer(5.0).timeout.connect(func(): label.queue_free())

func update_hud():
	var w = weapons[current_weapon]
	var hp_label = get_tree().root.find_child("HealthLabel", true, false)
	if hp_label: hp_label.text = "HP: %d" % health
	var sats_label = get_tree().root.find_child("SatsLabel", true, false)
	if sats_label: sats_label.text = "₿ %s" % str(sats)
	var ammo_label = get_tree().root.find_child("AmmoLabel", true, false)
	if ammo_label: ammo_label.text = "%d / %d" % [w.ammo, w.reserve]
	var weap_label = get_tree().root.find_child("WeaponLabel", true, false)
	if weap_label: weap_label.text = w.name
