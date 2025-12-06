extends Resource
class_name aiAction

enum ACTION_TYPES {
	COMBAT,
	COMBAT_AND_MOVE,
	MOVE,
	WAIT
}

var owner : CombatUnit
var action_position : Vector2i
var target_position : Vector2i
var distance_to_high_value_tile: int 
var target: CombatUnit
var rating : float = 0
var item_index: int #
var selected_Weapon : WeaponDefinition
var action_type : ACTION_TYPES ##ADD TO CONSTANTS?
var combat_action_data: UnitCombatExchangeData

func generate_rating():
	pass

func generate_attack_action_rating(terrain_bonus: float, player_hit: int, estimated_damage : float, target_max_hp : int, can_lethal: bool, estimated_incoming_damage : float):
	var kill_bonus = 0
	var no_damage_recieved_bonus = 0
	if can_lethal :
		kill_bonus = 1000
	var damage_bonus = 100
	if estimated_incoming_damage == 0:
		no_damage_recieved_bonus = 50
	## TODO add a bonus for damage taken
	self.rating = (1+terrain_bonus)*( 1+ (player_hit * kill_bonus) + clamp(estimated_damage/target_max_hp, 0, 1)* (damage_bonus + no_damage_recieved_bonus))

func generate_move_action_rating(terrain_bonus: float):
	var turn_penalty = 10
	self.rating = (turn_penalty/float(distance_to_high_value_tile/owner.effective_move)) * (2 * owner.unit.level) * pow((owner.unit.get_unit_type_definition().tier/2),2) + (1+terrain_bonus)
