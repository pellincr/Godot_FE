extends ItemDefinition
class_name WeaponDefinition

@export_subgroup("Weapon Type")
@export var weapon_type : itemConstants.WEAPON_TYPE
@export var alignment : itemConstants.ALIGNMENT
@export var physical_weapon_triangle_type : itemConstants.MUNDANE_WEAPON_TRIANGLE
@export var magic_weapon_triangle_type : itemConstants.MAGICAL_WEAPON_TRIANGLE
@export var item_damage_type : Constants.DAMAGE_TYPE = 0
@export var item_scaling_type : itemConstants.SCALING_TYPE = 0
@export var item_target_faction : Array[itemConstants.AVAILABLE_TARGETS] = [0]

@export_group("Weapon Requirements") ## TO BE IMPLEMENTED
@export var required_mastery : itemConstants.MASTERY_REQUIREMENT = itemConstants.MASTERY_REQUIREMENT.E
@export_range(0, 30, 1) var attack_range : Array[int] = [1]
@export_group("Combat Stats") 
@export_range(0, 30, 1, "or_greater") var damage = 0
@export_range(0, 100, 1, "or_greater") var hit = 100
@export_range(0, 30, 1, "or_greater") var critical_chance = 0
@export_range(0, 30, 1, "or_greater") var weight = 5
@export var critical_multiplier : float = 3
@export var attacks_per_combat_turn : int = 1

@export_group("Bonus Stats")
@export var bonus_stat : UnitStat = UnitStat.new()

@export_group("Weapon Effectiveness")
@export var weapon_effectiveness : Array[unitConstants.TRAITS] = []
@export var status_ailment : EffectConstants.EFFECT_TYPE = EffectConstants.EFFECT_TYPE.NONE #USED IN STAFFS ETC.
@export_group("Weapon Specials") 
@export var specials : Array[ItemConstants.WEAPON_SPECIALS] = []
