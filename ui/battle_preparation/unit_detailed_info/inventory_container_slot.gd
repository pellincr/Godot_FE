extends Panel

signal set_equippped(item)
signal item_selected_for_trade(item)

@onready var inventory_item_icon = $HBoxContainer/LeftContainer/InventoryItemIcon
@onready var item_name_label = $HBoxContainer/LeftContainer/ItemNameLabel
@onready var item_uses_label = $HBoxContainer/UsesLabel
@onready var left_container = $HBoxContainer/LeftContainer

var set_for_trade = false
var item : ItemDefinition

func _ready():
	if item != null:
		update_by_item()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and self.has_focus() and !set_for_trade:
		set_equippped.emit(item)
	if Input.is_action_just_pressed("ui_accept") and self.has_focus() and set_for_trade:
		self.theme = preload("res://ui/battle_preparation/inventory_not_focused_trade_ready.tres")
		item_selected_for_trade.emit(item)
		
		

func set_invetory_item_icon(icon:Texture2D):
	if icon:
		inventory_item_icon.set_image(icon)
	else:
		inventory_item_icon.set_image(null)



func set_item_name_label(text):
	item_name_label.text = text

func update_by_item():
	set_invetory_item_icon(item.icon)
	set_item_name_label(item.name)
	update_item_type_icon_by_item()
	set_item_uses(item.uses)

func set_item_uses(uses):
	if uses > 0:
		item_uses_label.text = str(uses)
	else:
		item_uses_label.text = ""

func clear_icons():
	var children = left_container.get_children()
	for child in children:
		if child is TextureRect:
			child.queue_free()

func update_item_type_icon_by_item():
	clear_icons()
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


func _on_focus_entered():
	var focus_theme = preload("res://ui/battle_preparation/inventory_focused.tres")
	self.theme = focus_theme


func _on_focus_exited():
	if theme != preload("res://ui/battle_preparation/inventory_not_focused_trade_ready.tres"):
		var un_focus_theme = preload("res://ui/battle_preparation/inventory_not_focused.tres")
		self.theme = un_focus_theme


func _on_mouse_entered():
	grab_focus()
