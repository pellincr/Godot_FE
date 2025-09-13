extends VBoxContainer

@onready var sword_icon = $SwordIcon
@onready var axe_icon = $AxeIcon
@onready var lance_icon = $LanceIcon
@onready var shield_icon = $ShieldIcon
@onready var dagger_icon = $DaggerIcon
@onready var fist_icon = $FistIcon
@onready var bow_icon = $BowIcon
@onready var banner_icon = $BannerIcon
@onready var staff_icon = $StaffIcon
@onready var nature_icon = $NatureIcon
@onready var light_icon = $LightIcon
@onready var dark_icon = $DarkIcon
@onready var animal_icon = $AnimalIcon

var weapon_type : Array[ItemConstants.WEAPON_TYPE]
# Called when the node enters the scene tree for the first time.
func _ready():
	if weapon_type:
		set_icon_visibility()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_icon_visibility():
	if weapon_type.has(ItemConstants.WEAPON_TYPE.SWORD):
		sword_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.AXE):
		axe_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.LANCE):
		lance_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.SHIELD):
		shield_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.DAGGER):
		dagger_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.FIST):
		fist_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.BOW):
		bow_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.BANNER):
		banner_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.STAFF):
		staff_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.NATURE):
		nature_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.LIGHT):
		light_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.DARK):
		dark_icon.visible = true
	if weapon_type.has(ItemConstants.WEAPON_TYPE.ANIMAL):
		animal_icon.visible = true
