extends Control

# Signals that the Manager will listen to
signal mission_clicked(mission_logic)

# References
@onready var timer_ring = $TimerRing
@onready var button = $InteractButton

# The Logic Object this visual represents
var mission_logic: ActiveMission

func setup(logic: ActiveMission):
	mission_logic = logic
	# Connect the button click
	button.pressed.connect(_on_clicked)
	
	# Set initial visuals (e.g. Title Tooltip)
	button.tooltip_text = mission_logic.def.title

func _process(_delta):
	if not mission_logic: return
	
	# 1. Update the Ring (Visual Timer)
	# We calculate percentage: time_left / total_duration
	var percent = (mission_logic.time_left / mission_logic.total_duration) * 100
	timer_ring.value = percent
	
	# 2. Color Code the State
	match mission_logic.current_state:
		ActiveMission.State.AVAILABLE:
			timer_ring.tint_progress = Color.GREEN # Counting down to expire
		ActiveMission.State.TRAVEL_TO:
			timer_ring.tint_progress = Color.YELLOW # Traveling
		ActiveMission.State.WORKING:
			timer_ring.tint_progress = Color.ORANGE # Working
		ActiveMission.State.READY_FOR_DEBRIEF:
			timer_ring.tint_progress = Color.CYAN # Done! Click me!

func _on_clicked():
	emit_signal("mission_clicked", mission_logic)
