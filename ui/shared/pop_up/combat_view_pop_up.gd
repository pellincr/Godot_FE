extends Control
class_name CombatViewPopUp

func set_item(i:ItemDefinition):
	if i != null:
		$PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/ItemName.text = i.name
		$PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/Icon.texture = i.icon
		$PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo.visible = true
