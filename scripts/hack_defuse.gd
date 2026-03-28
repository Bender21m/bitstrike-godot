extends Node

# ₿ITSTRIKE HACK/DEFUSE — Core Game Mode
# 
# CS 1.6 bomb/defuse mechanics, Bitcoin themed:
#
# SHITCOINERS (Terrorists / attackers):
#   - One player carries the "51% Attack Device" (the bomb)
#   - Must plant it at one of two HACK SITES (A or B)
#   - Hack sites are Bitcoin node terminals
#   - Planting = "Initiating 51% Attack" (takes 3 seconds)
#   - If planted and timer runs out → Exchange gets drained, Shitcoiners win
#
# BITCOINERS (Counter-Terrorists / defenders):
#   - Defend the two node terminals (hack sites A and B)
#   - If attack is planted, can DEFUSE it (takes 5 sec, 2.5 with kit)
#   - "Defuse Kit" = "Hardware Wallet" (buyable, speeds up defuse)
#   - Defusing = "Validating blocks / Restoring consensus"
#
# WIN CONDITIONS (same as CS):
#   - Shitcoiners: Plant device + timer expires OR eliminate all Bitcoiners
#   - Bitcoiners: Defuse planted device OR eliminate all Shitcoiners
#   - Timer runs out without plant → Bitcoiners win (defended successfully)
#
# ROUND ECONOMY (sats instead of dollars):
#   - Win round: +3,000 sats
#   - Lose round: +1,400 sats (increases with loss streak, max +3,400)
#   - Plant bonus: +800 sats (even if defused)
#   - Defuse bonus: +500 sats
#   - Kill: varies by weapon (300-1,500 sats)

enum Team { BITCOINERS, SHITCOINERS }
enum RoundState { BUY_PHASE, ACTIVE, DEVICE_PLANTED, ROUND_OVER }

# === ROUND CONFIG ===
const ROUND_TIME: float = 115.0  # 1:55 like CS 1.6
const PLANT_TIME: float = 3.0
const DEFUSE_TIME: float = 5.0
const DEFUSE_TIME_KIT: float = 2.5
const DEVICE_TIMER: float = 40.0  # After plant, 40 seconds to defuse
const BUY_PHASE_TIME: float = 15.0

# === STATE ===
var round_state: int = RoundState.BUY_PHASE
var round_timer: float = 0.0
var device_timer: float = 0.0
var plant_progress: float = 0.0
var defuse_progress: float = 0.0
var is_planting: bool = false
var is_defusing: bool = false
var device_planted: bool = false
var device_site: String = ""  # "A" or "B"
var round_number: int = 0

# === HACK SITES ===
var hack_sites: Dictionary = {
	"A": {"position": Vector3(6, 0, 18), "name": "NODE ALPHA", "planted": false},
	"B": {"position": Vector3(18, 0, 18), "name": "NODE BRAVO", "planted": false},
}

# === ECONOMY ===
const WIN_BONUS: int = 3000
const LOSS_BONUS_BASE: int = 1400
const LOSS_BONUS_INCREMENT: int = 500
const LOSS_BONUS_MAX: int = 3400
const PLANT_BONUS: int = 800
const DEFUSE_BONUS: int = 500
var loss_streak: int = 0

# === VISUALS ===
var site_a_marker: Node3D
var site_b_marker: Node3D
var device_model: Node3D
var timer_label: Label
var status_label: Label
var progress_bar: ColorRect
var progress_bg: ColorRect
var site_label_a: Label
var site_label_b: Label

signal round_started()
signal round_ended(winning_team: int)
signal device_planted_signal(site: String)
signal device_defused_signal()

func _ready():
	set_process(false)  # Disabled until game mode starts
	_build_hack_sites()
	_build_hud()

func start_game_mode():
	set_process(true)
	round_number = 0
	_start_new_round()

func _start_new_round():
	round_number += 1
	round_state = RoundState.BUY_PHASE
	round_timer = BUY_PHASE_TIME
	device_planted = false
	device_site = ""
	plant_progress = 0.0
	defuse_progress = 0.0
	is_planting = false
	is_defusing = false
	
	# Reset hack sites
	for site in hack_sites.values():
		site.planted = false
	
	# Hide device model
	if device_model:
		device_model.visible = false
	
	# Announce
	if has_node("/root/RoundAnnouncer"):
		$"/root/RoundAnnouncer".announce_custom(
			"ROUND %d" % round_number,
			"Defend the Bitcoin nodes!",
			Color(0.97, 0.58, 0.1), 3.0)
	
	emit_signal("round_started")

func _process(delta):
	match round_state:
		RoundState.BUY_PHASE:
			_process_buy_phase(delta)
		RoundState.ACTIVE:
			_process_active(delta)
		RoundState.DEVICE_PLANTED:
			_process_planted(delta)
		RoundState.ROUND_OVER:
			pass
	
	_update_hud()

func _process_buy_phase(delta):
	round_timer -= delta
	if round_timer <= 0:
		round_state = RoundState.ACTIVE
		round_timer = ROUND_TIME
		if has_node("/root/RoundAnnouncer"):
			$"/root/RoundAnnouncer".announce_custom(
				"ROUND LIVE",
				"Protect the nodes — watch for the 51% attack",
				Color(0, 0.8, 0.3), 2.0)

func _process_active(delta):
	round_timer -= delta
	
	# Check if player is near a hack site and planting
	if is_planting:
		plant_progress += delta
		if plant_progress >= PLANT_TIME:
			_plant_device()
	
	# Time ran out without plant → Bitcoiners win
	if round_timer <= 0:
		_end_round(Team.BITCOINERS, "TIME'S UP — NODES SECURED")

func _process_planted(delta):
	device_timer -= delta
	
	# Check defuse progress
	if is_defusing:
		defuse_progress += delta
		var defuse_time = DEFUSE_TIME  # TODO: check for hardware wallet
		if defuse_progress >= defuse_time:
			_defuse_device()
	
	# Timer expired → Shitcoiners win
	if device_timer <= 0:
		_end_round(Team.SHITCOINERS, "EXCHANGE DRAINED — 51% ATTACK SUCCESS")

func _plant_device():
	device_planted = true
	round_state = RoundState.DEVICE_PLANTED
	device_timer = DEVICE_TIMER
	is_planting = false
	plant_progress = 0.0
	
	# Show device at site
	if device_model:
		var site = hack_sites[device_site]
		device_model.global_position = site.position + Vector3(0, 0.3, 0)
		device_model.visible = true
		site.planted = true
	
	# Award plant bonus
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.sats += PLANT_BONUS
	
	# Announce
	if has_node("/root/RoundAnnouncer"):
		$"/root/RoundAnnouncer".announce_custom(
			"⚠ 51% ATTACK PLANTED",
			"Site %s — %.0f seconds to defuse!" % [device_site, DEVICE_TIMER],
			Color(1, 0.2, 0.1), 3.0)
	
	var p = get_tree().get_first_node_in_group("player")
	if p and p.has_method("add_kill_feed"):
		p.add_kill_feed("⚠ 51% ATTACK DEVICE PLANTED AT SITE %s" % device_site)
	
	emit_signal("device_planted_signal", device_site)

func _defuse_device():
	is_defusing = false
	defuse_progress = 0.0
	device_planted = false
	
	if device_model:
		device_model.visible = false
	
	# Award defuse bonus
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.sats += DEFUSE_BONUS
	
	_end_round(Team.BITCOINERS, "CONSENSUS RESTORED — ATTACK DEFUSED")
	
	emit_signal("device_defused_signal")

func _end_round(winning_team: int, message: String):
	round_state = RoundState.ROUND_OVER
	
	var color = Color(0, 0.8, 0.3) if winning_team == Team.BITCOINERS else Color(1, 0.2, 0.1)
	var team_name = "BITCOINERS WIN" if winning_team == Team.BITCOINERS else "SHITCOINERS WIN"
	
	if has_node("/root/RoundAnnouncer"):
		$"/root/RoundAnnouncer".announce_custom(team_name, message, color, 4.0)
	
	# Economy
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if winning_team == Team.BITCOINERS:
			player.sats += WIN_BONUS
			loss_streak = 0
		else:
			var loss_bonus = min(LOSS_BONUS_BASE + loss_streak * LOSS_BONUS_INCREMENT, LOSS_BONUS_MAX)
			player.sats += loss_bonus
			loss_streak += 1
	
	emit_signal("round_ended", winning_team)
	
	# Start next round after delay
	get_tree().create_timer(5.0).timeout.connect(_start_new_round)

# === INTERACTION (called from player) ===

func try_plant(site: String):
	if round_state != RoundState.ACTIVE:
		return false
	if device_planted:
		return false
	if not hack_sites.has(site):
		return false
	
	device_site = site
	is_planting = true
	plant_progress = 0.0
	return true

func cancel_plant():
	is_planting = false
	plant_progress = 0.0

func try_defuse():
	if round_state != RoundState.DEVICE_PLANTED:
		return false
	if not device_planted:
		return false
	
	is_defusing = true
	defuse_progress = 0.0
	return true

func cancel_defuse():
	is_defusing = false
	defuse_progress = 0.0

func get_nearest_site(pos: Vector3) -> Dictionary:
	var nearest = ""
	var nearest_dist = 999.0
	for site_id in hack_sites:
		var dist = pos.distance_to(hack_sites[site_id].position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = site_id
	return {"site": nearest, "distance": nearest_dist}

# === BUILD HACK SITE MARKERS ===

func _build_hack_sites():
	var parent = get_parent()
	if not parent:
		# Defer until in tree
		call_deferred("_build_hack_sites")
		return
	
	for site_id in hack_sites:
		var site = hack_sites[site_id]
		var marker = _create_site_marker(site_id, site.position)
		if parent:
			parent.add_child(marker)
	
	# Build the 51% attack device (portable, like the C4)
	device_model = _create_device_model()
	device_model.visible = false
	if parent:
		parent.add_child(device_model)

func _create_site_marker(site_id: String, pos: Vector3) -> Node3D:
	var root = Node3D.new()
	root.name = "HackSite_%s" % site_id
	root.position = pos
	
	# Terminal base
	var base = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(1.2, 0.1, 1.2)
	base.mesh = base_mesh
	var base_mat = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.15, 0.15, 0.2)
	base_mat.emission_enabled = true
	base_mat.emission = Color(0.97, 0.58, 0.1)
	base_mat.emission_energy_multiplier = 0.3
	base.set_surface_override_material(0, base_mat)
	base.position.y = 0.05
	root.add_child(base)
	
	# Terminal screen
	var screen = MeshInstance3D.new()
	var screen_mesh = BoxMesh.new()
	screen_mesh.size = Vector3(0.8, 0.6, 0.1)
	screen.mesh = screen_mesh
	var screen_mat = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.05, 0.1, 0.05)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0, 0.8, 0)
	screen_mat.emission_energy_multiplier = 0.5
	screen.set_surface_override_material(0, screen_mat)
	screen.position = Vector3(0, 0.8, 0)
	root.add_child(screen)
	
	# ₿ symbol on screen
	var btc_symbol = MeshInstance3D.new()
	var btc_mesh = BoxMesh.new()
	btc_mesh.size = Vector3(0.15, 0.25, 0.02)
	btc_symbol.mesh = btc_mesh
	var btc_mat = StandardMaterial3D.new()
	btc_mat.albedo_color = Color(0.97, 0.58, 0.1)
	btc_mat.emission_enabled = true
	btc_mat.emission = Color(0.97, 0.58, 0.1)
	btc_mat.emission_energy_multiplier = 2.0
	btc_symbol.set_surface_override_material(0, btc_mat)
	btc_symbol.position = Vector3(0, 0.8, -0.06)
	root.add_child(btc_symbol)
	
	# Site label floating above
	var label_light = OmniLight3D.new()
	label_light.light_color = Color(0.97, 0.58, 0.1)
	label_light.light_energy = 0.5
	label_light.omni_range = 5.0
	label_light.position = Vector3(0, 2, 0)
	root.add_child(label_light)
	
	# Letter marker (A or B) — large, visible from distance
	var letter = MeshInstance3D.new()
	var letter_mesh = BoxMesh.new()
	letter_mesh.size = Vector3(0.4, 0.5, 0.05)
	letter.mesh = letter_mesh
	var letter_mat = StandardMaterial3D.new()
	if site_id == "A":
		letter_mat.albedo_color = Color(1, 0.3, 0.1)
		letter_mat.emission = Color(1, 0.3, 0.1)
	else:
		letter_mat.albedo_color = Color(0.1, 0.5, 1)
		letter_mat.emission = Color(0.1, 0.5, 1)
	letter_mat.emission_enabled = true
	letter_mat.emission_energy_multiplier = 1.5
	letter.set_surface_override_material(0, letter_mat)
	letter.position = Vector3(0, 2.0, 0)
	root.add_child(letter)
	
	return root

func _create_device_model() -> Node3D:
	# 51% Attack Device — looks like a hacking terminal / mining rig
	var device = Node3D.new()
	device.name = "AttackDevice"
	
	# Main box (like C4 but techy)
	var body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.4, 0.15, 0.3)
	body.mesh = body_mesh
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.1, 0.1, 0.12)
	body_mat.metallic = 0.6
	body_mat.roughness = 0.4
	body.set_surface_override_material(0, body_mat)
	device.add_child(body)
	
	# Blinking red light
	var red_light = OmniLight3D.new()
	red_light.light_color = Color(1, 0, 0)
	red_light.light_energy = 1.0
	red_light.omni_range = 4.0
	red_light.position = Vector3(0, 0.2, 0)
	device.add_child(red_light)
	
	# Screen on top
	var screen = MeshInstance3D.new()
	var screen_mesh = BoxMesh.new()
	screen_mesh.size = Vector3(0.2, 0.02, 0.15)
	screen.mesh = screen_mesh
	var screen_mat = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(1, 0.1, 0.1)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(1, 0, 0)
	screen_mat.emission_energy_multiplier = 2.0
	screen.set_surface_override_material(0, screen_mat)
	screen.position = Vector3(0, 0.1, 0)
	device.add_child(screen)
	
	return device

# === HUD ===

func _build_hud():
	var canvas = CanvasLayer.new()
	canvas.layer = 8
	add_child(canvas)
	
	# Timer (top center)
	timer_label = Label.new()
	timer_label.name = "HackTimer"
	timer_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	timer_label.offset_left = -60
	timer_label.offset_right = 60
	timer_label.offset_top = 40
	timer_label.offset_bottom = 70
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 28)
	timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
	canvas.add_child(timer_label)
	
	# Status (below timer)
	status_label = Label.new()
	status_label.name = "HackStatus"
	status_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	status_label.offset_left = -200
	status_label.offset_right = 200
	status_label.offset_top = 70
	status_label.offset_bottom = 95
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	canvas.add_child(status_label)
	
	# Plant/Defuse progress bar
	progress_bg = ColorRect.new()
	progress_bg.color = Color(0.2, 0.2, 0.2, 0.7)
	progress_bg.set_anchors_preset(Control.PRESET_CENTER)
	progress_bg.offset_left = -100
	progress_bg.offset_right = 100
	progress_bg.offset_top = 40
	progress_bg.offset_bottom = 50
	progress_bg.visible = false
	canvas.add_child(progress_bg)
	
	progress_bar = ColorRect.new()
	progress_bar.color = Color(0.97, 0.58, 0.1)
	progress_bar.set_anchors_preset(Control.PRESET_CENTER)
	progress_bar.offset_left = -100
	progress_bar.offset_right = -100  # Grows from left
	progress_bar.offset_top = 40
	progress_bar.offset_bottom = 50
	progress_bar.visible = false
	canvas.add_child(progress_bar)

func _update_hud():
	if not timer_label:
		return
	
	match round_state:
		RoundState.BUY_PHASE:
			timer_label.text = "BUY: %d" % int(ceil(round_timer))
			timer_label.add_theme_color_override("font_color", Color(0, 0.8, 0.3))
			status_label.text = "Prepare your loadout"
		RoundState.ACTIVE:
			var mins = int(round_timer) / 60
			var secs = int(round_timer) % 60
			timer_label.text = "%d:%02d" % [mins, secs]
			if round_timer < 30:
				timer_label.add_theme_color_override("font_color", Color(1, 0.3, 0.1))
			else:
				timer_label.add_theme_color_override("font_color", Color(1, 1, 1))
			status_label.text = "Defend Node Alpha & Node Bravo"
		RoundState.DEVICE_PLANTED:
			timer_label.text = "💣 %d" % int(ceil(device_timer))
			timer_label.add_theme_color_override("font_color", Color(1, 0.1, 0.1))
			status_label.text = "51%% ATTACK AT SITE %s — DEFUSE NOW!" % device_site
			# Pulse the timer when low
			if device_timer < 10:
				var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.02) * 0.15
				timer_label.add_theme_font_size_override("font_size", int(28 * pulse))
		RoundState.ROUND_OVER:
			status_label.text = "Round over — next round starting..."
	
	# Progress bar for plant/defuse
	if is_planting:
		progress_bg.visible = true
		progress_bar.visible = true
		var pct = plant_progress / PLANT_TIME
		progress_bar.offset_right = -100 + pct * 200
		progress_bar.color = Color(1, 0.3, 0.1)  # Red for planting (enemy action)
	elif is_defusing:
		progress_bg.visible = true
		progress_bar.visible = true
		var pct = defuse_progress / DEFUSE_TIME
		progress_bar.offset_right = -100 + pct * 200
		progress_bar.color = Color(0, 0.8, 0.3)  # Green for defusing
	else:
		progress_bg.visible = false
		progress_bar.visible = false
	
	# Blink device model red light when planted
	if device_planted and device_model:
		var blink = fmod(Time.get_ticks_msec() * 0.001, 0.5) < 0.25
		for child in device_model.get_children():
			if child is OmniLight3D:
				child.light_energy = 2.0 if blink else 0.3
				# Faster blink when timer is low
				if device_timer < 10:
					var fast_blink = fmod(Time.get_ticks_msec() * 0.001, 0.15) < 0.075
					child.light_energy = 3.0 if fast_blink else 0.1
