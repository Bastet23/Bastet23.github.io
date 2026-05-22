class_name QueenData
extends UnitData

# State variable unique to the Queen
var stats_flipped: bool = false

func _init():
	unit_class = "Queen" 
	
	backstory = "A ruler of two faces. She navigates the court as effortlessly as the battlefield."
	
	# The mechanics text
	ability1_text = "Class: Swaps her Physical (STR/DEX/CON) and Mental (INT/WIS/CHA) stats after every mission."
