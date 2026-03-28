extends Node

# Sats Popup — CS-style "+$300" floating text on kills
# Shows sats earned floating up from crosshair area

var popup_canvas: CanvasLayer
var last_popup_time: float = 0.0
var popup_cooldown: float = 1.0  # Max one popup per second
var max_visible: int = 2  # Max 2 popups on screen at once

func _ready():
	popup_canvas = CanvasLayer.new()
	popup_canvas.layer = 14
	add_child(popup_canvas)

func show_sats(amount: int, reason: String = ""):
	# Throttle popups
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_popup_time < popup_cooldown:
		return
	last_popup_time = now
	
	# Limit visible popups
	if popup_canvas.get_child_count() >= max_visible:
		var oldest = popup_canvas.get_child(0)
		if is_instance_valid(oldest):
			oldest.queue_free()
	
	var label = Label.new()
	var text = "+₿%s" % _format_sats(amount)
	if reason != "":
		text += " %s" % reason
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	
	# Color based on amount
	if amount >= 10000:
		label.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))  # Big reward = orange
	elif amount >= 3000:
		label.add_theme_color_override("font_color", Color(0, 1, 0))  # Good = green
	else:
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))  # Normal = white
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Position near center-right
	label.set_anchors_preset(Control.PRESET_CENTER)
	var y_offset = randf_range(-20, 20)
	label.offset_left = 50
	label.offset_right = 250
	label.offset_top = -30 + y_offset
	label.offset_bottom = 0 + y_offset
	
	popup_canvas.add_child(label)
	
	# Animate: float up + fade out
	var tween = get_tree().create_tween()
	tween.tween_property(label, "offset_top", label.offset_top - 60, 1.5)
	tween.parallel().tween_property(label, "offset_bottom", label.offset_bottom - 60, 1.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.tween_callback(label.queue_free)

func show_penalty(amount: int, reason: String = ""):
	var label = Label.new()
	label.text = "-₿%s %s" % [_format_sats(amount), reason]
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_left = 50
	label.offset_right = 250
	label.offset_top = -10
	label.offset_bottom = 20
	popup_canvas.add_child(label)
	
	var tween = get_tree().create_tween()
	tween.tween_property(label, "offset_top", label.offset_top - 40, 1.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.tween_callback(label.queue_free)

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
