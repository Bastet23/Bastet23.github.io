extends Control

signal inventory_closed
const SLOT_SCENE = preload("res://Scenes/Items_Prayers/InventorySlot.tscn")

# --- LEFT PANEL REFERENCES ---
@onready var item_grid = $LeftPanelItems/ScrollContainer/ItemGrid

# --- RIGHT PANEL REFERENCES ---
@onready var stat_hexagon = $RightPanelBackground/StatHexagon
@onready var slot_1 = $RightPanelBackground/Slot1
@onready var slot_2 = $RightPanelBackground/Slot2
@onready var item_1_name = $RightPanelBackground/Item1Name
@onready var item_2_name = $RightPanelBackground/Item2Name
@onready var unit_class_label = $RightPanelBackground/Class
@onready var unit_name_label = $RightPanelBackground/Name
@onready var close_btn = $RightPanelBackground/CloseButton

# --- TOOLTIP REFERENCES ---
@onready var item_tooltip = $ItemToolTip            
@onready var desc_label = $ItemToolTip/ToolTipText  

var current_tooltip_slot = null
var current_unit_card = null 

func _ready():
	visible = false 
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
		
	if item_tooltip:
		item_tooltip.visible = false
		
	if slot_1: 
		slot_1.item_swapped.connect(_on_any_item_dropped)
		slot_1.slot_clicked.connect(_on_inventory_slot_clicked)
	if slot_2: 
		slot_2.item_swapped.connect(_on_any_item_dropped)
		slot_2.slot_clicked.connect(_on_inventory_slot_clicked)

func open_inventory(unit_card = null):
	visible = true
	if item_tooltip: item_tooltip.visible = false 
	current_tooltip_slot = null
	
	current_unit_card = unit_card
	
	_populate_item_grid()
	_update_right_panel()

func inspect_card(unit_card):
	current_unit_card = unit_card
	_update_right_panel()

# --- MAPS UNITDATA TO UI ---
func _update_right_panel():
	if not current_unit_card or not is_instance_valid(current_unit_card):
		if unit_name_label: unit_name_label.text = ""
		if unit_class_label: unit_class_label.text = ""
		if stat_hexagon: stat_hexagon.visible = false
		if slot_1: slot_1.set_item(null)
		if slot_2: slot_2.set_item(null)
		return
		
	var unit_data = current_unit_card.unit_data
	
	# 1. Update Labels (Using your specific UnitData variable names)
	if "character_name" in unit_data and unit_name_label: 
		unit_name_label.text = unit_data.character_name
	if "unit_class" in unit_data and unit_class_label: 
		unit_class_label.text = unit_data.unit_class
		
	# 2. Update Equipment Slots (Reading from your equipped_items array)
	if slot_1: slot_1.set_item(unit_data.equipped_items[0])
	if slot_2: slot_2.set_item(unit_data.equipped_items[1])
	
	# 3. Recalculate and Draw Hexagon
	_refresh_hexagon()

# --- REFRESHES HEXAGON STATS ---
func _refresh_hexagon():
	if stat_hexagon and current_unit_card and is_instance_valid(current_unit_card):
		stat_hexagon.visible = true
		var stats_array = current_unit_card.unit_data.get_total_stats()
		
		if stat_hexagon.has_method("update_stats") and not stats_array.is_empty():
			stat_hexagon.update_stats(stats_array, [])

# --- DRAG AND DROP SYNC LOGIC ---
func _on_any_item_dropped():
	if not current_unit_card or not is_instance_valid(current_unit_card): return
	
	var unit_data = current_unit_card.unit_data
	
	# 1. Physically equip the items to the UnitData using your functions
	unit_data.equip_item(slot_1.stored_item_data, 0)
	unit_data.equip_item(slot_2.stored_item_data, 1)
	
	# 2. Re-read the entire grid and save it so your RunManager is accurate
	RunManager.owned_items.clear()
	for child in item_grid.get_children():
		if child.stored_item_data != null:
			RunManager.owned_items.append(child.stored_item_data)
			
	# 3. Update the Hexagon with the newly applied item stats!
	_refresh_hexagon()

func _populate_item_grid():
	for child in item_grid.get_children():
		child.queue_free()
		
	var total_slots = 20
	var slots_array = []
	
	for i in range(total_slots):
		var empty_slot = SLOT_SCENE.instantiate()
		item_grid.add_child(empty_slot)
		slots_array.append(empty_slot)
		
		empty_slot.slot_clicked.connect(_on_inventory_slot_clicked)
		empty_slot.item_swapped.connect(_on_any_item_dropped) # Listen for drops in the grid too!
		
	var current_slot_index = 0
	for item_data in RunManager.owned_items:
		if current_slot_index < total_slots:
			slots_array[current_slot_index].set_item(item_data)
			current_slot_index += 1

func _on_inventory_slot_clicked(item_data, slot_node):
	if not item_tooltip or not desc_label: return
	
	if item_tooltip.visible and current_tooltip_slot == slot_node:
		item_tooltip.visible = false
		current_tooltip_slot = null
		return
		
	current_tooltip_slot = slot_node
	
	var display_text = ""
	if "item_name" in item_data: 
		display_text += "[center][color=yellow]" + item_data.item_name + "[/color][/center]\n\n"
	elif "prayer_name" in item_data: 
		display_text += "[center][color=cyan]" + item_data.prayer_name + "[/color][/center]\n\n"
	
	if "description" in item_data: 
		display_text += item_data.description
		
	desc_label.text = display_text
	
	# SMART POSITIONING: Check if the slot is on the right half of the screen
	var screen_center = get_viewport_rect().size.x / 2
	if slot_node.global_position.x > screen_center:
		# If it's an equipment slot, pop the tooltip to the LEFT
		var offset_x = item_tooltip.size.x + 10
		item_tooltip.global_position = slot_node.global_position - Vector2(offset_x, 0)
	else:
		# If it's the grid, pop the tooltip to the RIGHT
		var offset_x = slot_node.size.x + 10
		item_tooltip.global_position = slot_node.global_position + Vector2(offset_x, 0)
	
	item_tooltip.visible = true

func _on_close_pressed():
	visible = false
	if item_tooltip: 
		item_tooltip.visible = false 
	current_tooltip_slot = null
	inventory_closed.emit()
