extends Resource
class_name CombatMapGridAnalysis

var unit_indexes = {} #Dict<Faction, indexes : Array[Vector2i]>
var targetable_entity_indexes : Array[Vector2i] = []

func insert_unit_index(allegience: int, position: Vector2i):
	if unit_indexes.has(allegience):
		unit_indexes.get(allegience).append(position)
	else: 
		var positions :Array[Vector2i] = [position]
		unit_indexes[allegience] = positions

func get_allegience_unit_indexes(allegience:int) -> Array[Vector2i]:
	return unit_indexes.get(allegience)
