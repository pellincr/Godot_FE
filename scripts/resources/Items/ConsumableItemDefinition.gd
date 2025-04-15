extends ItemDefinition
class_name ConsumableItemDefinition


enum USE_EFFECTS
{
	HEAL,
	STAT_BONUS,
	KEY
}


@export var use_effect : USE_EFFECTS
@export var use_effect_power : int


func use(): 
	#Do something
	print(name + " was used!")
	uses = uses - 1
	print(str(uses) + " uses remain")
	if uses == 0:
		print(name + " broke!")
