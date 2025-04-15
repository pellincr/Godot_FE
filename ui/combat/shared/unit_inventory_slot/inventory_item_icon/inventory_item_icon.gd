extends Control

func set_image(texture: Texture2D):
	$ItemIcon.texture = texture

func set_item(item:ItemDefinition):
	if item:
		$ItemIcon.texture = item.icon
	else:
		$ItemIcon.texture = null

func clear_item():
	$ItemIcon.texture = null
