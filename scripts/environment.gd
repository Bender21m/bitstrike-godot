extends Node

# Environment enhancements — skybox, fog, post-processing
# Makes maps look more polished

func _ready():
	_enhance_environment()

func _enhance_environment():
	var world_env = get_tree().root.find_child("WorldEnvironment", true, false)
	if not world_env:
		return
	
	var env = world_env.environment
	if not env:
		return
	
	# Better ambient lighting
	env.ambient_light_energy = 0.7
	
	# Fog — atmospheric depth
	env.fog_enabled = true
	env.fog_density = 0.005
	env.fog_light_color = Color(0.06, 0.06, 0.09)
	
	# Glow / Bloom
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_bloom = 0.1
	env.glow_blend_mode = 0  # Additive
	
	# Tonemap for cinematic look
	env.tonemap_mode = 2  # ACES
	env.tonemap_exposure = 1.0
	
	# SSAO for depth
	env.ssao_enabled = true
	env.ssao_intensity = 1.0
	env.ssao_radius = 1.0
	
	# SSR for reflective floors
	env.ssr_enabled = false  # Too expensive for web, disable
	
	# Vignette effect via adjustment
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.05
	env.adjustment_saturation = 0.95
