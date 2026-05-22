extends Control

# --- SIGNALS ---
signal outcome_animation_finished

# --- VISUAL SETTINGS ---
@export var web_color: Color = Color(0.6, 0.6, 0.6, 0.5)
@export var bone_color: Color = Color(0.8, 0.2, 0.2, 1.0)
@export var stat_fill_color: Color = Color(0.2, 0.8, 0.2, 0.5)
@export var req_web_color: Color = Color(1.0, 0.2, 0.2, 0.5)

# --- CONFIG ---
const STAT_NAMES = ["STR", "CON", "DEX", "CHA", "WIS", "INT"]
@export var label_offset: float = 30.0 

# --- DATA ---
var current_stats = [0, 0, 0, 0, 0, 0]
var current_reqs = []
var max_stat_value = 10.0

# --- SCENE REFERENCES ---
var visual_root: Node2D = null 
var drawer: HexagonDrawer = null
var outcome_dot: Node2D = null   
var corner_labels: Array = [] 

func _ready():
	visual_root = Node2D.new()
	visual_root.name = "VisualRoot"
	add_child(visual_root)
	visual_root.position = size / 2 
	
	drawer = HexagonDrawer.new()
	drawer.name = "Drawer"
	drawer.main_script = self 
	visual_root.add_child(drawer)
	
	_create_corner_labels()
	update_labels()

# Called by Manager
func update_stats(new_stats: Array, requirements: Array):
	current_stats = new_stats
	current_reqs = requirements
	if drawer: drawer.queue_redraw()
	update_labels()

func _create_corner_labels():
	for lbl in corner_labels:
		lbl.queue_free()
	corner_labels.clear()
	
	for i in range(6):
		var lbl = Label.new()
		visual_root.add_child(lbl)
		lbl.text = STAT_NAMES[i] + ": 0"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color.WHITE) 
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.add_theme_constant_override("outline_size", 4)
		lbl.add_theme_font_size_override("font_size", 16)
		corner_labels.append(lbl)

func update_labels():
	if not visual_root: return
	var radius = (min(size.x, size.y) / 2) - 40 
	
	for i in range(6):
		if i < corner_labels.size():
			var lbl = corner_labels[i]
			var val = 0
			if i < current_stats.size(): val = current_stats[i]
			lbl.text = "%s: %s" % [STAT_NAMES[i], str(val)]
			
			var angle_deg = -90 + (i * 60)
			var angle_rad = deg_to_rad(angle_deg)
			var dir = Vector2(cos(angle_rad), sin(angle_rad))
			var pos = dir * (radius + label_offset)
			lbl.position = pos - (lbl.size / 2)

# --- SPIDER VISUAL SETUP ---
func _create_spider_visual():
	outcome_dot = Node2D.new()
	outcome_dot.name = "SpiderBody"
	visual_root.add_child(outcome_dot)
	
	# Body
	var body = Polygon2D.new()
	var circle_points = PackedVector2Array()
	for i in range(16):
		var angle = (i / 16.0) * TAU
		circle_points.append(Vector2(cos(angle), sin(angle)) * 6)
	body.polygon = circle_points
	body.color = Color.BLACK
	outcome_dot.add_child(body)
	
	# Legs
	for i in range(8):
		var leg = Line2D.new()
		leg.width = 2
		leg.default_color = Color.BLACK
		var side = -1 if i < 4 else 1
		var vertical_spread = (i % 4) * 4 - 6
		var start = Vector2(0, vertical_spread)
		var knee = Vector2(side * 8, vertical_spread - 2)
		var foot = Vector2(side * 14, vertical_spread + 4)
		leg.points = [start, knee, foot]
		outcome_dot.add_child(leg)

# --- ANIMATION LOGIC (UPDATED) ---
func play_outcome_animation(is_success: bool, was_rerolled: bool = false):
	if outcome_dot == null:
		_create_spider_visual()
	
	# Reset Spider
	outcome_dot.visible = true
	outcome_dot.modulate = Color(1, 1, 1, 1)
	outcome_dot.position = Vector2.ZERO
	outcome_dot.rotation = 0
	
	# Main Sequence
	var tween = create_tween()
	var spider_radius = 8.0
	var current_pos = Vector2.ZERO
	
	# 1. INITIAL SCUTTLE (Random movement)
	for i in range(5):
		var target_pos = _get_scuttle_target(spider_radius)
		_tween_spider_step(tween, outcome_dot, current_pos, target_pos)
		current_pos = target_pos
		tween.tween_interval(randf_range(0.05, 0.15))

	# 2. DECISION PATH
	if was_rerolled:
		# --- PHASE A: FAKE FAIL ---
		# Move to a Failure spot first
		var fail_pos = _get_final_position(false, spider_radius)
		_tween_spider_step(tween, outcome_dot, current_pos, fail_pos)
		current_pos = fail_pos
		
		# Pause for drama
		tween.tween_interval(0.6)
		
		# --- PHASE B: THE VISUAL CUE (Flash) ---
		tween.tween_callback(func():
			# We must target the Polygon2D and Line2D children directly 
			# because modulating a Black node doesn't make it bright!
			
			var body = outcome_dot.get_node("SpiderBody") # Access the child node we named earlier
			if body is Polygon2D:
				var flash = create_tween()
				# Flash from BLACK to GOLD/WHITE
				flash.tween_property(body, "color", Color(1, 0.8, 0.2), 0.1) 
				# Fade back to BLACK
				flash.tween_property(body, "color", Color.BLACK, 0.3)
				
			# Optional: Flash legs too if you want extra pop
			for child in outcome_dot.get_children():
				if child is Line2D:
					var leg_flash = create_tween()
					leg_flash.tween_property(child, "default_color", Color(1, 0.8, 0.2), 0.1)
					leg_flash.tween_property(child, "default_color", Color.BLACK, 0.3)
		)
		tween.tween_interval(0.4) # Wait for flash to finish
		
		# --- PHASE C: FINAL RESULT ---
		# FIX: Use "is_success" instead of "true"
		# This way, if reroll fails, it stays/moves to a fail spot.
		var final_result_pos = _get_final_position(is_success, spider_radius)
		_tween_spider_step(tween, outcome_dot, current_pos, final_result_pos)
		
	else:
		# --- NORMAL OUTCOME ---
		var final_pos = _get_final_position(is_success, spider_radius)
		_tween_spider_step(tween, outcome_dot, current_pos, final_pos)

	# Finish
	tween.finished.connect(func(): emit_signal("outcome_animation_finished"))

# --- ANIMATION HELPERS ---
func _tween_spider_step(tween: Tween, node: Node2D, from: Vector2, to: Vector2):
	var look_angle = (to - from).angle() + (PI / 2)
	
	# Rotate first (quickly)
	tween.tween_property(node, "rotation", look_angle, 0.1).set_trans(Tween.TRANS_QUAD)
	
	# Move (Scuttle)
	tween.tween_property(node, "position", to, randf_range(0.2, 0.3))\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _get_scuttle_target(radius_offset: float) -> Vector2:
	# Pick a random safe spot inside the chart
	var angle = randf_range(0, TAU)
	var wall_dist = _get_radius_at_angle(current_reqs, angle)
	var max_safe_dist = max(0, wall_dist - radius_offset)
	var dist = randf_range(max_safe_dist * 0.2, max_safe_dist)
	return Vector2(cos(angle), sin(angle)) * dist

func _get_final_position(success: bool, radius_offset: float) -> Vector2:
	var final_angle = 0.0
	var final_dist = 0.0
	
	if success:
		# Pick random spot anywhere, but safely inside stats (Green)
		final_angle = randf_range(0, TAU)
		var r_green = _get_radius_at_angle(current_stats, final_angle)
		var r_red = _get_radius_at_angle(current_reqs, final_angle)
		# Success means we are covering requirements, so we can be anywhere up to green line
		var limit = min(r_red, r_green)
		final_dist = randf_range(0, max(0, limit - radius_offset))
	else:
		# Failure: Find the biggest "Gap" where Red > Green and sit there
		var best_angle = 0.0
		var max_gap = -1.0
		
		# Scan 20 angles to find the worst failure point
		for k in range(20):
			var t = randf_range(0, TAU)
			var r_r = _get_radius_at_angle(current_reqs, t)
			var r_g = _get_radius_at_angle(current_stats, t)
			if r_r - r_g > max_gap:
				max_gap = r_r - r_g
				best_angle = t
		
		final_angle = best_angle
		var r_red = _get_radius_at_angle(current_reqs, final_angle)
		var r_green = _get_radius_at_angle(current_stats, final_angle)
		
		# Sit in the red zone (Between Green tip and Red tip)
		var min_d = r_green + radius_offset
		var max_d = r_red - radius_offset
		if max_d > min_d: final_dist = randf_range(min_d, max_d)
		else: final_dist = r_red - (radius_offset * 0.5)

	return Vector2(cos(final_angle), sin(final_angle)) * final_dist

# --- MATH HELPER (Unchanged) ---
func _get_radius_at_angle(stats_array: Array, angle_rad: float) -> float:
	if stats_array.is_empty(): return 0.0
	angle_rad = fmod(angle_rad, TAU)
	if angle_rad < 0: angle_rad += TAU
	var adjusted_angle = angle_rad + (PI / 2)
	adjusted_angle = fmod(adjusted_angle, TAU)
	var sector_size = PI / 3 
	var sector_index = int(adjusted_angle / sector_size)
	var angle_in_sector = fmod(adjusted_angle, sector_size)
	var idx1 = sector_index % 6
	var idx2 = (sector_index + 1) % 6
	var val1 = stats_array[idx1] if idx1 < stats_array.size() else 0.0
	var val2 = stats_array[idx2] if idx2 < stats_array.size() else 0.0
	var r1 = min(val1 / max_stat_value, 1.0)
	var r2 = min(val2 / max_stat_value, 1.0)
	var t = angle_in_sector / sector_size
	var linear_r = lerp(r1, r2, t)
	var max_pixel_radius = (min(size.x, size.y) / 2) - 40
	return linear_r * max_pixel_radius

# ==============================================================================
# INNER CLASS: HexagonDrawer (Unchanged)
# ==============================================================================
class HexagonDrawer extends Node2D:
	var main_script: Control = null
	
	func _draw():
		if not main_script: return
		var center = Vector2.ZERO 
		var radius = (min(main_script.size.x, main_script.size.y) / 2) - 40
		if radius <= 0: return

		for i in range(1, 6):
			var r = (radius / 5) * i
			var points = get_local_hex_points(center, r) 
			points.append(points[0]) 
			draw_polyline(points, main_script.web_color, 2.0)

		var corners = get_local_hex_points(center, radius)
		for point in corners:
			draw_line(center, point, main_script.bone_color, 4.0)

		if not main_script.current_reqs.is_empty():
			var scaled_reqs = []
			for val in main_script.current_reqs:
				var normalized = clampf(val / main_script.max_stat_value, 0.0, 1.0)
				scaled_reqs.append(normalized)
			draw_stat_shape(center, scaled_reqs, radius, main_script.req_web_color)

		var scaled_stats = []
		for val in main_script.current_stats:
			var normalized = clampf(val / main_script.max_stat_value, 0.0, 1.0)
			scaled_stats.append(normalized)
		draw_stat_shape(center, scaled_stats, radius, main_script.stat_fill_color)

	func get_local_hex_points(center, radius):
		var points = PackedVector2Array()
		for i in range(6):
			var angle_deg = -90 + (i * 60)
			var angle_rad = deg_to_rad(angle_deg)
			var point = center + Vector2(cos(angle_rad), sin(angle_rad)) * radius
			points.append(point)
		return points

	func draw_stat_shape(center, stats_normalized, max_radius, color):
		if stats_normalized.size() < 6: return
		var points = PackedVector2Array()
		for i in range(6):
			var angle_deg = -90 + (i * 60)
			var angle_rad = deg_to_rad(angle_deg)
			var length = stats_normalized[i] * max_radius
			var point = center + Vector2(cos(angle_rad), sin(angle_rad)) * length
			points.append(point)
		points.append(points[0])
		draw_colored_polygon(points, color)
		draw_polyline(points, color.darkened(0.2), 2.0)
