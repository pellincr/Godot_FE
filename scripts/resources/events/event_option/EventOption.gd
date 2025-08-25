extends Resource

class_name EventOption

enum EVENT_EFFECT{
	STRENGTH_ALL,
	MAGIC_ALL,
	RANDOM_WEAPON,
	RANDOM_CONSUMABLE
}

@export var description : String
@export var effect : EVENT_EFFECT
