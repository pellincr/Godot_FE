extends Resource
class_name ArmyArchetypeDefinition


@export_group("Archetype")
@export var archetype_name= ""
#@export_enum{"Axe", "Sword", "Lance", "Bow", "Anima", "Light", "Dark", "Staff", "Fist", "Monster", "Other",
#"Infantry","Calvary", "Armored", "Monster", "Animal", "Flying") var given_archetypes: Dictionary

@export var given_unit_trait_archetypes : Dictionary = {
	unitConstants.TRAITS.ARMORED : 0,
	unitConstants.TRAITS.MOUNTED : 0,
	unitConstants.TRAITS.FLIER : 0,
	unitConstants.TRAITS.UNDEAD : 0,
	unitConstants.TRAITS.MASSIVE : 0,
	unitConstants.TRAITS.LOCKPICK : 0,
}

@export var given_unit_faction_archetypes : Dictionary = {
	unitConstants.FACTION.MERCENARY : 0,
	unitConstants.FACTION.KINGDOM : 0,
	unitConstants.FACTION.THEOCRACY : 0,
	unitConstants.FACTION.LAWBREAKERS : 0,
	unitConstants.FACTION.CULTIST : 0,
	unitConstants.FACTION.SKELETAL : 0,
	unitConstants.FACTION.MONSTER : 0,
}

@export var given_unit_weapon_archetypes : Dictionary = {
	#USEABLE WEAPONS:
	ItemConstants.WEAPON_TYPE.SWORD: 0,
	ItemConstants.WEAPON_TYPE.AXE: 0,
	ItemConstants.WEAPON_TYPE.LANCE : 0,
	ItemConstants.WEAPON_TYPE.BOW: 0,
	ItemConstants.WEAPON_TYPE.FIST:0,
	ItemConstants.WEAPON_TYPE.STAFF:0,
	ItemConstants.WEAPON_TYPE.DARK:0,
	ItemConstants.WEAPON_TYPE.LIGHT: 0,
	ItemConstants.WEAPON_TYPE.NATURE: 0,
	ItemConstants.WEAPON_TYPE.ANIMAL: 0,
	ItemConstants.WEAPON_TYPE.MONSTER: 0,
	ItemConstants.WEAPON_TYPE.SHIELD: 0,
	ItemConstants.WEAPON_TYPE.DAGGER:0,
	ItemConstants.WEAPON_TYPE.BANNER: 0,
}

@export var given_item_weapon_archetypes : Dictionary = {
	#USEABLE WEAPONS:
	ItemConstants.WEAPON_TYPE.SWORD: 0,
	ItemConstants.WEAPON_TYPE.AXE: 0,
	ItemConstants.WEAPON_TYPE.LANCE : 0,
	ItemConstants.WEAPON_TYPE.BOW: 0,
	ItemConstants.WEAPON_TYPE.FIST:0,
	ItemConstants.WEAPON_TYPE.STAFF:0,
	ItemConstants.WEAPON_TYPE.DARK:0,
	ItemConstants.WEAPON_TYPE.LIGHT: 0,
	ItemConstants.WEAPON_TYPE.NATURE: 0,
	ItemConstants.WEAPON_TYPE.ANIMAL: 0,
	ItemConstants.WEAPON_TYPE.MONSTER: 0,
	ItemConstants.WEAPON_TYPE.SHIELD: 0,
	ItemConstants.WEAPON_TYPE.DAGGER:0,
	ItemConstants.WEAPON_TYPE.BANNER: 0,
}


#var units_given = add_all(given_archetypes.values())

#func add_all(arr):
#	var temp = 0
#	for number in arr:
#		temp += number
#	return temp
