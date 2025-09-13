extends Resource
class_name UnitSupportExchangeData

@export var exchange_data : Array[UnitSupportExchangeTurnData] =[]

@export var supporter : CombatUnit
@export var supporter_net_heal : int

@export var target : CombatUnit
@export var target_predicted_hp : int


func calc_net_heal():
	if exchange_data != null:
		for turn in exchange_data:
			if turn.effect_type == EffectConstants.EFFECT_TYPE.HEAL:
				supporter_net_heal = supporter_net_heal + turn.effect_weight
				
func calc_predicted_hp():
	target_predicted_hp = clampi(target.current_hp + supporter_net_heal, 0, target.get_max_hp())

func populate(data : Array[UnitSupportExchangeTurnData] = []):
	if not data.is_empty():
		exchange_data.clear()
		exchange_data = data
	calc_net_heal()
	calc_predicted_hp()
	
