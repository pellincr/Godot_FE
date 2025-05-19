extends VBoxContainer

signal item_bought(item : ItemDatabase)

const overworldButtonScene = preload("res://overworld/overworld_button.tscn")
var playerOverworldData : PlayerOverworldData
# Called when the node enters the scene tree for the first time.
func _ready():
	if playerOverworldData != null:
		instantiate_shop_buttons()
	else:
		playerOverworldData = PlayerOverworldData.new()
		instantiate_shop_buttons()

func set_po_data(po_data):
	playerOverworldData = po_data


#num string container -> list of buttons
#Creates a given amount of buttons with the specified text in the entered container
func create_buttons_list(button_count, button_text, button_function, button_container):
	var accum = []
	for i in range(button_count):
		#var button = OverworldButton.new()
		var button : OverworldButton = overworldButtonScene.instantiate()
		button.set_button_text(button_text)
		button.set_button_pressed(button_function, button_text)
		button_container.add_child(button)
		accum.append(button)
	return accum


#This section will have all the methods for interacting with the shop menu
var all_items = ItemDatabase.items.keys()
var magic_items = filter_items_by_damage_type(all_items, Constants.DAMAGE_TYPE.MAGIC)
var axe_items = filter_items_by_weapon_type(all_items, "Axe")

#Creates the initial amount of buttons needed in the Shop menu
func instantiate_shop_buttons():
	#set all items tab
	for i in all_items.size():
		create_buttons_list(1,all_items[i],_on_shop_item_button_pressed,
						$"TabContainer/All Items/VBoxContainer")
	#set axes tab
	for i in axe_items.size():
		create_buttons_list(1,axe_items[i],_on_shop_item_button_pressed,
						$TabContainer/Axes/VBoxContainer)
	#set magic tab
	for i in magic_items.size():
		create_buttons_list(1,magic_items[i],_on_shop_item_button_pressed,
						$TabContainer/Magic/VBoxContainer)


func _on_shop_item_button_pressed(button_text):
	if playerOverworldData.convoy.size() < playerOverworldData.convoy_size and playerOverworldData.gold >= 100:
		item_bought.emit(ItemDatabase.items.get(button_text))
		print("Item Bought!")


func filter_items_by_weapon_type(items, filter):
	var accum = []
	for i in items:
		var temp = ItemDatabase.items.get(i)
		if temp is WeaponDefinition:
			temp = temp.weapon_type
			if temp == filter:
				accum.append(i)
	return accum

func filter_items_by_damage_type(items, filter):
	var accum = []
	for i in items:
		var temp = ItemDatabase.items.get(i)
		if temp is WeaponDefinition:
			temp = temp.item_damage_type
			if temp == filter:
				accum.append(i)
	return accum
