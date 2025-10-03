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
	var _arr :Array[Vector2i] = []
	if unit_indexes.has(allegience):
		_arr.append_array(unit_indexes.get(allegience))
	return _arr

func get_all_targetables(targetable_allegiences:Array[int]) -> Array[Vector2i]:
	var _arr :Array[Vector2i] = []
	for entity_position in targetable_entity_indexes:
			_arr.append(entity_position)
	for allegience in targetable_allegiences:
		if unit_indexes.has(allegience):
			for unit_index in unit_indexes.get(allegience):
				_arr.append(unit_index)
	return _arr

func get_targetable_entities()-> Array[Vector2i]:
	return targetable_entity_indexes

class CombatMapGridAnalysisTargetablePosition:
	var positon : Vector2i
	var target_type : String
	
	func _init(pos, type) -> void:
		self.positon = pos
		self.target_type = type
