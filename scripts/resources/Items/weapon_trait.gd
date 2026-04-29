extends Resource
class_name WeaponTrait

@export_subgroup("Weapon Trait")
var name : String = ""
var description : String = ""

@export_group("Functional Meta Data")
var trigger : CombatMapConstants.TRIGGERS = CombatMapConstants.TRIGGERS.NONE

var bonus_stat: UnitStat = null

## Unit traits this weapon deals bonus damage against.
@export var effectiveness_trait: Array[unitConstants.TRAITS] = []

## Weapon types this weapon deals bonus damage against.
@export var effectiveness_weapon_type: Array[ItemConstants.WEAPON_TYPE] = []
