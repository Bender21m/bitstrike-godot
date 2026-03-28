extends Node

# WebGL Context Loss Recovery
# Detects when the browser loses the WebGL context (common on idle/tab switch)
# Shows a "Click to Resume" overlay and reloads if needed

var check_interval: float = 2.0
var check_timer: float = 0.0
var last_frame_time: float = 0.0
var stall_threshold: float = 5.0  # Seconds without frame update = stalled
var is_stalled: bool = false

func _ready():
	# Only active in web builds
	if not OS.has_feature("web"):
		set_process(false)
		return
	
	# Inject JavaScript for context loss detection
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
			// WebGL context loss detection
			var canvas = document.querySelector('canvas');
			if (canvas) {
				window._webglContextLost = false;
				canvas.addEventListener('webglcontextlost', function(e) {
					e.preventDefault();
					window._webglContextLost = true;
					console.warn('WebGL context lost!');
				});
				canvas.addEventListener('webglcontextrestored', function(e) {
					window._webglContextLost = false;
					console.log('WebGL context restored');
					// Force reload to reinitialize
					location.reload();
				});
			}
			
			// Also detect visibility change (tab switch)
			document.addEventListener('visibilitychange', function() {
				if (!document.hidden && window._webglContextLost) {
					location.reload();
				}
			});
		""")

func _process(delta):
	if not OS.has_feature("web"):
		return
	
	check_timer += delta
	
	if check_timer >= check_interval:
		check_timer = 0.0
		_check_context()
	
	last_frame_time = Time.get_ticks_msec() / 1000.0

func _check_context():
	# Check via JavaScript if context was lost
	if OS.has_feature("web"):
		var lost = JavaScriptBridge.eval("window._webglContextLost === true")
		if lost and not is_stalled:
			is_stalled = true
			_show_recovery_overlay()

func _show_recovery_overlay():
	# Show HTML overlay since Godot rendering may be dead
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
			if (!document.getElementById('webgl-recovery')) {
				var overlay = document.createElement('div');
				overlay.id = 'webgl-recovery';
				overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.9);display:flex;flex-direction:column;align-items:center;justify-content:center;z-index:9999;cursor:pointer;font-family:monospace;';
				overlay.innerHTML = '<div style="color:#f7941a;font-size:48px;margin-bottom:20px;">⚡ CONNECTION LOST</div><div style="color:#888;font-size:18px;">Click anywhere to reconnect</div><div style="color:#555;font-size:14px;margin-top:10px;">WebGL context was lost (happens after idle)</div>';
				overlay.onclick = function() { location.reload(); };
				document.body.appendChild(overlay);
			}
		""")
