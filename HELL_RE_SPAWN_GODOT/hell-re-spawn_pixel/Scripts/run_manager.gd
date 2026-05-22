extends Node

# --- SIGNALS ---
signal resources_changed(money, influence, target)
signal seals_updated(current, max_seals)     # Updates the life/seal icons
signal round_won                             # Triggers the Shop
signal level_cleared                         # Triggers Layer transition
signal game_over(reason)
signal inventory_updated(items)               # NEW: Updates the equipment UI

# --- CAMPAIGN SETTINGS ---
var current_layer: int = 1
var current_round: int = 1
var max_rounds_per_layer: int = 3

# --- SEAL SYSTEM (LIVES) ---
var max_seals: int = 3
var current_seals: int = 3

# --- RESOURCES ---
var current_money: int = 100
var current_influence: int = 50 
var influence_target: int = 300 

# --- INVENTORY DATA ---
# This holds the actual UnitData resources for your team.
# The Battlefield syncs the Hand to this list so UnitDetailView can read it.
var owned_units: Array = [] 

# NEW: Items owned but NOT equipped
var owned_items: Array = [] 

# NEW: The Legacy System
# Stores floating stats for each class.
# Structure: { "Knight": {"strength": 2, "constitution": 1}, "Pawn": {"all": 5} }
var legacy_pools: Dictionary = {}

func _ready():
	# We rely on Battlefield.gd to populate 'owned_units' based on the cards in the hand.
	# Force UI update so bars, seals, and menus appear correctly at launch.
	call_deferred("request_ui_update")

# --- INVENTORY MANAGEMENT ---
func add_item(item: ItemData):
	owned_items.append(item)
	emit_signal("inventory_updated", owned_items)

func remove_item(item: ItemData):
	if item in owned_items:
		owned_items.erase(item)
		emit_signal("inventory_updated", owned_items)

# Call this when a unit is SOLD
func register_legacy_stats(unit: UnitData):
	print("Legacy: Inspecting " + unit.character_name)
	
	# 1. Create Ghost to find defaults
	var default_ref = unit.get_script().new()
	
	# 2. Calculate TOTAL Growth (Current - Base)
	var total_growth = {}
	var stats_to_check = ["strength", "constitution", "dexterity", "charisma", "wisdom", "intelligence"]
	
	for s in stats_to_check:
		var diff = unit.get(s) - default_ref.get(s)
		if diff > 0: total_growth[s] = diff
	
	default_ref = null # Cleanup
	
	if total_growth.is_empty(): return

	# 3. Identify VOLATILE (Risky) Stats
	# We ask the unit: "How many of these points are temporary/risky?"
	var volatile_stats = {}
	
	# Check for Bishop-style trackers
	if "bonus_str_total" in unit and unit.bonus_str_total > 0:
		volatile_stats["strength"] = unit.bonus_str_total
		
	if "bonus_con_total" in unit and unit.bonus_con_total > 0:
		volatile_stats["constitution"] = unit.bonus_con_total

	# 4. Identify PERMANENT Stats (Total - Volatile)
	var permanent_stats = {}
	
	for stat in total_growth:
		var total_val = total_growth[stat]
		var vol_val = volatile_stats.get(stat, 0) # Default to 0 if not found
		
		# If we have more growth than what is marked volatile, the rest is permanent
		var perm_val = total_val - vol_val
		if perm_val > 0:
			permanent_stats[stat] = perm_val
			
		# Ensure we store the volatile amount correctly (clamped to total growth just in case)
		if vol_val > 0:
			volatile_stats[stat] = min(vol_val, total_val)

	# 5. Store in Pools
	var category = unit.unit_class
	if category == "Pawn": category = "Universal"
	
	_add_to_legacy_pool(category, permanent_stats, volatile_stats)

func _add_to_legacy_pool(category: String, perm: Dictionary, vol: Dictionary):
	if not legacy_pools.has(category):
		legacy_pools[category] = { "perm": {}, "vol": {} }
	
	var pool = legacy_pools[category]
	
	# Merge Permanent
	for k in perm:
		if not pool["perm"].has(k): pool["perm"][k] = 0
		pool["perm"][k] += perm[k]
		
	# Merge Volatile
	for k in vol:
		if not pool["vol"].has(k): pool["vol"][k] = 0
		pool["vol"][k] += vol[k]
		
	print("Updated Pool [%s]: Perm %s | Vol %s" % [category, pool["perm"], pool["vol"]])

# Call this when Buying
func consume_legacy_stats(new_unit: UnitData):
	var target_class = new_unit.unit_class
	var final_perm = {}
	var final_vol = {}
	
	# Helper to merge dictionaries
	var merge_stats = func(source_pool):
		for k in source_pool["perm"]:
			final_perm[k] = final_perm.get(k, 0) + source_pool["perm"][k]
		for k in source_pool["vol"]:
			final_vol[k] = final_vol.get(k, 0) + source_pool["vol"][k]

	# 1. Absorb Class-Specific
	if legacy_pools.has(target_class):
		merge_stats.call(legacy_pools[target_class])
		legacy_pools.erase(target_class)
		
	# 2. Absorb Universal (Pawn)
	# NOTE: Pawns don't have risky stats, so their "Volatile" bucket is likely empty,
	# but we merge it anyway to be safe.
	if legacy_pools.has("Universal"):
		merge_stats.call(legacy_pools["Universal"])
		legacy_pools.erase("Universal")

	# 3. Send to Unit
	if not final_perm.is_empty() or not final_vol.is_empty():
		new_unit.receive_legacy_stats(final_perm, final_vol)

func _apply_stats_to_unit(unit: UnitData, stats: Dictionary):
	if stats.has("strength"): unit.strength += stats["strength"]
	if stats.has("constitution"): unit.constitution += stats["constitution"]
	if stats.has("dexterity"): unit.dexterity += stats["dexterity"]
	if stats.has("charisma"): unit.charisma += stats["charisma"]
	if stats.has("wisdom"): unit.wisdom += stats["wisdom"]
	if stats.has("intelligence"): unit.intelligence += stats["intelligence"]

# --- INITIALIZATION ---
# (Kept as a helper if you ever need to generate data manually, but unused by default now)
func _initialize_starting_squad():
	print("DEBUG: RunManager initializing starting squad...")
	var unit1 = KnightData.new()
	unit1.character_name = "Sir Alric"
	owned_units.append(unit1)
	
# --- SEAL LOGIC ---
func break_seal():
	current_seals -= 1
	print("SEAL BROKEN! Remaining: ", current_seals)
	emit_signal("seals_updated", current_seals, max_seals)
	
	if current_seals <= 0:
		emit_signal("game_over", "The Council has revoked your authority. (All Seals Broken)")

func reset_seals():
	current_seals = max_seals
	emit_signal("seals_updated", current_seals, max_seals)

# --- ROUND PROGRESSION ---
func complete_round():
	print("Round %s Complete!" % current_round)
	current_round += 1
	
	if current_round > max_rounds_per_layer:
		complete_layer()
	else:
		emit_signal("round_won") # Opens Shop

func complete_layer():
	print("LAYER %s CONQUERED!" % current_layer)
	current_layer += 1
	current_round = 1
	
	# Increase Difficulty Scaling
	influence_target += 200 
	
	emit_signal("level_cleared") 

# --- RESOURCE LOGIC ---
# Updated: Purely handles math. No unit logic here.
func add_mission_rewards(money_reward: int, influence_reward: int):
	current_money += money_reward
	current_influence += influence_reward
	print("VICTORY! Gained %s Gold, %s Inf." % [money_reward, influence_reward])
	emit_signal("resources_changed", current_money, current_influence, influence_target)

func apply_mission_penalty(influence_penalty: int):
	current_influence -= influence_penalty
	print("FAILURE. Lost %s Inf." % influence_penalty)
	emit_signal("resources_changed", current_money, current_influence, influence_target)
	check_lose_condition()

func apply_expiration_penalty(influence_penalty: int):
	current_influence -= influence_penalty
	print("EXPIRED. Lost %s Inf." % influence_penalty)
	emit_signal("resources_changed", current_money, current_influence, influence_target)
	check_lose_condition()

func check_lose_condition():
	if current_influence <= 0:
		emit_signal("game_over", "You have lost all respect in Hell. (Influence 0)")

# --- UI HELPERS ---
func request_ui_update():
	emit_signal("resources_changed", current_money, current_influence, influence_target)
	emit_signal("seals_updated", current_seals, max_seals)
