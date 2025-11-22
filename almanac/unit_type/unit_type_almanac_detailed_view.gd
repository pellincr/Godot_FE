extends HBoxContainer


@onready var unit_type_label = $VBoxContainer/HBoxContainer/Panel/MarginContainer/MainContainer/HeaderContainer/UnitType

@onready var move_value_label = $VBoxContainer/HBoxContainer/Panel/MarginContainer/MainContainer/MoveConContainer/MoveContainer/Value
@onready var constitution_value_label = $VBoxContainer/HBoxContainer/Panel/MarginContainer/MainContainer/MoveConContainer/ConstitutionContainer/Value

@onready var unit_type_full_stat_container = $VBoxContainer/HBoxContainer/Panel/MarginContainer/MainContainer/UnitTypeFullStatContainer

@onready var weapon_type_container = $VBoxContainer/HBoxContainer/VBoxContainer/UnitTypeAlmanacWeaponTypes
@onready var trait_type_container = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/UnitTypeTraitContainer

@onready var mercenary_label = $VBoxContainer/HBoxContainer/FactionContainer/Mercenary
@onready var kingdom_label = $VBoxContainer/HBoxContainer/FactionContainer/Kingdom
@onready var theocracy_label = $VBoxContainer/HBoxContainer/FactionContainer/Theocracy
@onready var lawbreakers_label = $VBoxContainer/HBoxContainer/FactionContainer/Lawbreakers
@onready var cultist_label = $VBoxContainer/HBoxContainer/FactionContainer/Cultist
@onready var skeletal_label = $VBoxContainer/HBoxContainer/FactionContainer/Skeletal
@onready var monster_label = $VBoxContainer/HBoxContainer/FactionContainer/Monster

@onready var unit_icon = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/UnitIcon

@onready var unit_type_description_label = $VBoxContainer/PanelContainer/UnitTypeDescription



var unit_type : UnitTypeDefinition

# Called when the node enters the scene tree for the first time.
func _ready():
	if unit_type:
		update_by_unit_type()
	else:
		update_by_locked()


func set_value_label(label,value):
	label.text = str(value)

func set_label(label,text):
	label.text = text

func set_unit_icon(texture):
	unit_icon.texture = texture

func set_faction_text():
	var factions = unit_type.faction
	if factions.has(unitConstants.FACTION.MERCENARY):
		mercenary_label.visible = true
	if factions.has(unitConstants.FACTION.KINGDOM):
		kingdom_label.visible = true
	if factions.has(unitConstants.FACTION.THEOCRACY):
		theocracy_label.visible = true
	if factions.has(unitConstants.FACTION.LAWBREAKERS):
		lawbreakers_label.visible = true
	if factions.has(unitConstants.FACTION.CULTIST):
		cultist_label.visible = true
	if factions.has(unitConstants.FACTION.SKELETAL):
		skeletal_label.visible = true
	if factions.has(unitConstants.FACTION.MONSTER):
		monster_label.visible = true


func update_by_unit_type():
	set_label(unit_type_label,unit_type.unit_type_name)
	set_value_label(move_value_label,unit_type.base_stats.movement)
	set_value_label(constitution_value_label,unit_type.base_stats.constitution)
	set_label(unit_type_description_label,unit_type.description)
	set_unit_icon(unit_type.icon)
	set_faction_text()
	weapon_type_container.weapon_type = unit_type.usable_weapon_types
	weapon_type_container.set_icon_visibility()
	unit_type_full_stat_container.unit_type = unit_type
	unit_type_full_stat_container.update_by_unit_type()
	trait_type_container.unit_type = unit_type
	trait_type_container.set_icon_visibiltiy_by_unit_type()

func update_by_locked():
	var locked_icon = preload("res://resources/sprites/icons/UnitArchetype.png")
	set_label(unit_type_label,"???")
	set_value_label(move_value_label,"???")
	set_value_label(constitution_value_label,"???")
	set_label(unit_type_description_label,"Complete More Campaigns to See Potential New Secrets")
	set_unit_icon(locked_icon)
	unit_type_full_stat_container.update_by_locked()
