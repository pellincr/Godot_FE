extends VBoxContainer

@onready var unit_icon = $UnitIcon
@onready var unit_name = $HBoxContainer/UnitName
@onready var unit_dead_icon = $HBoxContainer/UnitDeadIcon
@onready var unit_level = $UnitLevel

var unit : Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	if unit:
		update_by_unit()

func set_icon_texture(icon,texture):
	icon.texture = texture

func set_name_label(name):
	unit_name.text = name

func set_level_label(lvl):
	unit_level.text = "LV " + str(lvl)

func set_dead_icon_visibility(vis):
	unit_dead_icon.visible = vis

func update_by_unit():
	set_icon_texture(unit_icon, unit.icon)
	set_name_label(unit.name)
	set_level_label(unit.level)
