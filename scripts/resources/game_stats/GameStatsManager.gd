extends Resource

class_name GameStatsManager

@export var enemy_types_killed = {}


func get_total_enemies_killed():
	var kill_count = 0
	for value in enemy_types_killed.values():
		kill_count += value
	return kill_count
