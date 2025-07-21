extends Resource
class_name ArmyArchetypeDefinition


@export_group("Archetype")
@export var archetype_name= ""
#@export_enum{"Axe", "Sword", "Lance", "Bow", "Anima", "Light", "Dark", "Staff", "Fist", "Monster", "Other",
#"Infantry","Calvary", "Armored", "Monster", "Animal", "Flying") var given_archetypes: Dictionary

@export var given_archetypes : Dictionary = {
	"Axe": 0,
	"Sword": 0,
	"Lance" : 0,
	"Bow": 0,
	"Anima": 0,
	"Light": 0,
	"Dark":0,
	"Staff":0,
	"Fist":0,
	"Other": 0,
	"Infantry":0,
	"Calvary":0,
	"Armored":0,
	"Monster":0,
	"Animal":0,
	"Flying":0
}

var units_given = add_all(given_archetypes.values())

func add_all(arr):
	var temp = 0
	for number in arr:
		temp += number
	return temp
