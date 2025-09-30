extends Resource
class_name ItemStats

#@export_range(-1, 100, 1, "or_greater") var uses = 0
@export_range(1, 2, 1, "or_greater") var max_uses = 0

@export_group("Bonus Stats From Held in Inventory")
@export var inventory_bonus_stats : CombatUnitStat = null
