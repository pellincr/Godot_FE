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
	MAGICAL
}

@export_subgroup("Weapon Type")
@export_enum("Axe", "Sword", "Lance", "Bow", "Anima", "Light", "Dark", "Staff", "Monster", "Other" ) var weapon_type = 0
@export_enum("Physical", "Magic") var item_damage_type = 0
@export_enum("Infantry","Calvary", "Armored", "Monster", "Animal", "Flying") var weapon_effectiveness : Array[String] = []


@export_group("Weapon Requirements") ## TO BE IMPLEMENTED
@export_enum("E","D","C","B","A","S", "NONE") var required_mastery = 0
@export_range(0, 30, 1) var attack_range : Array[int] = [1]
@export var class_locked = false
@export var locked_unit_type_key = ""
@export_group("Combat Stats") ## TO BE IMPLEMENTED
@export_range(0, 30, 1, "or_greater") var damage = 0
@export_range(0, 100, 1, "or_greater") var hit = 100
@export_range(0, 30, 1, "or_greater") var critical_chance = 0
@export_range(0, 30, 1, "or_greater") var weight = 5
