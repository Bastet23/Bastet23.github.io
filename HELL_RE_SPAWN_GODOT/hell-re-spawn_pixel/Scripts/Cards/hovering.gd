extends TextureRect

# SETTINGS
@export var smooth_speed: float = 10.0 
# CHANGED: The shader uses DEGREES. 0.5 is invisible. 15.0 is a good tilt.
@export var tilt_strength: float = 15.0 

var locked: bool = false 

func _ready():
	if material:
		material = material.duplicate()
		# --- CRITICAL FIX ---
		# This shader calculates 3D vertex displacement based on the image size.
		# We MUST send the size, or the card will disappear/flatten.
		material.set_shader_parameter("rect_size", size)

func _process(delta):
	# 1. Handle Locking (Stop visuals if card is busy)
	if "locked" in self and self.locked:
		_smooth_rotate_to(0.0, 0.0, delta)
		return

	var global_mouse = get_global_mouse_position()
	var rect = get_global_rect()
	
	# 2. Check Input
	if rect.has_point(global_mouse):
		# Get local position relative to CENTER (0,0 is middle)
		var center = rect.size / 2.0
		var local_mouse = (global_mouse - rect.position) - center
		
		# Normalize to -1.0 to 1.0 range
		var pct_x = clamp(local_mouse.x / center.x, -1.0, 1.0)
		var pct_y = clamp(local_mouse.y / center.y, -1.0, 1.0)
		
		# 3. Calculate Target Angles (In Degrees)
		# Mouse X controls Y Rotation (Spinning side-to-side)
		# Mouse Y controls X Rotation (Tilting up/down)
		var target_y = pct_x * tilt_strength
		var target_x = -pct_y * tilt_strength 
		
		_smooth_rotate_to(target_x, target_y, delta)
	else:
		# Mouse left the card? Smoothly return to flat.
		_smooth_rotate_to(0.0, 0.0, delta)

# Helper function to handle the smoothing math
func _smooth_rotate_to(target_x, target_y, delta):
	if not material: return
	
	# Get current values
	var current_x = material.get_shader_parameter("x_rot")
	var current_y = material.get_shader_parameter("y_rot")
	
	# Smoothly interpolate
	var new_x = lerpf(current_x, target_x, smooth_speed * delta)
	var new_y = lerpf(current_y, target_y, smooth_speed * delta)
	
	# Apply to Shader
	material.set_shader_parameter("x_rot", new_x)
	material.set_shader_parameter("y_rot", new_y)
