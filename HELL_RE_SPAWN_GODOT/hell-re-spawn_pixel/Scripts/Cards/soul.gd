extends Node2D

@onready var trail = $Line2D
@onready var sprite = $Sprite2D
@onready var particles = $CPUParticles2D

var p0: Vector2
var p1: Vector2
var p2: Vector2
var t: float = 0.0
var duration: float = 1.0

func _ready():
	# 1. VISIBILITY SAFETY
	visible = false
	if particles: particles.emitting = false
	
	# 2. RENDER SETTINGS ("Fly Over Everything")
	top_level = true 
	z_as_relative = false 
	z_index = 4096 
	
	# 3. TRAIL SETUP
	if trail: 
		trail.clear_points()
		trail.top_level = true 
		# Removed code that forced the color here. 
		# It now uses whatever you set in the Inspector!
		
		trail.z_index = 4095
		trail.z_as_relative = false
	
	# Removed code that forced Sprite color.
	
	# Stop processing until travel starts
	set_process(false)

func travel(start_pos: Vector2, end_pos: Vector2, time: float = 0.8):
	# 2. SET POSITION IN THE DARK
	global_position = start_pos
	
	# Setup Bezier points
	p0 = start_pos
	p2 = end_pos
	duration = time
	
	var center = (p0 + p2) / 2.0
	var curve_dir = -1.0 if start_pos.x < 960 else 1.0
	var curve_height = 400.0
	p1 = center + Vector2(curve_dir * curve_height, -200)

	# 3. WAKE UP!
	visible = true
	set_process(true)
	
	if particles:
		particles.emitting = true
	
	# Reset Loop vars
	t = 0.0
	scale = Vector2.ONE

func _process(delta):
	t += delta / duration
	
	if t >= 1.0:
		queue_free()
		return
		
	# Bezier Math
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var base_pos = q0.lerp(q1, t)
	
	# Ghost Wiggle
	var forward_dir = (q1 - q0).normalized()
	var side_dir = Vector2(-forward_dir.y, forward_dir.x)
	var wiggle_amount = sin(t * 20.0) * 10.0 
	
	global_position = base_pos + (side_dir * wiggle_amount)
	
	look_at(global_position + forward_dir)
	
	# Trail Logic
	if trail:
		trail.add_point(global_position)
		if trail.get_point_count() > 20:
			trail.remove_point(0)
			
	# Fade out near end
	if t > 0.8:
		var fade_t = (t - 0.8) / 0.2
		scale = scale.lerp(Vector2.ZERO, fade_t)
