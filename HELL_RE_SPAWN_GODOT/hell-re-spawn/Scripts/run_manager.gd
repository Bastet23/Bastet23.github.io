extends Node

# --- SIGNALS ---
signal resources_changed(money, influence, target)
signal seals_updated(current, max_seals)     # Updates the life/seal icons
signal round_won                             # Triggers the Shop
signal level_cleared                         # Triggers Layer transition
signal game_over(reason)
signal inventory_updated(items)              # Updates the equipment UI

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

# Items owned but NOT equipped
var owned_items: Array = [] 

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
# Purely handles math. No unit logic here.
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
