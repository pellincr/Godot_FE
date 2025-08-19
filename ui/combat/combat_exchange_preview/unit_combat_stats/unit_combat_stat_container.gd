extends VBoxContainer

@onready var dmg_value = $DamageContainer/Value
@onready var physical_icon = $DamageContainer/PhysicalIcon
@onready var magical_icon = $DamageContainer/MagicalIcon
@onready var damage_type_icon: DamageTypeIcon = $DamageContainer/DamageTypeIcon



@onready var hit_value = $HitContainer/Value

@onready var crit_value = $CritContainer/Value

var dmg :int 
var damage_type : Constants.DAMAGE_TYPE = Constants.DAMAGE_TYPE.NONE
var hit :int 
var crit :int 

func set_all(d: int, dt:Constants.DAMAGE_TYPE, h: int, c: int):
	self.dmg = d
	self.damage_type = dt
	self.hit = h
	self.crit = c
	update()

func set_label_value(label:Label,value:int):
	label.text = str(value)

func set_icon_visibility(icon, vis):
	icon.visible = vis

func update():
	set_label_value(dmg_value,dmg)
	set_label_value(hit_value,hit)
	set_label_value(crit_value,crit)
	damage_type_icon.set_damage_type(damage_type)
