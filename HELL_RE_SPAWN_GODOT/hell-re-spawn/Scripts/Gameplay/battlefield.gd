extends Control

signal card_selected(unit_data, card_node)

const SOUL_SCENE = preload("res://Scenes/Cards/Soul.tscn")

# --- COLORS ---
const COLOR_SELECTABLE = Color.WHITE          # Briefing Open + Available
const COLOR_SELECTED = Color.CYAN             # In Squad
const COLOR_BUSY = Color(0.0, 0.4, 0.4, 1.0)  # Deployed (Dark Cyan)
const COLOR_DEFAULT = Color(0, 0, 0, 0)       # Transparent (Trigger to revert to Yellow)

# --- STATE ---
var selected_units: Array = [null, null, null] 
var max_selection_limit: int = 3 
var returning_units: Array = []

# --- REFERENCES ---
@onready var mission_briefing = $MissionBriefing
@onready var hand_container = $HandContainer
@onready var mission_manager = $MissionManager
@onready var unit_detail_view = $UnitDetailView

# --- UI REFERENCES ---	
@onready var gold_label = $TopBar/HBoxContainer/StatsContainer/GoldLabel
@onready var seal_container = $TopBar/HBoxContainer/StatsContainer 
@onready var influence_bar = $TopBar/HBoxContainer/InfluenceBar
@onready var influence_text = $TopBar/HBoxContainer/InfluenceBar/InfText 

func _ready():
	await get_tree().process_frame
	_sync_hand_to_manager()
	
	if hand_container:
		for card in hand_container.get_children():
			if card.has_signal("card_selected"):
				if not card.card_selected.is_connected(_on_card_selected):
					card.card_selected.connect(_on_card_selected)
	
	if mission_briefing:
		if not mission_briefing.slot_clicked.is_connected(_on_briefing_slot_clicked):
			mission_briefing.slot_clicked.connect(_on_briefing_slot_clicked)
		if not mission_briefing.mission_started.is_connected(_on_mission_started):
			mission_briefing.mission_started.connect(_on_mission_started)
			
		if not mission_briefing.visibility_changed.is_connected(_update_interaction_state):
			mission_briefing.visibility_changed.connect(_update_interaction_state)

	if mission_manager:
		if not mission_manager.mission_finished.is_connected(_on_mission_finished):
			mission_manager.mission_finished.connect(_on_mission_finished)
		
	RunManager.resources_changed.connect(_on_resources_updated)
	RunManager.game_over.connect(_on_game_over)
	RunManager.level_cleared.connect(_on_level_cleared)
	RunManager.seals_updated.connect(_on_seals_updated)
	
	RunManager.request_ui_update()
	_update_interaction_state()

# --- INPUT HANDLING ---
func _input(event):
	if event.is_action_pressed("open_unit_menu"):
		if event.is_echo(): return
		toggle_unit_details()
		get_viewport().set_input_as_handled()

func toggle_unit_details():
	if not unit_detail_view: return
	
	if unit_detail_view.visible:
		unit_detail_view.close()
		if mission_manager: mission_manager.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		unit_detail_view.open()
		if mission_manager: mission_manager.process_mode = Node.PROCESS_MODE_DISABLED
	
	_update_interaction_state()

func _update_interaction_state():
	var is_inspecting = (unit_detail_view and unit_detail_view.visible)
	var is_briefing = (mission_briefing and mission_briefing.visible)
	
	var should_be_active = is_inspecting or is_briefing
	set_hand_interaction(should_be_active)

func _on_card_selected(unit_data, card_node):
	if not (unit_detail_view.visible or mission_briefing.visible):
		return

	if unit_detail_view.visible:
		_animate_jump(card_node)
		unit_detail_view.show_specific_unit(unit_data)
		return 

	if mission_manager:
		for mission in mission_manager.active_missions:
			if unit_data in mission.squad:
				return

	if unit_data in selected_units:
		var index = selected_units.find(unit_data)
		if index != -1:
			selected_units[index] = null
			if card_node.has_method("animate_deselect"):
				card_node.animate_deselect()
	else:
		var empty_index = selected_units.find(null)
		if empty_index != -1:
			selected_units[empty_index] = unit_data
			if card_node.has_method("animate_select"):
				card_node.animate_select()

	update_briefing_ui()

func _animate_jump(card_node: Control):
	# 1. IDENTIFY THE VISUAL TARGET
	# Instead of moving the whole 'card_node' (which holds the fog),
	# we try to find the 'card_renderer' inside it.
	var target_visual = card_node
	if "card_renderer" in card_node:
		target_visual = card_node.card_renderer
	
	# 2. MANAGE TWEENS
	if target_visual.has_meta("jump_tween"):
		var old_tween = target_visual.get_meta("jump_tween")
		if old_tween and old_tween.is_valid():
			old_tween.kill()
	
	var tween = create_tween()
	target_visual.set_meta("jump_tween", tween)
	
	# 3. ANIMATE ONLY THE VISUAL
	# We use the visual's CURRENT local position (so it jumps from wherever it is)
	var start_pos = target_visual.position
	
	# Jump UP (Go slightly higher than current)
	tween.tween_property(target_visual, "position:y", start_pos.y - 20, 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	# Fall BACK (Return to start)
	tween.tween_property(target_visual, "position:y", start_pos.y, 0.2)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

func _sync_hand_to_manager():
	RunManager.owned_units.clear()
	if hand_container:
		for card in hand_container.get_children():
			if "unit_data" in card and card.unit_data != null:
				RunManager.owned_units.append(card.unit_data)

func _on_resources_updated(money, influence, target):
	if gold_label: gold_label.text = "Gold: " + str(money)
	if influence_bar:
		influence_bar.max_value = target
		influence_bar.value = influence
	if influence_text: influence_text.text = str(influence) + " / " + str(target)

func _on_seals_updated(current_seals, _max_seals):
	if not seal_container: return
	var hearts = []
	for child in seal_container.get_children():
		if child is TextureRect: hearts.append(child)
	for i in range(hearts.size()):
		if i < current_seals: hearts[i].modulate = Color(1, 1, 1, 1) 
		else: hearts[i].modulate = Color(0.2, 0.2, 0.2, 0.5) 

func _on_game_over(reason): print("GAME OVER: ", reason)
func _on_level_cleared(): print("LEVEL CLEARED!")

func _on_mission_started(squad, mission_node): trigger_deploy_effects(squad, mission_node)
func _on_mission_finished(squad, mission_data): trigger_return_effects(squad, mission_data)   

func set_max_selection(limit: int):
	max_selection_limit = limit
	selected_units = []
	selected_units.resize(max_selection_limit)
	selected_units.fill(null)
	update_briefing_ui()

func trigger_deploy_effects(squad_data: Array, mission_data):
	var end_pos = Vector2(960, 540) 
	var target_node = null
	if "map_marker_node" in mission_data and mission_data.map_marker_node != null:
		target_node = mission_data.map_marker_node
	elif mission_data is Node2D or mission_data is Control:
		target_node = mission_data
	if target_node:
		end_pos = target_node.global_position
		if target_node is Control: end_pos += target_node.size / 2.0

	for i in range(squad_data.size()):
		var unit_data = squad_data[i]
		var card = _find_card_by_data(unit_data)
		if card:
			var delay = i * 0.3
			var tween = create_tween()
			tween.tween_interval(delay) 
			tween.tween_property(card, "modulate", Color(2.0, 3.0, 5.0, 1.0), 0.2)
			tween.tween_property(card, "modulate", Color(1, 1, 1, 1.0), 0.3)
			get_tree().create_timer(delay).timeout.connect(func():
				if SOUL_SCENE:
					var soul = SOUL_SCENE.instantiate()
					add_child(soul)
					soul.travel(card.global_position + (card.size / 2.0), end_pos)
			)

func trigger_return_effects(squad_data: Array, mission_data):
	for unit in squad_data:
		if unit not in returning_units: returning_units.append(unit)
	var start_pos = Vector2(960, 540)
	var target_node = null
	if "map_marker_node" in mission_data and mission_data.map_marker_node != null:
		target_node = mission_data.map_marker_node
	elif mission_data is Node2D:
		target_node = mission_data
	if target_node:
		start_pos = target_node.global_position
		if target_node is Control: start_pos += target_node.size / 2.0

	for i in range(squad_data.size()):
		var unit_data = squad_data[i]
		var card = _find_card_by_data(unit_data)
		if card:
			var delay = i * 0.3
			var flight_time = 0.8
			var end_pos = card.global_position + (card.size / 2.0)
			var timer = get_tree().create_timer(delay)
			timer.timeout.connect(func():
				if SOUL_SCENE:
					var soul = SOUL_SCENE.instantiate()
					add_child(soul)
					soul.travel(start_pos, end_pos, flight_time)
					get_tree().create_timer(flight_time).timeout.connect(func():
						var tween = create_tween()
						tween.tween_property(card, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.2)
						tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
						if unit_data in returning_units: returning_units.erase(unit_data)
					)
			)
			
func _find_card_by_data(data):
	for card in hand_container.get_children():
		if card.unit_data == data: return card
	return null

func _on_briefing_slot_clicked(unit_data):
	var found_card = null
	for card in hand_container.get_children():
		if card.unit_data == unit_data:
			found_card = card
			break
	if found_card: _on_card_selected(unit_data, found_card)

func update_briefing_ui():
	if mission_briefing and mission_briefing.visible:
		mission_briefing.update_squad_display(selected_units)

func clear_selection():
	selected_units.fill(null)
	var busy_units = []
	if mission_manager:
		for mission in mission_manager.active_missions:
			for unit in mission.squad: busy_units.append(unit)
	for card in hand_container.get_children():
		if card.unit_data not in busy_units:
			if card.has_method("force_reset"): card.force_reset()
	
	if mission_briefing: mission_briefing.update_squad_display([])
	
	_update_interaction_state()

func _process(_delta): _update_card_locks()

# --- CARD STATE LOGIC ---
func _update_card_locks():
	var busy_units = []
	if mission_manager:
		for mission in mission_manager.active_missions:
			for unit in mission.squad: busy_units.append(unit)
			
	var is_briefing_active = (mission_briefing and mission_briefing.visible)

	for card in hand_container.get_children():
		var is_busy = (card.unit_data in busy_units)
		var is_in_squad = (card.unit_data in selected_units)
		var is_returning = (card.unit_data in returning_units)
		
		# 1. BUSY / DEPLOYED
		if is_busy or is_returning:
			# FOG ON: True
			if card.has_method("set_locked"): card.set_locked(true, true)
			if card.has_method("set_border_color"): 
				card.set_border_color(COLOR_BUSY)
			
		else:
			# 2. IN SQUAD (Selected)
			if is_in_squad:
				# FOG OFF: False (Shrink only)
				if card.has_method("set_locked"): card.set_locked(true, false)
				if card.has_method("set_border_color"): 
					card.set_border_color(COLOR_SELECTED)
			
			# 3. AVAILABLE + BRIEFING OPEN
			elif is_briefing_active:
				if card.has_method("set_locked"): card.set_locked(false)
				if card.has_method("set_border_color"): 
					card.set_border_color(COLOR_SELECTABLE)
			
			# 4. DEFAULT
			else:
				if card.has_method("set_locked"): card.set_locked(false)
				if card.has_method("set_border_color"): 
					card.set_border_color(COLOR_DEFAULT) # Reverts to Yellow

func set_hand_interaction(is_active: bool):
	for card in hand_container.get_children(): card.mission_brief_active = is_active
