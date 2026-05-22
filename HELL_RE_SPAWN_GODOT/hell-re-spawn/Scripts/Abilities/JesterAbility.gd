class_name JesterAbility
extends Ability

func _connect_signals():
	# Listen for travel time calculations
	MissionEvents.calculating_travel_time.connect(_on_calculating_travel_time)

func _on_calculating_travel_time(mission: ActiveMission, context: Dictionary):
	# 1. Is my specific Jester on this mission?
	if not owner_unit in mission.squad:
		return
		
	# 2. Prevent double-dipping! We only want this to happen on the way TO the mission, 
	# not on the way back during TRAVEL_BACK.
	if mission.current_state != ActiveMission.State.TRAVEL_TO:
		return

	# 3. Roll the 25% chance!
	randomize()
	if (randi() % 100) < 25:
		print(">> Jester Ear Worm Triggered! Party slowed, but buffed.")
		
		# Hack the dictionary to make travel 50% slower!
		context["travel_modifier"] *= 1.5
		
		# Buff the teammates!
		_apply_party_buffs(mission.squad)

func _apply_party_buffs(squad: Array):
	for unit in squad:
		# Don't buff self, only teammates (and ignore null slots)
		if unit != owner_unit and unit != null:
			_buff_random_stat(unit)

func _buff_random_stat(unit: UnitData):
	# Pick one of the 6 stats randomly
	var roll = randi() % 6
	match roll:
		0: unit.strength += 1
		1: unit.dexterity += 1
		2: unit.constitution += 1
		3: unit.intelligence += 1
		4: unit.wisdom += 1
		5: unit.charisma += 1
		
	print("   -> " + unit.character_name + " gained +1 stat from Jester!")
