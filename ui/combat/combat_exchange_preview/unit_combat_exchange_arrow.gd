extends VBoxContainer
class_name UnitCombatExchangeArrow

@onready var damage_value = $HBoxContainer/DamageValue
@onready var damage_type_icon: DamageTypeIcon = $HBoxContainer/DamageTypeIcon


@onready var attack_direction_arrow = $AttackDirectionArrow

@export var dmg :int
@export var attack_quantity :int
@export var damage_type:Constants.DAMAGE_TYPE
@export var flipped: bool = false

func set_damage_value_label(dmg:int, aq: int):
	if aq != 1:
		damage_value.text = str(dmg) + " x " + str(aq)
	else:
		damage_value.text = str(dmg)

func set_damage_type_icon_visibility(dmg_type):
	damage_type_icon.set_damage_type(dmg_type)

func flip_attack_direction_arrow(flip:bool):
	attack_direction_arrow.flip_h = flip

func update():
	set_damage_value_label(dmg, attack_quantity)
	set_damage_type_icon_visibility(damage_type)
	flip_attack_direction_arrow(flipped)

func populate(dmg: int, attack_quantity:int, damage_type:Constants.DAMAGE_TYPE = Constants.DAMAGE_TYPE.NONE, flipped: bool = false):
	self.dmg = dmg
	self.attack_quantity = attack_quantity
	self.damage_type = damage_type
	self.flipped = flipped
	update()
