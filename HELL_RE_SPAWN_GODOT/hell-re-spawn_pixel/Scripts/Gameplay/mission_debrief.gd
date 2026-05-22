extends Control

# Signal to tell the manager "We are done reading, send them home"
signal return_confirmed

# --- REFERENCES ---
@onready var title_label = $MainLayout/InfoPanel/VBoxContainer/TitleAndClose/TitleLabel
@onready var result_title = $MainLayout/InfoPanel/VBoxContainer/ResultTitle
@onready var result_log = $MainLayout/InfoPanel/VBoxContainer/RichTextLabel
@onready var return_button = $MainLayout/InfoPanel/VBoxContainer/ReturnButton

@onready var slot_container = $MainLayout/LeftPanel/LeftContent/SlotContainer
@onready var stat_hexagon = $MainLayout/LeftPanel/LeftContent/StatHexagon
var current_mission_logic: ActiveMission

func _ready():
	if return_button:
		return_button.pressed.connect(_on_return_pressed)
	if stat_hexagon:
		stat_hexagon.outcome_animation_finished.connect(_on_dot_finished)

# --- SETUP FUNCTION (UPDATED) ---
func setup(mission: ActiveMission):
	current_mission_logic = mission
	
	# 1. Setup Basic Text
	title_label.text = mission.def.title
	
	# 2. Setup Slots
	_fill_unit_slots(mission.squad)

	# 3. Setup Hexagon
	var total_stats = _calculate_total_stats(mission.squad)
	# Note: stat_hexagon handles the math/normalization internally now
	stat_hexagon.update_stats(total_stats, mission.def.get_requirements_array())

	# 4. HIDE RESULTS INITIALLY
	result_title.visible = false
	result_log.visible = false
	return_button.disabled = true
	
	# 5. START ANIMATION
	await get_tree().process_frame
	
	# --- REROLL DETECTION ---
	# We check the log text to see if a specific ability was triggered.
	# Ensure your ActiveMission logic adds the word "Reroll" or the Ability Name to result_log!
	var was_rerolled = false
	if "Reroll" in mission.result_log:
		was_rerolled = true
	
	# Pass both flags to the Hexagon
	stat_hexagon.play_outcome_animation(mission.is_success, was_rerolled)
	
#----unit dot animation
func _on_dot_finished():
	result_title.visible = true
	result_log.visible = true
	return_button.disabled = false
	
	result_log.text = current_mission_logic.result_log
	
	if current_mission_logic.is_success:
		result_title.text = "VICTORY"
		result_title.modulate = Color.GREEN
	else:
		result_title.text = "DEFEAT"
		result_title.modulate = Color.RED
	
# --- HELPER: FILL SLOTS ---
func _fill_unit_slots(squad: Array):
	for child in slot_container.get_children():
		child.queue_free()
		
	for unit in squad:
		var new_slot = Panel.new()
		new_slot.custom_minimum_size = Vector2(120, 160)
		new_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		# Create the Unit Icon node
		var icon = TextureRect.new()
		icon.name = "UnitIcon"
		icon.custom_minimum_size = Vector2(120, 160)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		# Assign portrait from unit data
		if "icon" in unit and unit.icon != null:
			icon.texture = unit.icon
		elif "portrait" in unit and unit.portrait != null:
			icon.texture = unit.portrait
			
		new_slot.add_child(icon)
		
		# Add Name Label
		var label = Label.new()
		label.text = unit.character_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_constant_override("outline_size", 4)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		
		new_slot.add_child(label)
		slot_container.add_child(new_slot)
		

# --- HELPER: CALCULATE STATS ---
func _calculate_total_stats(squad: Array) -> Array:
	var stats = [0, 0, 0, 0, 0, 0]
	
	for unit in squad:
		# Use the new helper we added to UnitData
		# This automatically sums Base Stats + Item 1 + Item 2
		if unit.has_method("get_total_stats"):
			var u_stats = unit.get_total_stats()
			for i in range(6):
				stats[i] += u_stats[i]
		else:
			# Fallback if you haven't updated all unit scripts yet
			stats[0] += unit.strength
			stats[1] += unit.constitution
			stats[2] += unit.dexterity
			stats[3] += unit.charisma
			stats[4] += unit.wisdom
			stats[5] += unit.intelligence
			
	return stats

func _on_return_pressed():
	visible = false
	emit_signal("return_confirmed")
