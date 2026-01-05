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
#Trait Icons
const armored_icon = preload("res://resources/sprites/icons/unit_trait_icons/armor_icon.png")
const flyer_icon = preload("res://resources/sprites/icons/unit_trait_icons/flyer_icon.png")
const mounted_icon = preload("res://resources/sprites/icons/unit_trait_icons/Mounted_icon.png")
const undead_icon = preload("res://resources/sprites/icons/unit_trait_icons/undead_icon.png")
const mobile_icon = preload("res://resources/sprites/icons/unit_trait_icons/light_move_icon.png")

var unit_archetype_pick : armyArchetypePickUnitDefinition

func update_by_archetype_pick():
	var weapon_types = unit_archetype_pick.weapon_types
	var unit_type = unit_archetype_pick.unit_type
	var traits = unit_archetype_pick.traits
	var rarity = unit_archetype_pick.rarity
	var factions = unit_archetype_pick.factions
	if !weapon_types.is_empty():
		update_by_weapon_types(weapon_types)
	if unit_type:
		update_by_unit_type(unit_type)
	if !traits.is_empty():
		update_by_traits(traits)
	if rarity:
		update_by_rarity(rarity)
	if !factions.is_empty():
		update_by_factions(factions)
	hide_remaining_sub_icons()
	current_index = 0

func set_icon(texture_rect, texture):
	texture_rect.texture = texture

func update_by_weapon_types(weapon_types:Array[ItemConstants.WEAPON_TYPE]):
	for weapon_type in weapon_types:
		set_icon(sub_icon_list[current_index],get_weapon_type_icon(weapon_type))
		current_index += 1

func get_weapon_type_icon(weapon_type : ItemConstants.WEAPON_TYPE):
	match weapon_type:
		ItemConstants.WEAPON_TYPE.SWORD:
			return sword_icon_texture
		ItemConstants.WEAPON_TYPE.AXE:
			return axe_icon_texture
		ItemConstants.WEAPON_TYPE.LANCE:
			return lance_icon_texture
		ItemConstants.WEAPON_TYPE.BOW:
			return bow_icon_texture
		ItemConstants.WEAPON_TYPE.FIST:
			return fist_icon_texture
		ItemConstants.WEAPON_TYPE.STAFF:
			return staff_icon_texture
		ItemConstants.WEAPON_TYPE.DARK:
			return dark_icon_texture
		ItemConstants.WEAPON_TYPE.LIGHT:
			return light_icon_texture
		ItemConstants.WEAPON_TYPE.NATURE:
			return nature_icon_texture
		ItemConstants.WEAPON_TYPE.ANIMAL:
			return animal_icon_texture
		ItemConstants.WEAPON_TYPE.MONSTER:
			return monster_icon_texture
		ItemConstants.WEAPON_TYPE.SHIELD:
			return shield_icon_texture
		ItemConstants.WEAPON_TYPE.DAGGER:
			return dagger_icon_texture
		ItemConstants.WEAPON_TYPE.BANNER:
			return banner_icon_texture

func update_by_unit_type(unit_type):
	var unit_def := UnitTypeDatabase.get_definition(unit_type)
	var icon = unit_def.icon
	texture = icon
	self_modulate = 828282

func update_by_traits(traits):
	for unit_trait : unitConstants.TRAITS in traits:
		set_icon(sub_icon_list[current_index],get_trait_icon(unit_trait))
		current_index += 1

func get_trait_icon(unit_trait : unitConstants.TRAITS):
	match unit_trait:
		unitConstants.TRAITS.ARMORED:
			return armored_icon
		unitConstants.TRAITS.MOUNTED:
			return mounted_icon
		unitConstants.TRAITS.FLIER:
			return flyer_icon


func update_by_rarity(rarity:Rarity):
	self_modulate = rarity.ui_color

func update_by_factions(factions):
	pass

func hide_remaining_sub_icons():
	while current_index < sub_icon_list.size():
		sub_icon_list[current_index].visible = false
		current_index += 1
