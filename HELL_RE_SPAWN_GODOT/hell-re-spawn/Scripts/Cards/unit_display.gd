extends Control

signal card_selected(unit_data, card_node)
signal interaction_requested(card_node)

@export var unit_data: Resource

# --- REFERENCES ---
@onready var card_renderer = $CardRenderer
@onready var shadow_node = $Shadow
@onready var highlight_panel = $SubViewport/CardContent/SelectionHighlight
@onready var card_design = $SubViewport/CardContent/CardDesign
@onready var unit_icon = $SubViewport/CardContent/UnitIcon
@onready var name_label = $SubViewport/CardContent/NameLabel
@onready var class_label = $SubViewport/CardContent/ClassLabel
@onready var mini_stat_hexagon = $SubViewport/CardContent/MiniStatHexagon

# BUTTONS
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
	# Ensure they start hidden
	if action_btn:
		action_btn.visible = false
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
		highlight_panel.visible = false

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
	
	# 1. Set Text
	if price >= 0:
		action_btn.text = text + " (" + str(price) + ")"
	else:
		action_btn.text = text
	
	# 2. Set Disabled State (Gray out if poor)
	action_btn.disabled = is_disabled
	
	# 3. FORCE VISIBILITY
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
		if unit_data.has_method("initialize_base_stats"):
			unit_data.initialize_base_stats()
		name_label.text = unit_data.character_name
		class_label.text = unit_data.unit_class
		if "icon" in unit_data and unit_data.icon:
			unit_icon.texture = unit_data.icon
		elif "portrait" in unit_data and unit_data.portrait:
			unit_icon.texture = unit_data.portrait
		
		if mini_stat_hexagon and mini_stat_hexagon.has_method("update_stats"):
			var stats_array = []
			if unit_data.has_method("get_total_stats"):
				stats_array = unit_data.get_total_stats()
			else:
				stats_array = [unit_data.strength, unit_data.constitution, unit_data.dexterity, unit_data.charisma, unit_data.wisdom, unit_data.intelligence]
			
			# Pass the stats (with an empty array for requirements)
			mini_stat_hexagon.update_stats(stats_array, [])
			
# --- COLOR LOGIC ---
func set_border_color(color: Color = Color(0,0,0,0)):
	if not highlight_panel: return
	
	# If Battlefield sends the transparent "Default" color, hide the highlight
	if color.a == 0:
		highlight_panel.visible = false
	else:
		# Otherwise, make it visible and apply Cyan, Dark Cyan, or White
		highlight_panel.visible = true
		highlight_panel.self_modulate = color
# --- LOCK LOGIC ---
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
		# Selection Bounce (Kept this as it helps feedback)
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		var target_pos = _original_pos + Vector2(10, 10)
		tween.tween_property(card_renderer, "position", target_pos, 0.2)
		tween.parallel().tween_property(card_renderer, "scale", Vector2(0.95, 0.95), 0.2)
		if shadow_node:
			tween.parallel().tween_property(shadow_node, "scale", Vector2(0.95, 0.95), 0.2)
			tween.parallel().tween_property(shadow_node, "position", _original_shadow_pos, 0.2)
	else:
		var mouse_pos = get_global_mouse_position()
		var is_mouse_over = card_renderer.get_global_rect().has_point(mouse_pos)
		
		if is_mouse_over and mission_brief_active and allow_hover_animation:
			_animate_hover_state(true)
		else:
			_animate_hover_state(false)

# --- INPUT & HOVER ---
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
		tween.tween_property(card_renderer, "scale", Vector2(1.1, 1.1), 0.1)
		tween.parallel().tween_property(card_renderer, "position", _original_pos + Vector2(0, -15), 0.1)
		if shadow_node:
			tween.parallel().tween_property(shadow_node, "scale", Vector2(1.05, 1.05), 0.1)
			tween.parallel().tween_property(shadow_node, "position", _original_shadow_pos + Vector2(0, 5), 0.1)
	else:
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
