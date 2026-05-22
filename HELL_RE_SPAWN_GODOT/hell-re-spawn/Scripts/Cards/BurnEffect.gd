extends TextureRect

func start_burn(duration: float = 0.8):
	if material:
		material = material.duplicate()
	
	# INITIAL STATE: Make sure it starts fully visible (1.0)
	material.set_shader_parameter("dissolve_value", 1.0)
	
	var tween = create_tween()
	# ANIMATE: Go DOWN to 0.0 (Dissolved)
	tween.tween_property(material, "shader_parameter/dissolve_value", 0.0, duration)
	
	 
	var shake = create_tween().set_loops(10)
	shake.tween_property(self, "position", position + Vector2(2, 0), 0.1)
	shake.tween_property(self, "position", position - Vector2(2, 0), 0.1)
	
	tween.finished.connect(queue_free)

# --- NEW FUNCTION (For Buying) ---
func start_spawn(duration: float = 0.8):
	if material: material = material.duplicate()
	
	# FORCE INVISIBLE IMMEDIATELY
	# If 0.0 is "Gone" and 1.0 is "Visible", start at 0.0
	material.set_shader_parameter("dissolve_value", 0.0) 
	
	var tween = create_tween()
	# Animate to 1.0 (Visible)
	tween.tween_property(material, "shader_parameter/dissolve_value", 1.0, duration)
	var shake = create_tween().set_loops(10)
	
	shake.tween_property(self, "position", position + Vector2(2, 0), 0.1)
	shake.tween_property(self, "position", position - Vector2(2, 0), 0.1)
	
	tween.finished.connect(queue_free)
