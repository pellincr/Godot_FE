extends Node
class_name CombatEntityConstants

enum ENTITY_TYPE {
	CHEST,
	DOOR,
	LEVER, 
	MOVEMENT, ##TO BE IMPL
	BREAKABLE_TERRAIN,
	DEBRIS,
	VISITABLE,
	ON_GROUP_TRIGGER,
	SEARCH
}

const targetable_entity_types : Array[ENTITY_TYPE] = [ENTITY_TYPE.BREAKABLE_TERRAIN, ENTITY_TYPE.DEBRIS]

const valid_door_unlock_item_db_keys : Array[String] = ["skeleton_key", "door_key"]
const valid_chest_unlock_item_db_keys : Array[String] = ["skeleton_key", "chest_key"]
