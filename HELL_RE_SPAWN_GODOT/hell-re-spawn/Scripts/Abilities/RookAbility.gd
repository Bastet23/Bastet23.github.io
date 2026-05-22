class_name RookAbility
extends Ability

func _connect_signals():
	# The Rook listens to TWO different phases of the mission!
	MissionEvents.calculating_travel_time.connect(_on_calculating_travel_time)
	MissionEvents.calculating_work_time.connect(_on_calculating_work_time)

func _on_calculating_travel_time(mission: ActiveMission, context: Dictionary):
	# 1. Is my specific Rook on this mission?
	if not owner_unit in mission.squad:
		return
		
	# 2. Does the Rook have teammates?
	if mission.squad.size() ==1:
		print(">> Rook Urgent Delivery: Travel speed boosted!")
		context["travel_modifier"] *= 0.5 # 50% Time

func _on_calculating_work_time(mission: ActiveMission, context: Dictionary):
	# 1. Is my specific Rook on this mission?
	if not owner_unit in mission.squad:
		return
		
	# 2. Does the Rook have teammates?
	if mission.squad.size() == 1:
		print(">> Rook Urgent Delivery: Work speed boosted!")
		context["work_modifier"] *= 0.8 # 80% Time
