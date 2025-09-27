extends TextureRect


@onready var archetype_sub_icon_4: TextureRect = $IconContainer/UpperContainer/ArchetypeSubIcon4
@onready var archetype_sub_icon_5: TextureRect = $IconContainer/UpperContainer/ArchetypeSubIcon5
@onready var archetype_sub_icon_1: TextureRect = $IconContainer/LowerContainer/ArchetypeSubIcon1
@onready var archetype_sub_icon_2: TextureRect = $IconContainer/LowerContainer/ArchetypeSubIcon2
@onready var archetype_sub_icon_3: TextureRect = $IconContainer/LowerContainer/ArchetypeSubIcon3

@onready var sub_icon_list = [archetype_sub_icon_1,archetype_sub_icon_2,archetype_sub_icon_3,archetype_sub_icon_4,archetype_sub_icon_5]

var current_index := 0
#Weapon Type Icons
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
const item_icon_texture = preload("res://resources/sprites/icons/ui_icons/icon_potion.png") #TEMPORARY
#Damage Type Icons
const magic_damage_icon = preload("res://resources/sprites/icons/damage_icons/magic_damage_icon.png")
const physical_damage_icon = preload("res://resources/sprites/icons/damage_icons/physical_damage_icon.png")
const true_damage_icon = preload("res://resources/sprites/icons/damage_icons/true_damage_icon.png")

var item_archetype_pick : armyArchetypePickWeaponDefinition

func update_by_archetype_pick():
	var weapon_types := item_archetype_pick.weapon_type
	var item_damage_types := item_archetype_pick.item_damage_type
	var item_rarity := item_archetype_pick.item_rarity
	var scaling_types := item_archetype_pick.item_scaling_type
	if !weapon_types.is_empty():
		update_by_weapon_types(weapon_types)
	if !item_damage_types.is_empty():
		update_by_damage_types(item_damage_types)
	if item_rarity:
		update_by_item_rarity(item_rarity)
	if !scaling_types.is_empty():
		update_by_scaling_types(scaling_types)
	hide_remaining_sub_icons()
	current_index = 0

func set_icon(texture_rect, texture):
	texture_rect.texture = texture

func update_by_weapon_types(weapon_types:Array[itemConstants.WEAPON_TYPE]):
	for weapon_type in weapon_types:
		set_icon(sub_icon_list[current_index],get_weapon_type_icon(weapon_type))
		current_index += 1

func get_weapon_type_icon(weapon_type : itemConstants.WEAPON_TYPE):
	match weapon_type:
		itemConstants.WEAPON_TYPE.SWORD:
			return sword_icon_texture
		itemConstants.WEAPON_TYPE.AXE:
			return axe_icon_texture
		itemConstants.WEAPON_TYPE.LANCE:
			return lance_icon_texture
		itemConstants.WEAPON_TYPE.BOW:
			return bow_icon_texture
		itemConstants.WEAPON_TYPE.FIST:
			return fist_icon_texture
		itemConstants.WEAPON_TYPE.STAFF:
			return staff_icon_texture
		itemConstants.WEAPON_TYPE.DARK:
			return dark_icon_texture
		itemConstants.WEAPON_TYPE.LIGHT:
			return light_icon_texture
		itemConstants.WEAPON_TYPE.NATURE:
			return nature_icon_texture
		itemConstants.WEAPON_TYPE.ANIMAL:
			return animal_icon_texture
		itemConstants.WEAPON_TYPE.MONSTER:
			return monster_icon_texture
		itemConstants.WEAPON_TYPE.SHIELD:
			return shield_icon_texture
		itemConstants.WEAPON_TYPE.DAGGER:
			return dagger_icon_texture
		itemConstants.WEAPON_TYPE.BANNER:
			return banner_icon_texture

func update_by_damage_types(item_damage_types : Array[Constants.DAMAGE_TYPE]):
	for damage_type in item_damage_types:
		set_icon(sub_icon_list[current_index],get_damage_type_icon(damage_type))
		current_index += 1

func get_damage_type_icon(damage_type : Constants.DAMAGE_TYPE):
	match damage_type:
		Constants.DAMAGE_TYPE.MAGIC:
			return magic_damage_icon
		Constants.DAMAGE_TYPE.PHYSICAL:
			return physical_damage_icon
		Constants.DAMAGE_TYPE.TRUE:
			return true_damage_icon

func update_by_item_rarity(item_rarity:Rarity):
	modulate = item_rarity.ui_color

func update_by_scaling_types(item_scaling_types : Array[itemConstants.SCALING_TYPE]):
	pass

func hide_remaining_sub_icons():
	while current_index < sub_icon_list.size():
		sub_icon_list[current_index].visible = false
		current_index += 1
