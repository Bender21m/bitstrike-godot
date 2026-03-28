extends CanvasLayer

# Death Screen — "REKT" overlay with stats and respawn
# Shows kill stats, sats lost, and option to restart

var is_dead: bool = false
var respawn_timer: float = 0.0
var respawn_delay: float = 5.0
var sats_penalty: float = 0.15  # Lose 15% of sats on death

# UI refs
var bg: ColorRect
var title_label: Label
var stats_label: Label
var timer_label: Label
var restart_button: Button
var tip_label: Label

var death_tips = [
	"\"The root problem with conventional currency is all the trust that's required.\"",
	"\"If you don't believe me or don't understand, I don't have time to try to convince you.\"",
	"\"Lost coins only make everyone else's coins worth slightly more.\"",
	"\"I am very intrigued by Bitcoin. It has all the signs. Paradigm shift.\" — John McAfee",
	"Have you tried buying the dip?",
	"The bears got you. Stack harder.",
	"HODL would have been a better strategy.",
	"Weak hands detected.",
	"Your sats are safe. You are not.",
	"Another one bites the dust. — Satoshi, probably",
]

func _ready():
	layer = 20
	visible = false
	_build_ui()

func _build_ui():
	# Full screen dark overlay
	bg = ColorRect.new()
	bg.name = "DeathBG"
	bg.color = Color(0, 0, 0, 0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -250
	vbox.offset_right = 250
	vbox.offset_top = -180
	vbox.offset_bottom = 180
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)
	
	# REKT title
	title_label = Label.new()
	title_label.text = "REKT"
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.15, 0.1))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	# Stats
	stats_label = Label.new()
	stats_label.add_theme_font_size_override("font_size", 20)
	stats_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(stats_label)
	
	# Timer
	timer_label = Label.new()
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(timer_label)
	
	# Tip
	tip_label = Label.new()
	tip_label.add_theme_font_size_override("font_size", 14)
	tip_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(tip_label)
	
	# Restart button (appears after timer)
	restart_button = Button.new()
	restart_button.text = "RESTART ROUND"
	restart_button.add_theme_font_size_override("font_size", 20)
	restart_button.visible = false
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.97, 0.58, 0.1, 0.8)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	btn_style.content_margin_left = 20
	btn_style.content_margin_right = 20
	btn_style.content_margin_top = 10
	btn_style.content_margin_bottom = 10
	restart_button.add_theme_stylebox_override("normal", btn_style)
	restart_button.add_theme_color_override("font_color", Color(0, 0, 0))
	var hover_style = btn_style.duplicate()
	hover_style.bg_color = Color(1, 0.7, 0.2)
	restart_button.add_theme_stylebox_override("hover", hover_style)
	restart_button.pressed.connect(_on_restart)
	vbox.add_child(restart_button)

func show_death(player_kills: int, player_sats: int, round_num: int):
	if is_dead:
		return
	is_dead = true
	visible = true
	respawn_timer = respawn_delay
	restart_button.visible = false
	
	# Calculate sats loss
	var sats_lost = int(player_sats * sats_penalty)
	
	# Set stats text
	stats_label.text = "Kills: %d  |  Round: %d\n₿ %s sats lost" % [
		player_kills, round_num, _format_sats(sats_lost)]
	
	# Random tip
	tip_label.text = death_tips[randi() % death_tips.size()]
	
	# Release mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Animate fade in
	bg.color = Color(0, 0, 0, 0)
	
	return sats_lost

func _process(delta):
	if not is_dead:
		return
	
	# Fade in background
	bg.color.a = min(bg.color.a + delta * 1.5, 0.85)
	
	# Countdown
	if respawn_timer > 0:
		respawn_timer -= delta
		timer_label.text = "Respawning in %d..." % int(ceil(respawn_timer))
		if respawn_timer <= 0:
			timer_label.text = "Ready!"
			restart_button.visible = true
	
	# Pulse the REKT text
	var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.005) * 0.05
	title_label.add_theme_font_size_override("font_size", int(72 * pulse))

func _on_restart():
	is_dead = false
	visible = false
	
	# Reset the game
	get_tree().reload_current_scene()

func _format_sats(amount: int) -> String:
	var s = str(amount)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
