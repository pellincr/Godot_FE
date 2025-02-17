extends Control

func set_item(item:ItemDefinition):
	$ItemIcon.texture = item.icon

func clear_item():
	$ItemIcon.texture = null
