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

var current_equipped_stat: combatMapUnitStat 
var current_damage_type : Constants.DAMAGE_TYPE = 0
var current_attack_range : Array[int] = []
var current_weapon_effectiveness : Array[unitConstants.TRAITS] = []
var current_required_mastery : itemConstants.MASTERY_REQUIREMENT = itemConstants.MASTERY_REQUIREMENT.E

@export var hover_stat : combatMapUnitStat = combatMapUnitStat.new() 
var hover_damage_type : Constants.DAMAGE_TYPE = 0
var hover_attack_range : Array[int] = []
var hover_weapon_effectiveness : Array[unitConstants.TRAITS] = []
var hover_required_mastery : itemConstants.MASTERY_REQUIREMENT = itemConstants.MASTERY_REQUIREMENT.E

@export var hovering_new_item : bool = false

func calculate_hover_stats(combat_unit: CombatUnit, wpn :WeaponDefinition):
	hover_stat.clear()
	hover_stat.populate_unit_stats(combat_unit.unit)
	hover_stat.populate_weapon_stats(combat_unit, wpn)

func populate_equipped_stats(current_stats: combatMapUnitStat, current_weapon: WeaponDefinition):
	self.current_equipped_stat = current_stats
	self.current_damage_type = current_weapon.item_damage_type
	self.current_attack_range = current_weapon.attack_range
	self.current_weapon_effectiveness = current_weapon.weapon_effectiveness
	self.current_required_mastery = current_weapon.required_mastery
	update_fields()

func update_hover_stats(combat_unit: CombatUnit, hover_weapon: WeaponDefinition):
	calculate_hover_stats(combat_unit, hover_weapon)
	self.hover_damage_type = hover_weapon.item_damage_type
	self.hover_attack_range = hover_weapon.attack_range
	self.hover_weapon_effectiveness = hover_weapon.weapon_effectiveness
	self.hover_required_mastery = hover_weapon.required_mastery
	hovering_new_item = true
	update_fields()
	
func update_fields():
	if not hovering_new_item:
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
	else:
		do_number_styling(damage_value,current_equipped_stat.damage.evaluate(),hover_stat.damage.evaluate())
		damage_type_icon.set_damage_type(hover_damage_type)
		do_number_styling(hit_value,current_equipped_stat.hit.evaluate(),hover_stat.hit.evaluate())
		do_number_styling(crit_value,current_equipped_stat.critical_chance.evaluate(),hover_stat.critical_chance.evaluate())
		do_number_styling(attack_speed_value,current_equipped_stat.attack_speed.evaluate(),hover_stat.attack_speed.evaluate())
		do_number_styling(avoid_value,current_equipped_stat.avoid.evaluate(),hover_stat.avoid.evaluate())
		do_number_styling(crit_mult_value,current_equipped_stat.critical_multiplier.evaluate(),hover_stat.critical_multiplier.evaluate())

func populate_hover_stats(hover_stats: combatMapUnitStat, hover_weapon: WeaponDefinition):
	self.hover_stat = hover_stats
	self.hover_damage_type = hover_weapon.item_damage_type
	self.hover_attack_range = hover_weapon.attack_range
	self.hover_weapon_effectiveness = hover_weapon.weapon_effectiveness
	self.hover_required_mastery = hover_weapon.required_mastery

func do_number_styling(target:Label, equip_value:int, hover_value:int):
	target.text = str(hover_value)
	target.set("theme_override_colors/font_color", base_color)
	if equip_value > hover_value: 
		target.set("theme_override_colors/font_color", decrease_color)
	elif equip_value < hover_value:
		target.set("theme_override_colors/font_color", increase_color)
