extends Resource

class_name UnitStat
@export_group("Combat Stats")
@export var hp : int  = 0 
@export var strength : int = 0
@export var magic : int = 0
@export var skill : int = 0
@export var speed : int = 0
@export var luck : int = 0
@export var defense : int = 0
@export var resistance : int = 0

@export_group("Physical Stats")
@export var movement : int = 0
@export var constitution : int = 0

func to_array() -> Array[int]:
	var output : Array[int] = []
	output.append(hp)
	output.append(strength)
	output.append(magic)
	output.append(skill)
	output.append(speed)
	output.append(luck)
	output.append(defense)
	output.append(resistance)
	output.append(movement)
	output.append(constitution)
	return output
