extends Control
class_name EquippableItemInformation

const ARMOR_ICON = preload("res://resources/sprites/icons/unit_trait_icons/armor_icon.png")
const FLYER_ICON = preload("res://resources/sprites/icons/unit_trait_icons/flyer_icon.png")
const MOUNTED_ICON = preload("res://resources/sprites/icons/unit_trait_icons/Mounted_icon.png")
const UNDEAD_ICON = preload("res://resources/sprites/icons/unit_trait_icons/undead_icon.png")

var base_color : Color = Color(1,1,1)
var decrease_color : Color = Color(0.652, 0, 0)
var increase_color : Color = Color(0, 0.826, 0.946)

@onready var damage_value: Label = $HBoxContainer/DamageContainer/DamageValue/DamageValue
@onready var damage_type_icon: DamageTypeIcon = $HBoxContainer/DamageContainer/DamageValue/DamageTypeIcon
@onready var hit_value: Label = $HBoxContainer/HitContainer/HitValue
@onready var crit_value: Label = $HBoxContainer/CritContainer/CritValue
@onready var attack_speed_value: Label = $HBoxContainer/AttackSpeedContainer/AttackSpeedValue
@onready var avoid_value: Label = $HBoxContainer/AvoidContainer/AvoidValue
@onready var crit_mult_value: Label = $HBoxContainer/CritMultiplierContainer/CritMultValue
@onready var range_value: Label = $HBoxContainer/RangeContainer/RangeValue

@onready var armored_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/ArmoredIcon
@onready var mounted_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/MountedIcon
@onready var flier_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/FlierIcon
@onready var undead_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/UndeadIcon
@onready var sword_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/SwordIcon
@onready var axe_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/AxeIcon
@onready var lance_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/LanceIcon
@onready var shield_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/ShieldIcon
@onready var dagger_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/DaggerIcon
@onready var fist_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/FistIcon
@onready var bow_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/BowIcon
@onready var banner_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/BannerIcon
@onready var staff_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/StaffIcon
@onready var nature_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/NatureIcon
@onready var light_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/LightIcon
@onready var dark_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/DarkIcon
@onready var animal_icon: TextureRect = $HBoxContainer/EffectivenessContainer/Value/AnimalIcon

var current_equipped_stat: CombatMapUnitNetStat 
var current_damage_type : Constants.DAMAGE_TYPE = 0
var current_attack_range : Array[int] = []
var current_weapon_effectiveness_trait : Array[unitConstants.TRAITS] = []
var current_weapon_effectiveness_wpn_type : Array[ItemConstants.WEAPON_TYPE] = []
var current_required_mastery : ItemConstants.MASTERY_REQUIREMENT = ItemConstants.MASTERY_REQUIREMENT.E

@export var hover_stat : CombatMapUnitNetStat = CombatMapUnitNetStat.new() 
var hover_damage_type : Constants.DAMAGE_TYPE = 0
var hover_attack_range : Array[int] = []
var hover_weapon_effectiveness_trait : Array[unitConstants.TRAITS] = []
var hover_weapon_effectiveness_wpn_type : Array[ItemConstants.WEAPON_TYPE] = []

var hover_required_mastery : ItemConstants.MASTERY_REQUIREMENT = ItemConstants.MASTERY_REQUIREMENT.E

@export var hovering_new_item : bool = false

func calculate_hover_stats(combat_unit: CombatUnit, weapon :WeaponDefinition = null):
	hover_stat.clear()
	if weapon != null:
		hover_stat.populate_unit_stats(combat_unit.unit)
		hover_stat.populate_weapon_stats(combat_unit, weapon)

func populate_equipped_stats(current_stats: CombatMapUnitNetStat, current_weapon: WeaponDefinition):
	self.current_equipped_stat = current_stats
	if current_weapon != null:
		self.current_damage_type = current_weapon.item_damage_type
		self.current_attack_range = current_weapon.attack_range
		self.current_weapon_effectiveness_trait = current_weapon.weapon_effectiveness_trait
		self.current_weapon_effectiveness_wpn_type = current_weapon.weapon_effectiveness_weapon_type
		self.current_required_mastery = current_weapon.required_mastery
	update_fields()

func update_hover_stats(combat_unit: CombatUnit, item: ItemDefinition):
	if item is WeaponDefinition:
		calculate_hover_stats(combat_unit, item)
		self.hover_damage_type = item.item_damage_type
		self.hover_attack_range = item.attack_range
		self.hover_weapon_effectiveness_trait = item.weapon_effectiveness_trait
		self.hover_weapon_effectiveness_wpn_type = item.weapon_effectiveness_weapon_type
		self.hover_required_mastery = item.required_mastery
		update_fields()
	else: 
		update_fields_consumable()
	hovering_new_item = true

	
func update_fields():
	if not hovering_new_item:
		if current_equipped_stat != null:
			damage_value.set("theme_override_colors/font_color", base_color)
			damage_value.text = str(current_equipped_stat.damage.evaluate())
			damage_type_icon.set_damage_type(current_damage_type)
			hit_value.set("theme_override_colors/font_color", base_color)
			hit_value.text = str(current_equipped_stat.hit.evaluate())
			crit_value.set("theme_override_colors/font_color", base_color)
			crit_value.text = str(current_equipped_stat.critical_chance.evaluate())
			attack_speed_value.set("theme_override_colors/font_color", base_color)
			attack_speed_value.text = str(current_equipped_stat.attack_speed.evaluate())
			avoid_value.set("theme_override_colors/font_color", base_color)
			avoid_value.text = str(current_equipped_stat.avoid.evaluate())
			crit_mult_value.set("theme_override_colors/font_color", base_color)
			crit_mult_value.text = str(current_equipped_stat.critical_multiplier.evaluate())
			set_effective_trait_visibility(current_weapon_effectiveness_trait, current_weapon_effectiveness_wpn_type)
	else:
		if current_equipped_stat != null:
			do_number_styling(damage_value,current_equipped_stat.damage.evaluate(),hover_stat.damage.evaluate())
			damage_type_icon.set_damage_type(hover_damage_type)
			do_number_styling(hit_value,current_equipped_stat.hit.evaluate(),hover_stat.hit.evaluate())
			do_number_styling(crit_value,current_equipped_stat.critical_chance.evaluate(),hover_stat.critical_chance.evaluate())
			do_number_styling(attack_speed_value,current_equipped_stat.attack_speed.evaluate(),hover_stat.attack_speed.evaluate())
			do_number_styling(avoid_value,current_equipped_stat.avoid.evaluate(),hover_stat.avoid.evaluate())
			do_number_styling(crit_mult_value,current_equipped_stat.critical_multiplier.evaluate(),hover_stat.critical_multiplier.evaluate())
			set_effective_trait_visibility(hover_weapon_effectiveness_trait, hover_weapon_effectiveness_wpn_type)
		

func update_fields_consumable():
	damage_value.set("theme_override_colors/font_color", base_color)
	damage_value.text = "--"
	damage_type_icon.set_damage_type(Constants.DAMAGE_TYPE.NONE)
	hit_value.set("theme_override_colors/font_color", base_color)
	hit_value.text = "--"
	crit_value.set("theme_override_colors/font_color", base_color)
	crit_value.text = "--"
	attack_speed_value.set("theme_override_colors/font_color", base_color)
	attack_speed_value.text = "--"
	avoid_value.set("theme_override_colors/font_color", base_color)
	avoid_value.text = "--"
	crit_mult_value.set("theme_override_colors/font_color", base_color)
	crit_mult_value.text = "--"
	set_effective_trait_visibility([],[])

func populate_hover_stats(hover_stats: CombatMapUnitNetStat, hover_weapon: WeaponDefinition):
	self.hover_stat = hover_stats
	self.hover_damage_type = hover_weapon.item_damage_type
	self.hover_attack_range = hover_weapon.attack_range
	self.hover_weapon_effectiveness_trait = hover_weapon.weapon_effectiveness_trait
	self.hover_weapon_effectiveness_wpn_type = hover_weapon.weapon_effectiveness_weapon_type
	self.hover_required_mastery = hover_weapon.required_mastery

func do_number_styling(target:Label, equip_value:int, hover_value:int):
	target.text = str(hover_value)
	target.set("theme_override_colors/font_color", base_color)
	if equip_value > hover_value: 
		target.set("theme_override_colors/font_color", decrease_color)
	elif equip_value < hover_value:
		target.set("theme_override_colors/font_color", increase_color)


func set_effective_trait_visibility(effective_traits, effective_weapon_types):
	for child in $HBoxContainer/EffectivenessContainer/Value.get_children():
		child.visible = false
	#DO TRATIS
	if effective_traits.has(unitConstants.TRAITS.ARMORED):
		armored_icon.visible = true
	if effective_traits.has(unitConstants.TRAITS.MOUNTED):
		mounted_icon.visible = true
	if effective_traits.has(unitConstants.TRAITS.FLIER):
		flier_icon.visible = true
	if effective_traits.has(unitConstants.TRAITS.UNDEAD):
		undead_icon.visible = true
	#Weapon Types
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.AXE):
		axe_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.LANCE):
		lance_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.SHIELD):
		shield_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.DAGGER):
		dagger_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.FIST):
		fist_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.BOW):
		bow_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.BANNER):
		banner_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.STAFF):
		staff_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.NATURE):
		nature_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.LIGHT):
		light_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.DARK):
		dark_icon.visible = true
	if effective_weapon_types.has(ItemConstants.WEAPON_TYPE.ANIMAL):
		animal_icon.visible = true	
