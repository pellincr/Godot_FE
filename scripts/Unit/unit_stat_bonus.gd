extends Resource

class_name UnitStatBonus

##MAKE GLOBAL ENUM OF STAT
@export_enum("HP","Strength", "Magic", "Skill", "Speed", "Luck", "Defense","Magic Defense","Movement","Constitution", "Avoid") var stat :String
@export var weight :int
@export_enum("Flat","Percentage") var scaling_type :String = "Flat"
@export var source: String ##This could be updated to a db key?
@export_enum("Skill","Equipment","Unit", "Terrain")  var source_type: String
