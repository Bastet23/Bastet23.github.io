class_name UnitData
extends Resource

# --- IDENTITY ---
@export var character_name: String = "Unnamed Unit"
@export var unit_class: String = "Villager"
@export var portrait: Texture2D # Big Art (Left Panel)
@export var icon: Texture2D     # Small Icon (Battlefield Cards)

# --- LORE & ABILITIES ---
@export_multiline var backstory: String = "A wanderer from distant lands..."
@export_multiline var ability1_text: String = "Passive: None"
@export_multiline var ability2_text: String = ""

# --- ABILITIES (Backpack) ---
# You drop the .tres files in here in the Godot Inspector!
@export var mission_abilities: Array[Resource] = []

# --- RUNTIME ABILITIES ---
# This holds the unique, awakened copies during gameplay
var active_abilities: Array = []

# --- BASE STATS (Defaults start at 1) ---
@export_group("Base Stats")
@export var strength: int = 1
@export var constitution: int = 1
@export var dexterity: int = 1
@export var charisma: int = 1
@export var wisdom: int = 1
@export var intelligence: int = 1

@export var base_cost: int = 2

# --- NEW: BASE STAT MEMORY ---
var _base_stats_saved: bool = false
var base_strength: int = 0
var base_constitution: int = 0
var base_dexterity: int = 0
var base_charisma: int = 0
var base_wisdom: int = 0
var base_intelligence: int = 0

func initialize_base_stats():
	if _base_stats_saved: return
	base_strength = strength
	base_constitution = constitution
	base_dexterity = dexterity
	base_charisma = charisma
	base_wisdom = wisdom
	base_intelligence = intelligence
	_base_stats_saved = true
	
	# --- WAKE UP ABILITIES ---
	_setup_abilities()

func _setup_abilities():
	active_abilities.clear()
	for ability_res in mission_abilities:
		if ability_res != null:
			# 1. Make a unique copy so multiple units don't share the same brain
			var unique_ability = ability_res.duplicate()
			# 2. Tell the ability who it belongs to and connect it to the megaphone
			unique_ability.setup(self)
			# 3. Store it safely
			active_abilities.append(unique_ability)

# Returns ONLY the stats earned during the run
func get_earned_legacy_stats() -> Dictionary:
	var earned = {}
	if strength > base_strength: earned["strength"] = strength - base_strength
	if constitution > base_constitution: earned["constitution"] = constitution - base_constitution
	if dexterity > base_dexterity: earned["dexterity"] = dexterity - base_dexterity
	if charisma > base_charisma: earned["charisma"] = charisma - base_charisma
	if wisdom > base_wisdom: earned["wisdom"] = wisdom - base_wisdom
	if intelligence > base_intelligence: earned["intelligence"] = intelligence - base_intelligence
	return earned

func get_sell_cost() -> int:
	return int(base_cost / 2)

func receive_legacy_stats(permanent: Dictionary, volatile: Dictionary):
	print(character_name + " receiving stats. Perm: ", permanent, " Vol: ", volatile)
	_add_stats_dict(permanent)
	_add_stats_dict(volatile)

func _add_stats_dict(stats: Dictionary):
	if stats.has("strength"): strength += stats["strength"]
	if stats.has("constitution"): constitution += stats["constitution"]
	if stats.has("dexterity"): dexterity += stats["dexterity"]
	if stats.has("charisma"): charisma += stats["charisma"]
	if stats.has("wisdom"): wisdom += stats["wisdom"]
	if stats.has("intelligence"): intelligence += stats["intelligence"]

# --- EQUIPMENT (Runtime Only) ---
var equipped_items: Array = [null, null] 

func equip_item(item, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= equipped_items.size():
		return false
	equipped_items[slot_index] = item
	return true

func unequip_item(slot_index: int):
	if slot_index >= 0 and slot_index < equipped_items.size():
		equipped_items[slot_index] = null

func get_total_stats() -> Array:
	var total = [strength, constitution, dexterity, charisma, wisdom, intelligence]
	for item in equipped_items:
		if item != null:
			total[0] += item.strength_bonus
			total[1] += item.constitution_bonus
			total[2] += item.dexterity_bonus
			total[3] += item.charisma_bonus
			total[4] += item.wisdom_bonus
			total[5] += item.intelligence_bonus
	return total

func has_ability(ability_key: String) -> bool:
	for item in equipped_items:
		if item != null and item.ability_id == ability_key:
			return true
	return false
