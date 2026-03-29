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
	
	# Procedural sky
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.05, 0.05, 0.12)
	sky_mat.sky_horizon_color = Color(0.15, 0.12, 0.2)
	sky_mat.ground_bottom_color = Color(0.05, 0.05, 0.08)
	sky_mat.ground_horizon_color = Color(0.1, 0.08, 0.12)
	sky_mat.sun_angle_max = 30.0
	sky_mat.sun_curve = 0.15
	sky.sky_material = sky_mat
	env.sky = sky
	env.background_mode = 2  # Sky mode
	
	# Good ambient lighting
	env.ambient_light_energy = 0.8
	env.ambient_light_color = Color(0.5, 0.5, 0.6)
	env.ambient_light_source = 1  # Sky
	
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
