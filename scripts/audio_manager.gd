extends Node

# Procedural audio for FPS
var audio_players: Dictionary = {}

func _ready():
	# Pre-create audio players
	for sound_name in ["shoot", "hit", "kill", "reload", "footstep", "hurt"]:
		var player = AudioStreamPlayer.new()
		player.name = sound_name
		player.bus = "Master"
		add_child(player)
		audio_players[sound_name] = player
	
	# Generate audio samples
	_generate_sounds()

func _generate_sounds():
	# Gunshot
	var shoot_stream = _make_noise(0.1, 4000, 0.8)
	audio_players["shoot"].stream = shoot_stream
	
	# Hit marker
	var hit_stream = _make_tone(0.08, 800, 0.3)
	audio_players["hit"].stream = hit_stream
	
	# Kill jingle
	var kill_stream = _make_tone(0.15, 523, 0.2)
	audio_players["kill"].stream = kill_stream
	
	# Reload click
	var reload_stream = _make_noise(0.05, 2000, 0.2)
	audio_players["reload"].stream = reload_stream
	
	# Footstep
	var foot_stream = _make_noise(0.04, 400, 0.15)
	audio_players["footstep"].stream = foot_stream
	
	# Hurt
	var hurt_stream = _make_noise(0.15, 800, 0.4)
	audio_players["hurt"].stream = hurt_stream

func _make_noise(duration: float, cutoff: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / samples
		var noise = randf_range(-1.0, 1.0) * (1.0 - t) * volume
		# Simple low-pass by averaging
		var val = int(clamp(noise * 32767, -32768, 32767))
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _make_tone(duration: float, freq: float, volume: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / samples
		var wave = sin(i * TAU * freq / sample_rate) * (1.0 - t) * volume
		var val = int(clamp(wave * 32767, -32768, 32767))
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func play(sound_name: String):
	if audio_players.has(sound_name):
		audio_players[sound_name].play()
