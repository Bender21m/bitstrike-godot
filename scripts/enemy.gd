extends CharacterBody3D

@export var enemy_type: String = "banker"
var health = 60
var move_speed = 3.0
var attack_damage = 10
var sats_reward = 5000
var player: Node3D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	var data = {
		"banker": {"hp":60,"spd":3.0,"dmg":12,"reward":5000},
		"shitcoiner": {"hp":40,"spd":4.5,"dmg":8,"reward":3000},
		"bear": {"hp":50,"spd":3.5,"dmg":10,"reward":4000},
		"roger": {"hp":45,"spd":5.0,"dmg":8,"reward":6000},
		"adam": {"hp":120,"spd":2.0,"dmg":18,"reward":8000},
		"fed": {"hp":200,"spd":2.0,"dmg":25,"reward":21000}
	}.get(enemy_type, {"hp":60,"spd":3.0,"dmg":12,"reward":5000})
	health = data.hp; move_speed = data.spd
	attack_damage = data.dmg; sats_reward = data.reward

func _physics_process(delta):
	if not player or health <= 0: return
	var dir = (player.global_position - global_position).normalized()
	var dist = global_position.distance_to(player.global_position)
	look_at(player.global_position)
	if dist > 1.5:
		velocity = dir * move_speed
		if enemy_type == "roger" and sin(Time.get_ticks_msec() * 0.001) > 0.7:
			velocity = -dir * move_speed * 0.5
	velocity.y -= 9.8 * delta
	move_and_slide()

func take_damage(amount, headshot = false):
	health -= amount
	if health <= 0: die()

func die():
	var p = get_tree().get_first_node_in_group("player")
	if p: p.sats += sats_reward; p.kills += 1
	var tw = create_tween()
	tw.tween_property(self, "rotation:x", PI/2, 0.5)
	tw.tween_callback(queue_free).set_delay(1.0)
