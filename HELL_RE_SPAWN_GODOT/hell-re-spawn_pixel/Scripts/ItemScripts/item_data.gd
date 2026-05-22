class_name ItemData
extends Resource

# --- VISUALS ---
@export var item_name: String = "New Item"
@export_multiline var description: String = "Item Description"
@export var icon: Texture2D # The Square Icon

# --- STATS (Can be negative for tradeoffs!) ---
@export_group("Stat Modifiers")
@export var strength_bonus: int = 0
@export var constitution_bonus: int = 0
@export var dexterity_bonus: int = 0
@export var charisma_bonus: int = 0
@export var wisdom_bonus: int = 0
@export var intelligence_bonus: int = 0

# --- SPECIAL ABILITIES ---
# We use a string ID to code special logic later.
# Examples: "reroll_solo", "prevent_death", "gold_bonus"
@export_group("Special Rules")
@export var ability_id: String = ""
