extends Resource
class_name LevelPool

@export var tier_1_battle_levels : Array[PackedScene]
@export var tier_2_battle_levels : Array[PackedScene]
@export var boss_levels : Array[PackedScene]

@export var tier_thresholds = { # TO BE FLUSHED OUT
	
}
@export var battle_levels = { #Dict<Tier, level_array()>
	0: [], #intro level
	1: [], #used for tier levels
	"BOSS": [], #used for boss
	"MID_BOSS" : [], # used for the mid boss
	"EXTRA": [], #used for encounters etc.
}
