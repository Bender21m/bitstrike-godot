extends Node

# Environment enhancements — tuned for web performance
# No heavy effects (SSAO, SSR) — those tank WebGL

func _ready():
	_enhance_environment()

func _enhance_environment():
	var world_env = get_tree().root.find_child("WorldEnvironment", true, false)
	if not world_env:
		return
	
	var env = world_env.environment
	if not env:
		return
	
	# Good ambient lighting
	env.ambient_light_energy = 0.8
	env.ambient_light_color = Color(0.5, 0.5, 0.6)
	
	# Light fog for depth
	env.fog_enabled = true
	env.fog_density = 0.003
	env.fog_light_color = Color(0.06, 0.06, 0.09)
	
	# Subtle glow (muzzle flash, lights pop)
	env.glow_enabled = true
	env.glow_intensity = 0.3
	env.glow_bloom = 0.05
	env.glow_blend_mode = 0
	
	# Tonemap
	env.tonemap_mode = 2  # ACES
	env.tonemap_exposure = 1.0
	
	# NO SSAO — too expensive for WebGL
	env.ssao_enabled = false
	
	# NO SSR
	env.ssr_enabled = false
	
	# Slight contrast bump
	env.adjustment_enabled = true
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.05
	env.adjustment_saturation = 0.95
