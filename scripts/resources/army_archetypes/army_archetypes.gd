extends Resource
class_name ArmyArchetypeDefinition


@export_group("Archetype")
@export var archetype_name= ""
@export_enum("Axe", "Sword", "Lance", "Bow", "Anima", "Light", "Dark", "Staff", "Fist", "Monster", "Other",
"Infantry","Calvary", "Armored", "Monster", "Animal", "Flying") var given_archetypes: Array[String]
var units_given = given_archetypes.size()
