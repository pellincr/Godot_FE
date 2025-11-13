extends Control


@onready var promotion_option_container: VBoxContainer = $PromotionOptionSelection/MarginContainer/PromotionOptionContainer
@onready var weapon_trait_icon_container: VBoxContainer = $UnitTypeDescription/VBoxContainer/WeaponTraitIconContainer
@onready var unit_type_description_label: Label = $UnitTypeDescription/VBoxContainer/UnitTypeDescriptionLabel
@onready var promotion_unit_icon: TextureRect = $PromotionUnitIcon
@onready var promotion_unit_type_label: Label = $PromotionUnitIcon/PromotionUnitTypeLabel

var available_promotions : Array[UnitTypeDefinition]
var current_promotion_option : UnitTypeDefinition

func _ready() -> void:
	#available_promotions = [UnitTypeDatabase.get_definition("lance_armor"),UnitTypeDatabase.get_definition("axe_armor"),UnitTypeDatabase.get_definition("sword_armor")]
	if available_promotions:
		fill_promotion_option_container()



func fill_promotion_option_container():
	for unit_type : UnitTypeDefinition in available_promotions:
		var button = preload("res://ui/shared/general_menu_button/general_menu_button.tscn").instantiate()
		button.text = unit_type.unit_type_name
		promotion_option_container.add_child(button)
		button.focus_entered.connect(_on_promotion_option_focus_entered)
		if !current_promotion_option:
			button.grab_focus()

func set_unit_type_description_label(desc):
	unit_type_description_label.text = desc

func set_unit_type_icon(texture):
	promotion_unit_icon.texture = texture

func set_unit_type_label(unit_type):
	promotion_unit_type_label.text = unit_type

func get_current_unit_type():
	for child_index in promotion_option_container.get_child_count():
		if promotion_option_container.get_child(child_index).has_focus():
			return available_promotions[child_index]

func update_by_current_promotion_option():
	weapon_trait_icon_container.unit = current_promotion_option
	weapon_trait_icon_container.set_icon_visibility()
	set_unit_type_description_label(current_promotion_option.description)
	set_unit_type_icon(current_promotion_option.icon)
	set_unit_type_label(current_promotion_option.unit_type_name)

func _on_promotion_option_focus_entered():
	var current_unit_type = get_current_unit_type()
	current_promotion_option = current_unit_type
	update_by_current_promotion_option()
