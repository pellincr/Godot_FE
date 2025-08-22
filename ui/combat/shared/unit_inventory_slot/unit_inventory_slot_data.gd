extends Resource
class_name UnitInventorySlotData


@export var item : ItemDefinition
@export var equipped : bool
#For Combat / Support 
@export var valid : bool = false

#For inventory Management
@export var can_use : bool = false
@export var can_arrange : bool = false
