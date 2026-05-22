extends Control

# --- REFERENCES ---
@onready var rotator = $Rotator
@onready var bg_node = $Rotator/DiamondBG
@onready var icon_node = $Rotator/ItemIcon

var item_data: ItemData

func _ready():
	# We listen for clicks/hover on the Background (the solid visible part)
	# But we animate the Rotator (the container)
	if bg_node:
		bg_node.mouse_entered.connect(_on_mouse_entered)
		bg_node.mouse_exited.connect(_on_mouse_exited)

func setup(data: ItemData):
	item_data = data
	
	if item_data.icon:
		icon_node.texture = item_data.icon
		# Ensure icon stays upright despite Rotator's 45-degree tilt
		icon_node.rotation_degrees = -45 
	
	tooltip_text = "%s\n%s" % [item_data.item_name, item_data.description]

# --- ANIMATION ---
func _on_mouse_entered():
	# Pop the whole container
	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(rotator, "scale", Vector2(1.1, 1.1), 0.1)
	
	# Optional: Brighten the background slightly
	tween.parallel().tween_property(bg_node, "modulate", Color(1.2, 1.2, 1.2), 0.1)

func _on_mouse_exited():
	# Reset container
	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(rotator, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Reset color
	tween.parallel().tween_property(bg_node, "modulate", Color.WHITE, 0.1)
