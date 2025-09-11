extends Resource

class_name CampaignRoom

enum TYPE{
	NOT_ASSIGNED, BATTLE, EVENT, TREASURE, SHOP, ELITE, BOSS, KEY_BATTLE, RECRUITMENT
}

@export var type : TYPE
@export var row : int
@export var column : int
@export var position : Vector2
@export var next_rooms: Array[CampaignRoom]
@export var selected := false

func _to_string() -> String:
	#displays column number and type of current room
	return "%s (%s)" % [column,TYPE.keys()[type]]
