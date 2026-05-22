class_name BishopData
extends UnitData

# We track exactly how much we have added to each stat
# so we can remove the correct amount on failure.
var bonus_str_total: int = 0
var bonus_con_total: int = 0

func _init():
	unit_class = "Bishop"
	
	backstory = "A devout follower who believes victory is the only proof of divine love."
	
	# Explains the mechanics in the Detail View
	ability1_text = "Class: Gains +1 STR or CON after every successful mission. All bonuses are lost if a mission fails."
	
func receive_legacy_stats(permanent: Dictionary, volatile: Dictionary):
	# 1. Let the base class apply ALL the numbers to Strength/Constitution
	super.receive_legacy_stats(permanent, volatile)
	
	# 2. Bishop Special: Track the Volatile portion so we can lose it later
	if volatile.has("strength"):
		bonus_str_total += volatile["strength"]
		print("Bishop: %s Strength marked as volatile." % volatile["strength"])
		
	if volatile.has("constitution"):
		bonus_con_total += volatile["constitution"]
		print("Bishop: %s Constitution marked as volatile." % volatile["constitution"])
