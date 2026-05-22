extends Control

signal prayer_selected(prayer_data, prayer_node)
signal interaction_requested(prayer_node)

@export var prayer_data: Resource

@onready var item_icon = $PrayerIcon
@onready var diamond_bg = $DiamondBG
@onready var action_btn = $ActionBtn
@onready var action_btn_shadow = $ActionBtnShadow

func _ready():
	gui_input.connect(_on_gui_input)
	
	if action_btn:
		action_btn.visible = false
		action_btn.pressed.connect(_on_interaction_pressed)
	if action_btn_shadow:
		action_btn_shadow.visible = false
		
	if prayer_data:
		update_visuals()

func update_visuals():
	if not prayer_data: return
	if "icon" in prayer_data and prayer_data.icon:
		item_icon.texture = prayer_data.icon

# --- INTERACTION ---
func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		prayer_selected.emit(prayer_data, self)

func show_interaction_button(text: String, price: int = -1, is_disabled: bool = false):
	if not action_btn: return
	if price >= 0:
		action_btn.text = text + " (" + str(price) + ")"
	else:
		action_btn.text = text
	action_btn.disabled = is_disabled
	action_btn.visible = true
	if action_btn_shadow:
		action_btn_shadow.visible = true

func hide_interaction_button():
	if action_btn: action_btn.visible = false
	if action_btn_shadow: action_btn_shadow.visible = false

func _on_interaction_pressed():
	interaction_requested.emit(self)
