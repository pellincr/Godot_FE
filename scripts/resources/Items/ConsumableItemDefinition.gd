extends ItemDefinition
class_name ConsumableItemDefinition

@export var use_effect : ItemConstants.CONSUMABLE_USE_EFFECT = ItemConstants.CONSUMABLE_USE_EFFECT.NONE
@export var power : int = 0

@export_subgroup("Stat Boost")
@export var boost_stat : UnitStat
@export var boost_growth : UnitStat

@export_subgroup("Status Effect TO BE IMPL")
@export var status_effect : Array[CombatUnitStatusEffect] #TODO Implement
