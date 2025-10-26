extends VBoxContainer

@onready var weapons_header_label = $WeaponsHeaderLabel

@onready var sword_icon = $WeaponTypeContainer/SwordIcon
@onready var axe_icon = $WeaponTypeContainer/AxeIcon
@onready var lance_icon = $WeaponTypeContainer/LanceIcon
@onready var shield_icon = $WeaponTypeContainer/ShieldIcon
@onready var dagger_icon = $WeaponTypeContainer/DaggerIcon
@onready var fist_icon = $WeaponTypeContainer/FistIcon
@onready var bow_icon = $WeaponTypeContainer/BowIcon
@onready var banner_icon = $WeaponTypeContainer/BannerIcon
@onready var staff_icon = $WeaponTypeContainer/StaffIcon
@onready var nature_icon = $WeaponTypeContainer/NatureIcon
@onready var light_icon = $WeaponTypeContainer/LightIcon
@onready var dark_icon = $WeaponTypeContainer/DarkIcon
@onready var animal_icon = $WeaponTypeContainer/AnimalIcon
@onready var consumable_icon: TextureRect = $WeaponTypeContainer/ConsumableIcon
@onready var equipment_icon: TextureRect = $WeaponTypeContainer/EquipmentIcon
@onready var treasure_icon: TextureRect = $WeaponTypeContainer/TreasureIcon

var unit : Unit

var item : ItemDefinition

func set_header_visibility(vis):
	weapons_header_label.visible = vis

func set_icon_visibility_unit():
	reset_icon_visibility()
	var usable_weapons = unit.usable_weapon_types
	var traits = unit.traits
	#Weapons
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.SWORD):
		sword_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.AXE):
		axe_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.LANCE):
		lance_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.SHIELD):
		shield_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.DAGGER):
		dagger_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.FIST):
		fist_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.BOW):
		bow_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.BANNER):
		banner_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.STAFF):
		staff_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.NATURE):
		nature_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.LIGHT):
		light_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.DARK):
		dark_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.ANIMAL):
		animal_icon.visible = true


func set_icon_visibility_item():
	reset_icon_visibility()
	if item is WeaponDefinition:
		if item.weapon_type == ItemConstants.WEAPON_TYPE.SWORD:
			sword_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.AXE:
			axe_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.LANCE:
			lance_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.SHIELD:
			shield_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.DAGGER:
			dagger_icon.visible = true
		if item.weapon_type ==ItemConstants.WEAPON_TYPE.FIST:
			fist_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.BOW:
			bow_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.BANNER:
			banner_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.STAFF:
			staff_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.NATURE:
			nature_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.LIGHT:
			light_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.DARK:
			dark_icon.visible = true
		if item.weapon_type == ItemConstants.WEAPON_TYPE.ANIMAL:
			animal_icon.visible = true
	if item.item_type == ItemConstants.ITEM_TYPE.USEABLE_ITEM:
		consumable_icon.visible = true
	if item.item_type == ItemConstants.ITEM_TYPE.EQUIPMENT:
		equipment_icon.visible = true
	if item.item_type == ItemConstants.ITEM_TYPE.TREASURE:
		treasure_icon.visible = true
		
func set_magic_triangle_icon_visibilty():
	if item is WeaponDefinition:
		match item.magic_weapon_triangle_type:
			ItemConstants.MAGICAL_WEAPON_TRIANGLE.NONE:
				pass
			ItemConstants.MAGICAL_WEAPON_TRIANGLE.NATURE:
				if item.weapon_type == ItemConstants.WEAPON_TYPE.NATURE:
					pass
				else:
					nature_icon.visible = true
			ItemConstants.MAGICAL_WEAPON_TRIANGLE.LIGHT:
				if item.weapon_type == ItemConstants.WEAPON_TYPE.LIGHT:
					pass
				else:
					light_icon.visible = true
			ItemConstants.MAGICAL_WEAPON_TRIANGLE.DARK:
				if item.weapon_type == ItemConstants.WEAPON_TYPE.DARK:
					pass
				else:
					dark_icon.visible = true

func set_mundane_triangle_icon_visibility():
	if item is WeaponDefinition:
		match item.physical_weapon_triangle_type:
			ItemConstants.MUNDANE_WEAPON_TRIANGLE.NONE:
				pass
			ItemConstants.MUNDANE_WEAPON_TRIANGLE.SWORD:
				if item.weapon_type == ItemConstants.WEAPON_TYPE.SWORD:
					pass
				else:
					sword_icon.visible = true
			ItemConstants.MUNDANE_WEAPON_TRIANGLE.AXE:
				if item.weapon_type == ItemConstants.WEAPON_TYPE.AXE:
					pass
				else:
					axe_icon.visible = true
			ItemConstants.MUNDANE_WEAPON_TRIANGLE.LANCE:
				if item.weapon_type == ItemConstants.WEAPON_TYPE.LANCE:
					pass
				else:
					lance_icon.visible = true

func reset_icon_visibility():
	sword_icon.visible = false
	axe_icon.visible = false
	lance_icon.visible = false
	shield_icon.visible = false
	dagger_icon.visible = false
	fist_icon.visible = false
	bow_icon.visible = false
	banner_icon.visible = false
	staff_icon.visible = false
	nature_icon.visible = false
	light_icon.visible = false
	dark_icon.visible = false
	animal_icon.visible = false
	consumable_icon.visible = false
	equipment_icon.visible = false
	treasure_icon.visible = false
