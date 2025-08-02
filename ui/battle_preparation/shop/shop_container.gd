extends VBoxContainer


@onready var item_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/ItemTabIcon
#WEAPONS
@onready var sword_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/SwordTabIcon
@onready var axe_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/AxeTabIcon
@onready var lance_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/LanceTabIcon
@onready var bow_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/BowTabIcon
@onready var fist_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/FistTabIcon
@onready var staff_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/StaffTabIcon
@onready var dark_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/DarkTabIcon
@onready var light_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/LightTabIcon
@onready var nature_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/NatureTabIcon
@onready var animal_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/AnimalTabIcon
@onready var monster_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/MonsterTabIcon
@onready var shield_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/ShieldTabIcon
@onready var dagger_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/DaggerTabIcon
@onready var banner_tab_icon = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer/BannerTabIcon

@onready var main_shop_inventory_container = $HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var main_container = $HBoxContainer

const sword_icon_texture = preload("res://resources/sprites/icons/weapon_icons/sword_icon.png")
const axe_icon_texture = preload("res://resources/sprites/icons/weapon_icons/axe_icon.png")
const lance_icon_texture = preload("res://resources/sprites/icons/weapon_icons/lance_icon.png")
const bow_icon_texture = preload("res://resources/sprites/icons/weapon_icons/bow_icon.png")
const fist_icon_texture = preload("res://resources/sprites/icons/weapon_icons/fist_icon.png")
const staff_icon_texture = preload("res://resources/sprites/icons/weapon_icons/staff_icon.png")
const dark_icon_texture = preload("res://resources/sprites/icons/weapon_icons/dark_icon.png")
const light_icon_texture = preload("res://resources/sprites/icons/weapon_icons/light_icon.png")
const nature_icon_texture = preload("res://resources/sprites/icons/weapon_icons/nature_icon.png")
const animal_icon_texture = preload("res://resources/sprites/icons/weapon_icons/animal_icon.png")
const monster_icon_texture = preload("res://resources/sprites/icons/monster_icon.png")
const shield_icon_texture = preload("res://resources/sprites/icons/weapon_icons/shield_icon.png")
const dagger_icon_texture = preload("res://resources/sprites/icons/weapon_icons/dagger_icon.png")
const banner_icon_texture = preload("res://resources/sprites/icons/weapon_icons/banner_icon.png")
const item_icon_texture = preload("res://resources/sprites/icons/infantry_icon.png") #TEMPORARY

const item_panel_container_scene = preload("res://ui/battle_preparation/convoy_item_panel_container.tscn")
const weapon_detailed_info_scene = preload("res://ui/battle_preparation/item_detailed_info/weapon_detailed_info.tscn")

@onready var current_tab = ItemConstants.WEAPON_TYPE.SWORD

func _ready():
	sword_tab_icon.set_icon(sword_icon_texture)
	sword_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.SWORD)
	axe_tab_icon.set_icon(axe_icon_texture)
	axe_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.AXE)
	lance_tab_icon.set_icon(lance_icon_texture)
	lance_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.LANCE)
	bow_tab_icon.set_icon(bow_icon_texture)
	bow_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.BOW)
	fist_tab_icon.set_icon(fist_icon_texture)
	fist_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.FIST)
	staff_tab_icon.set_icon(staff_icon_texture)
	staff_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.STAFF)
	dark_tab_icon.set_icon(dark_icon_texture)
	dark_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.DARK)
	light_tab_icon.set_icon(light_icon_texture)
	light_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.LIGHT)
	nature_tab_icon.set_icon(nature_icon_texture)
	nature_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.NATURE)
	animal_tab_icon.set_icon(animal_icon_texture)
	animal_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.ANIMAL)
	monster_tab_icon.set_icon(monster_icon_texture)
	monster_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.MONSTER)
	shield_tab_icon.set_icon(shield_icon_texture)
	shield_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.SHIELD)
	dagger_tab_icon.set_icon(dagger_icon_texture)
	dagger_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.DAGGER)
	banner_tab_icon.set_icon(banner_icon_texture)
	banner_tab_icon.set_item_theme(ItemConstants.WEAPON_TYPE.BANNER)
	item_tab_icon.set_icon(item_icon_texture)
	item_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.USEABLE_ITEM)
	fill_current_tab_view()



func fill_current_tab_view():
	var items_list
	items_list = filter_by_weapon_type(current_tab)
	for item in items_list:
		var item_panel_container = item_panel_container_scene.instantiate()
		item_panel_container.item = item
		main_shop_inventory_container.add_child(item_panel_container)
		item_panel_container.focus_entered.connect(on_item_panel_focused.bind(item))

func clear_shop_list():
	var children = main_shop_inventory_container.get_children()
	for child in children:
		child.queue_free()

func turn_off_all_tabs():
	var tab_container = $HBoxContainer/VBoxContainer/ScrollContainer2/HBoxContainer
	var children = tab_container.get_children()
	for child in children:
		if child.item_theme == current_tab:
			pass
		else:
			child.on_tab_view = false

func filter_by_weapon_type(weapon_type : ItemConstants.WEAPON_TYPE):
	var all_items = ItemDatabase.items.keys()
	var accum = []
	for item_key in all_items:
		var item = ItemDatabase.items[item_key]
		if item is WeaponDefinition and item.weapon_type == weapon_type:
			accum.append(item)
	return accum


func _on_tab_icon_switch(item_theme):
	current_tab = item_theme
	update_shop_items()

func update_shop_items():
	if current_tab == ItemConstants.ITEM_TYPE.USEABLE_ITEM:
		pass
	else:
		clear_shop_list()
		turn_off_all_tabs()
		fill_current_tab_view()

func clear_main_container():
	var children = main_container.get_children()
	for child_index in children.size():
		if child_index != 0:
			children[child_index].queue_free()

func on_item_panel_focused(item):
	clear_main_container()
	var weapon_detailed_info = weapon_detailed_info_scene.instantiate()
	weapon_detailed_info.item = item
	main_container.add_child(weapon_detailed_info)
	weapon_detailed_info.update_by_item()
	weapon_detailed_info.layout_direction = Control.LAYOUT_DIRECTION_LTR
