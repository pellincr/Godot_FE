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

@export var type: itemConstants.ITEM_TYPE
@export var weapon_type : itemConstants.WEAPON_TYPE


func set_types(new_type:  itemConstants.ITEM_TYPE, new_weapon_type: itemConstants.WEAPON_TYPE = itemConstants.WEAPON_TYPE.NONE):
	self.type = new_type
	if new_weapon_type != itemConstants.WEAPON_TYPE.NONE:
		self.weapon_type = new_weapon_type
	self.update()

func set_types_from_item(input_item: ItemDefinition):
	if input_item != null:
		self.type = input_item.item_type
		if input_item is WeaponDefinition:
			self.weapon_type = input_item.weapon_type
		else:
			self.weapon_type = itemConstants.WEAPON_TYPE.NONE
		update()
	else :
		self.texture = null

func update():
	match type:
		itemConstants.ITEM_TYPE.WEAPON:
			match type:
				itemConstants.WEAPON_TYPE.AXE:
					self.texture = AXE_ICON
				itemConstants.WEAPON_TYPE.BOW:
					self.texture = BOW_ICON
				itemConstants.WEAPON_TYPE.BANNER:
					self.texture = BANNER_ICON
				itemConstants.WEAPON_TYPE.DAGGER:
					self.texture = DAGGER_ICON
				itemConstants.WEAPON_TYPE.DARK:
					self.texture = DARK_ICON
				itemConstants.WEAPON_TYPE.FIST:
					self.texture = FIST_ICON
				itemConstants.WEAPON_TYPE.LANCE:
					self.texture = LANCE_ICON
				itemConstants.WEAPON_TYPE.LIGHT:
					self.texture = LIGHT_ICON
				itemConstants.WEAPON_TYPE.NATURE:
					self.texture = NATURE_ICON
				itemConstants.WEAPON_TYPE.SHIELD:
					self.texture = SHIELD_ICON
				itemConstants.WEAPON_TYPE.STAFF:
					self.texture = STAFF_ICON
				itemConstants.WEAPON_TYPE.SWORD:
					self.texture = SWORD_ICON
				itemConstants.WEAPON_TYPE.NONE:
					self.texture = null
		itemConstants.ITEM_TYPE.EQUIPMENT_LOOT:
			self.texture = null
