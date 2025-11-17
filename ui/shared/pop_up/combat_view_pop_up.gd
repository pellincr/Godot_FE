extends Control
class_name CombatViewPopUp

var type : String
var subject : String
var icon : Texture2D

@onready var text_label = $PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/Text
@onready var icon_display = $PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/Icon

func _init(popup_type: String, subject_input: String = "", subject_icon:Texture2D = null) -> void:
	self.type = popup_type
	self.subject = subject_input
	self.icon = subject_icon
	
func init_obtained_item_panel(item: String, icon:Texture2D):
	text_label.text = "Obtained a [color=#B22]" + item + "/[color=#B22]"
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

func set_item(i:ItemDefinition):
	if i != null:
		$PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/ItemName.text = i.name
		$PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo/Icon.texture = i.icon
		$PanelContainer/MarginContainer/CenterContainer/ItemPopUpInfo.visible = true

# Broke text

# Obtained Text

# Expended Text

# Stats Increased Text
