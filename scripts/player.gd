extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const MOUSE_SENSITIVITY = 0.002

@onready var camera = $"Camera3D"
var health = 100
var armor = 0
var sats = 16000
var kills = 0
var current_weapon = 0
var recoil = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if event.is_action_pressed("shoot"): shoot()
	if event.is_action_pressed("reload"): reload()

func _physics_process(delta):
	if not is_on_floor(): velocity.y -= 9.8 * delta
	var spd = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var input = Input.get_vector("move_left","move_right","move_forward","move_back")
	var dir = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if dir:
		velocity.x = dir.x * spd
		velocity.z = dir.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd * delta * 10)
		velocity.z = move_toward(velocity.z, 0, spd * delta * 10)
	if recoil > 0: camera.rotation.x += recoil * delta; recoil *= 0.9
	move_and_slide()

func shoot():
	var w = GameState.weapons[current_weapon]
	if w.ammo <= 0: return
	w.ammo -= 1
	recoil = -w.recoil

func reload():
	var w = GameState.weapons[current_weapon]
	if w.ammo >= w.max_ammo or w.reserve <= 0: return
	var give = min(w.max_ammo - w.ammo, w.reserve)
	w.ammo += give; w.reserve -= give

func take_damage(amount):
	var dmg = amount
	if armor > 0:
		var ab = dmg * 0.5; armor = max(0, armor - ab); dmg -= ab
	health -= int(dmg)
	if health <= 0: GameState.game_over = true
