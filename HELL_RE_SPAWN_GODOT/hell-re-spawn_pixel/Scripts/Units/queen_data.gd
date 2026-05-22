extends UnitData
class_name QueenData

# State variable unique to the Queen
var stats_flipped: bool = false

func _init():
	unit_class = "Queen" 
	
	backstory = "A ruler of two faces. She navigates the court as effortlessly as the battlefield."
	
	# The mechanics text
	ability1_text = "Class: Swaps her Physical (STR/DEX/CON) and Mental (INT/WIS/CHA) stats after every mission."

# OVERRIDE the hook from the base script
func on_mission_complete(_is_success: bool):
	_toggle_stats()

func _toggle_stats():
	stats_flipped = !stats_flipped
	
	# The Swap Logic
	var t_str = strength
	var t_dex = dexterity
	var t_con = constitution
	
	strength = intelligence
	dexterity = wisdom
	constitution = charisma
	
	intelligence = t_str
	wisdom = t_dex
	charisma = t_con
	
	print(character_name + " (Queen) stats flipped! Strength is now: ", strength)
