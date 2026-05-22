class_name PrincessRerollAbility
extends Ability

func _connect_signals():
	# Listen to the global megaphone for the success calculation phase!
	MissionEvents.calculating_success.connect(_on_calculating_success)

func _on_calculating_success(mission: ActiveMission, context: Dictionary):
	# 1. Is my specific Princess actually on this mission?
	if not owner_unit in mission.squad:
		return
		
	# 2. Is she alone? (Solo mission condition)
	if mission.squad.size() > 1:
		return
		
	# 3. Did the mission already succeed?
	if context["is_successful"]:
		return 
		
	# --- THE PRINCESS DEMANDS A REROLL ---
	print(">> Princess " + owner_unit.character_name + " demands a reroll!")
	context["was_rerolled"] = true
	
	# Roll the dice again using the exact same success chance
	var new_roll = randi() % 100
	if new_roll < context["success_chance"]:
		# WE HACK THE DICTIONARY! 
		# When this function finishes, ActiveMission reads these new values!
		context["is_successful"] = true
		context["result_log"] = "Saved by the Princess! (Reroll Success)"
	else:
		context["result_log"] = "Princess Reroll Failed."
