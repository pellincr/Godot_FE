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


var unit : Unit



func set_icon_visibility():
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
