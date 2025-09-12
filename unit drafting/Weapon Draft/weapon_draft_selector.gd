extends Control

const treasure_blacklist = ["iron_sword","iron_axe","iron_lance","iron_bow","iron_fist","heal_staff","shade","smite", "fire_spell","iron_shield","iron_dagger"]

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

@export var weapon : WeaponDefinition

func update_all():
	set_item_name(weapon.name)
	set_item_icon(weapon.icon)
	set_price_label(weapon.worth)
	set_item_rarity_header(weapon.rarity)
	main_weapon_icon_container.set_header_visibility(false)
	main_weapon_icon_container.item = weapon
	main_weapon_icon_container.set_icon_visibility_item()
	mundane_weapon_icon_container.set_header_visibility(false)
	mundane_weapon_icon_container.item = weapon
	mundane_weapon_icon_container.set_mundane_triangle_icon_visibility()
	magic_weapon_icon_container.set_header_visibility(false)
	magic_weapon_icon_container.item = weapon
	magic_weapon_icon_container.set_magic_triangle_icon_visibilty()
	set_item_description(weapon.description)
	weapon_stat_container.item = weapon
	weapon_stat_container.update_by_item()

func set_item_rarity_header(rarity : Rarity):
	item_rarity_header.text = rarity.rarity_name
	item_rarity_header.self_modulate = rarity.ui_color

func set_item_type_header(item_type):
	item_type_header.text = item_type

func set_item_name(name):
	item_name_label.text = name

func set_item_description(desc):
	item_description_label.text = desc

func set_item_icon(texture):
	item_icon.texture = texture

func set_price_label(price):
	price_label.text = str(price) + "G"

func randomize_weapon() -> WeaponDefinition:
	# Remove default / Iron Weapons
	var all_item_types = ItemDatabase.items.keys()
	var all_weapon_types = []
	for item_key in all_item_types:
		if item_key not in treasure_blacklist:
			if ItemDatabase.items.get(item_key) is WeaponDefinition:
				var roll = randi_range(0, 100)
				if roll < 3:
					if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["legendary"]:
						all_weapon_types.append(ItemDatabase.items.get(item_key))
				elif roll < 10:
					if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["mythical"]:
						all_weapon_types.append(ItemDatabase.items.get(item_key))
				elif roll < 25:
					if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["rare"]:
						all_weapon_types.append(ItemDatabase.items.get(item_key))
				elif roll < 40:
					if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["rare"]:
						all_weapon_types.append(ItemDatabase.items.get(item_key))
				elif roll < 65:
					if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["uncommon"]:
						all_weapon_types.append(ItemDatabase.items.get(item_key))
				else :
					if ItemDatabase.items[item_key].rarity == RarityDatabase.rarities["common"]:
						all_weapon_types.append(ItemDatabase.items.get(item_key))
				#all_weapon_types.append(ItemDatabase.items.get(item_key))
	return all_weapon_types.pick_random()
