class_name UnitData
extends Resource

# --- IDENTITY ---
@export var character_name: String = "Unnamed Unit"
@export var unit_class: String = "Villager"
@export var portrait: Texture2D # Big Art (Left Panel)
@export var icon: Texture2D     # Small Icon (Battlefield Cards)

# --- LORE & ABILITIES ---
# NOTE: We removed 'description'. Now use these specific fields:
@export_multiline var backstory: String = "A wanderer from distant lands..."
@export_multiline var ability1_text: String = "Passive: None"
@export_multiline var ability2_text: String = "" # Optional (Leave empty to hide)

# --- BASE STATS (Defaults start at 1) ---
@export_group("Base Stats")
@export var strength: int = 1
@export var constitution: int = 1
@export var dexterity: int = 1
@export var charisma: int = 1
@export var wisdom: int = 1
@export var intelligence: int = 1

@export var base_cost: int = 2

func get_sell_cost() -> int:
	return int(base_cost / 2)

# Updated to accept TWO dictionaries
func receive_legacy_stats(permanent: Dictionary, volatile: Dictionary):
	print(character_name + " receiving stats. Perm: ", permanent, " Vol: ", volatile)
	
	# 1. Apply Permanent
	_add_stats_dict(permanent)
	
	# 2. Apply Volatile
	# (For a normal unit like a Knight, these effectively become permanent 
	# because the Knight has no logic to remove them later)
	_add_stats_dict(volatile)

func _add_stats_dict(stats: Dictionary):
	if stats.has("strength"): strength += stats["strength"]
	if stats.has("constitution"): constitution += stats["constitution"]
	if stats.has("dexterity"): dexterity += stats["dexterity"]
	if stats.has("charisma"): charisma += stats["charisma"]
	if stats.has("wisdom"): wisdom += stats["wisdom"]
	if stats.has("intelligence"): intelligence += stats["intelligence"]

# --- EQUIPMENT (Runtime Only) ---
# This array holds the actual ItemData resources.
var equipped_items: Array = [null, null] 

# --- HELPER FUNCTIONS ---

# Equip an item to slot 0 or 1
func equip_item(item: ItemData, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= equipped_items.size():
		return false
	equipped_items[slot_index] = item
	return true

# Remove item
func unequip_item(slot_index: int):
	if slot_index >= 0 and slot_index < equipped_items.size():
		equipped_items[slot_index] = null

# Calculates Base Stats + Item Stats
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

# Check for special rules (e.g. "reroll_solo") on items
func has_ability(ability_key: String) -> bool:
	for item in equipped_items:
		if item != null and item.ability_id == ability_key:
			return true
	return false
