extends HBoxContainer

@onready var armored_icon = $ArmoredIcon
@onready var mounted_icon = $MountedIcon
@onready var flier_icon = $FlierIcon
@onready var undead_icon = $UndeadIcon

func set_all_icons_invisible():
	armored_icon.visible = false
	mounted_icon.visible = false
	flier_icon.visible = false
	undead_icon.visible = false

func set_icon_visibility(unit : Unit):
	set_all_icons_invisible()
	match unit.traits:
		unitConstants.TRAITS.ARMORED:
			armored_icon.visible = true
		unitConstants.TRAITS.MOUNTED:
			mounted_icon.visible = true
		unitConstants.TRAITS.FLIER:
			flier_icon.visible = true
		unitConstants.TRAITS.UNDEAD:
			undead_icon.visible = true
