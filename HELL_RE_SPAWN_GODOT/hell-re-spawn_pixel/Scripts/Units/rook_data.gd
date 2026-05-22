extends UnitData
class_name RookData

func _init():
	unit_class = "Rook"
	
	backstory = "A sturdy castle siege engine converted for transport. It moves best when supporting a column."
	
	# The mechanics text
	ability1_text = "Class: When deployed with teammates (Squad size > 1), Travel time is reduced by 50% and Work time by 20%."

# OVERRIDE: Urgent Delivery (Faster Travel if NOT Solo)
func get_travel_time_modifier(squad: Array) -> float:
	# Note: Squad size > 1 means 2 or 3 units
	if squad.size() > 1:
		print(">> Rook Urgent Delivery: Travel speed boosted!")
		return 0.5 # 50% Time
	return 1.0

# OVERRIDE: Urgent Delivery (Faster Work if NOT Solo)
func get_work_time_modifier(squad: Array) -> float:
	if squad.size() > 1:
		print(">> Rook Urgent Delivery: Work speed boosted!")
		return 0.8 # 80% Time
	return 1.0
