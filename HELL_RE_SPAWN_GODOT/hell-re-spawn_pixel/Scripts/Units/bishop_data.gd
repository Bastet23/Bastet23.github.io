extends UnitData
class_name BishopData

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

# Called by Mission Manager
func on_mission_complete(is_success: bool):
	if is_success:
		_apply_random_bonus()
	else:
		_reset_bonuses()

func _apply_random_bonus():
	randomize()
	
	# Coin Flip: 0 = Strength, 1 = Constitution
	if randi() % 2 == 0:
		strength += 1
		bonus_str_total += 1
		print(character_name + " (Bishop) prayer answered: +1 STRENGTH")
	else:
		constitution += 1
		bonus_con_total += 1
		print(character_name + " (Bishop) prayer answered: +1 CONSTITUTION")

func _reset_bonuses():
	if bonus_str_total == 0 and bonus_con_total == 0:
		return # Nothing to reset
		
	print(character_name + " failed. The streak is broken.")
	
	# Remove exactly what we added
	strength -= bonus_str_total
	constitution -= bonus_con_total
	
	# Reset trackers
	bonus_str_total = 0
	bonus_con_total = 0
