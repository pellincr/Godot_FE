extends Resource
class_name aiAction
## A reource that stores information about ai combat_unit's moves and actions
##
## The description of the script, what it can do,
## and any further detail.
##


enum ACTION_TYPES {
	COMBAT,
	COMBAT_AND_MOVE,
	MOVE,
	WAIT
}


##
## Who is performing the action
##
var owner : CombatUnit
##
## Where the owner of the action will reside when it is performed
##
var action_position : Vector2i
##
## If there are multiple action_positions for a certain action, with a certain rating they are aggregated here
##
var action_positions: Array[Vector2i] = []
##
## Used in combat, where the target is positioned
##
var target_position : Vector2i
##
## Used during movement rating calculation, the astar weight to a high value, that has been identified to hold a "Combat" action
##
var distance_to_high_value_tile: int 
##
## Used in combat, the definnition of the target combat unit
##
var target: CombatUnit
##
## The action's value rating, used by the CController to check and see what actions should be prioritized
##
var rating : float = 0
##
## Used in combat, The item index of the item used in the action
##
var item_index: int #
var selected_Weapon : WeaponDefinition
var action_type : ACTION_TYPES ##ADD TO CONSTANTS?
var combat_action_data: UnitCombatExchangeData
var terrain_rating : float = 0

func generate_rating():
	pass


##
##
##
static func calculate_terrain_rating(terrain:Terrain) -> float:
	return terrain.avoid/50 + terrain.defense + terrain.resistance
	

func generate_attack_action_rating(terrain_bonus: float, player_hit: int, estimated_damage : float, target_max_hp : int, can_lethal: bool, estimated_incoming_damage : float):
	var kill_bonus = 0
	var no_damage_recieved_bonus = 0
	if can_lethal :
		kill_bonus = 1000
	var damage_bonus = 100
	if estimated_incoming_damage == 0:
		no_damage_recieved_bonus = 50
	## TODO add a bonus for damage taken
	self.rating = ( 1+ (player_hit * kill_bonus) + clamp(estimated_damage/target_max_hp, 0, 1)* (damage_bonus + no_damage_recieved_bonus))

func generate_move_action_rating(terrain_bonus: float):
	var turn_penalty = 10
	self.rating = (turn_penalty/float(distance_to_high_value_tile/owner.effective_move)) * (2 * owner.unit.level) * pow((owner.unit.get_unit_type_definition().tier/2),2) + (1+terrain_bonus)
