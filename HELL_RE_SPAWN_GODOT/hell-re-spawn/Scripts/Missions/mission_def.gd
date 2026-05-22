class_name MissionDefinition
extends Resource

@export_group("Mission Details")
@export var title: String = "Mission Title"
@export_multiline var description: String = "Mission Description"
@export var icon: Texture2D
@export var max_party_size: int = 3
@export var is_critical: bool = false 

@export_group("Timing")
@export var base_work_time: float = 5.0
@export var base_travel_time: float = 2.0
@export var expiration_time: float = 20.0

@export_group("Requirements")
# Individual variables for the Inspector
@export var req_strength: int = 1
@export var req_constitution: int = 1
@export var req_dexterity: int = 1
@export var req_charisma: int = 1
@export var req_wisdom: int = 1
@export var req_intelligence: int = 1

@export_group("Rewards")
@export var reward_gold: int = 0
@export var reward_influence: int = 20

# --- ADD THIS VARIABLE ---
@export_group("Penalties")
@export var influence_penalty: int = 10


# --- HELPER FUNCTION ---
# This allows you to get the array manually if needed
func get_requirements_array() -> Array:
	return [
		req_strength, 
		req_constitution, 
		req_dexterity, 
		req_charisma, 
		req_wisdom, 
		req_intelligence
	]

# --- COMPATIBILITY PROPERTY ---
# IMPORTANT: This must be un-indented (touching the left side)
# This allows other scripts to access "def.stat_requirements" like before
var stat_requirements: Array:
	get:
		return [
			req_strength, 
			req_constitution, 
			req_dexterity, 
			req_charisma, 
			req_wisdom, 
			req_intelligence
		]
