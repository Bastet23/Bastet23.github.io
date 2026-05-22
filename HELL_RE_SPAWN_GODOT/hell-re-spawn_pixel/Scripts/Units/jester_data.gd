extends UnitData
class_name JesterData



func _init():
	unit_class = "Jester"
	
	backstory = "A chaotic performer who knows that a good laugh is worth waiting for."
	
	# The mechanics text
	ability1_text = "Class: 25% chance to delay travel by 50%, but grants +1 random stat to all teammates."

# OVERRIDE: We use the Travel Time hook to trigger the effect
func get_travel_time_modifier(squad: Array) -> float:
	randomize()
	
	# 25% Chance to trigger Ear Worm
	if (randi() % 100) < 25:
		print(">> Jester Ear Worm Triggered! Party slowed, but buffed.")
		_apply_party_buffs(squad)
		return 1.5 # 50% Slower (Bad)
		
	return 1.0 # Normal speed

func _apply_party_buffs(squad: Array):
	for unit in squad:
		# Don't buff self, only teammates (and ignore null slots)
		if unit != self and unit != null:
			_buff_random_stat(unit)

func _buff_random_stat(unit: UnitData):
	# Pick one of the 6 stats randomly
	var roll = randi() % 6
	match roll:
		0: unit.strength += 1
		1: unit.dexterity += 1
		2: unit.constitution += 1
		3: unit.intelligence += 1
		4: unit.wisdom += 1
		5: unit.charisma += 1
	print("   -> " + unit.character_name + " gained +1 stat from Jester!")
