extends Control

signal card_selected(unit_data, card_node)
signal interaction_requested(card_node)

@export var unit_data: Resource

# --- REFERENCES ---
@onready var card_renderer = $CardRenderer
@onready var shadow_node = $Shadow
@onready var highlight_panel = $SubViewport/SelectionHighlight
@onready var unit_icon = $SubViewport/CardVisuals/BackgroundPanel/UnitIcon
@onready var name_label = $SubViewport/CardVisuals/BackgroundPanel/UnitIcon/NameLabel
@onready var class_label = $SubViewport/CardVisuals/BackgroundPanel/UnitIcon/ClassLabel

# BUTTONS (Assumes they are children of CardRenderer based on your previous message)
@onready var action_btn = $CardRenderer/ActionBtn
@onready var action_btn_shadow = $CardRenderer/ActionBtnShadow

@onready var fog_nodes: Array[CPUParticles2D] = [
	$Fogs/FogParticles,
	$Fogs/FogParticles2,
	$Fogs/FogParticles3,
	$Fogs/FogParticles4
]

# --- VARIABLES ---
var _original_pos: Vector2
var _original_scale: Vector2 = Vector2(1, 1)
var _original_shadow_pos: Vector2

var mission_brief_active: bool = true
var allow_hover_animation: bool = true
var is_selected: bool = false

var _default_border_color: Color = Color.WHITE
var _default_self_modulate: Color = Color.WHITE

func _ready():
	if not card_renderer.material:
		card_renderer.material = ShaderMaterial.new()

	card_renderer.gui_input.connect(_on_card_input)
	card_renderer.mouse_entered.connect(_on_hover_enter)
	card_renderer.mouse_exited.connect(_on_hover_exit)
	
	# --- BUTTON SETUP ---
	if action_btn:
		action_btn.visible = false
		if action_btn.pressed.is_connected(_on_interaction_pressed):
			action_btn.pressed.disconnect(_on_interaction_pressed)
		action_btn.pressed.connect(_on_interaction_pressed)
		
	if action_btn_shadow:
		action_btn_shadow.visible = false

	if unit_data: update_visuals()
	
	card_renderer.pivot_offset = card_renderer.size / 2
	if shadow_node:
		shadow_node.pivot_offset = shadow_node.size / 2
	
	await get_tree().process_frame
	_original_pos = card_renderer.position
	_original_scale = card_renderer.scale
	_original_shadow_pos = shadow_node.position
	
	for fog in fog_nodes:
		if fog: fog.emitting = false
	
	if highlight_panel:
		highlight_panel.visible = true
		_default_self_modulate = highlight_panel.self_modulate
		var style = highlight_panel.get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			_default_border_color = style.bg_color

func _process(_delta):
	if is_selected and card_renderer.material:
		card_renderer.material.set_shader_parameter("hovering", 0.0)
	
	if "locked" in card_renderer:
		if not allow_hover_animation:
			card_renderer.locked = true

# --- INTERACTION BUTTON LOGIC ---

func _on_interaction_pressed():
	interaction_requested.emit(self)

func show_interaction_button(text: String, price: int = -1, is_disabled: bool = false):
	if not action_btn: 
		print("ERROR: No ActionBtn found on ", self.name)
		return
	
	if price >= 0:
		action_btn.text = text + " (" + str(price) + ")"
	else:
		action_btn.text = text
	
	action_btn.disabled = is_disabled
	action_btn.visible = true
	
	if action_btn_shadow:
		action_btn_shadow.visible = true

func hide_interaction_button():
	if action_btn:
		action_btn.visible = false
	if action_btn_shadow:
		action_btn_shadow.visible = false

# --- VISUALS ---
func update_visuals():
	if unit_data:
		name_label.text = unit_data.character_name
		class_label.text = unit_data.unit_class
		if "icon" in unit_data and unit_data.icon:
			unit_icon.texture = unit_data.icon
		elif "portrait" in unit_data and unit_data.portrait:
			unit_icon.texture = unit_data.portrait

# --- COLOR LOGIC ---
func set_border_color(color: Color = Color(0,0,0,0)):
	if not highlight_panel: return
	highlight_panel.visible = true
	
	var style = highlight_panel.get_theme_stylebox("panel")
	if not (style is StyleBoxFlat): return
	
	var target_modulate = _default_self_modulate
	var target_bg = _default_border_color
	
	if color.a > 0:
		target_modulate = Color(1, 1, 1, 1)
		target_bg = color
	
	highlight_panel.self_modulate = target_modulate
	
	if style.bg_color != target_bg:
		var new_style = style.duplicate()
		new_style.bg_color = target_bg
		highlight_panel.add_theme_stylebox_override("panel", new_style)

# --- LOCK LOGIC (UPDATED FOR PIXEL ART) ---
func set_locked(should_lock: bool, show_fog: bool = true):
	if "locked" in card_renderer:
		card_renderer.locked = should_lock

	for fog in fog_nodes:
		if fog:
			if should_lock and show_fog:
				if not fog.emitting:
					fog.visible = true
					fog.emitting = true
			else:
				if fog.emitting:
					fog.visible = false
					fog.emitting = false

	if should_lock == is_selected: return
	is_selected = should_lock
	
	if is_selected:
		# PIXEL ART UPDATE: Small "Press Down" effect
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		# Move down by 4 pixels (instead of diagonal 10)
		var target_pos = _original_pos + Vector2(0, 4) 
		tween.tween_property(card_renderer, "position", target_pos, 0.2)
		tween.parallel().tween_property(card_renderer, "scale", Vector2(0.95, 0.95), 0.2)
		if shadow_node:
			# Shadow shrinks slightly
			tween.parallel().tween_property(shadow_node, "scale", Vector2(0.95, 0.95), 0.2)
			tween.parallel().tween_property(shadow_node, "position", _original_shadow_pos, 0.2)
	else:
		var mouse_pos = get_global_mouse_position()
		var is_mouse_over = card_renderer.get_global_rect().has_point(mouse_pos)
		
		if is_mouse_over and mission_brief_active and allow_hover_animation:
			_animate_hover_state(true)
		else:
			_animate_hover_state(false)

# --- INPUT & HOVER (UPDATED FOR PIXEL ART) ---
func _on_card_input(event):
	if not mission_brief_active: return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_pressed()

func _on_pressed():
	if unit_data: card_selected.emit(unit_data, self)

func _on_hover_enter():
	if is_selected: return
	if mission_brief_active and allow_hover_animation:
		_animate_hover_state(true)

func _on_hover_exit():
	if is_selected: return
	if allow_hover_animation:
		_animate_hover_state(false)

func _animate_hover_state(is_hovering: bool):
	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	if is_hovering:
		# PIXEL ART UPDATE: 
		# Move UP by 4 pixels (Standard retro "pop")
		# Scale up only slightly (1.05) to avoid distortion
		tween.tween_property(card_renderer, "scale", Vector2(1.05, 1.05), 0.1)
		tween.parallel().tween_property(card_renderer, "position", _original_pos + Vector2(0, -4), 0.1)
		if shadow_node:
			# Shadow grows and moves down slightly
			tween.parallel().tween_property(shadow_node, "scale", Vector2(1.05, 1.05), 0.1)
			tween.parallel().tween_property(shadow_node, "position", _original_shadow_pos + Vector2(0, 2), 0.1)
	else:
		# Reset to exact originals
		tween.tween_property(card_renderer, "scale", _original_scale, 0.1)
		tween.parallel().tween_property(card_renderer, "position", _original_pos, 0.1)
		if shadow_node:
			tween.parallel().tween_property(shadow_node, "scale", Vector2(1, 1), 0.1)
			tween.parallel().tween_property(shadow_node, "position", _original_shadow_pos, 0.1)

func force_reset():
	mission_brief_active = false
	allow_hover_animation = true
	is_selected = false
	if "locked" in card_renderer: card_renderer.locked = false
	for fog in fog_nodes: if fog: fog.emitting = false
	set_border_color()
	_animate_hover_state(false)
	hide_interaction_button()

func enable_shop_visuals():
	allow_hover_animation = true
	if shadow_node:
		shadow_node.visible = true
	for fog in fog_nodes:
		if fog:
			fog.visible = true
			fog.emitting = true
