extends ItemStats
class_name WeaponStats

@export var item_damage_type : Constants.DAMAGE_TYPE = 0
@export var item_scaling_type : itemConstants.SCALING_TYPE = 0
@export var item_scaling_multiplier : float = 0

@export_range(0, 30, 1) var attack_range : Array[int] = []
@export_group("Combat Stats") 
@export_range(0, 30, 1, "or_greater") var damage = 0
@export_range(0, 100, 1, "or_greater") var hit = 0
@export_range(0, 30, 1, "or_greater") var critical_chance = 0
@export_range(0, 30, 1, "or_greater") var weight = 0
@export var critical_multiplier : float = 0
@export var attacks_per_combat_turn : int = 0

@export_group("Bonus Stats")
@export var bonus_stat : UnitStat = UnitStat.new()

@export_group("Weapon Specials") 
@export var weapon_effectiveness : Array[unitConstants.TRAITS] = []
@export var specials : Array[WeaponDefinition.WEAPON_SPECIALS] = [] # Activated on weapon equipped
