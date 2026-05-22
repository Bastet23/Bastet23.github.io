extends UnitData
class_name PrincessData

func _init():
	unit_class = "Princess"
	
	backstory = "Born to rule, she refuses to accept failure as an option."
	
	# The mechanics text
	ability1_text = "Class: Rerolls the dice if a solo mission fails."

# OVERRIDE: Check the debrief condition
func should_force_reroll(squad: Array, is_success: bool) -> bool:
	# Condition 1: Must be Solo
	# (Note: This assumes the squad array passed by ActiveMission has nulls removed, which it should)
	if squad.size() != 1:
		return false
		
	# Condition 2: Must have failed
	if is_success:
		return false
		
	print(">> Princess demands a reroll!")
	return true
