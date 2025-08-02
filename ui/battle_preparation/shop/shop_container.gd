extends VBoxContainer


@onready var sword_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/SwordTabIcon
@onready var axe_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/AxeTabIcon
@onready var lance_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/LanceTabIcon
@onready var bow_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/BowTabIcon
@onready var fist_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/FistTabIcon
@onready var staff_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/StaffTabIcon
@onready var dark_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/DarkTabIcon
@onready var light_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/LightTabIcon
@onready var nature_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/NatureTabIcon
@onready var animal_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/AnimalTabIcon
@onready var monster_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/MonsterTabIcon
@onready var shield_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/ShieldTabIcon
@onready var dagger_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/DaggerTabIcon
@onready var banner_tab_icon = $HBoxContainer/VBoxContainer/HBoxContainer/BannerTabIcon

@onready var main_shop_inventory_container = $HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer


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


const item_panel_container_scene = preload("res://ui/battle_preparation/convoy_item_panel_container.tscn")


enum TAB_VIEW{
	SWORD,
	AXE,
	LANCE,
	BOW,
	FIST,
	STAFF,
	DARK,
	LIGHT,
	NATURE,
	MONSTER,
	ANIMAL,
	SHIELD,
	DAGGER,
	BANNER
}

@onready var current_tab = TAB_VIEW.SWORD

func _ready():
	sword_tab_icon.set_icon(sword_icon_texture)
	axe_tab_icon.set_icon(axe_icon_texture)
	lance_tab_icon.set_icon(lance_icon_texture)
	bow_tab_icon.set_icon(bow_icon_texture)
	fist_tab_icon.set_icon(fist_icon_texture)
	staff_tab_icon.set_icon(staff_icon_texture)
	dark_tab_icon.set_icon(dark_icon_texture)
	light_tab_icon.set_icon(light_icon_texture)
	nature_tab_icon.set_icon(nature_icon_texture)
	animal_tab_icon.set_icon(animal_icon_texture)
	monster_tab_icon.set_icon(monster_icon_texture)
	shield_tab_icon.set_icon(shield_icon_texture)
	dagger_tab_icon.set_icon(dagger_icon_texture)
	banner_tab_icon.set_icon(banner_icon_texture)
	fill_current_tab_view()



func fill_current_tab_view():
	var items_list
	
	match current_tab:
		TAB_VIEW.SWORD:
			items_list = filter_by_weapon_type(ItemConstants.WEAPON_TYPE.SWORD)
			for item in items_list:
				var item_panel_container = item_panel_container_scene.instantiate()
				item_panel_container.item = item
				main_shop_inventory_container.add_child(item_panel_container)
			


func filter_by_weapon_type(weapon_type : ItemConstants.WEAPON_TYPE):
	var all_items = ItemDatabase.items.keys()
	var accum = []
	for item_key in all_items:
		var item = ItemDatabase.items[item_key]
		if item is WeaponDefinition and item.weapon_type == weapon_type:
			accum.append(item)
	return accum
