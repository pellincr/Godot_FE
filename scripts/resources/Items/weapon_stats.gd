extends ItemStats
class_name WeaponStats
@export_group("Weapon Function Change Stats")
@export var change_damage_type: bool = false
@export var item_new_damage_type : Constants.DAMAGE_TYPE = 0
@export var change_scaling_type: bool = false
@export var item_new_scaling_type : ItemConstants.SCALING_TYPE = 0
@export var item_scaling_multiplier_change : float = 0

@export_range(0, 30, 1) var attack_range : Array[int] = []
@export_group("Combat Stats") 
@export_range(0, 30, 1, "or_greater") var damage = 0
@export_range(0, 100, 1, "or_greater") var hit = 0
@export_range(0, 30, 1, "or_greater") var critical_chance = 0
@export_range(0, 30, 1, "or_greater") var weight = 0
@export var critical_multiplier : float = 0
@export var attacks_per_combat_turn : int = 0

@export_group("Bonus Stats")
@export var bonus_stat : UnitStat = null

@export_group("Weapon Specials") 
#@export var weapon_effectiveness : Array[unitConstants.TRAITS] = []
@export var weapon_effectiveness_trait : Array[unitConstants.TRAITS] = []
@export var weapon_effectiveness_weapon_type : Array[ItemConstants.WEAPON_TYPE] = []
@export var specials : Array[WeaponDefinition.WEAPON_SPECIALS] = [] # Activated on weapon equipped


func apply_weapon_stats(weapon: WeaponDefinition):
	#item_stats
	weapon.max_uses = weapon.max_uses - max_uses
	weapon.uses = clampi(weapon.uses - max_uses, 1, 10000000000)
	
	if percent_durability != 1:
		weapon.uses = int(weapon.uses * percent_durability)
	if ubreakable:
		weapon.unbreakable = true
	if inventory_bonus_stats != null:
		if weapon.inventory_bonus_stats != null:
			weapon.inventory_bonus_stats = CustomUtilityLibrary.add_unit_stat(weapon.inventory_bonus_stats, inventory_bonus_stats)
		else :
			weapon.inventory_bonus_stats = inventory_bonus_stats.duplicate()
	#weapon_stats
	if change_damage_type:
		weapon.item_damage_type = item_new_damage_type
	if change_scaling_type:
		weapon.item_scaling_type = item_new_scaling_type
	weapon.item_scaling_multiplier = weapon.item_scaling_multiplier + item_scaling_multiplier_change
	weapon.attack_range.append_array(attack_range)
	weapon.damage = weapon.damage + damage
	weapon.hit = weapon.hit + hit
	weapon.critical_chance = weapon.critical_chance + critical_chance
	weapon.weight = weapon.weight + weight
	weapon.critical_multiplier = weapon.critical_multiplier + critical_multiplier
	weapon.attacks_per_combat_turn = weapon.attacks_per_combat_turn + attacks_per_combat_turn
	if bonus_stat != null:
		if weapon.bonus_stat != null:
			weapon.bonus_stat = CustomUtilityLibrary.add_unit_stat(weapon.bonus_stat, bonus_stat)
		else :
			weapon.bonus_stat = bonus_stat.duplicate()
	if not weapon_effectiveness_trait.is_empty():
		weapon.weapon_effectiveness_trait.append_array(weapon_effectiveness_trait)
	if not weapon_effectiveness_weapon_type.is_empty():
		weapon.weapon_effectiveness_weapon_type.append_array(weapon_effectiveness_weapon_type)
	if not specials.is_empty():
		weapon.specials.append_array(specials)
	
