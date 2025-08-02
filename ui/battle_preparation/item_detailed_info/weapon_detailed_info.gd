extends Panel


@onready var item_name_label = $MarginContainer/VBoxContainer/ItemNameLabel

@onready var weapon_icon_container = $MarginContainer/VBoxContainer/WeaponIconContainer

@onready var item_description_label = $MarginContainer/VBoxContainer/ItemDescriptionLabel

@onready var weapon_stat_container = $MarginContainer/VBoxContainer/WeaponStatContainer

@onready var stat_augment_label = $MarginContainer/VBoxContainer/StatAugmentContainer/StatAugmentLabel
@onready var special_value_container = $MarginContainer/VBoxContainer/SpecialTraitContainer/SpecialValueLabel

@onready var item_icon = $ItemIcon


var item : ItemDefinition




func set_item_name(name):
	item_name_label.text = name

func set_item_description(desc):
	item_description_label.text = desc

func set_item_icon(texture):
	item_icon.texture = texture

func set_stat_augmentation(augmentation):
	pass

func set_special(special_list):
	pass


func update_by_item():
	set_item_name(item.name)
	set_item_icon(item.icon)
	weapon_icon_container.set_header_visibility(false)
	weapon_icon_container.item = item
	weapon_icon_container.set_icon_visibility_item()
	set_item_description(item.description)
	weapon_stat_container.item = item
	weapon_stat_container.update_by_item()
	set_stat_augmentation(null)#TO BE UPDATED WHEN ITEM IS UPDATED
	set_special(null)#TO BE UPDATED WHE ITEM IS UPDATED
	
