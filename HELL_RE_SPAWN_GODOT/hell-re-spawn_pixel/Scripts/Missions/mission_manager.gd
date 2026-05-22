extends Node

# --- SETTINGS ---
@export var mission_visual_scene: PackedScene 
@export var mission_pool: Array[MissionDefinition] 
# Pacing: How often a new mission appears (in seconds)
@export var min_spawn_time: float = 5.0
@export var max_spawn_time: float = 10.0

# --- REFERENCES ---
@export var map_spots_container: Node2D 
@export var mission_container: Node2D
@onready var mission_briefing = $"../MissionBriefing" 
@onready var mission_debrief = $"../MissionDebrief"

# --- STATE ---
var active_missions: Array = []
var active_visuals: Dictionary = {} 

# The Queue: Missions waiting to appear this round
var pending_round_missions: Array = [] 
var spawn_timer: float = 2.0 # Start first mission quickly (2s)

#----Signals---
signal mission_finished(squad, mission_data)
signal round_completed # Emitted when all 15 missions are done

# --- INITIALIZATION ---
func _ready():
	await get_tree().create_timer(1.0).timeout
	start_new_round()

# --- ROUND SETUP ---
func start_new_round():
	print("--- PREPARING NEW ROUND ---")
	
	_clear_all_missions()
	pending_round_missions.clear()
	
	if mission_pool.is_empty():
		print("ERROR: Mission Pool is empty!")
		return
	
	# 1. Sort Mission Pool
	var critical_defs = []
	var normal_defs = []
	
	for m_def in mission_pool:
		if m_def.is_critical:
			critical_defs.append(m_def)
		else:
			normal_defs.append(m_def)
			
	# 2. Build the Round Queue (15 Total)
	
	# A. Add 3 Criticals (Recycling if needed)
	for i in range(3):
		if not critical_defs.is_empty():
			pending_round_missions.append(critical_defs.pick_random())
		elif not normal_defs.is_empty():
			pending_round_missions.append(normal_defs.pick_random())

	# B. Add 12 Normals (Recycling if needed)
	for i in range(12):
		if not normal_defs.is_empty():
			pending_round_missions.append(normal_defs.pick_random())
		elif not critical_defs.is_empty():
			pending_round_missions.append(critical_defs.pick_random())
	
	# 3. Shuffle so Criticals don't all appear at once or at the end
	pending_round_missions.shuffle()
	
	print("Round Ready: %s Missions queued." % pending_round_missions.size())
	
	# Reset timer to spawn the first one soon
	spawn_timer = 2.0

# --- PROCESS LOOP (SPAWNING & UPDATING) ---
func _process(delta):
	# 0. PAUSE CHECK
	if mission_briefing.visible or mission_debrief.visible:
		return 
	
	# 1. SPAWN LOGIC (The Drip Feed)
	if not pending_round_missions.is_empty():
		spawn_timer -= delta
		if spawn_timer <= 0:
			_spawn_next_from_queue()
			# Reset timer for the next one (Random 15-30s)
			spawn_timer = randf_range(min_spawn_time, max_spawn_time)
	
	# 2. UPDATE LOGIC (Existing missions)
	for i in range(active_missions.size() - 1, -1, -1):
		var mission = active_missions[i]
		var changed = mission.update(delta)
		
		# Mission Complete
		if mission.current_state == ActiveMission.State.COMPLETED:
			mission_finished.emit(mission.squad, mission)
			_remove_mission(mission)
			_check_round_end() # Check if round is over
			
		# Mission Expired (Ignored)
		elif mission.current_state == ActiveMission.State.AVAILABLE and mission.time_left <= 0:
			print("Mission Expired!")
			# ActiveMission handles the penalty logic
			_remove_mission(mission)
			_check_round_end()

func _spawn_next_from_queue():
	# Get available map spots
	var spots = map_spots_container.get_children()
	
	# Filter out spots currently taken by active missions
	var available_indices = []
	for i in range(spots.size()):
		var taken = false
		for m in active_missions:
			if m.map_spot_index == i:
				taken = true
				break
		if not taken:
			available_indices.append(i)
	
	if available_indices.is_empty():
		print("Map full! Waiting for spot to free up...")
		spawn_timer = 5.0 # Try again sooner
		return

	# Pop the next mission definition from the queue
	var def = pending_round_missions.pop_front()
	
	# Pick a random free spot
	var spot_idx = available_indices.pick_random()
	var spot_node = spots[spot_idx]
	
	_spawn_single_mission(def, spot_idx, spot_node)
	print("Spawned mission. Remaining in queue: ", pending_round_missions.size())

func _spawn_single_mission(def, spot_index, spot_node):
	var new_mission = ActiveMission.new(def, spot_index)
	new_mission.map_marker_node = spot_node 
	
	active_missions.append(new_mission)
	_create_visual(new_mission, spot_node.position)

func _check_round_end():
	# If queue is empty AND no active missions left -> Round Over
	if pending_round_missions.is_empty() and active_missions.is_empty():
		print("ROUND COMPLETE!")
		emit_signal("round_completed")
		# Here you would trigger the Shop Screen
		if RunManager:
			RunManager.complete_round()

# --- HELPER FUNCTIONS ---
func _create_visual(mission_logic, pos):
	var visual = mission_visual_scene.instantiate()
	mission_container.add_child(visual)
	visual.position = pos
	
	visual.setup(mission_logic)
	visual.mission_clicked.connect(_on_mission_clicked)
	
	if mission_logic.def.is_critical:
		visual.modulate = Color(1.0, 0.4, 0.4) 
		visual.scale = Vector2(1.2, 1.2)
	
	active_visuals[mission_logic] = visual

func _remove_mission(mission_logic):
	active_missions.erase(mission_logic)
	if active_visuals.has(mission_logic):
		var node = active_visuals[mission_logic]
		node.queue_free()
		active_visuals.erase(mission_logic)

func _clear_all_missions():
	for m in active_missions:
		if active_visuals.has(m):
			active_visuals[m].queue_free()
	active_missions.clear()
	active_visuals.clear()

# --- INTERACTION ---
func _on_mission_clicked(mission_logic):
	if mission_briefing.visible or mission_debrief.visible: 
		return 
	
	if mission_logic.current_state == ActiveMission.State.READY_FOR_DEBRIEF:
		mission_debrief.visible = true
		
		# UPDATED: Pass empty list [] because items are now on units
		mission_debrief.setup(mission_logic)
		
		await mission_debrief.return_confirmed
		mission_logic.finish_debrief()

	elif mission_logic.current_state == ActiveMission.State.AVAILABLE:
		mission_briefing.visible = true
		mission_briefing.setup_mission(mission_logic)
		if get_parent().has_method("set_hand_interaction"):
			get_parent().set_hand_interaction(true)
