extends CanvasLayer

# Scoreboard — TAB key to show, CS 1.6 style
# Shows round stats, kills, deaths, sats

var is_showing: bool = false
var panel: PanelContainer
var stats_container: VBoxContainer

# Track game stats
var total_kills: int = 0
var total_deaths: int = 0
var rounds_won: int = 0
var rounds_lost: int = 0
var total_sats_earned: int = 0
var total_headshots: int = 0
var highest_streak: int = 0
var round_kills: Array = []  # Kills per round

func _ready():
	layer = 18
	visible = false
	_build_ui()

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_TAB:
			if event.pressed:
				_show()
			else:
				_hide()

func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	
	panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.08, 0.95)
	style.border_color = Color(0.97, 0.58, 0.1, 0.6)
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -280
	panel.offset_right = 280
	panel.offset_top = -220
	panel.offset_bottom = 220
	add_child(panel)
	
	stats_container = VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 8)
	panel.add_child(stats_container)

func _show():
	_refresh_stats()
	is_showing = true
	visible = true

func _hide():
	is_showing = false
	visible = false

func _refresh_stats():
	# Clear
	for child in stats_container.get_children():
		child.queue_free()
	
	# Get current player data
	var player = get_tree().get_first_node_in_group("player")
	var current_kills = player.kills if player else 0
	var current_sats = player.sats if player else 0
	
	# Title
	var title = Label.new()
	title.text = "₿ITSTRIKE — SCOREBOARD"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_container.add_child(title)
	
	# Separator
	var sep = HSeparator.new()
	stats_container.add_child(sep)
	
	# Player stats header
	_add_stat_row("PLAYER STATS", "", Color(0.6, 0.6, 0.6), 14)
	
	# Stats
	_add_stat_row("Kills", str(current_kills), Color(0, 1, 0))
	_add_stat_row("Deaths", str(total_deaths), Color(1, 0.3, 0.3))
	_add_stat_row("K/D Ratio", "%.2f" % (float(current_kills) / max(total_deaths, 1)), Color(1, 1, 1))
	_add_stat_row("Headshots", str(total_headshots), Color(1, 0.8, 0))
	_add_stat_row("Best Streak", str(highest_streak), Color(0.97, 0.58, 0.1))
	
	var sep2 = HSeparator.new()
	stats_container.add_child(sep2)
	
	# Economy
	_add_stat_row("ECONOMY", "", Color(0.6, 0.6, 0.6), 14)
	_add_stat_row("Current Sats", "₿ %s" % _format_sats(current_sats), Color(0.97, 0.58, 0.1))
	_add_stat_row("Total Earned", "₿ %s" % _format_sats(total_sats_earned), Color(0.97, 0.58, 0.1))
	
	var sep3 = HSeparator.new()
	stats_container.add_child(sep3)
	
	# Round info
	var spawner = get_tree().root.find_child("EnemySpawner", true, false)
	var round_num = spawner.round_num if spawner else 1
	_add_stat_row("ROUND INFO", "", Color(0.6, 0.6, 0.6), 14)
	_add_stat_row("Current Round", str(round_num), Color(1, 1, 1))
	_add_stat_row("Rounds Won", str(rounds_won), Color(0, 1, 0))
	_add_stat_row("Rounds Lost", str(rounds_lost), Color(1, 0.3, 0.3))
	
	# Footer
	var footer = Label.new()
	footer.text = "[TAB] Close"
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_container.add_child(footer)

func _add_stat_row(label_text: String, value_text: String, color: Color, font_size: int = 18):
	var hbox = HBoxContainer.new()
	stats_container.add_child(hbox)
	
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(label)
	
	if value_text != "":
		var value = Label.new()
		value.text = value_text
		value.add_theme_font_size_override("font_size", font_size)
		value.add_theme_color_override("font_color", color)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(value)

func register_kill(is_headshot: bool = false):
	total_kills += 1
	if is_headshot:
		total_headshots += 1

func register_death():
	total_deaths += 1

func register_sats(amount: int):
	total_sats_earned += amount

func register_streak(count: int):
	highest_streak = max(highest_streak, count)

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
