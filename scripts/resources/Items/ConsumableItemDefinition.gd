extends ItemDefinition
class_name ConsumableItemDefinition

@export var use_effect : Array[CombatEffect]

func use(): 
	#Do something
	print(name + " was used!")
	uses = uses - 1
	print(str(uses) + " uses remain")
	if uses == 0:
		print(name + " broke!")
