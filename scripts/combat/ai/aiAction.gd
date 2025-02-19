extends Resource
class_name aiAction

var action_position : Vector2
var target_position : Vector2
var target: CombatUnit
var rating : float = 0
var item_index: int
var action_type : String ##ADD TO CONSTANTS?

func generate_rating():
	pass

func generate_attack_action_rating(terrain_bonus: float, player_hit: int, estimated_damage : float, target_max_hp : int, can_lethal: bool):
	var kill_bonus = 0
	if can_lethal :
		kill_bonus = 1000
	var damage_bonus = 100
	self.rating =  (1+terrain_bonus)*((player_hit * kill_bonus) + clamp(estimated_damage/target_max_hp, 0, 1)* damage_bonus)
	
