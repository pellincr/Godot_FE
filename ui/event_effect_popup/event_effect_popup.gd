extends PanelContainer


@onready var effected_icon: TextureRect = $MarginContainer/HBoxContainer/EffectedIcon
@onready var effected_label: Label = $MarginContainer/HBoxContainer/EffectedLabel

var effect

func _ready():
	if effect:
		update_by_effect(effect)

func set_effected_icon(texture):
	effected_icon.texture = texture

func set_effected_label(text):
	effected_label.text = text

func update_by_effect(effect):
	set_effected_icon(effect.icon)
	set_effected_label(effect.name)
