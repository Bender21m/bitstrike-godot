extends CanvasLayer

# Main Menu — shown on game load
# Map selection, Settings, Credits

var is_showing: bool = true

func _ready():
	layer = 30
	visible = true
	_build_ui()
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
	vbox.offset_left = -280
	vbox.offset_right = 280
	vbox.offset_top = -280
	vbox.offset_bottom = 280
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)
	
	# Bitcoin symbol
	var btc = Label.new()
	btc.text = "₿"
	btc.add_theme_font_size_override("font_size", 72)
	btc.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	btc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(btc)
	
	# Title
	var title = Label.new()
	title.text = "BITSTRIKE"
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Subtitle
	var sub = Label.new()
	sub.text = "Counter-Strike meets Bitcoin"
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 12
	vbox.add_child(spacer)
	
	# Map selection header
	var map_header = Label.new()
	map_header.text = "SELECT MAP"
	map_header.add_theme_font_size_override("font_size", 14)
	map_header.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	map_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(map_header)
	
	# Map buttons from MapManager
	if has_node("/root/MapManager"):
		var mm = $"/root/MapManager"
		for i in range(mm.maps.size()):
			var map_data = mm.maps[i]
			var map_colors = [
				Color(0.97, 0.58, 0.1),  # Mining Facility — orange
				Color(0.85, 0.7, 0.4),   # Silk Road — sand
				Color(0.4, 0.5, 0.9),    # Citadel — blue night
				Color(0.2, 0.7, 0.5),    # Offshore — tropical green
				Color(0.85, 0.65, 0.13), # The Vault — gold
			]
			var color = map_colors[i] if i < map_colors.size() else Color(0.6, 0.6, 0.6)
			var btn_text = "%s  %s" % [map_data.icon, map_data.name]
			_add_map_button(vbox, btn_text, map_data.description, color, i)
	else:
		# Fallback
		_add_menu_button(vbox, "PLAY", Color(0.97, 0.58, 0.1), func(): _start_game(0))
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 4
	vbox.add_child(spacer2)
	
	# Settings
	_add_menu_button(vbox, "⚙️  SETTINGS", Color(0.4, 0.4, 0.4), func():
		if has_node("/root/SettingsMenu"):
			$"/root/SettingsMenu".open_menu()
	)
	
	# Version + credits
	var version = Label.new()
	version.text = "v0.3.0 — Made with Godot 4.3\nAK-74M model: Cransh (CC-BY-4.0)"
	version.add_theme_font_size_override("font_size", 11)
	version.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(version)

func _add_map_button(parent: VBoxContainer, text: String, desc: String, color: Color, map_index: int):
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 2)
	
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 20)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.1)
	style.border_color = color
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 2
	style.border_width_right = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_top = 10
	style.content_margin_bottom = 4
	style.content_margin_left = 16
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", color)
	var hover = style.duplicate()
	hover.bg_color = Color(color.r, color.g, color.b, 0.25)
	btn.add_theme_stylebox_override("hover", hover)
	btn.pressed.connect(func(): _start_game(map_index))
	container.add_child(btn)
	
	# Description below button
	var desc_label = Label.new()
	desc_label.text = "    " + desc
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	container.add_child(desc_label)
	
	parent.add_child(container)

func _add_menu_button(parent: VBoxContainer, text: String, color: Color, callback: Callable):
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 18)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, 0.1)
	style.border_color = Color(color.r, color.g, color.b, 0.4)
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", color)
	var hover = style.duplicate()
	hover.bg_color = Color(color.r, color.g, color.b, 0.2)
	btn.add_theme_stylebox_override("hover", hover)
	btn.pressed.connect(callback)
	parent.add_child(btn)

func _start_game(map_index: int):
	is_showing = false
	visible = false
	
	# Set selected map
	if has_node("/root/MapManager"):
		$"/root/MapManager".set_map(map_index)
		var map_data = $"/root/MapManager".get_current_map()
		
		# Load the selected map
		var map_builder = get_tree().root.find_child("MapBuilder", true, false)
		if map_builder and map_index > 0:
			# Replace default map with selected
			# Clear existing map geometry
			for child in map_builder.get_children():
				child.queue_free()
			
			var script = load(map_data.script)
			if script:
				map_builder.set_script(script)
				# Re-run _ready to build the map
				map_builder._ready()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
