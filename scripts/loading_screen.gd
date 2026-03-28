extends CanvasLayer

# Loading Screen with Bitcoin facts while assets load
# Shows briefly on game start

var tips = [
	"There will only ever be 21 million Bitcoin.",
	"Satoshi Nakamoto mined the first block on January 3, 2009.",
	"The Genesis Block contains: 'The Times 03/Jan/2009 Chancellor on brink of second bailout for banks'",
	"Bitcoin's smallest unit is 1 satoshi = 0.00000001 BTC.",
	"The first Bitcoin transaction was 10,000 BTC for two pizzas.",
	"Bitcoin halving occurs every 210,000 blocks (~4 years).",
	"Lightning Network enables instant, near-free Bitcoin payments.",
	"Proof of Work secures the network — not proof of stake.",
	"'Not your keys, not your coins.' — Andreas Antonopoulos",
	"The Times 03/Jan/2009 Chancellor on brink of second bailout for banks",
	"Bitcoin fixes this.",
	"Stack sats. Stay humble.",
	"FYI: Running with knife is 16% faster.",
	"Crouching improves accuracy by ~50%.",
	"Tap-fire the AK for better accuracy at range.",
	"Headshots deal 2x damage.",
	"Buy a Hardware Wallet (₿400) for faster defuse.",
	"Flashbangs blind enemies AND you — don't look at them.",
	"The BCash Grenade does self-damage if you're too close.",
	"Backstab with the knife for an instant kill (180 damage).",
]

func _ready():
	layer = 50
	_show_loading()

func _show_loading():
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -300
	vbox.offset_right = 300
	vbox.offset_top = -100
	vbox.offset_bottom = 100
	vbox.add_theme_constant_override("separation", 20)
	add_child(vbox)
	
	# Bitcoin symbol spinning
	var btc = Label.new()
	btc.text = "₿"
	btc.add_theme_font_size_override("font_size", 64)
	btc.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1))
	btc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(btc)
	
	var title = Label.new()
	title.text = "BITSTRIKE"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var loading = Label.new()
	loading.text = "Loading..."
	loading.add_theme_font_size_override("font_size", 16)
	loading.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(loading)
	
	var tip = Label.new()
	tip.text = tips[randi() % tips.size()]
	tip.add_theme_font_size_override("font_size", 14)
	tip.add_theme_color_override("font_color", Color(0.97, 0.58, 0.1, 0.7))
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(tip)
	
	# Fade out after scene is ready
	get_tree().create_timer(1.5).timeout.connect(func():
		var tween = get_tree().create_tween()
		tween.tween_property(bg, "color:a", 0.0, 0.5)
		tween.parallel().tween_property(vbox, "modulate:a", 0.0, 0.5)
		tween.tween_callback(queue_free)
	)
