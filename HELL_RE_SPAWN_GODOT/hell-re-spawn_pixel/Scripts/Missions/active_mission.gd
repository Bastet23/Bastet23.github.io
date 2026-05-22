class_name ActiveMission
extends RefCounted

# --- STATES ---
enum State {
	AVAILABLE,        # On map, waiting
	TRAVEL_TO,        # Moving to site
	WORKING,          # Doing the job
	READY_FOR_DEBRIEF,# Job done, waiting for player click
	TRAVEL_BACK,      # Returning home
	COMPLETED         # Done, safe to delete
}

# --- DATA ---
var def: MissionDefinition
var squad: Array = []
var assigned_items: Array = []
var map_spot_index: int = -1
var map_marker_node: Node2D = null

# LOGIC OVERRIDE: Allows Manager to force critical status
var is_critical: bool = false 

# --- STATE TRACKING ---
var current_state = State.AVAILABLE
var time_left: float = 0.0
var total_duration: float = 0.0

# --- RESULTS ---
var is_success: bool = false
var was_rerolled: bool = false # True if a reroll was ATTEMPTED
var result_log: String = ""
var success_chance: int = 0

# --- CONSTRUCTOR ---
func _init(p_def: MissionDefinition, p_spot_index: int):
	def = p_def
	map_spot_index = p_spot_index
	time_left = def.expiration_time
	total_duration = def.expiration_time
	is_critical = def.is_critical

# --- MAIN LOOP ---
func update(delta: float) -> bool:
	time_left -= delta
	if time_left <= 0:
		return _advance_state()
	return false

# --- STATE MACHINE ---
func _advance_state() -> bool:
	match current_state:
		State.AVAILABLE:
			if RunManager:
				# --- UPDATED EXPIRATION LOGIC ---
				if is_critical:
					print("CRITICAL MISSION EXPIRED! SEAL BROKEN.")
					RunManager.break_seal() # Lose a Life directly
				else:
					# Standard penalty for normal missions
					RunManager.apply_expiration_penalty(50)
			return false
			
		State.TRAVEL_TO:
			current_state = State.WORKING
			time_left = def.base_work_time
			total_duration = def.base_work_time
			return true
			
		State.WORKING:
			resolve_outcome_geometric(assigned_items)
			current_state = State.READY_FOR_DEBRIEF
			time_left = 0
			return true
			
		State.TRAVEL_BACK:
			current_state = State.COMPLETED
			return true
			
	return false

# --- INTERACTIONS ---
func start_mission(assigned_squad: Array, p_items: Array):
	squad = assigned_squad
	assigned_items = p_items
	current_state = State.TRAVEL_TO
	
	var travel_mod = 1.0
	for unit in squad:
		if unit.has_method("get_travel_time_modifier"):
			travel_mod *= unit.get_travel_time_modifier(squad)
			
	time_left = def.base_travel_time * travel_mod
	total_duration = time_left

# --- PAYOUT ---
func finish_debrief():
	
	_payout_rewards()
	
	current_state = State.TRAVEL_BACK
	time_left = def.base_travel_time
	total_duration = time_left

# --- MATH & OUTCOME ---
func resolve_outcome_geometric(global_items: Array):
	# 1. Get Requirements
	var reqs = def.get_requirements_array()
	
	# 2. Sum up Player Stats
	var player_stats = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	
	for unit in squad:
		# Use the new helper for equipment stats
		if unit.has_method("get_total_stats"):
			var u_stats = unit.get_total_stats()
			for i in range(6):
				player_stats[i] += u_stats[i]
		else:
			# Fallback
			player_stats[0] += unit.strength
			player_stats[1] += unit.constitution
			player_stats[2] += unit.dexterity
			player_stats[3] += unit.charisma
			player_stats[4] += unit.wisdom
			player_stats[5] += unit.intelligence

	# Note: We ignore 'global_items' now since items are equipped on units

	# 3. Calculate Area Coverage
	var total_required_area = 0.0
	var total_covered_area = 0.0
	
	for i in range(6):
		var next_i = (i + 1) % 6
		var r1 = reqs[i]
		var r2 = reqs[next_i]
		var s1 = player_stats[i]
		var s2 = player_stats[next_i]
		
		total_required_area += (r1 * r2)
		total_covered_area += (min(s1, r1) * min(s2, r2))

	# 4. Final Percentage
	if total_required_area <= 0:
		success_chance = 100
	else:
		success_chance = int((total_covered_area / total_required_area) * 100)
	
	success_chance = clampi(success_chance, 0, 100)
	print("Geometric Result: " + str(success_chance) + "% Coverage")

	# 5. DETERMINE OUTCOME
	randomize()
	var roll = randi() % 100
	var outcome_secured = false
	
	if roll < success_chance:
		outcome_secured = true
		result_log = "Success! (Area Covered: " + str(success_chance) + "%)"
	else:
		outcome_secured = false
		result_log = "Failure. (Area Covered: " + str(success_chance) + "%)"
		
		# --- PRINCESS REROLL LOGIC ---
		for unit in squad:
			if unit.has_method("should_force_reroll"):
				if unit.should_force_reroll(squad, false):
					
					was_rerolled = true 
					
					var new_roll = randi() % 100
					if new_roll < success_chance:
						outcome_secured = true
						result_log = "Saved by the Princess! (Reroll Success)"
					else:
						result_log = "Reroll Failed."
					break 
	
	# 6. SAVE RESULT
	is_success = outcome_secured
	
	for unit in squad:
		if unit.has_method("on_mission_complete"):
			unit.on_mission_complete(is_success)
			print("Ability Triggered: ", unit.character_name, " Success: ", is_success)
	
func _payout_rewards():
	if not RunManager: return
	
	if is_success:
		var gold = def.reward_gold
		var inf = def.reward_influence
		
		if is_critical:
			gold *= 2
			inf *= 2
			
		RunManager.add_mission_rewards(gold, inf)
	else:
		# FAILURE LOGIC
		if is_critical:
			RunManager.break_seal() # Lose a Life
		else:
			RunManager.apply_mission_penalty(20) # Lose Influence
