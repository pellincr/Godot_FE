extends PanelContainer


@onready var unit_type_label = $MarginContainer/HBoxContainer/UnitTypeLabel
@onready var unit_type_icon = $MarginContainer/HBoxContainer/UnitTypeIcon

var unit_type : UnitTypeDefinition



# Called when the node enters the scene tree for the first time.
func _ready():
	if unit_type:
		update_by_unit_type()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_focus():
		theme = preload("res://unit_type_dictionary/panel_container_focused.tres")
	else:
		theme = preload("res://unit_type_dictionary/panel_container_not_focused.tres")


func set_unit_type_label(text):
	unit_type_label.text = text

func set_unit_type_icon(texture):
	unit_type_icon.texture = texture
	


func update_by_unit_type():
	set_unit_type_label(unit_type.unit_type_name)
	set_unit_type_icon(unit_type.icon)


func _on_mouse_entered():
	grab_focus()
