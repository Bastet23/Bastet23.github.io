class_name Ability
extends Resource

# The unit this ability is currently attached to
var owner_unit: UnitData = null

# Called by the game when a mission or battle starts
func setup(unit: UnitData):
	owner_unit = unit
	_connect_signals()

# Override this function in your specific abilities!
func _connect_signals():
	pass
