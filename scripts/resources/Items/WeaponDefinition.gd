extends ItemDefinition
class_name WeaponDefinition

enum WEAPON_SPECIALS
{
	WEAPON_TRIANGLE_ADVANTAGE_EFFECTIVE,
	CRITICAL_DISABLED,
	VAMPYRIC,
	NEGATES_FOE_DEFENSE,
	NEGATES_FOE_DEFENSE_ON_CRITICAL,
	HEAL_10_PERCENT_ON_TURN_BEGIN,
	CANNOT_RETALIATE,
	HEAL_ON_COMBAT_END,
	DEVIL_REVERSAL
}
enum SUPPORT_TYPES{
	NONE,
	HEAL
}

@export_subgroup("Weapon Type")
@export var weapon_type : ItemConstants.WEAPON_TYPE
@export var alignment : ItemConstants.ALIGNMENT
@export var physical_weapon_triangle_type : ItemConstants.MUNDANE_WEAPON_TRIANGLE
@export var magic_weapon_triangle_type : ItemConstants.MAGICAL_WEAPON_TRIANGLE
@export var support_type : SUPPORT_TYPES = SUPPORT_TYPES.NONE
@export var item_damage_type : Constants.DAMAGE_TYPE = 0
@export var item_scaling_type : ItemConstants.SCALING_TYPE = 0
@export var item_scaling_multiplier : float = 1
@export var item_target_faction : Array[ItemConstants.AVAILABLE_TARGETS] = [0]

@export_group("Weapon Requirements") ## TO BE IMPLEMENTED
@export var required_mastery : ItemConstants.MASTERY_REQUIREMENT = ItemConstants.MASTERY_REQUIREMENT.E
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
#@export var weapon_effectiveness : Array[unitConstants.TRAITS] = [] #TRAIT (OLD)
@export var weapon_effectiveness_trait : Array[unitConstants.TRAITS] = [] #TRAIT
@export var weapon_effectiveness_weapon_type : Array[ItemConstants.WEAPON_TYPE] = []
@export_group("Weapon Specials") 

@export var status_ailment : EffectConstants.EFFECT_TYPE = EffectConstants.EFFECT_TYPE.NONE #USED IN STAFFS ETC.
@export var specials : Array[WEAPON_SPECIALS] = [] # Activated on weapon equipped
@export var augmented: bool = false
