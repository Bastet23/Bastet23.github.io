class_name PrayerData
extends Resource

@export_category("Visuals")
@export var prayer_name: String = "Prayer of Strength"
@export var icon: Texture2D
@export_multiline var description: String = "Grants +1 Strength permanently."
@export var base_cost: int = 3

@export_category("Effect")
# A dropdown menu in the Inspector to choose which stat to buff
@export_enum("strength", "constitution", "dexterity", "charisma", "wisdom", "intelligence") var stat_to_boost: String = "strength"
@export var boost_amount: int = 1

func get_sell_cost() -> int:
	return int(base_cost / 2)

# This will be called when the player drags the scroll onto a card
func apply_prayer_to(unit: UnitData):
	if stat_to_boost in unit:
		var current_val = unit.get(stat_to_boost)
		unit.set(stat_to_boost, current_val + boost_amount)
		print(prayer_name + " applied! " + unit.character_name + " gained " + str(boost_amount) + " " + stat_to_boost.capitalize())
