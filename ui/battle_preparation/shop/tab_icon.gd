extends PanelContainer

@onready var icon = $TextureRect


func set_icon(texture):
	icon.texture = texture
