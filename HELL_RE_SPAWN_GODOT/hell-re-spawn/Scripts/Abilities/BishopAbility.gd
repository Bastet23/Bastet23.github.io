class_name BishopAbility
extends Ability

func _connect_signals():
	# Listen for the final outcome of any mission
	MissionEvents.mission_resolved.connect(_on_mission_resolved)

func _on_mission_resolved(mission: ActiveMission, context: Dictionary):
	# 1. Make sure my owner is actually on this mission!
	if not owner_unit in mission.squad:
		return
		
	# 2. Make sure the owner actually has the volatile tracking variables 
	# (Safety check in case you give this ability to a non-Bishop!)
	if not "bonus_str_total" in owner_unit or not "bonus_con_total" in owner_unit:
		return
		
	# 3. Read the outcome from the context dictionary!
	if context["is_success"]:
		_apply_random_bonus()
	else:
		_reset_bonuses()

func _apply_random_bonus():
	randomize()
	
	# Coin Flip: 0 = Strength, 1 = Constitution
	if randi() % 2 == 0:
		owner_unit.strength += 1
		owner_unit.bonus_str_total += 1
		print(owner_unit.character_name + " (Bishop) prayer answered: +1 STRENGTH")
	else:
		owner_unit.constitution += 1
		owner_unit.bonus_con_total += 1
		print(owner_unit.character_name + " (Bishop) prayer answered: +1 CONSTITUTION")

func _reset_bonuses():
	if owner_unit.bonus_str_total == 0 and owner_unit.bonus_con_total == 0:
		return # Nothing to reset
		
	print(owner_unit.character_name + " failed. The streak is broken.")
	
	# Remove exactly what we added
	owner_unit.strength -= owner_unit.bonus_str_total
	owner_unit.constitution -= owner_unit.bonus_con_total
	
	# Reset trackers
	owner_unit.bonus_str_total = 0
	owner_unit.bonus_con_total = 0
