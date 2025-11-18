extends Control
class_name CombatViewPopUp

#var subject : String
#var icon : Texture2D

@onready var text_label = $PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/Text
@onready var icon_display = $PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/Icon
	
func init_obtained_item_panel(item: String, icon:Texture2D, color: Color):	
	text_label.text = "Obtained a [color=" + color.to_html() +"]" + item + "[color=#"+ color.to_html() + "]"
	icon_display.texture = icon

func init_expended_item(item: String, icon:Texture2D):
	text_label.text = item + " was expended"
	icon_display.texture = icon

func init_broke_item_panel(item: String, icon:Texture2D):
	text_label.text = "A " + item + " broke!"
	icon_display.texture = icon

func init_stats_increased():
	text_label.text = "Stats increased!"
	icon_display.texture = null
	icon_display.visible = false
