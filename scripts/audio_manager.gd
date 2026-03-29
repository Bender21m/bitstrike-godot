extends Node

# Procedural audio for FPS — v2, actually sounds decent now
var audio_players: Dictionary = {}
var sample_rate: int = 44100

func _ready():
	# Pre-create audio players with polyphony for overlapping sounds
	for sound_name in ["shoot", "shoot_pistol", "shoot_sniper", "hit", "kill", "reload",
						"footstep", "hurt", "headshot", "round_start", "buy"]:
		var player = AudioStreamPlayer.new()
		player.name = sound_name
		player.bus = "Master"
		add_child(player)
		audio_players[sound_name] = player
	
	_generate_sounds()

func _generate_sounds():
	# --- GUNSHOT (rifle) — punchy layered: transient + body + tail ---
	audio_players["shoot"].stream = _make_gunshot_rifle()
	audio_players["shoot"].volume_db = -3
	
	# --- GUNSHOT (pistol) — snappier, shorter ---
	audio_players["shoot_pistol"].stream = _make_gunshot_pistol()
	audio_players["shoot_pistol"].volume_db = -2
	
	# --- GUNSHOT (sniper) — big boom, longer tail ---
	audio_players["shoot_sniper"].stream = _make_gunshot_sniper()
	audio_players["shoot_sniper"].volume_db = -1
	
	# --- HIT MARKER — sharp metallic tick ---
	audio_players["hit"].stream = _make_hit_marker()
	audio_players["hit"].volume_db = -6
	
	# --- KILL CONFIRM — satisfying double ding ---
	audio_players["kill"].stream = _make_kill_confirm()
	audio_players["kill"].volume_db = -4
	
	# --- HEADSHOT — crunchy impact ---
	audio_players["headshot"].stream = _make_headshot()
	audio_players["headshot"].volume_db = -3
	
	# --- RELOAD — mechanical click-clack ---
	audio_players["reload"].stream = _make_reload()
	audio_players["reload"].volume_db = -5
	
	# --- FOOTSTEP — soft thud ---
	audio_players["footstep"].stream = _make_footstep()
	audio_players["footstep"].volume_db = -12
	
	# --- HURT — thump + grunt ---
	audio_players["hurt"].stream = _make_hurt()
	audio_players["hurt"].volume_db = -4
	
	# --- ROUND START — dramatic horn ---
	audio_players["round_start"].stream = _make_round_start()
	audio_players["round_start"].volume_db = -6
	
	# --- BUY — cash register cha-ching ---
	audio_players["buy"].stream = _make_buy_sound()
	audio_players["buy"].volume_db = -5

# ============================================================
# GUNSHOT — RIFLE (AK / M4)
# Layered: sharp transient + low body + filtered noise tail
# ============================================================
func _make_gunshot_rifle() -> AudioStreamWAV:
	var duration = 0.35
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# Layer 1: CRACK — sharp initial transient (first 2ms)
		var crack = 0.0
		if t < 0.002:
			crack = randf_range(-1.0, 1.0) * (1.0 - t / 0.002)
		
		# Layer 2: BANG — main body, low freq punch
		var bang_env = exp(-t * 25.0)
		var bang = sin(t * TAU * 65) * bang_env * 0.7
		bang += sin(t * TAU * 130) * bang_env * 0.4
		bang += sin(t * TAU * 95) * bang_env * 0.3
		
		# Layer 3: SNAP — mid frequency bite (what makes it sound "sharp")
		var snap_env = exp(-t * 60.0)
		var snap = sin(t * TAU * 1200 + sin(t * TAU * 300) * 3.0) * snap_env * 0.35
		snap += sin(t * TAU * 2400) * snap_env * 0.15
		
		# Layer 4: MECHANICAL — bolt/action sound (metallic ring)
		var mech = 0.0
		if t > 0.01 and t < 0.08:
			var mt = t - 0.01
			mech = sin(mt * TAU * 3500) * exp(-mt * 50.0) * 0.12
			mech += sin(mt * TAU * 5000) * exp(-mt * 70.0) * 0.08
		
		# Layer 5: TAIL — room reverb / echo
		var tail_env = exp(-t * 8.0) * 0.2
		var tail = randf_range(-1.0, 1.0) * tail_env
		# Simple echo at ~100ms
		if t > 0.1:
			tail += sin((t - 0.1) * TAU * 70) * exp(-(t - 0.1) * 12.0) * 0.1
		
		var sample = clamp(crack + bang + snap + mech + tail, -1.0, 1.0)
		var val = int(sample * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# GUNSHOT — PISTOL (snappier, higher freq)
# ============================================================
func _make_gunshot_pistol() -> AudioStreamWAV:
	var duration = 0.2
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# Sharp initial crack
		var crack = 0.0
		if t < 0.0015:
			crack = randf_range(-1.0, 1.0) * (1.0 - t / 0.0015)
		
		# Punchy mid-body (pistol = higher freq than rifle)
		var body_env = exp(-t * 40.0)
		var body = sin(t * TAU * 180) * body_env * 0.6
		body += sin(t * TAU * 360) * body_env * 0.3
		
		# Snappy high-end
		var snap_env = exp(-t * 80.0)
		var snap = sin(t * TAU * 1800) * snap_env * 0.3
		snap += sin(t * TAU * 3200) * snap_env * 0.15
		
		# Slide racking (metallic)
		var slide = 0.0
		if t > 0.02 and t < 0.06:
			var st = t - 0.02
			slide = sin(st * TAU * 4500) * exp(-st * 60.0) * 0.1
		
		# Short reverb
		var tail = randf_range(-1.0, 1.0) * exp(-t * 20.0) * 0.1
		
		var sample = clamp(crack + body + snap + slide + tail, -1.0, 1.0)
		var val = int(sample * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# GUNSHOT — SNIPER (big boom, long reverb tail)
# ============================================================
func _make_gunshot_sniper() -> AudioStreamWAV:
	var duration = 0.6
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# Massive transient crack
		var crack = 0.0
		if t < 0.003:
			crack = randf_range(-1.0, 1.0) * (1.0 - t / 0.003)
		
		# Deep thunderous body
		var body_env = exp(-t * 10.0)
		var body = sin(t * TAU * 45) * body_env * 0.8
		body += sin(t * TAU * 90) * body_env * 0.5
		body += sin(t * TAU * 135) * body_env * 0.25
		
		# Supersonic snap (the distinctive "crack" of high-velocity round)
		var snap_env = exp(-t * 40.0)
		var snap = sin(t * TAU * 800 + sin(t * TAU * 200) * 4.0) * snap_env * 0.4
		snap += sin(t * TAU * 1600) * snap_env * 0.2
		
		# Bolt action mechanical sound
		var bolt = 0.0
		if t > 0.05 and t < 0.12:
			var bt = t - 0.05
			bolt = sin(bt * TAU * 3000) * exp(-bt * 40.0) * 0.15
			bolt += sin(bt * TAU * 6000) * exp(-bt * 60.0) * 0.08
		
		# Long echo / room reverb (sniper rifles echo for ages)
		var echo1 = 0.0
		if t > 0.12:
			echo1 = sin((t - 0.12) * TAU * 50) * exp(-(t - 0.12) * 8.0) * 0.15
		var echo2 = 0.0
		if t > 0.25:
			echo2 = sin((t - 0.25) * TAU * 45) * exp(-(t - 0.25) * 6.0) * 0.1
		
		# Noise tail
		var tail = randf_range(-1.0, 1.0) * exp(-t * 5.0) * 0.12
		
		var sample = clamp(crack + body + snap + bolt + echo1 + echo2 + tail, -1.0, 1.0)
		var val = int(sample * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# HIT MARKER — sharp metallic tick
# ============================================================
func _make_hit_marker() -> AudioStreamWAV:
	var duration = 0.06
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		var env = exp(-t * 80.0)
		# Two metallic tones
		var sample = sin(t * TAU * 3200) * env * 0.5
		sample += sin(t * TAU * 4800) * env * 0.3
		sample += sin(t * TAU * 6400) * env * 0.15
		
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# KILL CONFIRM — satisfying double ding
# ============================================================
func _make_kill_confirm() -> AudioStreamWAV:
	var duration = 0.3
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# First ding
		var d1_env = exp(-t * 12.0) * 0.4
		var d1 = sin(t * TAU * 880) * d1_env
		d1 += sin(t * TAU * 1320) * d1_env * 0.5
		
		# Second ding (higher, delayed)
		var d2 = 0.0
		if t > 0.08:
			var t2 = t - 0.08
			var d2_env = exp(-t2 * 10.0) * 0.5
			d2 = sin(t2 * TAU * 1100) * d2_env
			d2 += sin(t2 * TAU * 1650) * d2_env * 0.4
		
		var sample = clamp(d1 + d2, -1.0, 1.0)
		var val = int(sample * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# HEADSHOT — crunchy impact + metallic ring
# ============================================================
func _make_headshot() -> AudioStreamWAV:
	var duration = 0.2
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# Crunch
		var crunch = 0.0
		if t < 0.02:
			crunch = randf_range(-1.0, 1.0) * (1.0 - t / 0.02) * 0.7
		
		# Impact thud
		var thud = sin(t * TAU * 200) * exp(-t * 30.0) * 0.4
		
		# High metallic ring
		var ring = sin(t * TAU * 2400) * exp(-t * 15.0) * 0.3
		ring += sin(t * TAU * 3600) * exp(-t * 20.0) * 0.2
		
		var sample = clamp(crunch + thud + ring, -1.0, 1.0)
		var val = int(sample * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# RELOAD — mechanical click + slide + click
# ============================================================
func _make_reload() -> AudioStreamWAV:
	var duration = 0.4
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		var sample = 0.0
		
		# Mag release click (0-30ms)
		if t < 0.03:
			var e1 = (1.0 - t / 0.03)
			sample += sin(t * TAU * 2000) * e1 * 0.3
			sample += randf_range(-1.0, 1.0) * e1 * 0.2
		
		# Mag sliding out (30-120ms)
		if t > 0.03 and t < 0.12:
			var lt2 = t - 0.03
			var e2 = sin(lt2 / 0.09 * PI) * 0.15
			sample += randf_range(-1.0, 1.0) * e2
		
		# Mag insert (180-250ms) 
		if t > 0.18 and t < 0.25:
			var lt3 = t - 0.18
			var e3 = exp(-lt3 * 40.0)
			sample += sin(lt3 * TAU * 1500) * e3 * 0.3
			sample += randf_range(-1.0, 1.0) * e3 * 0.25
		
		# Bolt release (300-370ms)
		if t > 0.30 and t < 0.37:
			var lt4 = t - 0.30
			var e4 = exp(-lt4 * 50.0)
			sample += sin(lt4 * TAU * 800) * e4 * 0.35
			sample += sin(lt4 * TAU * 3000) * e4 * 0.15
			sample += randf_range(-1.0, 1.0) * e4 * 0.2
		
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# FOOTSTEP — soft thud on concrete
# ============================================================
func _make_footstep() -> AudioStreamWAV:
	var duration = 0.08
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		var env = exp(-t * 50.0)
		
		# Low thud
		var sample = sin(t * TAU * 100) * env * 0.4
		# Surface noise
		sample += randf_range(-1.0, 1.0) * env * 0.2
		# Slight scuff
		sample += sin(t * TAU * 400) * env * 0.1
		
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# HURT — impact thud + grunt-like noise
# ============================================================
func _make_hurt() -> AudioStreamWAV:
	var duration = 0.25
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# Impact
		var impact = sin(t * TAU * 150) * exp(-t * 20.0) * 0.5
		
		# Grunt-like (low pass noise with formant)
		var grunt_env = 0.0
		if t > 0.02 and t < 0.2:
			grunt_env = sin((t - 0.02) / 0.18 * PI) * 0.35
		var grunt = sin(t * TAU * 180 + sin(t * TAU * 6) * 2.0) * grunt_env
		grunt += randf_range(-1.0, 1.0) * grunt_env * 0.15
		
		var sample = clamp(impact + grunt, -1.0, 1.0)
		var val = int(sample * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# ROUND START — dramatic rising horn
# ============================================================
func _make_round_start() -> AudioStreamWAV:
	var duration = 0.8
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		var env_t = float(i) / samples
		
		# Fade in then out
		var env = 0.0
		if env_t < 0.1:
			env = env_t / 0.1
		elif env_t < 0.7:
			env = 1.0
		else:
			env = (1.0 - env_t) / 0.3
		env *= 0.4
		
		# Rising frequency horn
		var freq = 220 + t * 200
		var sample = sin(t * TAU * freq) * env
		# Harmonics for richness
		sample += sin(t * TAU * freq * 2) * env * 0.3
		sample += sin(t * TAU * freq * 3) * env * 0.15
		# Second voice, fifth above
		sample += sin(t * TAU * freq * 1.5) * env * 0.2
		
		var val = int(clamp(sample, -1.0, 1.0) * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# BUY SOUND — cash register cha-ching
# ============================================================
func _make_buy_sound() -> AudioStreamWAV:
	var duration = 0.25
	var samples = int(duration * sample_rate)
	var data = PackedByteArray()
	data.resize(samples * 2)
	
	for i in range(samples):
		var t = float(i) / sample_rate
		
		# Cha (first hit)
		var cha = 0.0
		if t < 0.05:
			cha = sin(t * TAU * 4000) * (1.0 - t / 0.05) * 0.4
			cha += randf_range(-1.0, 1.0) * (1.0 - t / 0.05) * 0.15
		
		# Ching (bell, delayed)
		var ching = 0.0
		if t > 0.06:
			var t2 = t - 0.06
			var env = exp(-t2 * 8.0) * 0.5
			ching = sin(t2 * TAU * 2200) * env
			ching += sin(t2 * TAU * 3300) * env * 0.4
			ching += sin(t2 * TAU * 4400) * env * 0.2
		
		var sample = clamp(cha + ching, -1.0, 1.0)
		var val = int(sample * 32767)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	
	return _pack_wav(data)

# ============================================================
# HELPER
# ============================================================
func _pack_wav(data: PackedByteArray) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func play(sound_name: String):
	if not audio_players.has(sound_name):
		return
	var base = audio_players[sound_name]
	# If already playing, create a temporary player for polyphony
	if base.playing:
		var temp = AudioStreamPlayer.new()
		temp.stream = base.stream
		temp.volume_db = base.volume_db
		temp.bus = "Master"
		add_child(temp)
		temp.play()
		temp.finished.connect(temp.queue_free)
	else:
		base.play()
