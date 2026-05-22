extends Control

# We pass 'self' so the inventory knows where this specific pillow is located
signal slot_clicked(item_data, slot_node)
signal item_swapped # NEW: Alerts the inventory that a drop happened!

var stored_item_data: Resource = null
@onready var item_icon = $ItemIcon

func _ready():
	# Hide the icon initially
	if item_icon: item_icon.visible = false
	
	# Listen for clicks!
	gui_input.connect(_on_gui_input)

const DEFAULT_ICON = preload("res://Sprites/Items/sword.webp") 

func set_item(new_item_data):
	stored_item_data = new_item_data
	
	if stored_item_data != null:
		if "icon" in stored_item_data and stored_item_data.icon != null:
			item_icon.texture = stored_item_data.icon
		else:
			# If you forgot to assign an icon, use the default!
			item_icon.texture = DEFAULT_ICON 
			
		item_icon.visible = true
	else:
		item_icon.texture = null
		item_icon.visible = false

# --- INTERACTION ---
func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Only emit the signal if there is actually an item sitting on this pillow!
		if stored_item_data != null:
			slot_clicked.emit(stored_item_data, self)
			
# --- DRAG AND DROP SYSTEM ---

# 1. Picking the item up
func _get_drag_data(at_position):
	if stored_item_data == null:
		return null # Nothing to pick up!
		
	# Create a "Ghost" image to follow the mouse
	var preview_texture = TextureRect.new()
	preview_texture.texture = item_icon.texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.custom_minimum_size = Vector2(64, 64) # Adjust if your icons are bigger/smaller
	preview_texture.modulate.a = 0.7 # Make it slightly transparent
	
	# Center the ghost image on the mouse cursor
	var preview_control = Control.new()
	preview_control.add_child(preview_texture)
	preview_texture.position = -preview_texture.custom_minimum_size / 2
	set_drag_preview(preview_control)
	
	# Package the data to send to the drop zone
	return {
		"item_data": stored_item_data,
		"source_slot": self # We pass 'self' so we know where it came from
	}

# 2. Checking if we are allowed to drop it here
func _can_drop_data(at_position, data):
	# Only say 'yes' if the data is our specific dictionary format
	return typeof(data) == TYPE_DICTIONARY and data.has("item_data") and data.has("source_slot")

# 3. Dropping the item

func _drop_data(at_position, data):
	var source_slot = data["source_slot"]
	var incoming_item = data["item_data"]
	
	# Swap the items visually
	source_slot.set_item(self.stored_item_data)
	self.set_item(incoming_item)
	
	# Hide the tooltip so it doesn't get stuck
	if get_node_or_null("../../ItemToolTip"):
		get_node("../../ItemToolTip").visible = false
		
	# NEW: Ring the alarm! Tell both slots to broadcast that an item moved
	self.item_swapped.emit()
	source_slot.item_swapped.emit()
