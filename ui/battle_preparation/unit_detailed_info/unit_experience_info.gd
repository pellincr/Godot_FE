extends VBoxContainer

@onready var unit_type_label = $UpperHalhContainer/TopLeftContainer/UnitTypeLabel
@onready var top_left_container = $UpperHalhContainer/TopLeftContainer
@onready var level_number_label = $UpperHalhContainer/LevelNumberLabel

@onready var experience_bar = $ExperienceBar

@onready var experience_value_label = $LowerHalfContainer/ExperienceValueLabel

var unit : Unit



func _ready():
	if unit != null:
		update_by_unit()





func set_unit_type_label(type):
	unit_type_label.text = type

func clear_unit_type_icon():
	var children = top_left_container.get_children()
	for child in children:
		if child is TextureRect:
			child.queue_free()

func set_unit_type_icon(unit_type: UnitTypeDefinition):
	clear_unit_type_icon()
	var icon = TextureRect.new()
	if unit_type.traits.has(unitConstants.TRAITS.ARMORED):
		icon.texture = preload("res://resources/sprites/icons/unit_trait_icons/armor_icon.png")
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		top_left_container.add_child(icon)
	if unit_type.traits.has(unitConstants.TRAITS.MOUNTED):
		icon.texture = preload("res://resources/sprites/icons/unit_trait_icons/Mounted_icon.png")
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		top_left_container.add_child(icon)
	if unit_type.traits.has(unitConstants.TRAITS.UNDEAD):
		icon.texture = preload("res://resources/sprites/icons/unit_trait_icons/undead_icon.png")
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		top_left_container.add_child(icon)
	if unit_type.traits.has(unitConstants.TRAITS.LOCKPICK):
		icon.texture = preload("res://resources/sprites/icons/unit_trait_icons/flyer_icon.png")
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		top_left_container.add_child(icon)
	if unit_type.traits.has(unitConstants.TRAITS.MASSIVE):
		icon.texture = preload("res://resources/sprites/icons/unit_trait_icons/flyer_icon.png")
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		top_left_container.add_child(icon)
	if unit_type.traits.has(unitConstants.TRAITS.FLIER):
		icon.texture = preload("res://resources/sprites/icons/unit_trait_icons/flyer_icon.png")
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		top_left_container.add_child(icon)

func set_level_number_label(level):
	level_number_label.text = "lv " +  str(level)

func set_experience_bar_value(exp):
	experience_bar.value = exp

func set_experience_value_label(exp):
	experience_value_label.text = "EXP: " + str(exp) + "/100"

func update_by_unit():
	var unit_type :UnitTypeDefinition
	if UnitTypeDatabase.unit_types.keys().has(unit.unit_type_key):
		unit_type = UnitTypeDatabase.unit_types.get(unit.unit_type_key)
	else:
		unit_type = CommanderDatabase.commander_types.get(unit.unit_type_key)
	set_unit_type_label(unit_type.unit_type_name)
	set_unit_type_icon(unit_type)
	set_level_number_label(unit.level)
	set_experience_bar_value(unit.experience)
	set_experience_value_label(unit.experience)
