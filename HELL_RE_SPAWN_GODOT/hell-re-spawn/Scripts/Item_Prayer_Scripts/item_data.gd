class_name ItemData
extends Resource

@export_category("Visuals")
@export var item_name: String = "Unknown Relic"
@export var icon: Texture2D
@export_multiline var description: String = "A mysterious artifact."
@export var base_cost: int = 5

@export_category("Stat Bonuses")
@export var strength_bonus: int = 0
@export var constitution_bonus: int = 0
@export var dexterity_bonus: int = 0
@export var charisma_bonus: int = 0
@export var wisdom_bonus: int = 0
@export var intelligence_bonus: int = 0

@export_category("Special Abilities")
# Use this string in your gameplay loop! 
# Example: if unit.has_ability("fast_travel"): time_needed -= 1
@export var ability_id: String = "" 

func get_sell_cost() -> int:
	return int(base_cost / 2)
