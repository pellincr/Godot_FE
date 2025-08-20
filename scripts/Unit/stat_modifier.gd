extends Resource
class_name StatModifier

@export var value : int
@export var source : String

static func create(input_value: int, reference_source: String) -> StatModifier:
	var statMod : StatModifier = StatModifier.new()
	statMod.value = input_value
	statMod.source = reference_source
	return statMod
	
