extends Node

# Ambient Audio — environmental sounds that make the world feel alive
# Procedurally generated like all other audio

var players: Dictionary = {}
var sample_rate: int = 22050  # Lower for ambient (saves memory)

func _ready():
	_create_ambient_sounds()
	# Start ambient loop after short delay
	get_tree().create_timer(2.0).timeout.connect(_start_ambience)

func _create_ambient_sounds():
	# Server room hum (constant low drone)
	var hum = AudioStreamPlayer.new()
	hum.name = "server_hum"
	hum.stream = _make_hum()
	hum.volume_db = -18
	hum.bus = "Master"
	add_child(hum)
	players["hum"] = hum
	
	# Electrical buzz (intermittent)
	var buzz = AudioStreamPlayer.new()
	buzz.name = "elec_buzz"
	buzz.stream = _make_buzz()
	buzz.volume_db = -22
	buzz.bus = "Master"
	add_child(buzz)
	players["buzz"] = buzz
	
	# Ventilation / air flow
	var vent = AudioStreamPlayer.new()
	vent.name = "vent"
	vent.stream = _make_vent()
	vent.volume_db = -20
	vent.bus = "Master"
	add_child(vent)
	players["vent"] = vent
	
	# Distant radio chatter (occasional)
	var radio = AudioStreamPlayer.new()
	radio.name = "radio"
	radio.stream = _make_radio_chatter()
	radio.volume_db = -24
	radio.bus = "Master"
	add_child(radio)
	players["radio"] = radio

func _start_ambience():
	# Loop the constant sounds
	if players.has("hum"):
		players["hum"].play()
	if players.has("vent"):
		players["vent"].play()
	# Intermittent sounds on timer
	_schedule_intermittent()

func _schedule_intermittent():
	# Buzz every 8-15 seconds
	get_tree().create_timer(randf_range(8.0, 15.0)).timeout.connect(func():
		if players.has("buzz") and not players["buzz"].playing:
			players["buzz"].play()
		_schedule_intermittent()
	)
	# Radio chatter every 20-40 seconds
	get_tree().create_timer(randf_range(20.0, 40.0)).timeout.connect(func():
		if players.has("radio") and not players["radio"].playing:
			players["radio"].play()
	)

# === SOUND GENERATORS ===

func _make_hum() -> AudioStreamWAV:
	# Low 60Hz electrical hum + harmonics, loopable
	var duration = 2.0
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / sample_rate
		var sample = sin(t * TAU * 60) * 0.3
		sample += sin(t * TAU * 120) * 0.15
		sample += sin(t * TAU * 180) * 0.05
		# Slight wobble
		sample += sin(t * TAU * 59.5 + sin(t * 0.5) * 0.1) * 0.1
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	stream.data = data
	return stream

func _make_buzz() -> AudioStreamWAV:
	# Short electrical buzz/crackle
	var duration = 0.3
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / sample_rate
		var env = sin(t / duration * PI) * 0.4
		var sample = randf_range(-1, 1) * env * 0.3
		sample += sin(t * TAU * 2000) * env * 0.2
		sample += sin(t * TAU * 4000) * env * 0.1
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _make_vent() -> AudioStreamWAV:
	# White noise (filtered) — air flowing through vents
	var duration = 3.0
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	var prev = 0.0
	for i in range(samples):
		var noise = randf_range(-1, 1) * 0.15
		# Simple low-pass filter
		var sample = prev * 0.95 + noise * 0.05
		prev = sample
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	stream.data = data
	return stream

func _make_radio_chatter() -> AudioStreamWAV:
	# Garbled radio — short tones simulating voice
	var duration = 1.5
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	for i in range(samples):
		var t = float(i) / sample_rate
		var env = sin(t / duration * PI) * 0.3
		# Voice-like: formant frequencies with modulation
		var f1 = 300 + sin(t * 5) * 100
		var f2 = 800 + sin(t * 3) * 200
		var sample = sin(t * TAU * f1) * env * 0.2
		sample += sin(t * TAU * f2) * env * 0.15
		# Add crackle
		if randf() < 0.05:
			sample += randf_range(-0.3, 0.3) * env
		# Radio filter (harsh)
		sample = clamp(sample * 3, -0.3, 0.3)
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream
