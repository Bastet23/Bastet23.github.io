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
					RunManager.apply_expiration_penalty(50)
			return false
			
		State.TRAVEL_TO:
			current_state = State.WORKING
			
			# EVENT: Calculating Work Time
			var work_context = {"work_modifier": 1.0}
			MissionEvents.calculating_work_time.emit(self, work_context)
			
			time_left = def.base_work_time * work_context["work_modifier"]
			total_duration = time_left
			return true
			
		State.WORKING:
			resolve_outcome_geometric()
			current_state = State.READY_FOR_DEBRIEF
			time_left = 0
			return true
			
		State.TRAVEL_BACK:
			current_state = State.COMPLETED
			return true
			
	return false

# --- INTERACTIONS ---
func start_mission(assigned_squad: Array, p_items: Array):
	assigned_items = p_items
	current_state = State.TRAVEL_TO
	
	# 1. EVENT: Squad Assembling (Abilities can add clones here!)
	var assembly_context = {"squad": assigned_squad.duplicate()}
	MissionEvents.squad_assembling.emit(self, assembly_context)
	
	# Apply whatever the final assembled squad is!
	squad = assembly_context["squad"]
	
	# 2. EVENT: Calculating Travel Time (Outbound)
	var travel_context = {"travel_modifier": 1.0}
	MissionEvents.calculating_travel_time.emit(self, travel_context)
			
	time_left = def.base_travel_time * travel_context["travel_modifier"]
	total_duration = time_left

# --- PAYOUT ---
func finish_debrief():
	_payout_rewards()
	
	current_state = State.TRAVEL_BACK
	
	# EVENT: Calculating Travel Time (Return trip)
	var travel_context = {"travel_modifier": 1.0}
	MissionEvents.calculating_travel_time.emit(self, travel_context)
	
	time_left = def.base_travel_time * travel_context["travel_modifier"]
	total_duration = time_left

# --- MATH & OUTCOME ---
func resolve_outcome_geometric():
	# 1. Get Requirements
	var reqs = def.get_requirements_array()
	
	# 2. Sum up Player Stats
	var player_stats = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	
	for unit in squad:
		if unit.has_method("get_total_stats"):
			var u_stats = unit.get_total_stats()
			for i in range(6):
				player_stats[i] += u_stats[i]
		else:
			player_stats[0] += unit.strength
			player_stats[1] += unit.constitution
			player_stats[2] += unit.dexterity
			player_stats[3] += unit.charisma
			player_stats[4] += unit.wisdom
			player_stats[5] += unit.intelligence

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

	# 5. INITIAL DICE ROLL
	randomize()
	var roll = randi() % 100
	var initial_success = (roll < success_chance)
	
	var initial_log = "Success! (Area Covered: " + str(success_chance) + "%)" if initial_success else "Failure. (Area Covered: " + str(success_chance) + "%)"
	
	# 6. EVENT: Success Calculation (Abilities can intercept and reroll here!)
	var success_context = {
		"success_chance": success_chance,
		"is_successful": initial_success,
		"was_rerolled": false, 
		"result_log": initial_log
	}
	
	MissionEvents.calculating_success.emit(self, success_context)
	
	# 7. APPLY FINAL RESULTS
	is_success = success_context["is_successful"]
	was_rerolled = success_context["was_rerolled"]
	result_log = success_context["result_log"]
	
	# 8. EVENT: Mission Resolved (Let units know the final outcome)
	var resolve_context = {"is_success": is_success}
	MissionEvents.mission_resolved.emit(self, resolve_context)
	
func _payout_rewards():
	if not RunManager: return
	
	if is_success:
		# EVENT: Calculating Rewards
		var reward_context = {
			"gold_multiplier": 1.0,
			"flat_bonus_gold": 0,
			"inf_multiplier": 1.0,
			"flat_bonus_inf": 0
		}
		
		MissionEvents.calculating_rewards.emit(self, reward_context)
		
		var final_gold = int((def.reward_gold * reward_context["gold_multiplier"]) + reward_context["flat_bonus_gold"])
		var final_inf = int((def.reward_influence * reward_context["inf_multiplier"]) + reward_context["flat_bonus_inf"])
		
		if is_critical:
			final_gold *= 2
			final_inf *= 2
			
		RunManager.add_mission_rewards(final_gold, final_inf)
	else:
		if is_critical:
			RunManager.break_seal() # Lose a Life
		else:
			RunManager.apply_mission_penalty(20) # Lose Influence
