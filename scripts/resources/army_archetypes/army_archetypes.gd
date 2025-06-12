extends Resource
class_name ArmyArchetypeDefinition


@export_group("Archetype")
@export var archetype_name= ""
@export var given_classes: Array[UnitTypeDefinition]
var units_given = given_classes.size()
