extends ItemDefinition
class_name WeaponDefinition

enum WEAPON_TYPE
{
	AXE,
	SWORD,
	LANCE,
	BOW,
	ANIMA,
	LIGHT,
	DARK,
	STAFF,
	MONSTER,
	OTHER
}

enum DAMAGE_TYPE
{
	PHYSICAL,
	MAGICAL,
	NONE
}

enum SCALING_TYPE
{
	PHYSICAL,
	MAGICAL,
	NONE
}
enum HIT_EFFECT
{
	PHYSICAL_DAMAGE,
	MAGICAL_DAMAGE,
	HEAL,
	SLEEP,
	PLACEHOLDER
}
enum AVAILABLE_TARGETS #this will expanded when more factions are added
{
	ENEMY,
	ALLY,
	SELF
}

@export_subgroup("Weapon Type")
@export_enum("Axe", "Sword", "Lance", "Bow", "Nature", "Light", "Dark", "Staff", "Monster", "Other" ) var weapon_type : String
@export_enum("none", "Axe", "Sword", "Lance") var physical_weapon_triangle_type : String
@export_enum("none","Dark", "Light", "Nature") var magic_weapon_triangle_type : String
@export_enum("Physical", "Magic", "NONE" ) var item_damage_type : int = 0
@export_enum("Physical", "Magic", "NONE" ) var item_scaling_type : int = 0
@export_enum("Enemy", "Ally", "Self") var item_target_faction : int = 0

@export_group("Weapon Requirements") ## TO BE IMPLEMENTED
@export_enum("E","D","C","B","A","S", "NONE") var required_mastery = 0
@export_range(0, 30, 1) var attack_range : Array[int] = [1]
@export_group("Combat Stats") 
@export_range(0, 30, 1, "or_greater") var damage = 0
@export_range(0, 100, 1, "or_greater") var hit = 100
@export_range(0, 30, 1, "or_greater") var critical_chance = 0
@export_range(0, 30, 1, "or_greater") var weight = 5

@export_group("Weapon Effects & Specials") ## TO BE IMPLEMENTED
@export_enum("Infantry","Calvary", "Armored", "Monster", "Animal", "Flying") var weapon_effectiveness : Array[String] = []
@export_enum("PHYSICAL_DAMAGE","MAGICAL_DAMAGE","HEAL","SLEEP","PLACEHOLDER") var weapon_hit_effect = 0
@export var is_wpn_triangle_effective = false
@export var crit_disabled : bool = false
@export var is_brave = false
@export var applies_status_effect = false
@export var negates_defense = false
