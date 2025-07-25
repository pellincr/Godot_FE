extends VBoxContainer

@onready var sword_icon = $WeaponTypeContainer/SwordIcon
@onready var axe_icon = $WeaponTypeContainer/AxeIcon
@onready var lance_icon = $WeaponTypeContainer/LanceIcon
@onready var fist_icon = $WeaponTypeContainer/FistIcon
@onready var bow_icon = $WeaponTypeContainer/BowIcon
@onready var staff_icon = $WeaponTypeContainer/StaffIcon
@onready var light_icon = $WeaponTypeContainer/LightIcon
@onready var dark_icon = $WeaponTypeContainer/DarkIcon
#Traits
@onready var infantry_icon = $TraitsContainer/InfantryIcon
@onready var armored_icon = $TraitsContainer/ArmoredIcon
@onready var mounted_icon = $TraitsContainer/MountedIcon
@onready var monster_icon = $TraitsContainer/MonsterIcon
@onready var flier_icon = $TraitsContainer/FlierIcon
@onready var animal_icon = $TraitsContainer/AnimalIcon


func set_icon_visibility(unit:Unit):
	var usable_weapons = unit.usable_weapon_types
	var traits = unit.traits
	#Weapons
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.SWORD):
		sword_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.AXE):
		axe_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.LANCE):
		lance_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.FIST):
		fist_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.BOW):
		bow_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.STAFF):
		staff_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.LIGHT):
		light_icon.visible = true
	if usable_weapons.has(ItemConstants.WEAPON_TYPE.DARK):
		dark_icon.visible = true
	#Traits
	if traits.has(unitConstants.TRAITS.ARMORED):
		armored_icon.visible = true
	if traits.has(unitConstants.TRAITS.MOUNTED):
		mounted_icon.visible = true
	if traits.has(unitConstants.TRAITS.FLIER):
		flier_icon.visible = true
	if traits.has(unitConstants.TRAITS.UNDEAD):
		monster_icon.visible = true
	if traits.has(unitConstants.TRAITS.LOCKPICK):
		armored_icon.visible = true#NO ICON EXISTS CURRENTLY
	if traits.has(unitConstants.TRAITS.MASSIVE):
		armored_icon.visible = true#NO ICON EXISTS CURRENTLY
