extends PanelContainer

#signal item_bought(item)
#signal item_sent_to_unit(item)
#signal item_sold(item)
signal item_panel_pressed(item)

@onready var left_container: HBoxContainer = $MarginContainer/HBoxContainer/LeftContainer
@onready var item_icon: TextureRect = $MarginContainer/HBoxContainer/LeftContainer/ItemIcon
@onready var item_name_label: Label = $MarginContainer/HBoxContainer/LeftContainer/ItemNameLabel

@onready var uses_label: Label = $MarginContainer/HBoxContainer/UsesLabel

var item : ItemDefinition

func _ready():
	if !item:
		item = ItemDatabase.items["iron_axe"]
	update_by_item()

func _on_mouse_entered():
	grab_focus()



func set_item_icon(texture):
	item_icon.texture = texture

func set_item_name_label(item_name):
	item_name_label.text = item_name

func set_uses_label(use_count):
	if use_count > 0:
		uses_label.text = str(use_count)
	else:
		uses_label.text = ""

func update_by_item():
	set_item_icon(item.icon)
	update_item_type_icon_by_item()
	set_item_name_label(item.name)
	if item.unbreakable:
		set_uses_label(0)
	else :
		set_uses_label(item.uses)
	
func clear_item_type_icon_comtainer():
	var children = left_container.get_children()
	for child_index in children.size():
		if child_index > 2:
			children[child_index].queue_free()

func update_item_type_icon_by_item():
	clear_item_type_icon_comtainer()
	var icon = TextureRect.new()
	if item is WeaponDefinition:
		if item.weapon_type == ItemConstants.WEAPON_TYPE.SWORD:
			var sword_icon = preload("res://resources/sprites/icons/weapon_icons/sword_icon.png")
			icon.texture = sword_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.AXE:
			var axe_icon = preload("res://resources/sprites/icons/weapon_icons/axe_icon.png")
			icon.texture = axe_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.LANCE:
			var lance_icon = preload("res://resources/sprites/icons/weapon_icons/lance_icon.png")
			icon.texture = lance_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.BOW:
			var bow_icon = preload("res://resources/sprites/icons/weapon_icons/bow_icon.png")
			icon.texture = bow_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.FIST:
			var fist_icon = preload("res://resources/sprites/icons/weapon_icons/fist_icon.png")
			icon.texture = fist_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.STAFF:
			var staff_icon = preload("res://resources/sprites/icons/weapon_icons/staff_icon.png")
			icon.texture = staff_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.DARK:
			var dark_icon = preload("res://resources/sprites/icons/weapon_icons/dark_icon.png")
			icon.texture = dark_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.LIGHT:
			var light_icon = preload("res://resources/sprites/icons/weapon_icons/light_icon.png")
			icon.texture = light_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.NATURE:
			var nature_icon = preload("res://resources/sprites/icons/weapon_icons/nature_icon.png")
			icon.texture = nature_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.ANIMAL:
			var animal_icon = preload("res://resources/sprites/icons/weapon_icons/animal_icon.png")
			icon.texture = animal_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.MONSTER:
			var monster_icon = preload("res://resources/sprites/icons/monster.png")
			icon.texture = monster_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.SHIELD:
			var shield_icon = preload("res://resources/sprites/icons/weapon_icons/shield_icon.png")
			icon.texture = shield_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.DAGGER:
			var dagger_icon = preload("res://resources/sprites/icons/weapon_icons/dagger_icon.png")
			icon.texture = dagger_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)
		if item.weapon_type == ItemConstants.WEAPON_TYPE.BANNER:
			var banner_icon = preload("res://resources/sprites/icons/weapon_icons/banner_icon.png")
			icon.texture = banner_icon
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			left_container.add_child(icon)


func _on_focus_entered() -> void:
	item_name_label.self_modulate = "FFFFFF"
	self.theme = preload("res://ui/battle_prep_new/panel_option_focused.tres")


func _on_focus_exited() -> void:
	item_name_label.self_modulate = "828282"
	self.theme = preload("res://ui/battle_prep_new/panel_option_not_focused.tres")


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		item_panel_pressed.emit(item)
