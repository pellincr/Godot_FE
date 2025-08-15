extends VBoxContainer

@onready var dmg_value = $DamageContainer/Value
@onready var physical_icon = $DamageContainer/PhysicalIcon
@onready var magical_icon = $DamageContainer/MagicalIcon



@onready var hit_value = $HitContainer/Value

@onready var crit_value = $CritContainer/Value

var unit : Unit

func _ready():
	if unit:
		update_by_unit()

func set_label_value(label:Label,value:int):
	label.text = str(value)

func set_icon_visibility(icon, vis):
	icon.visible = vis

#func update_damage_type_visibility_by_unit():
#	if 

func update_by_unit():
	set_label_value(dmg_value,unit.attack)
	set_label_value(hit_value,unit.hit)
	set_label_value(crit_value,unit.critical_hit)
	#update_damage_type_visibility_by_unit()
