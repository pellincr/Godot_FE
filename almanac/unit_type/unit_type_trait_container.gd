extends VBoxContainer

@onready var armored_icon = $ArmoredIcon
@onready var mounted_icon = $MountedIcon
@onready var flier_icon = $FlierIcon
@onready var undead_icon = $UndeadIcon
@onready var light_icon: TextureRect = $LightIcon

var unit_type : UnitTypeDefinition
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_icon_visibiltiy_by_unit_type():
	var traits = unit_type.traits
	if traits.has(unitConstants.TRAITS.ARMORED):
		armored_icon.visible = true
	if traits.has(unitConstants.TRAITS.MOUNTED):
		mounted_icon.visible = true
	if traits.has(unitConstants.TRAITS.FLIER):
		flier_icon.visible = true
	if traits.has(unitConstants.TRAITS.TERROR):
		undead_icon.visible = true
	if traits.has(unitConstants.movement_type.MOBILE):
		light_icon.visible = true
