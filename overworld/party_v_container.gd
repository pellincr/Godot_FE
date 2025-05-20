extends VBoxContainer

const overworldButtonScene = preload("res://overworld/overworld_button.tscn")
const unit_stats = preload("res://overworld/unit_stats.tscn")

var playerOverworldData : PlayerOverworldData
var control_node : Node
# Called when the node enters the scene tree for the first time.
func _ready():
	if playerOverworldData != null:
		instantiate_party_buttons()
	else:
		playerOverworldData = PlayerOverworldData.new()
		instantiate_party_buttons()
	update_manage_party_buttons()

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


var party_buttons = []

#Creates the initial amount of buttons needed in the Manage Party menu
func instantiate_party_buttons():
	party_buttons = create_buttons_list(playerOverworldData.total_party_capacity,
	"-EMPTY-",_on_party_member_button_pressed,$ScrollContainer/VBoxContainer)

func update_manage_party_buttons():
	for i in party_buttons.size():
		if i < playerOverworldData.total_party.size():
			update_manage_party_button(party_buttons[i],playerOverworldData.total_party[i])
		else:
			party_buttons[i].set_button_text("-EMPTY-")

func update_manage_party_button(button: OverworldButton, unit: Unit):
	button.contained_variable = unit
	button.set_button_text("NAME:" + unit.unit_name + 
							"\n" + "CLASS:" + unit.unit_class_key)


func _on_party_member_button_pressed(button_index):
	if(party_buttons.size() > button_index):
		var pressed_button = party_buttons[button_index]
		var unit = pressed_button.get_contained_var()
		var button_container = pressed_button.get_hbox_container()
		if unit != null:
			var u_stats = unit_stats.instantiate()
			u_stats.set_po_data(playerOverworldData)
			u_stats.set_control_node(control_node)
			u_stats.connect("unit_selected", unit_selected)
			u_stats.connect("unit_dismissed",unit_dismissed)
			u_stats.unit = unit
			u_stats.set_level(unit.level)
			u_stats.set_hp(unit.hp)
			u_stats.set_strength(unit.strength)
			u_stats.set_magic(unit.magic)
			u_stats.set_skill(unit.skill)
			u_stats.set_speed(unit.speed)
			u_stats.set_luck(unit.luck)
			u_stats.set_defense(unit.defense)
			u_stats.set_magic_defense(unit.magic_defense)
			button_container.add_child(u_stats)

#adds or removes the given unit to the selected party
func unit_selected(unit, selected):
	if selected:
		playerOverworldData.append_to_array(playerOverworldData.selected_party,unit)
	elif playerOverworldData.selected_party.size() < playerOverworldData.available_party_capacity:
		playerOverworldData.selected_party.remove_at(playerOverworldData.selected_party.find(unit))

#removes the given unit from the total party and selected party if necessary
func unit_dismissed(unit):
	playerOverworldData.total_party.remove_at(playerOverworldData.total_party.find(unit))
	if playerOverworldData.selected_party.find(unit) != -1:
		playerOverworldData.selected_party.remove_at(playerOverworldData.selected_party.find(unit))
	unit = null
	update_manage_party_buttons()
