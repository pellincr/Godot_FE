extends VBoxContainer

const overworldButtonScene = preload("res://overworld/overworld_button.tscn")
var playerOverworldData : PlayerOverworldData
var control_node : Node
# Called when the node enters the scene tree for the first time.
func _ready():
	if playerOverworldData != null:
		instantiate_convoy_buttons()
	else:
		playerOverworldData = PlayerOverworldData.new()
		instantiate_convoy_buttons()

func set_po_data(po_data):
	playerOverworldData = po_data

func set_control_node(c_node):
	control_node = c_node

#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_buttons_list(button_count, button_text, button_function, button_container, text = false):
	var accum = []
	for i in range(button_count):
		#var button = OverworldButton.new()
		var button : OverworldButton = overworldButtonScene.instantiate()
		button.set_button_text(button_text)
		if text:
			button.set_button_pressed(button_function, button_text)
		else:
			button.set_button_pressed(button_function, i)
		button_container.add_child(button)
		accum.append(button)
	return accum


var convoy_buttons = []

func instantiate_convoy_buttons():
	convoy_buttons = create_buttons_list(playerOverworldData.convoy_size,"-EMPTY-",_on_convoy_button_pressed,
								$ScrollContainer/VBoxContainer)

func update_convoy_buttons():
	for i in convoy_buttons.size():
		if i < playerOverworldData.convoy.size():
			update_convoy_button(convoy_buttons[i],playerOverworldData.convoy[i])
		else:
			convoy_buttons[i].set_button_text("-EMPTY-")

func update_convoy_button(button: OverworldButton, item):
	button.contained_variable = item
	button.set_button_text(str(item.name))

func _on_convoy_button_pressed():
	pass
