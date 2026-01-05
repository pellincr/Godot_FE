extends PanelContainer



@onready var item_name_label: Label = $MarginContainer/MainContainer/ItemNameLabel
@onready var item_icon: TextureRect = $MarginContainer/MainContainer/ItemNameLabel/ItemIcon
@onready var item_worth_label: Label = $MarginContainer/MainContainer/ItemNameLabel/ItemIcon/ItemWorthLabel
@onready var item_description_label: Label = $MarginContainer/MainContainer/ItemDescriptionLabel
@onready var item_type_header: Label = $MarginContainer/MainContainer/ItemTypeContainer/ItemTypeHeader


var item : ItemDefinition

func _ready() -> void:
	#item = ItemDatabase.items.get("bastion_crab")
	if item:
		update_by_item()

func set_name_label(n):
	item_name_label.text = n

func set_icon(texture):
	item_icon.texture = texture

func set_item_description_label(description_text):
	item_description_label.text = description_text

func set_value_label(label,value):
	label.text = str(value)


func update_by_item():
	set_name_label(item.name)
	set_icon(item.icon)
	set_value_label(item_worth_label,item.worth)
	set_item_description_label(item.description)
	set_item_rarity_header(item.rarity)

func set_item_rarity_header(rarity : Rarity):
	item_type_header.text = rarity.rarity_name
	item_type_header.self_modulate = rarity.ui_color
