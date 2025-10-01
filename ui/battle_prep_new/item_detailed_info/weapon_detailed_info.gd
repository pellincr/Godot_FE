extends Panel


@onready var item_name_label = $MarginContainer/VBoxContainer/ItemNameLabel

@onready var main_weapon_icon_container = $MarginContainer/VBoxContainer/FullWeaponIconContainer/MainWeaponIconContainer
@onready var mundane_weapon_icon_container = $MarginContainer/VBoxContainer/FullWeaponIconContainer/MundaneWeaponIconContainer
@onready var magic_weapon_icon_container = $MarginContainer/VBoxContainer/FullWeaponIconContainer/MagicWeaponIconContainer


@onready var item_description_label = $MarginContainer/VBoxContainer/ItemDescriptionLabel

@onready var weapon_stat_container = $MarginContainer/VBoxContainer/WeaponStatContainer

@onready var item_rarity_header = $MarginContainer/VBoxContainer/ItemTypeContainer/ItemTypeHeader
@onready var item_type_header = $MarginContainer/VBoxContainer/ItemTypeContainer/ItemType


@onready var item_icon = $ItemIcon
@onready var price_label = $ItemIcon/PriceLabel

var item : ItemDefinition


func set_item_rarity_header(rarity : Rarity):
	item_rarity_header.text = rarity.rarity_name
	item_rarity_header.self_modulate = rarity.ui_color

func set_item_type_header(item: ItemDefinition):
	match item.item_type:
		ItemConstants.ITEM_TYPE.WEAPON:
			item_type_header.text = "Weapon"
		ItemConstants.ITEM_TYPE.STAFF:
			item_type_header.text = "Staff"
		ItemConstants.ITEM_TYPE.USEABLE_ITEM:
			item_type_header.text = "Consumable"
		ItemConstants.ITEM_TYPE.EQUIPMENT:
			item_type_header.text = "Equipment"
		ItemConstants.ITEM_TYPE.TREASURE:
			item_type_header.text = "Treasure"

func set_item_name(name):
	item_name_label.text = name

func set_item_description(desc):
	item_description_label.text = desc

func set_item_icon(texture):
	item_icon.texture = texture

func set_price_label(price):
	price_label.text = str(price) + "G"


func update_by_item():
	set_item_name(item.name)
	set_item_icon(item.icon)
	set_price_label(item.worth)
	set_item_rarity_header(item.rarity)
	main_weapon_icon_container.set_header_visibility(false)
	main_weapon_icon_container.item = item
	main_weapon_icon_container.set_icon_visibility_item()
	mundane_weapon_icon_container.set_header_visibility(false)
	mundane_weapon_icon_container.item = item
	mundane_weapon_icon_container.set_mundane_triangle_icon_visibility()
	magic_weapon_icon_container.set_header_visibility(false)
	magic_weapon_icon_container.item = item
	magic_weapon_icon_container.set_magic_triangle_icon_visibilty()
	set_item_type_header(item)
	set_item_description(item.description)
	weapon_stat_container.item = item
	weapon_stat_container.update_by_item()
