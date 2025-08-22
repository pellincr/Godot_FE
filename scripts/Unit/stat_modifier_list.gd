extends Resource
class_name StatModifierList

@export var statModifierDictionary : Dictionary = {}

func append(input: StatModifier):
	statModifierDictionary[input.source] = input.value

func evaluate():
	var total : int = 0
	for value in statModifierDictionary.values():
		total = total + value
	return total

func remove(source: String):
	if statModifierDictionary.has(source):
		statModifierDictionary.erase(source)
	
func clear():
	statModifierDictionary.clear()
