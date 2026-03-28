extends Node

# Match System — CS-style match structure
# MR15 format: first to 16 rounds wins
# Teams swap sides at half (round 15)
# Overtime if tied at 15-15

const ROUNDS_PER_HALF: int = 15
const ROUNDS_TO_WIN: int = 16

var bitcoiner_score: int = 0
var shitcoiner_score: int = 0
var current_round: int = 0
var is_first_half: bool = true
var match_over: bool = false

# HUD elements
var score_label: Label

func _ready():
	_build_score_hud()

func _build_score_hud():
	var canvas = CanvasLayer.new()
	canvas.layer = 9
	add_child(canvas)
	
	# Score display — top center, CS style
	# BITCOINERS [score] : [score] SHITCOINERS
	var container = HBoxContainer.new()
	container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	container.offset_left = -160
	container.offset_right = 160
	container.offset_top = 5
	container.offset_bottom = 35
	container.add_theme_constant_override("separation", 0)
	canvas.add_child(container)
	
	# Bitcoiner side
	var btc_bg = PanelContainer.new()
	var btc_style = StyleBoxFlat.new()
	btc_style.bg_color = Color(0.97, 0.58, 0.1, 0.3)
	btc_style.content_margin_left = 12
	btc_style.content_margin_right = 12
	btc_style.content_margin_top = 2
	btc_style.content_margin_bottom = 2
	btc_bg.add_theme_stylebox_override("panel", btc_style)
	btc_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(btc_bg)
	
	var btc_label = Label.new()
	btc_label.name = "BTCScoreLabel"
	btc_label.text = "₿TC  0"
	btc_label.add_theme_font_size_override("font_size", 18)
	btc_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	btc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	btc_bg.add_child(btc_label)
	
	# Separator
	var sep = PanelContainer.new()
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = Color(0.3, 0.3, 0.3, 0.5)
	sep_style.content_margin_left = 8
	sep_style.content_margin_right = 8
	sep_style.content_margin_top = 2
	sep_style.content_margin_bottom = 2
	sep.add_theme_stylebox_override("panel", sep_style)
	container.add_child(sep)
	
	var sep_label = Label.new()
	sep_label.text = ":"
	sep_label.add_theme_font_size_override("font_size", 18)
	sep_label.add_theme_color_override("font_color", Color(1, 1, 1))
	sep.add_child(sep_label)
	
	# Shitcoiner side
	var sc_bg = PanelContainer.new()
	var sc_style = StyleBoxFlat.new()
	sc_style.bg_color = Color(0.6, 0.2, 0.8, 0.3)
	sc_style.content_margin_left = 12
	sc_style.content_margin_right = 12
	sc_style.content_margin_top = 2
	sc_style.content_margin_bottom = 2
	sc_bg.add_theme_stylebox_override("panel", sc_style)
	sc_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(sc_bg)
	
	var sc_label = Label.new()
	sc_label.name = "SCScoreLabel"
	sc_label.text = "0  FIAT"
	sc_label.add_theme_font_size_override("font_size", 18)
	sc_label.add_theme_color_override("font_color", Color(0.6, 0.2, 0.8))
	sc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	sc_bg.add_child(sc_label)

func bitcoiners_win_round():
	bitcoiner_score += 1
	current_round += 1
	_update_score()
	_check_match_end()

func shitcoiners_win_round():
	shitcoiner_score += 1
	current_round += 1
	_update_score()
	_check_match_end()

func _update_score():
	var btc_label = get_tree().root.find_child("BTCScoreLabel", true, false)
	var sc_label = get_tree().root.find_child("SCScoreLabel", true, false)
	if btc_label:
		btc_label.text = "₿TC  %d" % bitcoiner_score
	if sc_label:
		sc_label.text = "%d  FIAT" % shitcoiner_score
	
	# Check for halftime
	if current_round == ROUNDS_PER_HALF and is_first_half:
		is_first_half = false
		if has_node("/root/RoundAnnouncer"):
			$"/root/RoundAnnouncer".announce_custom(
				"HALFTIME",
				"Switching sides — ₿TC %d : %d FIAT" % [bitcoiner_score, shitcoiner_score],
				Color(1, 1, 0), 5.0)

func _check_match_end():
	if match_over:
		return
	
	if bitcoiner_score >= ROUNDS_TO_WIN:
		match_over = true
		if has_node("/root/RoundAnnouncer"):
			$"/root/RoundAnnouncer".announce_custom(
				"BITCOINERS WIN!",
				"Final Score: ₿TC %d : %d FIAT\nHard money wins." % [bitcoiner_score, shitcoiner_score],
				Color(0.97, 0.58, 0.1), 8.0)
	
	elif shitcoiner_score >= ROUNDS_TO_WIN:
		match_over = true
		if has_node("/root/RoundAnnouncer"):
			$"/root/RoundAnnouncer".announce_custom(
				"SHITCOINERS WIN!",
				"Final Score: ₿TC %d : %d FIAT\nFiat prevails... for now." % [bitcoiner_score, shitcoiner_score],
				Color(0.6, 0.2, 0.8), 8.0)
