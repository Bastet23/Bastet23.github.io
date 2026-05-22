extends Node

# 1. BRIEFING: Emitted right as the mission starts, before travel. 
# context = {"squad": Array} (Abilities can add temporary clones here!)
signal squad_assembling(mission, context)

# 2. TRAVEL: Emitted when starting travel (outbound and returning)
# context = {"travel_modifier": 1.0}
signal calculating_travel_time(mission, context)

# 3. WORK: Emitted when the squad arrives
# context = {"work_modifier": 1.0}
signal calculating_work_time(mission, context)

# 4. DEBRIEF: Emitted to calculate success and allow rerolls
# context = {"success_chance": int, "is_successful": bool, "was_rerolled": bool, "result_log": String}
signal calculating_success(mission, context)

# 5. RESOLVED: Emitted after the final outcome is locked in. 
# context = {"is_success": bool} (Replaces your old on_mission_complete loop)
signal mission_resolved(mission, context)

# 6. REWARDS: Emitted to modify gold/influence payouts
# context = {"gold_multiplier": 1.0, "flat_bonus_gold": 0, "inf_multiplier": 1.0, "flat_bonus_inf": 0}
signal calculating_rewards(mission, context)
