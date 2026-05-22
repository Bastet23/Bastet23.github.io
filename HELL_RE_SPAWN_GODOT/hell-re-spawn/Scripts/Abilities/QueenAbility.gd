class_name QueenAbility
extends Ability

func _connect_signals():
	# Listen for the absolute final phase of the mission
	MissionEvents.mission_resolved.connect(_on_mission_resolved)

func _on_mission_resolved(mission: ActiveMission, context: Dictionary):
	# 1. Was my specific Queen on this mission?
	if not owner_unit in mission.squad:
		return
		
	# 2. Toggle the state memory variable safely
	if "stats_flipped" in owner_unit:
		owner_unit.stats_flipped = !owner_unit.stats_flipped
	
	# 3. The Swap Logic applied directly to the owner!
	var t_str = owner_unit.strength
	var t_dex = owner_unit.dexterity
	var t_con = owner_unit.constitution
	
	owner_unit.strength = owner_unit.intelligence
	owner_unit.dexterity = owner_unit.wisdom
	owner_unit.constitution = owner_unit.charisma
	
	owner_unit.intelligence = t_str
	owner_unit.wisdom = t_dex
	owner_unit.charisma = t_con
	
	print(owner_unit.character_name + " (Queen) stats flipped! Strength is now: ", owner_unit.strength)
