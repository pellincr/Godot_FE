extends Resource
class_name UnitCombatExchangeTurnData

@export var owner : CombatUnit
@export var attack_damage : int = 0
@export var damage_type : Constants.DAMAGE_TYPE = Constants.DAMAGE_TYPE.NONE
@export var effective_damage : bool = false
@export var attack_count : int = 1
@export var critical: int = 0
@export var hit: int = 0
#TO BE IMPL SKILL INTEGRATION
