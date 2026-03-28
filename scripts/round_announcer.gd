extends CanvasLayer

# Round Announcer — big center-screen text for round starts, buy phase, etc.

var announcement_label: Label
var sub_label: Label
var anim_timer: float = 0.0
var is_showing: bool = false
var show_duration: float = 3.0

func _ready():
	layer = 12
	
	announcement_label = Label.new()
	announcement_label.name = "RoundAnnouncement"
	announcement_label.set_anchors_preset(Control.PRESET_CENTER)
	announcement_label.offset_left = -300
	announcement_label.offset_right = 300
	announcement_label.offset_top = -60
	announcement_label.offset_bottom = 0
	announcement_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	announcement_label.add_theme_font_size_override("font_size", 48)
	announcement_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	announcement_label.visible = false
	add_child(announcement_label)
	
	sub_label = Label.new()
	sub_label.name = "RoundSubtext"
	sub_label.set_anchors_preset(Control.PRESET_CENTER)
	sub_label.offset_left = -300
	sub_label.offset_right = 300
	sub_label.offset_top = 10
	sub_label.offset_bottom = 50
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.add_theme_font_size_override("font_size", 20)
	sub_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	sub_label.visible = false
	add_child(sub_label)

func announce_round(round_num: int, round_name: String):
	announcement_label.text = "ROUND %d" % round_num
	sub_label.text = round_name
	_show(3.0)

func announce_buy_phase(seconds: int):
	announcement_label.text = "BUY PHASE"
	sub_label.text = "Press B to open shop — %ds" % seconds
	announcement_label.add_theme_color_override("font_color", Color(0, 0.8, 0.3))
	_show(2.5)

func announce_custom(text: String, subtext: String = "", color: Color = Color(0.97, 0.58, 0.1), duration: float = 3.0):
	announcement_label.text = text
	sub_label.text = subtext
	announcement_label.add_theme_color_override("font_color", color)
	_show(duration)

func _show(duration: float):
	is_showing = true
	show_duration = duration
	anim_timer = 0.0
	announcement_label.visible = true
	sub_label.visible = true
	# Reset color if not custom
	if announcement_label.get_theme_color("font_color") != Color(0, 0.8, 0.3):
		announcement_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))

func _process(delta):
	if not is_showing:
		return
	
	anim_timer += delta
	
	# Scale in effect
	if anim_timer < 0.3:
		var t = anim_timer / 0.3
		var size = int(lerp(72, 48, t))
		announcement_label.add_theme_font_size_override("font_size", size)
	
	# Fade out near end
	if anim_timer > show_duration - 0.5:
		var fade = (show_duration - anim_timer) / 0.5
		var c = announcement_label.get_theme_color("font_color")
		c.a = fade
		announcement_label.add_theme_color_override("font_color", c)
		var sc = sub_label.get_theme_color("font_color")
		sc.a = fade
		sub_label.add_theme_color_override("font_color", sc)
	
	if anim_timer >= show_duration:
		is_showing = false
		announcement_label.visible = false
		sub_label.visible = false
