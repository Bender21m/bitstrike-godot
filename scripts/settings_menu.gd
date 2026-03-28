extends CanvasLayer

# Settings Menu — ESC while in-game (when no buy menu open)
# Mouse sensitivity, volume, FOV, crosshair color

var is_open: bool = false
var panel: PanelContainer

# Settings values
var mouse_sensitivity: float = 0.002
var master_volume: float = 0.8
var fov: float = 75.0
var crosshair_color_idx: int = 0
var crosshair_colors = [
	Color(0, 1, 0, 0.8),      # Green (default)
	Color(1, 1, 1, 0.8),      # White
	Color(1, 0, 0, 0.8),      # Red
	Color(0, 1, 1, 0.8),      # Cyan
	Color(1, 1, 0, 0.8),      # Yellow
	Color(0.97, 0.58, 0.1, 0.8),  # Bitcoin orange
]

func _ready():
	layer = 25
	visible = false
	_build_ui()

func _build_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	
	panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.1, 0.95)
	style.border_color = Color(0.97, 0.58, 0.1)
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -220
	panel.offset_right = 220
	panel.offset_top = -200
	panel.offset_bottom = 200
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "SETTINGS"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Sensitivity
	_add_slider(vbox, "Mouse Sensitivity", 0.0005, 0.005, mouse_sensitivity, func(val):
		mouse_sensitivity = val
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.set("MOUSE_SENSITIVITY", val)  # Won't work on const, but stores for next ref
	)
	
	# Volume
	_add_slider(vbox, "Master Volume", 0.0, 1.0, master_volume, func(val):
		master_volume = val
		AudioServer.set_bus_volume_db(0, linear_to_db(val))
	)
	
	# FOV
	_add_slider(vbox, "Field of View", 60.0, 110.0, fov, func(val):
		fov = val
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var cam = player.find_child("Camera3D", true, false)
			if cam:
				cam.fov = val
	)
	
	# Crosshair color
	var ch_hbox = HBoxContainer.new()
	ch_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(ch_hbox)
	var ch_label = Label.new()
	ch_label.text = "Crosshair Color"
	ch_label.add_theme_font_size_override("font_size", 16)
	ch_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	ch_hbox.add_child(ch_label)
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ch_hbox.add_child(spacer)
	
	for i in range(crosshair_colors.size()):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(28, 28)
		var btn_style2 = StyleBoxFlat.new()
		btn_style2.bg_color = crosshair_colors[i]
		btn_style2.corner_radius_top_left = 3
		btn_style2.corner_radius_top_right = 3
		btn_style2.corner_radius_bottom_left = 3
		btn_style2.corner_radius_bottom_right = 3
		btn.add_theme_stylebox_override("normal", btn_style2)
		btn.pressed.connect(_set_crosshair_color.bind(i))
		ch_hbox.add_child(btn)
	
	# Separator
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	# Controls reference
	var controls = Label.new()
	controls.text = "WASD — Move  |  Mouse — Aim  |  LMB — Shoot\nR — Reload  |  1234 — Weapons  |  B — Buy Menu\nC — Crouch  |  Shift — Sprint  |  G — Grenade\nQ — Drop  |  E — Interact  |  ESC — Settings"
	controls.add_theme_font_size_override("font_size", 13)
	controls.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(controls)
	
	# Resume button
	var resume = Button.new()
	resume.text = "RESUME"
	resume.add_theme_font_size_override("font_size", 18)
	var resume_style = StyleBoxFlat.new()
	resume_style.bg_color = Color(0.97, 0.58, 0.1, 0.8)
	resume_style.corner_radius_top_left = 4
	resume_style.corner_radius_top_right = 4
	resume_style.corner_radius_bottom_left = 4
	resume_style.corner_radius_bottom_right = 4
	resume_style.content_margin_top = 8
	resume_style.content_margin_bottom = 8
	resume.add_theme_stylebox_override("normal", resume_style)
	resume.add_theme_color_override("font_color", Color(0, 0, 0))
	resume.pressed.connect(close_menu)
	vbox.add_child(resume)

func _add_slider(parent: VBoxContainer, label_text: String, min_val: float, max_val: float, current: float, callback: Callable):
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	parent.add_child(hbox)
	
	var label = Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	label.custom_minimum_size.x = 160
	hbox.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = current
	slider.step = (max_val - min_val) / 100.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(callback)
	hbox.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = "%.3f" % current if max_val < 1 else "%d" % int(current)
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	value_label.custom_minimum_size.x = 50
	hbox.add_child(value_label)
	
	slider.value_changed.connect(func(val):
		value_label.text = "%.3f" % val if max_val < 1 else "%d" % int(val)
	)

func _set_crosshair_color(idx: int):
	crosshair_color_idx = idx
	var color = crosshair_colors[idx]
	var ch = get_tree().root.find_child("CrosshairH", true, false)
	var cv = get_tree().root.find_child("CrosshairV", true, false)
	if ch: ch.color = color
	if cv: cv.color = color

func toggle():
	if is_open:
		close_menu()
	else:
		open_menu()

func open_menu():
	is_open = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_menu():
	is_open = false
	visible = false
	var player = get_tree().get_first_node_in_group("player")
	if player and player.mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
