extends Resource
class_name Campaign

@export_subgroup("Campaign Info")
@export var name : String

@export_subgroup("Campaign Draft Info")
@export var commander_draft_limit : = 1
@export var number_of_archetypes_drafted : int

@export_subgroup("Campaign Map Info")
@export var max_floor_number : int
@export var number_of_required_combat_maps : int
@export var level_pool : LevelPool

@export_subgroup("Campaign Overview Info")
@export var boss_commander: CommanderDefinition
var difficulty : int #= calculate_campaign_difficulty()
@export var length : String = ""
@export var starting_gold = 1000

@export_subgroup("Campaign Rewards Info")
#@export var rewards : String
@export var unit_unlock_rewards : Array[UnitTypeDefinition]



func get_element_difficulty_scale(value:float, min_value:float, max_value:float) -> float:
	return clamp((value-min_value)/ float(max_value-min_value), 0.0, 1.0)

func calculate_average_key_battle_difficulty():
	var min_enemy_amount : int = 10
	var max_enemy_amount : int = 50
	var min_allowed_units : int = 4
	var max_allowed_units : int = 12
	var level_count :int = 0
	var battle_score : float = 0
	if level_pool:
		for level_array_key in level_pool.battle_levels.keys():
			if level_array_key is int:
				var current_level_array = level_pool.battle_levels[level_array_key]
				for current_level in current_level_array:
					var combat = current_level.instantiate().get_child(2)
					var starting_enemy_group :EnemyGroup = combat.unit_data.starting_enemy_group
					var enemy_count := starting_enemy_group.group.size()
					var allowed_units_amount = combat.ally_spawn_tiles.size()
					battle_score += get_element_difficulty_scale(enemy_count, min_enemy_amount, max_enemy_amount) * 0.7 + (1 - get_element_difficulty_scale(allowed_units_amount,min_allowed_units,max_allowed_units)) * 0.3
					level_count += 1
			elif !level_array_key == 'EXTRA':
				var current_level_array = level_pool.battle_levels[level_array_key]
				for current_level in current_level_array:
					var combat = current_level.instantiate().get_child(2)
					var starting_enemy_group :EnemyGroup = combat.unit_data.starting_enemy_group
					var enemy_count := starting_enemy_group.group.size()
					var allowed_units_amount = combat.ally_spawn_tiles.size()
					battle_score += get_element_difficulty_scale(enemy_count, min_enemy_amount, max_enemy_amount) * 0.7 + (1 - get_element_difficulty_scale(allowed_units_amount,min_allowed_units,max_allowed_units)) * 0.3
					level_count += 1
	return battle_score/level_count

func calculate_campaign_difficulty():
	var key_battles_difficulty_scale = get_element_difficulty_scale(number_of_required_combat_maps,3,20)
	var floors_difficulty_scale = get_element_difficulty_scale(max_floor_number, 5, 20)
	var archetypes_difficulty_scale = 1 - get_element_difficulty_scale(number_of_archetypes_drafted, 1, 10)
	var commander_difficulty_scale = 1 - get_element_difficulty_scale(commander_draft_limit, 1, 6)
	var avg_battle_sale = calculate_average_key_battle_difficulty()
	const KEY_BATTLE_DIFFICULTY_WEIDGHT := 0.2
	const FLOORS_DIFFICULTY_WEIDGHT := 0.2
	const AVG_BATTLE_DIFFICULTY_WEIDGHT := 0.45
	const ARCHETYPE_DIFFICULTY_WEIDGHT := 0.1
	const COMMANDER_DIFFICULTY_WEIDGHT := 0.05
	var final_difficulty = (key_battles_difficulty_scale  * KEY_BATTLE_DIFFICULTY_WEIDGHT) + (floors_difficulty_scale * FLOORS_DIFFICULTY_WEIDGHT) + (archetypes_difficulty_scale * ARCHETYPE_DIFFICULTY_WEIDGHT) + (commander_difficulty_scale * COMMANDER_DIFFICULTY_WEIDGHT) + (avg_battle_sale * AVG_BATTLE_DIFFICULTY_WEIDGHT)
	return get_star_count_from_difficulty(final_difficulty)


func get_star_count_from_difficulty(dif_val:float):
	var star_count = 0
	if dif_val <= 0.2:
		star_count = 1
	elif dif_val <= 0.4:
		star_count = 2
	elif dif_val <= 0.6:
		star_count = 3
	elif star_count <= 0.8:
		star_count = 4
	else:
		star_count = 5
	return star_count
