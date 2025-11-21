extends TextureRect
class_name ItemTypeIcon

#Icons
const ANIMAL_ICON = preload("res://resources/sprites/icons/weapon_icons/animal_icon.png")
const AXE_ICON = preload("res://resources/sprites/icons/weapon_icons/axe_icon.png")
const BOW_ICON = preload("res://resources/sprites/icons/weapon_icons/bow_icon.png")
const BANNER_ICON = preload("res://resources/sprites/icons/weapon_icons/banner_icon.png")
const DAGGER_ICON = preload("res://resources/sprites/icons/weapon_icons/dagger_icon.png")
const DARK_ICON = preload("res://resources/sprites/icons/weapon_icons/dark_icon.png")
const FIST_ICON = preload("res://resources/sprites/icons/weapon_icons/fist_icon.png")
const LANCE_ICON = preload("res://resources/sprites/icons/weapon_icons/lance_icon.png")
const LIGHT_ICON = preload("res://resources/sprites/icons/weapon_icons/light_icon.png")
const NATURE_ICON = preload("res://resources/sprites/icons/weapon_icons/nature_icon.png")
const SHIELD_ICON = preload("res://resources/sprites/icons/weapon_icons/shield_icon.png")
const STAFF_ICON = preload("res://resources/sprites/icons/weapon_icons/staff_icon.png")
const SWORD_ICON = preload("res://resources/sprites/icons/weapon_icons/sword_icon.png")

const TREASURE_ICON = preload("uid://dmiyk53kpvbxu")
const EQUIPMENT_ICON_2 = preload("uid://d1ac55ixfm31n")
const CONSUMABLE_ICON = preload("uid://bvcesanalw154")
const ICON_POTION = preload("uid://vla6wmq1pcqy")


@export var type: ItemConstants.ITEM_TYPE
@export var weapon_type : ItemConstants.WEAPON_TYPE
@export var use_effect : ItemConstants.CONSUMABLE_USE_EFFECT


func set_types(new_type:  ItemConstants.ITEM_TYPE, new_weapon_type: ItemConstants.WEAPON_TYPE = ItemConstants.WEAPON_TYPE.NONE,  new_consume_type: ItemConstants.CONSUMABLE_USE_EFFECT = ItemConstants.CONSUMABLE_USE_EFFECT.NONE):
	self.type = new_type
	if type == ItemConstants.ITEM_TYPE.WEAPON:
		if new_weapon_type != ItemConstants.WEAPON_TYPE.NONE:
			self.weapon_type = new_weapon_type
	if type == ItemConstants.ITEM_TYPE.USEABLE_ITEM:
		if new_consume_type != ItemConstants.CONSUMABLE_USE_EFFECT.NONE:
			self.use_effect = new_consume_type
	self.update()

func set_types_from_item(input_item: ItemDefinition):
	if input_item != null:
		self.type = input_item.item_type
		if input_item is WeaponDefinition:
			self.weapon_type = input_item.weapon_type
		else:
			self.weapon_type = ItemConstants.WEAPON_TYPE.NONE
		if input_item is ConsumableItemDefinition:
			self.use_effect = input_item.use_effect
		else:
			self.use_effect = ItemConstants.CONSUMABLE_USE_EFFECT.NONE
		update()
	else :
		self.texture = null


func update():
	match type:
		ItemConstants.ITEM_TYPE.WEAPON:
			match weapon_type:
				ItemConstants.WEAPON_TYPE.AXE:
					self.texture = AXE_ICON
				ItemConstants.WEAPON_TYPE.BOW:
					self.texture = BOW_ICON
				ItemConstants.WEAPON_TYPE.BANNER:
					self.texture = BANNER_ICON
				ItemConstants.WEAPON_TYPE.DAGGER:
					self.texture = DAGGER_ICON
				ItemConstants.WEAPON_TYPE.DARK:
					self.texture = DARK_ICON
				ItemConstants.WEAPON_TYPE.FIST:
					self.texture = FIST_ICON
				ItemConstants.WEAPON_TYPE.LANCE:
					self.texture = LANCE_ICON
				ItemConstants.WEAPON_TYPE.LIGHT:
					self.texture = LIGHT_ICON
				ItemConstants.WEAPON_TYPE.NATURE:
					self.texture = NATURE_ICON
				ItemConstants.WEAPON_TYPE.SHIELD:
					self.texture = SHIELD_ICON
				ItemConstants.WEAPON_TYPE.STAFF:
					self.texture = STAFF_ICON
				ItemConstants.WEAPON_TYPE.SWORD:
					self.texture = SWORD_ICON
				ItemConstants.WEAPON_TYPE.NONE:
					self.texture = null
		ItemConstants.ITEM_TYPE.EQUIPMENT:
			self.texture = EQUIPMENT_ICON_2
		ItemConstants.ITEM_TYPE.TREASURE:
			self.texture = TREASURE_ICON
		ItemConstants.ITEM_TYPE.USEABLE_ITEM:
			match use_effect:
				ItemConstants.CONSUMABLE_USE_EFFECT.HEAL:
					self.texture = ICON_POTION
				ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
					self.texture = CONSUMABLE_ICON
