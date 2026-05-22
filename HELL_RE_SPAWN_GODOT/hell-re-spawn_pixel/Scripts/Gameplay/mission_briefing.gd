extends Control

# Keyword Dictionary: "Word to find" : "Replacement Text/Color"
const KEYWORDS = {
	"Defeat": "[color=#ff4444]Defeat[/color]",
	"Kill": "[color=#ff4444]Kill[/color]",
	"Defend": "[color=#44ff44]Defend[/color]",
	"Protect": "[color=#44ff44]Protect[/color]",
	"Persuade": "[color=#ff44ff]Persuade[/color]",
	"Steal": "[color=#ffff44]Steal[/color]",
	"Haste": "[color=#ffff44]Haste[/color]",
	"Study": "[color=#44ffff]Study[/color]",
	"Pray": "[color=#ffffff]Pray[/color]",
	"Strength": "[color=orange]Strength[/color]",
	"Dexterity": "[color=yellow]Dexterity[/color]",
	"Intelligence": "[color=blue]Intelligence[/color]",
	"Wisdom": "[color=purple]Wisdom[/color]",
	"Constitution": "[color=brown]Constitution[/color]",
	"Charisma": "[color=pink]Charisma[/color]"
}

# --- SIGNALS ---
signal mission_started(squad, mission_node)
signal slot_clicked(unit_data) 

# --- REFERENCES (Internal UI Parts Only) ---
@onready var slot_container = $MainLayout/LeftPanel/LeftContent/SlotContainer
@onready var stat_hexagon = $MainLayout/LeftPanel/LeftContent/StatHexagon

# Buttons
@onready var deploy_button = $MainLayout/InfoPanel/VBoxContainer/DeployButton
@onready var close_button = $MainLayout/InfoPanel/VBoxContainer/TitleAndClose/CloseButton

# Text Labels
@onready var title_label = $MainLayout/InfoPanel/VBoxContainer/TitleAndClose/TitleLabel
@onready var description_label = $MainLayout/InfoPanel/VBoxContainer/DescriptionLabel

# --- DATA ---
var current_squad: Array = []
var target_mission: ActiveMission 
var max_slots_allowed: int = 3

# --- SETUP ---
func _ready():
	if deploy_button: deploy_button.pressed.connect(_on_deploy_pressed)
	if close_button: close_button.pressed.connect(_on_close_pressed)

func setup_mission(mission_node: ActiveMission):
	target_mission = mission_node
	var def = mission_node.def
	
	if title_label: title_label.text = def.title
	if description_label: 
		update_mission_text(def.description)
	
	max_slots_allowed = def.max_party_size
	
	# Tell Battlefield to limit selection
	if get_parent().has_method("set_max_selection"):
		get_parent().set_max_selection(max_slots_allowed)
	
	# Reset with empty squad
	update_squad_display([])

# --- UPDATE VISUALS ---
# UPDATED: Removed 'owned_items' argument
func update_squad_display(selected_units: Array):
	current_squad = selected_units
	
	# 1. Clear Old
	for child in slot_container.get_children():
		child.queue_free()
	
	# 2. Build New
	for i in range(max_slots_allowed):
		_create_single_slot(i)
	
	# 3. Update Hexagon
	recalculate_stats(selected_units)

# --- HELPER: Create Slot ---
func _create_single_slot(index: int):
	var unit_data = null
	if index < current_squad.size():
		unit_data = current_squad[index]
	
	var slot_panel = Panel.new()
	slot_panel.custom_minimum_size = Vector2(120, 160)
	slot_panel.mouse_filter = Control.MOUSE_FILTER_STOP 
	
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(120, 160)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	if unit_data:
		icon.modulate = Color(1, 1, 1, 1)
		if "icon" in unit_data and unit_data.icon:
			icon.texture = unit_data.icon
		elif "portrait" in unit_data and unit_data.portrait:
			icon.texture = unit_data.portrait
			
		# Connect Input
		slot_panel.gui_input.connect(_on_slot_gui_input.bind(unit_data))
		
	else:
		icon.modulate = Color(1, 1, 1, 0.2)
		
	slot_panel.add_child(icon)
	slot_container.add_child(slot_panel)

# --- INPUT HANDLER ---
func _on_slot_gui_input(event, unit_data):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(unit_data)

# --- MATH (UPDATED) ---
func recalculate_stats(selected_units: Array):
	var total_stats = [0, 0, 0, 0, 0, 0]
	
	for unit in selected_units:
		if unit != null:
			# NEW: Use get_total_stats() to include Equipment
			if unit.has_method("get_total_stats"):
				var u_stats = unit.get_total_stats()
				for i in range(6):
					total_stats[i] += u_stats[i]
			else:
				# Fallback
				if "strength" in unit:      total_stats[0] += unit.strength
				if "constitution" in unit:  total_stats[1] += unit.constitution
				if "dexterity" in unit:     total_stats[2] += unit.dexterity
				if "charisma" in unit:      total_stats[3] += unit.charisma
				if "wisdom" in unit:        total_stats[4] += unit.wisdom
				if "intelligence" in unit:  total_stats[5] += unit.intelligence

	if stat_hexagon and target_mission:
		# VISUAL IMPROVEMENT: Pass Requirements too so we see Red vs Green!
		stat_hexagon.update_stats(total_stats, [])

# --- ACTIONS ---
func _on_deploy_pressed():
	if target_mission == null: return
	
	var final_squad = []
	for unit in current_squad:
		if unit != null: final_squad.append(unit)
			
	if final_squad.is_empty(): return

	# UPDATED: Pass empty array for global items (items are on units now)
	target_mission.start_mission(final_squad, [])
	
	mission_started.emit(final_squad, target_mission)
	
	visible = false
	if get_parent().has_method("clear_selection"): get_parent().clear_selection()

func _on_close_pressed():
	visible = false
	current_squad = []
	if get_parent().has_method("clear_selection"): get_parent().clear_selection()

# --- TEXT UPDATE (UPDATED) ---
func update_mission_text(raw_text: String):
	var final_text = raw_text

	for word in KEYWORDS:

# Case-insensitive replacement would be better, but this is simple:

		final_text = final_text.replace(word, KEYWORDS[word])

		final_text = final_text.replace(word.to_lower(), KEYWORDS[word])

	description_label.text = final_text 

# If using RichTextLabel, ensure BBCode is enabled in Inspector!
