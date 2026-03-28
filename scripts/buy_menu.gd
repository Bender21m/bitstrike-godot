extends CanvasLayer

# Buy menu — CS-style. Press B to toggle, click items to buy.
# Closes automatically when round starts.

signal item_purchased(item_type: String, item_data: Dictionary)

var is_open: bool = false
var player: Node3D

# Buy menu items with categories
var categories = {
	"RIFLES": [
		{"name": "AK-B7", "price": 2700, "type": "weapon", "weapon_idx": 1,
		 "desc": "Full-auto rifle. 30 rounds. 25 dmg.", "icon": "🔫"},
		{"name": "M4-SAT", "price": 3100, "type": "weapon", "weapon_idx": 4,
		 "desc": "Full-auto carbine. 25 rounds. 28 dmg. Low recoil.", "icon": "🔫"},
		{"name": "SABOT", "price": 4750, "type": "weapon", "weapon_idx": 3,
		 "desc": "Sniper. 5 rounds. 120 dmg.", "icon": "🎯"},
	],
	"PISTOLS": [
		{"name": "BEAGLE", "price": 700, "type": "weapon", "weapon_idx": 2,
		 "desc": "Pistol. 7 rounds. 55 dmg.", "icon": "🔫"},
	],
	"GEAR": [
		{"name": "Kevlar Vest", "price": 650, "type": "armor", "armor_amount": 50,
		 "desc": "Absorbs 50% damage.", "icon": "🛡️"},
		{"name": "Kevlar + Helmet", "price": 1000, "type": "armor_full", "armor_amount": 100,
		 "desc": "Full armor + headshot protection.", "icon": "⛑️"},
	],
	"AMMO": [
		{"name": "Ammo Refill", "price": 500, "type": "ammo",
		 "desc": "Refill current weapon reserve.", "icon": "🎯"},
		{"name": "Full Ammo Pack", "price": 1200, "type": "ammo_all",
		 "desc": "Refill ALL weapon reserves.", "icon": "📦"},
	],
	"GRENADES": [
		{"name": "Flashbang", "price": 200, "type": "grenade", "grenade_type": 0,
		 "desc": "Blinds enemies (and you if you look). CS classic.", "icon": "💥"},
		{"name": "BCash Grenade", "price": 300, "type": "grenade", "grenade_type": 1,
		 "desc": "Explosive. 80 dmg at center. Roger's revenge.", "icon": "💣"},
		{"name": "Smoke Grenade", "price": 300, "type": "grenade", "grenade_type": 2,
		 "desc": "Visual cover for 15 seconds.", "icon": "💨"},
	],
	"UTILITY": [
		{"name": "Health Kit", "price": 800, "type": "health", "heal_amount": 50,
		 "desc": "Restore 50 HP.", "icon": "💊"},
		{"name": "Hardware Wallet", "price": 400, "type": "defuse_kit",
		 "desc": "Defuse 51% attacks in 2.5s instead of 5s.", "icon": "🔑"},
	],
}

# UI references
var panel: PanelContainer
var category_buttons: Dictionary = {}
var item_container: VBoxContainer
var sats_label: Label
var timer_label: Label
var title_label: Label
var active_category: String = "RIFLES"
var item_buttons: Array = []

func _ready():
	layer = 10
	visible = false
	_build_ui()

func _build_ui():
	# Dark semi-transparent background
	var bg = ColorRect.new()
	bg.name = "BuyBG"
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)
	
	# Main panel - centered
	panel = PanelContainer.new()
	panel.name = "BuyPanel"
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
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -340
	panel.offset_right = 340
	panel.offset_top = -260
	panel.offset_bottom = 260
	add_child(panel)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	panel.add_child(main_vbox)
	
	# Title bar
	var title_bar = HBoxContainer.new()
	title_bar.add_theme_constant_override("separation", 12)
	main_vbox.add_child(title_bar)
	
	title_label = Label.new()
	title_label.text = "₿UY MENU"
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	title_bar.add_child(title_label)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(spacer)
	
	sats_label = Label.new()
	sats_label.add_theme_font_size_override("font_size", 24)
	sats_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	title_bar.add_child(sats_label)
	
	timer_label = Label.new()
	timer_label.add_theme_font_size_override("font_size", 20)
	timer_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	title_bar.add_child(timer_label)
	
	# Separator
	var sep = HSeparator.new()
	sep.add_theme_constant_override("separation", 4)
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = Color(0.97, 0.58, 0.1, 0.5)
	sep.add_theme_stylebox_override("separator", sep_style)
	main_vbox.add_child(sep)
	
	# Content area: categories on left, items on right
	var content = HBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content)
	
	# Category sidebar
	var cat_vbox = VBoxContainer.new()
	cat_vbox.add_theme_constant_override("separation", 4)
	cat_vbox.custom_minimum_size.x = 160
	content.add_child(cat_vbox)
	
	var cat_label = Label.new()
	cat_label.text = "CATEGORY"
	cat_label.add_theme_font_size_override("font_size", 14)
	cat_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	cat_vbox.add_child(cat_label)
	
	for cat_name in categories.keys():
		var btn = Button.new()
		btn.text = cat_name
		btn.add_theme_font_size_override("font_size", 16)
		var btn_normal = StyleBoxFlat.new()
		btn_normal.bg_color = Color(0.15, 0.15, 0.18)
		btn_normal.corner_radius_top_left = 3
		btn_normal.corner_radius_top_right = 3
		btn_normal.corner_radius_bottom_left = 3
		btn_normal.corner_radius_bottom_right = 3
		btn_normal.content_margin_left = 8
		btn_normal.content_margin_right = 8
		btn_normal.content_margin_top = 6
		btn_normal.content_margin_bottom = 6
		btn.add_theme_stylebox_override("normal", btn_normal)
		var btn_hover = btn_normal.duplicate()
		btn_hover.bg_color = Color(0.25, 0.25, 0.3)
		btn.add_theme_stylebox_override("hover", btn_hover)
		var btn_pressed = btn_normal.duplicate()
		btn_pressed.bg_color = Color(0.97, 0.58, 0.1, 0.3)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.pressed.connect(_on_category_pressed.bind(cat_name))
		cat_vbox.add_child(btn)
		category_buttons[cat_name] = btn
	
	# Vertical separator
	var vsep = VSeparator.new()
	var vsep_style = StyleBoxFlat.new()
	vsep_style.bg_color = Color(0.3, 0.3, 0.35, 0.5)
	vsep.add_theme_stylebox_override("separator", vsep_style)
	content.add_child(vsep)
	
	# Items area
	var items_scroll = ScrollContainer.new()
	items_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(items_scroll)
	
	item_container = VBoxContainer.new()
	item_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_container.add_theme_constant_override("separation", 6)
	items_scroll.add_child(item_container)
	
	# Footer hint
	var footer = Label.new()
	footer.text = "[B] Close    |    Click to buy"
	footer.add_theme_font_size_override("font_size", 14)
	footer.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(footer)

func _on_category_pressed(cat_name: String):
	active_category = cat_name
	_refresh_items()
	_update_category_highlight()

func _update_category_highlight():
	for cat_name in category_buttons:
		var btn = category_buttons[cat_name]
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 3
		style.corner_radius_top_right = 3
		style.corner_radius_bottom_left = 3
		style.corner_radius_bottom_right = 3
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		if cat_name == active_category:
			style.bg_color = Color(0.97, 0.58, 0.1, 0.3)
			style.border_color = Color(0.97, 0.58, 0.1)
			style.border_width_left = 3
			btn.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
		else:
			style.bg_color = Color(0.15, 0.15, 0.18)
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_stylebox_override("normal", style)

func _refresh_items():
	# Clear existing
	for child in item_container.get_children():
		child.queue_free()
	item_buttons.clear()
	
	if not categories.has(active_category):
		return
	
	var items = categories[active_category]
	for item in items:
		var row = _create_item_row(item)
		item_container.add_child(row)

func _create_item_row(item: Dictionary) -> PanelContainer:
	var row_panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.15)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	row_panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	row_panel.add_child(hbox)
	
	# Icon
	var icon = Label.new()
	icon.text = item.get("icon", "•")
	icon.add_theme_font_size_override("font_size", 24)
	icon.custom_minimum_size.x = 36
	hbox.add_child(icon)
	
	# Name + desc
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)
	
	var name_label = Label.new()
	name_label.text = item.name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	info_vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = item.get("desc", "")
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	info_vbox.add_child(desc_label)
	
	# Price + buy button
	var buy_btn = Button.new()
	var can_afford = player and player.sats >= item.price
	buy_btn.text = "₿ %s" % _format_sats(item.price)
	buy_btn.add_theme_font_size_override("font_size", 16)
	buy_btn.custom_minimum_size.x = 120
	
	var btn_style = StyleBoxFlat.new()
	btn_style.corner_radius_top_left = 3
	btn_style.corner_radius_top_right = 3
	btn_style.corner_radius_bottom_left = 3
	btn_style.corner_radius_bottom_right = 3
	btn_style.content_margin_left = 8
	btn_style.content_margin_right = 8
	btn_style.content_margin_top = 6
	btn_style.content_margin_bottom = 6
	
	if can_afford:
		btn_style.bg_color = Color(0.1, 0.4, 0.1)
		buy_btn.add_theme_color_override("font_color", Color(0, 1, 0))
		var hover_style = btn_style.duplicate()
		hover_style.bg_color = Color(0.15, 0.55, 0.15)
		buy_btn.add_theme_stylebox_override("hover", hover_style)
	else:
		btn_style.bg_color = Color(0.3, 0.1, 0.1)
		buy_btn.add_theme_color_override("font_color", Color(0.6, 0.3, 0.3))
		buy_btn.disabled = true
	
	buy_btn.add_theme_stylebox_override("normal", btn_style)
	buy_btn.pressed.connect(_on_buy_pressed.bind(item))
	hbox.add_child(buy_btn)
	item_buttons.append(buy_btn)
	
	return row_panel

func _on_buy_pressed(item: Dictionary):
	if not player:
		return
	if player.sats < item.price:
		return
	
	# Deduct sats
	player.sats -= item.price
	
	match item.type:
		"weapon":
			# Refill ammo for that weapon
			var idx = item.weapon_idx
			player.weapons[idx].ammo = player.weapons[idx].max_ammo
			player.weapons[idx].reserve = _get_max_reserve(idx)
			player.switch_weapon(idx)
		"armor":
			player.armor = max(player.armor, item.armor_amount)
		"armor_full":
			player.armor = item.armor_amount
		"ammo":
			var w = player.weapons[player.current_weapon]
			w.reserve = _get_max_reserve(player.current_weapon)
		"ammo_all":
			for i in range(player.weapons.size()):
				player.weapons[i].reserve = _get_max_reserve(i)
		"health":
			player.health = min(100, player.health + item.heal_amount)
		"grenade":
			if has_node("/root/Grenades"):
				$"/root/Grenades".add_grenade(item.grenade_type)
		"defuse_kit":
			player.set_meta("has_defuse_kit", true)
	
	# Play buy sound
	if has_node("/root/AudioManager"):
		$"/root/AudioManager".play("buy")
	
	# Show purchase feedback
	_show_purchase_feedback(item.name)
	
	emit_signal("item_purchased", item.type, item)
	
	# Refresh to update afford states
	_refresh_items()
	_update_sats_display()

func _get_max_reserve(weapon_idx: int) -> int:
	match weapon_idx:
		0: return 0    # KNIFE (no ammo)
		1: return 90   # AK-B7
		2: return 35   # BEAGLE
		3: return 20   # SABOT
		4: return 75   # M4-SAT
	return 90

func _show_purchase_feedback(item_name: String):
	# Flash the title briefly
	var original_text = title_label.text
	title_label.text = "✓ BOUGHT: %s" % item_name
	title_label.add_theme_color_override("font_color", Color(0, 1, 0))
	get_tree().create_timer(1.0).timeout.connect(func():
		if is_instance_valid(title_label):
			title_label.text = "₿UY MENU"
			title_label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	)

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

func _update_sats_display():
	if player:
		sats_label.text = "₿ %s" % _format_sats(player.sats)

func open_menu():
	if is_open:
		return
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	is_open = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	active_category = "RIFLES"
	_update_sats_display()
	_update_category_highlight()
	_refresh_items()

func close_menu():
	if not is_open:
		return
	is_open = false
	visible = false
	if player and player.mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func toggle_menu():
	if is_open:
		close_menu()
	else:
		open_menu()

func _process(_delta):
	if not is_open:
		return
	_update_sats_display()
	
	# Update buy timer from GameState
	if has_node("/root/GameState"):
		var gs = $"/root/GameState"
		if gs.buy_phase:
			timer_label.text = "  ⏱ %ds" % int(ceil(gs.buy_timer))
		else:
			timer_label.text = ""
