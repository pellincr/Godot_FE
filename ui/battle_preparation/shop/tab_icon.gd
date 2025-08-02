extends PanelContainer

signal tab_switch(item_theme)

@onready var icon = $TextureRect
var on_tab_view = false

var item_theme 

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and has_focus():
		on_tab_view = true
		tab_switch.emit(item_theme)
		
	if on_tab_view:
		set_icon_color("FFFFFF")
	else:
		set_icon_color("828282")
	
	if has_focus():
		if on_tab_view:
			#when on tab view and has focus, should be big and bold
			self.theme = preload("res://ui/battle_preparation/shop/big_and_bold.tres")
		else:
			#when not on tab view but has vocus should be big but not bold
			self.theme = preload("res://ui/battle_preparation/shop/not_big_but_bold.tres")
	else:
		#when does not have focus should not be big or bold
		self.theme = preload("res://ui/battle_preparation/shop/not_big_not_bold.tres")
		



func set_icon(texture):
	icon.texture = texture
	

func set_icon_color(color):
	icon.self_modulate = color

func set_item_theme(theme):
	item_theme = theme

func _on_mouse_entered():
	grab_focus()
