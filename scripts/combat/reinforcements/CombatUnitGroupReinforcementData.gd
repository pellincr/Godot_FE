extends Resource
class_name CombatUnitGroupReinforcementData

@export_group("Trigger Info")
@export var trigger_type: CombatMapConstants.REINFORCEMENT_TYPE

@export var turns : Array[int] = []
@export var zone_id : String 
var triggered: bool = false
#Unit Info
@export_group("Unit Info")
@export var faction : Constants.FACTION = Constants.FACTION.ENEMIES
@export var units : Array[CombatUnitData]
