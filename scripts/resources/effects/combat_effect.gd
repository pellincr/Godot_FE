extends Resource
class_name CombatEffect


@export var effect_weight : int
@export var source : int
@export var effect : ItemConstants.ITEM_USE_EFFECT
@export var duration : int  = -1 #-1 is instant
@export var effect_stats: UnitStat = UnitStat.new()
