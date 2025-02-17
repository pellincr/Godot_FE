extends Control

class_name IventoryOptionsContainer

func show_options(item:ItemDefinition):
	$OptionsContainer.visible = true
	if item is WeaponDefinition:
		$OptionsContainer/Panel/VBoxContainer/Button1.text = "Equip"
	else :
		$OptionsContainer/Panel/VBoxContainer/Button1.text = "Use"
	$OptionsContainer/Panel/VBoxContainer/Button2.text = "Discard"


func get_button1() -> Button:
	return $Container/Panel/CenterContainer/VBoxContainer/Button1

func get_button2() -> Button:
	return $Container/Panel/CenterContainer/VBoxContainer/Button2
