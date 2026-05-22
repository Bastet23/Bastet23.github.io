extends Control

# ==========================================
# --- REFERENCES & VARIABLES ---
# ==========================================

@onready var shop_container = $Caravan/ShopSlotsContainer
@onready var items_container = $Caravan/ItemsContainer      
@onready var prayers_container = $Caravan/PrayersContainer  
@onready var hand_container = $Scarf_hand_container/HandContainer 
@onready var gold_label = $TopBar/GoldLabel 

# --- INVENTORY REFERENCES ---
@onready var inventory_btn = $InventoryButton   
@onready var inventory_view = $InventoryView           

# REROLL BUTTONS & COSTS
@onready var reset_cards_btn = $Caravan/ResetCardsButton
@onready var reset_items_btn = $Caravan/ResetItemsButton

var current_cards_reroll_cost: int = 4
var current_items_reroll_cost: int = 4

# STATIC MENU (Side Panel)
@onready var description_sign = $DescriptionSign
@onready var hexagon_paper = $DescriptionSign/HexagonPaper
@onready var ability_signs_paper = $DescriptionSign/AbilitySigns
@onready var stat_hexagon = $DescriptionSign/HexagonPaper/StatHexagon
@onready var item_desc_label = $DescriptionSign/HexagonPaper/ItemRichTextLabel
@onready var ability_label_1 = $DescriptionSign/AbilitySigns/AbilityLabel1
@onready var ability_label_2 = $DescriptionSign/AbilitySigns/AbilityLabel2

# --- RESOURCES ---
const CARD_SCENE = preload("res://Scenes/Cards/unit_display.tscn")
const ITEM_SCENE = preload("res://Scenes/Items_Prayers/ItemDisplay.tscn")     
const PRAYER_SCENE = preload("res://Scenes/Items_Prayers/PrayerDisplay.tscn") 
const BURN_SCENE = preload("res://Scenes/Cards/BurnEffect.tscn")

var available_resources: Array = []
var available_items: Array = []     
var available_prayers: Array = []   

var selected_card_node = null
var current_highlighted_card = null

# --- STATE LOCKS ---
var processing_cards: Array = []
var pending_blessing_data: Resource = null
var floating_souls: Array = [] # Holds souls waiting to be claimed!

# ==========================================
# --- CORE SETUP & INITIALIZATION ---
# ==========================================

func _ready():
	_load_resources_from_folder("res://Resources/Unit_Resources/")
	_load_resources_from_folder("res://Resources/Items/")
	_load_resources_from_folder("res://Resources/Prayers/")
	
	description_sign.visible = true
	description_sign.z_index = 0 
	
	if inventory_btn: inventory_btn.pressed.connect(_on_inventory_btn_pressed)
	if inventory_view: inventory_view.inventory_closed.connect(_on_inventory_closed)
	
	# Connect the dual reroll buttons!
	if reset_cards_btn: reset_cards_btn.pressed.connect(_on_reset_cards_pressed)
	if reset_items_btn: reset_items_btn.pressed.connect(_on_reset_items_pressed)
	
	hexagon_paper.visible = true
	ability_signs_paper.visible = true
	
	if hexagon_paper.material: 
		hexagon_paper.material.set_shader_parameter("dissolve_value", 1.0)
	if ability_signs_paper.material: 
		ability_signs_paper.material.set_shader_parameter("dissolve_value", 1.0)
	
	_clear_description()
	generate_shop_cards()
	_connect_hand_signals()
	_update_ui()

func _load_resources_from_folder(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".remap"):
				var clean_name = file_name.replace(".remap", "")
				var res = load(path + "/" + clean_name)
				
				if res is UnitData: available_resources.append(res)
				elif "Items" in path: available_items.append(res)
				elif "Prayers" in path: available_prayers.append(res)
					
			file_name = dir.get_next()

func _connect_hand_signals():
	for card in hand_container.get_children():
		card.mission_brief_active = true
		card.z_index = 1
		if not card.card_selected.is_connected(_on_hand_card_clicked):
			card.card_selected.connect(_on_hand_card_clicked)


# ==========================================
# --- TOP BAR & UI BUTTONS ---
# ==========================================

func _on_reset_cards_pressed():
	if pending_blessing_data != null or not processing_cards.is_empty(): return 
	
	if RunManager.current_money >= current_cards_reroll_cost:
		RunManager.current_money -= current_cards_reroll_cost
		current_cards_reroll_cost += 1 # Only increments the Cards cost!
		
		floating_souls.clear() # Souls dissipate if you reroll the characters!
		for child in shop_container.get_children(): 
			child.queue_free()
			
		for i in range(3): 
			_spawn_shop_card()
		_update_ui()

func _on_reset_items_pressed():
	if pending_blessing_data != null or not processing_cards.is_empty(): return 
	
	if RunManager.current_money >= current_items_reroll_cost:
		RunManager.current_money -= current_items_reroll_cost
		current_items_reroll_cost += 1 # Only increments the Items cost!
		
		for child in items_container.get_children(): 
			child.queue_free()
		for child in prayers_container.get_children(): 
			child.queue_free()
			
		for i in range(3): _spawn_item()
		for i in range(2): _spawn_prayer()
		_update_ui()

func _on_inventory_btn_pressed():
	if pending_blessing_data != null: return # LOCK
	
	# 1. THE TOGGLE
	if inventory_view and inventory_view.visible:
		inventory_view.visible = false
		_on_inventory_closed() 
		return
		
	# 2. CAPTURE THE CARD FIRST
	var card_to_view = null
	if selected_card_node and selected_card_node.get_parent() == hand_container:
		card_to_view = selected_card_node
		
	# 3. SAFE TO CLEAR UI
	_clear_description()
	
	# 4. ASSIGN AND ANIMATE
	if card_to_view:
		selected_card_node = card_to_view 
		if card_to_view.has_method("set_locked"): card_to_view.set_locked(true, false)
		if card_to_view.has_method("set_border_color"): card_to_view.set_border_color(Color.CYAN)
	else:
		if hand_container.get_child_count() > 0:
			card_to_view = hand_container.get_child(0)
			selected_card_node = card_to_view 
			if card_to_view.has_method("set_locked"): card_to_view.set_locked(true, false)
			if card_to_view.has_method("set_border_color"): card_to_view.set_border_color(Color.CYAN)
			
	# 5. OPEN INVENTORY
	if inventory_view:
		inventory_view.open_inventory(card_to_view)

func _on_inventory_closed():
	var card_to_restore = null
	if inventory_view and inventory_view.current_unit_card:
		card_to_restore = inventory_view.current_unit_card

	_clear_description()

	if card_to_restore and is_instance_valid(card_to_restore):
		_on_hand_card_clicked(card_to_restore.unit_data, card_to_restore)


# ==========================================
# --- SELECTION & CLICKS ---
# ==========================================

func _on_shop_card_clicked(unit_data, card_node):
	if pending_blessing_data != null: return # LOCK
	
	_deselect_all_cards() 
	selected_card_node = card_node
	_update_description_panel(unit_data, card_node)
	
	var price = unit_data.base_cost
	var can_afford = (RunManager.current_money >= price)
	var has_space = (hand_container.get_child_count() < 7)
	var is_buyable = (can_afford and has_space)
	
	card_node.show_interaction_button("\nBUY", price, not is_buyable)
	if not card_node.interaction_requested.is_connected(_on_card_interaction):
		card_node.interaction_requested.connect(_on_card_interaction)

func _on_hand_card_clicked(unit_data, card_node):
	# --- BLESSING INTERCEPTOR ---
	if pending_blessing_data != null:
		_apply_blessing_to_unit(unit_data, pending_blessing_data)
		pending_blessing_data = null # Clear the state!
		if card_node.has_method("set_border_color"): card_node.set_border_color(Color.GOLD)
		_on_hand_card_clicked(unit_data, card_node) # Refresh UI
		return
	# ----------------------------

	_deselect_all_cards()
	selected_card_node = card_node
	
	# MODE 1: INVENTORY OPEN
	if inventory_view and inventory_view.visible:
		if card_node.has_method("set_locked"): card_node.set_locked(true, false)
		if card_node.has_method("set_border_color"): card_node.set_border_color(Color.CYAN)
		inventory_view.inspect_card(card_node)
		
	# MODE 2: SHOP NORMAL
	else:
		_update_description_panel(unit_data, card_node)
		var sell_price = unit_data.get_sell_cost()
		card_node.show_interaction_button("\nSELL", sell_price, false)
		if not card_node.interaction_requested.is_connected(_on_card_interaction):
			card_node.interaction_requested.connect(_on_card_interaction)

func _on_item_clicked(item_data, item_node):
	if pending_blessing_data != null: return # LOCK
	
	_deselect_all_cards()
	selected_card_node = item_node
	_update_item_description(item_data, item_node)
	
	var price = 0
	if "base_cost" in item_data: price = item_data.base_cost
	var can_afford = (RunManager.current_money >= price)
	
	if item_node.has_method("show_interaction_button"):
		item_node.show_interaction_button("\nBUY", price, not can_afford)
	if item_node.has_signal("interaction_requested") and not item_node.interaction_requested.is_connected(_on_item_interaction):
		item_node.interaction_requested.connect(_on_item_interaction)

func _on_prayer_clicked(prayer_data, prayer_node):
	if pending_blessing_data != null: return # LOCK
	
	_deselect_all_cards()
	selected_card_node = prayer_node
	_update_item_description(prayer_data, prayer_node) 
	
	var price = 0
	if "base_cost" in prayer_data: price = prayer_data.base_cost
	var can_afford = (RunManager.current_money >= price)
	
	if prayer_node.has_method("show_interaction_button"):
		prayer_node.show_interaction_button("\nBUY", price, not can_afford)
	if prayer_node.has_signal("interaction_requested") and not prayer_node.interaction_requested.is_connected(_on_prayer_interaction):
		prayer_node.interaction_requested.connect(_on_prayer_interaction)


# ==========================================
# --- TRANSACTIONS & INTERACTIONS ---
# ==========================================

func _on_card_interaction(card_node):
	if card_node in processing_cards: return 
	
	if card_node.get_parent() == shop_container:
		if RunManager.current_money >= card_node.unit_data.base_cost:
			processing_cards.append(card_node) 
			_buy_card(card_node)
	elif card_node.get_parent() == hand_container:
		processing_cards.append(card_node) 
		_sell_card(card_node)

func _on_item_interaction(item_node):
	var price = 0
	if "base_cost" in item_node.item_data: price = item_node.item_data.base_cost
		
	if RunManager.current_money >= price:
		RunManager.current_money -= price
		RunManager.owned_items.append(item_node.item_data) 
		
		_clear_description()
		_update_ui()
		
		var spacer = Control.new()
		spacer.custom_minimum_size = item_node.size
		spacer.size_flags_horizontal = item_node.size_flags_horizontal
		
		var parent_container = item_node.get_parent()
		var item_index = item_node.get_index()
		parent_container.add_child(spacer)
		parent_container.move_child(spacer, item_index)
		item_node.queue_free()

func _on_prayer_interaction(prayer_node):
	if pending_blessing_data != null: return # Already waiting!
	
	var price = 0
	if "base_cost" in prayer_node.prayer_data: price = prayer_node.prayer_data.base_cost
		
	if RunManager.current_money >= price:
		RunManager.current_money -= price
		pending_blessing_data = prayer_node.prayer_data
		
		_clear_description()
		_update_ui()
		
		if item_desc_label:
			item_desc_label.visible = true
			item_desc_label.text = "[center][color=cyan]BLESSING ACQUIRED[/color][/center]\n\nSelect a character in your hand to receive this permanent blessing!"
		
		var spacer = Control.new()
		spacer.custom_minimum_size = prayer_node.size
		spacer.size_flags_horizontal = prayer_node.size_flags_horizontal
		
		var parent_container = prayer_node.get_parent()
		var prayer_index = prayer_node.get_index()
		parent_container.add_child(spacer)
		parent_container.move_child(spacer, prayer_index)
		prayer_node.queue_free()

func _buy_card(card_to_buy):
	_deselect_all_cards() 
	
	var price = card_to_buy.unit_data.base_cost
	RunManager.current_money -= price
	RunManager.owned_units.append(card_to_buy.unit_data)
	
	# --- ABSORB FLOATING SOUL ---
	for i in range(floating_souls.size() - 1, -1, -1):
		var soul = floating_souls[i]
		if soul["target_class"] == card_to_buy.unit_data.unit_class or soul["target_class"] == "Pawn":
			card_to_buy.unit_data.receive_legacy_stats(soul["permanent"], soul["volatile"])
			if card_to_buy.has_method("update_visuals"): card_to_buy.update_visuals()
			print(card_to_buy.unit_data.character_name + " absorbed a soul! The effect is now consumed.")
			floating_souls.remove_at(i) 
			break 
	# ---------------------------------
	
	card_to_buy.set_border_color(Color(0,0,0,0))
	if "fog_nodes" in card_to_buy:
		for fog in card_to_buy.fog_nodes:
			if fog: fog.emitting = false 
			
	# Move the card directly to the hand
	var parent_container = card_to_buy.get_parent()
	parent_container.remove_child(card_to_buy)
	hand_container.add_child(card_to_buy)
	
	card_to_buy.card_selected.disconnect(_on_shop_card_clicked)
	card_to_buy.card_selected.connect(_on_hand_card_clicked)
	card_to_buy.allow_hover_animation = true
	
	if selected_card_node == card_to_buy:
		var sell_price = card_to_buy.unit_data.get_sell_cost()
		card_to_buy.show_interaction_button("\nSELL", sell_price, false)
	
	processing_cards.erase(card_to_buy)
	_update_ui()

func _sell_card(card_to_sell):
	_deselect_all_cards()
	
	var sold_unit_data = card_to_sell.unit_data
	for i in range(2):
		if sold_unit_data.equipped_items[i] != null:
			RunManager.owned_items.append(sold_unit_data.equipped_items[i])
			sold_unit_data.unequip_item(i)
	
	var sell_price = card_to_sell.unit_data.get_sell_cost()
	RunManager.current_money += sell_price
	_create_floating_soul(sold_unit_data)
	RunManager.owned_units.erase(card_to_sell.unit_data)
	
	# --- RESTORED: THE BURN ANIMATION ---
	var burn_instance = BURN_SCENE.instantiate()
	self.add_child(burn_instance) 
	
	var viewport_texture = card_to_sell.card_renderer.texture
	var final_texture = ImageTexture.create_from_image(viewport_texture.get_image())
	
	burn_instance.global_position = card_to_sell.card_renderer.global_position
	burn_instance.size = card_to_sell.card_renderer.size
	burn_instance.texture = final_texture
	
	if burn_instance.has_method("start_burn"):
		burn_instance.start_burn(0.8)
	
	card_to_sell.modulate.a = 0.0 
	card_to_sell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# ------------------------------------
	
	_clear_description()
	_update_ui()
	
	await get_tree().create_timer(0.8).timeout
	processing_cards.erase(card_to_sell)
	if is_instance_valid(card_to_sell): card_to_sell.queue_free()


# ==========================================
# --- STATS, BUFFS & SOULS LOGIC ---
# ==========================================

func _create_floating_soul(sold_data: UnitData):
	if not sold_data.has_method("get_earned_legacy_stats"): return
	
	var earned_stats = sold_data.get_earned_legacy_stats()
	if earned_stats.is_empty(): return 

	var volatile_stats = {}
	if "bonus_str_total" in sold_data and sold_data.bonus_str_total > 0: volatile_stats["strength"] = sold_data.bonus_str_total
	if "bonus_con_total" in sold_data and sold_data.bonus_con_total > 0: volatile_stats["constitution"] = sold_data.bonus_con_total

	var permanent_stats = {}
	for stat in earned_stats:
		var total_val = earned_stats[stat]
		var vol_val = volatile_stats.get(stat, 0)
		var perm_val = total_val - vol_val
		if perm_val > 0: permanent_stats[stat] = perm_val
		if vol_val > 0: volatile_stats[stat] = min(vol_val, total_val)

	var target_class = sold_data.unit_class
	var valid_target_exists = false
	
	for card in shop_container.get_children():
		if not "unit_data" in card or card.unit_data == null: continue
		if card.unit_data.unit_class == target_class or target_class == "Pawn":
			valid_target_exists = true
			break

	if valid_target_exists:
		floating_souls.append({
			"target_class": target_class,
			"permanent": permanent_stats,
			"volatile": volatile_stats
		})
		print("SOUL CREATED! Waiting for the next " + ("character" if target_class == "Pawn" else target_class) + " to be bought.")
	else:
		print("FAILURE: No matching class in shop. The Soul was lost to the void.")

func _apply_blessing_to_unit(target_unit_data, blessing_data):
	var permanent_stats = {}
	
	if "stat_to_boost" in blessing_data and "boost_amount" in blessing_data:
		var stat_name = blessing_data.stat_to_boost
		var amount = blessing_data.boost_amount
		if amount > 0: permanent_stats[stat_name] = amount
	
	target_unit_data.receive_legacy_stats(permanent_stats, {})
	print(target_unit_data.character_name + " received a blessing of " + str(blessing_data.boost_amount) + " " + blessing_data.stat_to_boost + "!")

# ==========================================
# --- VISUAL UPDATES & UI CLEARING ---
# ==========================================

func _update_ui():
	if gold_label: gold_label.text = "Gold:" + str(RunManager.current_money)
	
	if reset_cards_btn:
		reset_cards_btn.text = "REROLL("+ str(current_cards_reroll_cost) +")"
		reset_cards_btn.disabled = (RunManager.current_money < current_cards_reroll_cost)
		
	if reset_items_btn:
		reset_items_btn.text = "REROLL("+ str(current_items_reroll_cost) +")"
		reset_items_btn.disabled = (RunManager.current_money < current_items_reroll_cost)

func _update_description_panel(unit_data, card_node):
	if current_highlighted_card and is_instance_valid(current_highlighted_card) and current_highlighted_card != card_node:
		if current_highlighted_card.has_method("set_border_color"):
			current_highlighted_card.set_border_color(Color(0,0,0,0))
	
	current_highlighted_card = card_node
	if current_highlighted_card.has_method("set_border_color"):
		current_highlighted_card.set_border_color(Color.CYAN)
	
	if stat_hexagon: stat_hexagon.visible = true
	if ability_label_1: ability_label_1.visible = true
	if ability_label_2: ability_label_2.visible = true
	if item_desc_label: item_desc_label.visible = false
	
	var stats_array = []
	if unit_data.has_method("get_total_stats"): stats_array = unit_data.get_total_stats()
	elif "strength" in unit_data: stats_array = [unit_data.strength, unit_data.constitution, unit_data.dexterity, unit_data.charisma, unit_data.wisdom, unit_data.intelligence]
	
	if stat_hexagon and stat_hexagon.has_method("update_stats") and not stats_array.is_empty():
		stat_hexagon.update_stats(stats_array, [])

	if ability_label_1 and "ability1_text" in unit_data: ability_label_1.text = unit_data.ability1_text
	if ability_label_2 and "ability2_text" in unit_data: ability_label_2.text = unit_data.ability2_text

func _update_item_description(data, node):
	if current_highlighted_card and is_instance_valid(current_highlighted_card) and current_highlighted_card != node:
		if current_highlighted_card.has_method("set_border_color"):
			current_highlighted_card.set_border_color(Color(0,0,0,0))
			
	current_highlighted_card = node
	if current_highlighted_card.has_method("set_border_color"):
		current_highlighted_card.set_border_color(Color.CYAN)
		
	if stat_hexagon: stat_hexagon.visible = false 
	if ability_label_1: ability_label_1.visible = false
	if ability_label_2: ability_label_2.visible = false
	
	if item_desc_label:
		item_desc_label.visible = true
		var display_text = ""
		if "item_name" in data: display_text += "[center][color=yellow]" + data.item_name + "[/color][/center]\n\n"
		elif "prayer_name" in data: display_text += "[center][color=cyan]" + data.prayer_name + "[/color][/center]\n\n"
		if "description" in data: display_text += data.description
		item_desc_label.text = display_text

func _clear_description():
	_deselect_all_cards() 
	current_highlighted_card = null
	selected_card_node = null

	if stat_hexagon: stat_hexagon.visible = false
	if ability_label_1: ability_label_1.text = ""
	if ability_label_2: ability_label_2.text = ""
	if item_desc_label: item_desc_label.visible = false

func _deselect_all_cards():
	var all_cards = shop_container.get_children() + hand_container.get_children() + items_container.get_children() + prayers_container.get_children()
	
	for card in all_cards:
		if not card.has_signal("interaction_requested"): continue
		
		if card.has_method("hide_interaction_button"): card.hide_interaction_button()
		if card.has_method("set_locked"): card.set_locked(false, false)
		if card.has_method("set_border_color"): card.set_border_color(Color(0,0,0,0))
			
		if card.interaction_requested.is_connected(_on_card_interaction): card.interaction_requested.disconnect(_on_card_interaction)
		if card.interaction_requested.is_connected(_on_item_interaction): card.interaction_requested.disconnect(_on_item_interaction)
		if card.interaction_requested.is_connected(_on_prayer_interaction): card.interaction_requested.disconnect(_on_prayer_interaction)


# ==========================================
# --- GENERATORS & SPAWNERS ---
# ==========================================

func generate_shop_cards():
	floating_souls.clear() # Clear souls on initial full spawn!
	
	for child in shop_container.get_children(): child.queue_free()
	for child in items_container.get_children(): child.queue_free()
	for child in prayers_container.get_children(): child.queue_free()
		
	for i in range(3): _spawn_shop_card()
	for i in range(3): _spawn_item()
	for i in range(2): _spawn_prayer()

func _spawn_shop_card():
	if available_resources.is_empty(): return
	var chosen_resource = available_resources.pick_random()
	var new_unit_data = chosen_resource.duplicate(true)
	
	var card = CARD_SCENE.instantiate()
	card.unit_data = new_unit_data
	card.mission_brief_active = true 
	card.z_index = 2
	
	shop_container.add_child(card)
	
	# --- FIX: Wait two frames for the container to position the card! ---
	await get_tree().process_frame 
	await get_tree().process_frame 
	
	if card.has_method("enable_shop_visuals"): card.enable_shop_visuals()
	card.card_selected.connect(_on_shop_card_clicked)

func _spawn_item():
	if available_items.is_empty(): return
	var chosen_item = available_items.pick_random()
	
	var item_node = ITEM_SCENE.instantiate()
	item_node.z_index = 2 
	if "item_data" in item_node: item_node.item_data = chosen_item.duplicate(true)
		
	items_container.add_child(item_node)
	if item_node.has_signal("item_selected"): item_node.item_selected.connect(_on_item_clicked)

func _spawn_prayer():
	if available_prayers.is_empty(): return
	var chosen_prayer = available_prayers.pick_random()
	
	var prayer_node = PRAYER_SCENE.instantiate()
	prayer_node.z_index = 2 
	if "prayer_data" in prayer_node: prayer_node.prayer_data = chosen_prayer.duplicate(true)
		
	prayers_container.add_child(prayer_node)
	if prayer_node.has_signal("prayer_selected"): prayer_node.prayer_selected.connect(_on_prayer_clicked)
