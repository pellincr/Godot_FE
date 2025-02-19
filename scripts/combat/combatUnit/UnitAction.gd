extends Resource
class_name UnitAction


@export var name = ""
@export var is_major : bool = false
@export var is_minor : bool = false
@export var requires_target = false
@export var requires_item = false
@export var requires_entity = false
@export var description : String
@export var flow : Array[Constants.UNIT_ACTION_STATE] = []
