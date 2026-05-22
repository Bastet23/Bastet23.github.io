extends UnitData
class_name PawnData

func _init():
	unit_class = "Pawn"
	
	# Flavor text goes here
	backstory = "A humble foot soldier dreaming of becoming royalty."
	
	# The actual mechanic explanation goes here
	ability1_text = "Class: When sold, passes its stats to the next recruit."
	

# OVERRIDE: Called when you sell this unit
func on_sold_transfer_stats() -> Dictionary:
	print("Pawn promoted! Passing stats...")
	return {
		"strength": strength,
		"dexterity": dexterity,
		"constitution": constitution,
		"intelligence": intelligence,
		"wisdom": wisdom,
		"charisma": charisma
	}
