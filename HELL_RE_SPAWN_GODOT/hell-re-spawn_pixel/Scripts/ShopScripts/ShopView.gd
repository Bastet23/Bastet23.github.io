extends Control

# --- REFERENCES ---
@onready var shop_container = $Caravan/ShopSlotsContainer
@onready var hand_container = $Scarf_hand_container/HandContainer 
@onready var gold_label = $TopBar/HBoxContainer/StatsContainer/GoldLabel 

# REROLL BUTTON
@onready var reset_btn = $Caravan/ResetButton
var current_reroll_cost: int = 4

# STATIC MENU (Side Panel)
@onready var description_sign = $DescriptionSign
@onready var stat_hexagon = $DescriptionSign/StatHexagon
@onready var ability_label_1 = $DescriptionSign/AbilityLabel1
@onready var ability_label_2 = $DescriptionSign/AbilityLabel2

# --- RESOURCES ---
const CARD_SCENE = preload("res://Scenes/Cards/unit_display.tscn")
const BURN_SCENE = preload("res://Scenes/Cards/BurnEffect.tscn")

var available_resources: Array = []
var selected_card_node = null
var current_highlighted_card = null

# --- NEW: INTERACTION LOCK ---
var is_shop_busy: bool = false

func _ready():
	_load_resources_from_folder("res://Resources/Unit_Resources/")
	
	description_sign.visible = true
	description_sign.z_index = 2 
	
	_clear_description()
	
	if reset_btn:
		reset_btn.pressed.connect(_on_reset_btn_pressed)
	
	generate_shop_cards()
	_connect_hand_signals()
	_update_ui()

# --- INPUT HANDLING ---

func _on_reset_btn_pressed():
	if is_shop_busy: return # Lock input
	
	if RunManager.current_money >= current_reroll_cost:
		RunManager.current_money -= current_reroll_cost
		current_reroll_cost += 1
		generate_shop_cards()
		_update_ui()

func _on_shop_card_clicked(unit_data, card_node):
	if is_shop_busy: return
	
	_deselect_all_cards() 
	
	selected_card_node = card_node
	_update_description_panel(unit_data, card_node)
	
	# --- FIX: ALWAYS SHOW THE BUTTON ---
	var price = unit_data.base_cost
	
	# 1. Determine if we can afford it
	var can_afford = (RunManager.current_money >= price)
	var has_space = (hand_container.get_child_count() < 7)
	var is_buyable = (can_afford and has_space)
	
	# 2. Show the button regardless of money!
	# We pass 'not is_buyable' as the 3rd argument to disable it visually if we're poor.
	card_node.show_interaction_button("\n\n\nBUY", price, not is_buyable)
	
	# 3. Connect signal
	if not card_node.interaction_requested.is_connected(_on_card_interaction):
		card_node.interaction_requested.connect(_on_card_interaction)

func _on_hand_card_clicked(unit_data, card_node):
	if is_shop_busy: return
	
	_deselect_all_cards()
	selected_card_node = card_node
	_update_description_panel(unit_data, card_node)
	
	var sell_price = unit_data.get_sell_cost()
	
	# Sell button is never disabled (false)
	card_node.show_interaction_button("\n\n\nSELL", sell_price, false)
	
	if not card_node.interaction_requested.is_connected(_on_card_interaction):
		card_node.interaction_requested.connect(_on_card_interaction)

# --- NEW: CENTRAL ACTION HANDLER ---
func _on_card_interaction(card_node):
	if is_shop_busy: return
	
	# Determine if we are buying or selling based on parent container
	if card_node.get_parent() == shop_container:
		if RunManager.current_money >= card_node.unit_data.base_cost:
			selected_card_node = card_node # Ensure sync
			_buy_card()
			
	elif card_node.get_parent() == hand_container:
		selected_card_node = card_node
		_sell_card()

func _deselect_all_cards():
	# Loop through both containers and hide buttons
	var all_cards = shop_container.get_children() + hand_container.get_children()
	
	for card in all_cards:
		# SAFETY CHECK: If this is a Spacer (doesn't have the signal), skip it!
		if not card.has_signal("interaction_requested"):
			continue

		if card.has_method("hide_interaction_button"):
			card.hide_interaction_button()
			
		# Disconnect to prevent duplicate signals
		if card.interaction_requested.is_connected(_on_card_interaction):
			card.interaction_requested.disconnect(_on_card_interaction)

# --- BUYING & SELLING LOGIC ---

func _buy_card():
	# 1. LOCK
	is_shop_busy = true
	_deselect_all_cards() # Hide buttons immediately
	
	# 2. Money & Data
	var price = selected_card_node.unit_data.base_cost
	RunManager.current_money -= price
	RunManager.owned_units.append(selected_card_node.unit_data)
	
	# 3. Visual Prep
	var viewport_texture = selected_card_node.card_renderer.texture
	var snapshot_image = viewport_texture.get_image()
	var final_texture = ImageTexture.create_from_image(snapshot_image)
	
	selected_card_node.set_border_color(Color(0,0,0,0))
	if "fog_nodes" in selected_card_node:
		for fog in selected_card_node.fog_nodes:
			if fog: fog.emitting = false 
	
	# 4. HIDE & MOVE
	selected_card_node.modulate.a = 0.0 # Invisible before move
	
	# Spacer Logic
	var spacer = Control.new()
	spacer.custom_minimum_size = selected_card_node.size
	spacer.size_flags_horizontal = selected_card_node.size_flags_horizontal
	var parent_container = selected_card_node.get_parent()
	var card_index = selected_card_node.get_index()
	parent_container.add_child(spacer)
	parent_container.move_child(spacer, card_index)
	
	# Move to Hand
	parent_container.remove_child(selected_card_node)
	hand_container.add_child(selected_card_node)
	
	# Swap Signals
	selected_card_node.card_selected.disconnect(_on_shop_card_clicked)
	selected_card_node.card_selected.connect(_on_hand_card_clicked)
	selected_card_node.allow_hover_animation = true
	
	# 5. ANIMATION
	await get_tree().process_frame
	await get_tree().process_frame # Wait for layout
	
	var final_hand_pos = selected_card_node.card_renderer.global_position
	
	var burn_instance = BURN_SCENE.instantiate()
	if burn_instance.material:
		burn_instance.material.set_shader_parameter("dissolve_value", 0.0)
	
	self.add_child(burn_instance) 
	burn_instance.z_index = 100 
	burn_instance.global_position = final_hand_pos
	burn_instance.size = selected_card_node.card_renderer.size
	burn_instance.texture = final_texture
	
	var duration = 0.8
	
	if burn_instance.has_method("start_spawn"):
		burn_instance.start_spawn(duration)
	
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.7) 
	fade_tween.tween_property(selected_card_node, "modulate:a", 1.0, duration - 0.25)
	
	await get_tree().create_timer(duration).timeout
	
	if is_instance_valid(selected_card_node):
		selected_card_node.modulate.a = 1.0
	
	# 6. UNLOCK
	is_shop_busy = false
	_clear_description()
	_update_ui()


func _sell_card():
	# 1. LOCK
	is_shop_busy = true
	_deselect_all_cards()
	
	var sell_price = selected_card_node.unit_data.get_sell_cost()
	RunManager.current_money += sell_price
	RunManager.register_legacy_stats(selected_card_node.unit_data)
	RunManager.owned_units.erase(selected_card_node.unit_data)
	
	# 2. Burn Effect
	var burn_instance = BURN_SCENE.instantiate()
	self.add_child(burn_instance) 
	
	var viewport_texture = selected_card_node.card_renderer.texture
	var final_texture = ImageTexture.create_from_image(viewport_texture.get_image())
	
	burn_instance.global_position = selected_card_node.card_renderer.global_position
	burn_instance.size = selected_card_node.card_renderer.size
	burn_instance.texture = final_texture
	
	burn_instance.start_burn(0.8)
	
	# 3. Transparent Wait
	selected_card_node.modulate.a = 0.0 
	selected_card_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_clear_description()
	_update_ui()
	
	await get_tree().create_timer(0.8).timeout
	
	# 4. Delete & UNLOCK
	if is_instance_valid(selected_card_node):
		selected_card_node.queue_free()
	
	is_shop_busy = false


# --- HELPER FUNCTIONS ---

func _update_description_panel(unit_data, card_node):
	# Handle Highlight Border
	if current_highlighted_card and is_instance_valid(current_highlighted_card) and current_highlighted_card != card_node:
		current_highlighted_card.set_border_color(Color(0,0,0,0))
	
	current_highlighted_card = card_node
	current_highlighted_card.set_border_color(Color.CYAN)
	
	# Update Side Panel
	stat_hexagon.visible = true
	ability_label_1.visible = true
	ability_label_2.visible = true
	
	var stats_array = []
	if unit_data.has_method("get_total_stats"):
		stats_array = unit_data.get_total_stats()
	else:
		stats_array = [unit_data.strength, unit_data.constitution, unit_data.dexterity, unit_data.charisma, unit_data.wisdom, unit_data.intelligence]
	
	if stat_hexagon and stat_hexagon.has_method("update_stats"):
		stat_hexagon.update_stats(stats_array, [])

	if ability_label_1: ability_label_1.text = unit_data.ability1_text
	if ability_label_2: ability_label_2.text = unit_data.ability2_text

func _clear_description():
	if current_highlighted_card and is_instance_valid(current_highlighted_card):
		current_highlighted_card.set_border_color(Color(0,0,0,0))
		current_highlighted_card.hide_interaction_button() # Ensure button is hidden
		current_highlighted_card = null

	if stat_hexagon: stat_hexagon.visible = false
	if ability_label_1: ability_label_1.visible = false
	if ability_label_2: ability_label_2.visible = false

func generate_shop_cards():
	for child in shop_container.get_children():
		child.queue_free()
	for i in range(3):
		_spawn_shop_card()

func _spawn_shop_card():
	if available_resources.is_empty(): return
	var chosen_resource = available_resources.pick_random()
	var new_unit_data = chosen_resource.duplicate(true)
	RunManager.consume_legacy_stats(new_unit_data)
	
	var card = CARD_SCENE.instantiate()
	card.unit_data = new_unit_data
	card.mission_brief_active = true 
	card.z_index = 2
	
	shop_container.add_child(card)
	
	await get_tree().process_frame 
	
	if card.has_method("enable_shop_visuals"):
		card.enable_shop_visuals()
	
	card.card_selected.connect(_on_shop_card_clicked)

func _connect_hand_signals():
	for card in hand_container.get_children():
		card.mission_brief_active = true
		card.z_index = 1
		if not card.card_selected.is_connected(_on_hand_card_clicked):
			card.card_selected.connect(_on_hand_card_clicked)

func _update_ui():
	if gold_label:
		gold_label.text = "Gold: " + str(RunManager.current_money)
	if reset_btn:
		reset_btn.text = "REROLL (" + str(current_reroll_cost) + ")"
		reset_btn.disabled = (RunManager.current_money < current_reroll_cost)

func _load_resources_from_folder(path: String):
	# (Your existing loading logic remains unchanged)
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".remap"):
				var clean_name = file_name.replace(".remap", "")
				var res = load(path + "/" + clean_name)
				if res is UnitData:
					available_resources.append(res)
			file_name = dir.get_next()
