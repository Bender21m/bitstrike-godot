extends CanvasLayer

# Main Menu — shown on game load
# Play, Settings, Credits

var is_showing: bool = true

func _ready():
	layer = 30
	visible = true
	_build_ui()
	# Ensure mouse is free
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _build_ui():
	# Full background
	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.05, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	
	# Center container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -250
	vbox.offset_right = 250
	vbox.offset_top = -220
	vbox.offset_bottom = 220
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)
	
	# Bitcoin symbol
	var btc = Label.new()
	btc.text = "₿"
	btc.add_theme_font_size_override("font_size", 80)
	btc.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	btc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(btc)
	
	# Title
	var title = Label.new()
	title.text = "BITSTRIKE"
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Subtitle
	var sub = Label.new()
	sub.text = "Counter-Strike meets Bitcoin"
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	vbox.add_child(spacer)
	
	# Play button
	_add_menu_button(vbox, "PLAY — Mining Facility", Color(0.97, 0.58, 0.1), func():
		_start_game("facility")
	)
	
	_add_menu_button(vbox, "PLAY — Island Compound", Color(0.2, 0.6, 0.9), func():
		_start_game("island")
	)
	
	# Settings
	_add_menu_button(vbox, "SETTINGS", Color(0.4, 0.4, 0.4), func():
		if has_node("/root/SettingsMenu"):
			$"/root/SettingsMenu".open_menu()
	)
	
	# Version + credits
	var version = Label.new()
	version.text = "v0.2.0 — Made with Godot 4.3\nAK-74M model: Cransh (CC-BY-4.0)"
	version.add_theme_font_size_override("font_size", 12)
	version.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(version)

func _add_menu_button(parent: VBoxContainer, text: String, color: Color, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 22)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.15)
	style.border_color = color
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", color)
	var hover = style.duplicate()
	hover.bg_color = Color(color.r, color.g, color.b, 0.3)
	btn.add_theme_stylebox_override("hover", hover)
	btn.pressed.connect(callback)
	parent.add_child(btn)

func _start_game(map_name: String):
	is_showing = false
	visible = false
	
	# Notify map system which map to use
	# For now, facility is the default scene — island is the second map script
	if map_name == "island":
		# Swap map builder script
		var map_builder = get_tree().root.find_child("MapBuilder", true, false)
		if map_builder:
			var island_script = load("res://scripts/map_island.gd")
			if island_script:
				# Remove old map props (keep walls from scene)
				for child in map_builder.get_parent().get_children():
					if child.name.begins_with("ServerRack") or child.name.begins_with("Crate") or child.name.begins_with("Barrel") or child.name == "BitcoinPickup":
						child.queue_free()
				map_builder.set_script(island_script)
				map_builder._ready()
	
	# Hide menu, capture mouse on first click
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
