extends Node

# Kill Streak System — CS-style announcements
# Tracks rapid kills and announces streaks

var kills_in_window: int = 0
var kill_window_timer: float = 0.0
var kill_window_duration: float = 3.0  # Seconds between kills to count
var last_announced: int = 0  # Don't re-announce same level
var total_kills_round: int = 0

var streak_names = {
	2: {"text": "DOUBLE KILL", "color": Color(1, 0.8, 0)},
	3: {"text": "TRIPLE KILL", "color": Color(1, 0.5, 0)},
	4: {"text": "ULTRA KILL", "color": Color(1, 0.3, 0)},
	5: {"text": "RAMPAGE!", "color": Color(1, 0.1, 0.1)},
	6: {"text": "UNSTOPPABLE!", "color": Color(0.9, 0, 0.2)},
	7: {"text": "GODLIKE!", "color": Color(0.97, 0.58, 0.1)},
	8: {"text": "WHOLE COINER!", "color": Color(0.97, 0.58, 0.1)},
}

var streak_label: Label

func _ready():
	# Create center-screen streak announcement label
	var canvas = CanvasLayer.new()
	canvas.layer = 15
	add_child(canvas)
	
	streak_label = Label.new()
	streak_label.name = "StreakLabel"
	streak_label.set_anchors_preset(Control.PRESET_CENTER)
	streak_label.offset_left = -200
	streak_label.offset_right = 200
	streak_label.offset_top = -80
	streak_label.offset_bottom = -40
	streak_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	streak_label.add_theme_font_size_override("font_size", 36)
	streak_label.visible = false
	canvas.add_child(streak_label)

func register_kill():
	kills_in_window += 1
	total_kills_round += 1
	kill_window_timer = kill_window_duration
	
	# Only announce if we haven't already announced this streak level
	if streak_names.has(kills_in_window) and kills_in_window > last_announced:
		last_announced = kills_in_window
		_announce_streak(kills_in_window)

func _announce_streak(count: int):
	var data = streak_names[count]
	# Only show on-screen for triple kill and above (double is too common)
	if count < 3:
		return
	
	streak_label.text = data.text
	streak_label.add_theme_color_override("font_color", data.color)
	streak_label.add_theme_font_size_override("font_size", 28)
	streak_label.visible = true
	
	# Quick 1.5s display then gone
	get_tree().create_timer(1.5).timeout.connect(func():
		if is_instance_valid(streak_label):
			streak_label.visible = false
	)

func _process(delta):
	if kill_window_timer > 0:
		kill_window_timer -= delta
		if kill_window_timer <= 0:
			kills_in_window = 0
			last_announced = 0
	
	# Animate streak label
	if streak_label.visible:
		var t = Time.get_ticks_msec() * 0.01
		streak_label.offset_top = -80 + sin(t) * 3

func reset_round():
	kills_in_window = 0
	total_kills_round = 0
	kill_window_timer = 0.0
