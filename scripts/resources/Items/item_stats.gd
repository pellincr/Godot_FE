extends Resource
class_name ItemStats

#@export_range(-1, 100, 1, "or_greater") var uses = 0
@export_group("Item Stat Changes")
@export var max_uses = 0
@export_range(0,1) var percent_durability: float = 1
@export var ubreakable : bool = false
@export_group("Bonus Stats From Held in Inventory")
@export var inventory_bonus_stats : CombatUnitStat = null
