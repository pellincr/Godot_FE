extends Resource
class_name LevelPool

@export var battle_levels = { #Dict<Tier, level_array()>
	0: [], #intro level
	1: [], #used for tier levels
	"BOSS": [], #used for boss
	"MID_BOSS" : [], # used for the mid boss
	"EXTRA": [], #used for encounters etc.
}
