extends UnitData
class_name KnightData

func _init():
	unit_class = "Knight"
	
	backstory = "A heavily armored rider who believes honor is found in single combat."
	
	# Describes the mechanics provided in your code
	ability1_text = "Class: When deployed alone, Travel time is reduced by 50% and Work time by 20%."

# OVERRIDE: Gallop (Faster Travel if Solo)
func get_travel_time_modifier(squad: Array) -> float:
	# Note: 'squad' usually has nulls filtered out by the time it reaches here.
	if squad.size() == 1:
		print(">> Knight Gallop: Travel speed boosted!")
		return 0.5 # 50% Time
	return 1.0

# OVERRIDE: Gallop (Faster Work if Solo)
func get_work_time_modifier(squad: Array) -> float:
	if squad.size() == 1:
		print(">> Knight Gallop: Work speed boosted!")
		return 0.8 # 80% Time
	return 1.0
