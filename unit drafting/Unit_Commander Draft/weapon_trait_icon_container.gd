extends VBoxContainer

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
#Traits
@onready var armored_icon = $TraitsContainer/ArmoredIcon
@onready var mounted_icon = $TraitsContainer/MountedIcon
@onready var undead_icon = $TraitsContainer/UndeadIcon
@onready var flier_icon = $TraitsContainer/FlierIcon
@onready var mobile_icon = $TraitsContainer/LightMoveIcon

var unit : UnitTypeDefinition

func _ready():
	if unit!= null:
		set_icon_visibility()


func set_icon_visibility():
	var usable_weapons = unit.usable_weapon_types
	var traits = unit.traits
	#Weapons
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.SWORD):
		sword_icon.visible = true
	else:
		sword_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.AXE):
		axe_icon.visible = true
	else:
		axe_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.LANCE):
		lance_icon.visible = true
	else:
		lance_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.SHIELD):
		shield_icon.visible = true
	else:
		shield_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.DAGGER):
		dagger_icon.visible = true
	else:
		dagger_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.FIST):
		fist_icon.visible = true
	else:
		fist_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.BOW):
		bow_icon.visible = true
	else:
		bow_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.BANNER):
		banner_icon.visible = true
	else:
		banner_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.STAFF):
		staff_icon.visible = true
	else:
		staff_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.NATURE):
		nature_icon.visible = true
	else:
		nature_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.LIGHT):
		light_icon.visible = true
	else:
		light_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.DARK):
		dark_icon.visible = true
	else:
		dark_icon.visible = false
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.ANIMAL):
		animal_icon.visible = true
	else:
		animal_icon.visible = false
	#Traits
	if traits.has(unitConstants.TRAITS.ARMORED):
		armored_icon.visible = true
	else:
		armored_icon.visible = false
	if traits.has(unitConstants.TRAITS.MOUNTED):
		mounted_icon.visible = true
	else:
		mounted_icon.visible = false
	if traits.has(unitConstants.TRAITS.FLIER):
		flier_icon.visible = true
	else:
		flier_icon.visible = false
	if traits.has(unitConstants.TRAITS.TERROR):
		undead_icon.visible = true
	else:
		undead_icon.visible = false
