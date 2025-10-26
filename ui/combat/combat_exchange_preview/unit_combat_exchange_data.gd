extends Resource
class_name UnitCombatExchangeData

@export var exchange_data : Array[UnitCombatExchangeTurnData] =[]
@export var weapon_triange : Unit #"NONE", "ATTACKER", "DEFENDER"
@export var effective : Array[Unit] = []

@export var attacker : CombatUnit
@export var attacker_predicted_hp : int
@export var attacker_net_damage : int
@export var attacker_hit : int
@export var attacker_critical : int
@export var attacker_effective : bool

@export var defender : CombatUnit
@export var defender_predicted_hp : int
@export var defender_net_damage : int
@export var defender_hit : int
@export var defender_critical : int
@export var defender_effective : bool

func calc_net_damage():
	attacker_net_damage = 0
	defender_net_damage = 0
	if exchange_data != null:
		for turn in exchange_data:
			if attacker == turn.owner:
				for attack in turn.attack_count:
					attacker_net_damage = attacker_net_damage + turn.attack_damage
			elif defender == turn.owner:
				for attack in turn.attack_count:
					defender_net_damage = defender_net_damage + turn.attack_damage

func calc_predicted_hp():
	attacker_predicted_hp = clampi(attacker.current_hp - defender_net_damage, 0, 9999)
	defender_predicted_hp = clampi(defender.current_hp - attacker_net_damage, 0, 9999)

func calc_predicted_hp_entity(ent_hp :int):
	defender_predicted_hp = clampi(ent_hp - attacker_net_damage, 0, 9999)

func populate(data : Array[UnitCombatExchangeTurnData] = []):
	if not data.is_empty():
		exchange_data.clear()
		exchange_data = data
	calc_net_damage()
	calc_predicted_hp()
	
