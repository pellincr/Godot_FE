extends VBoxContainer

signal item_bought(item)

@onready var item_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/ItemTabIcon
#WEAPONS
@onready var sword_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/SwordTabIcon
@onready var axe_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/AxeTabIcon
@onready var lance_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/LanceTabIcon
@onready var bow_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/BowTabIcon
@onready var fist_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/FistTabIcon
@onready var staff_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/StaffTabIcon
@onready var dark_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/DarkTabIcon
@onready var light_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/LightTabIcon
@onready var nature_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/NatureTabIcon
@onready var animal_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/AnimalTabIcon
@onready var monster_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/MonsterTabIcon
@onready var shield_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/ShieldTabIcon
@onready var dagger_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/DaggerTabIcon
@onready var banner_tab_icon: PanelContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer/BannerTabIcon

#var tab_list = [sword_tab_icon,axe_tab_icon,lance_tab_icon,bow_tab_icon,fist_tab_icon,staff_tab_icon,dark_tab_icon,light_tab_icon,nature_tab_icon,animal_tab_icon,monster_tab_icon,shield_tab_icon,dagger_tab_icon,banner_tab_icon,item_tab_icon]

@onready var main_shop_inventory_container: VBoxContainer = $HBoxContainer/VBoxContainer/MarginContainer/ShopScrollContainer/MainShopInventoryContainer
@onready var main_container = $HBoxContainer

const sword_icon_texture = preload("res://resources/sprites/icons/weapon_icons/sword_icon.png")
const axe_icon_texture = preload("res://resources/sprites/icons/weapon_icons/axe_icon.png")
const lance_icon_texture = preload("res://resources/sprites/icons/weapon_icons/lance_icon.png")
const bow_icon_texture = preload("res://resources/sprites/icons/weapon_icons/bow_icon.png")
const fist_icon_texture = preload("res://resources/sprites/icons/weapon_icons/fist_icon.png")
const staff_icon_texture = preload("res://resources/sprites/icons/weapon_icons/staff_icon.png")
const dark_icon_texture = preload("res://resources/sprites/icons/weapon_icons/dark_icon.png")
const light_icon_texture = preload("res://resources/sprites/icons/weapon_icons/light_icon.png")
const nature_icon_texture = preload("res://resources/sprites/icons/weapon_icons/nature_icon.png")
const animal_icon_texture = preload("res://resources/sprites/icons/weapon_icons/animal_icon.png")
const monster_icon_texture = preload("res://resources/sprites/icons/monster_icon.png")
const shield_icon_texture = preload("res://resources/sprites/icons/weapon_icons/shield_icon.png")
const dagger_icon_texture = preload("res://resources/sprites/icons/weapon_icons/dagger_icon.png")
const banner_icon_texture = preload("res://resources/sprites/icons/weapon_icons/banner_icon.png")
const item_icon_texture = preload("res://resources/sprites/icons/ui_icons/icon_potion.png") #TEMPORARY

const item_panel_container_scene = preload("res://ui/battle_prep_new/item_panel/item_panel_container.tscn")
const weapon_detailed_info_scene = preload("res://ui/battle_prep_new/item_detailed_info/weapon_detailed_info.tscn")

@onready var current_tab_theme = ItemConstants.ITEM_TYPE.WEAPON
@onready var current_tab_subtheme = ItemConstants.WEAPON_TYPE.SWORD

var expanded_shop = false
var focused = false

func _ready():
	sword_tab_icon.set_icon(sword_icon_texture)
	sword_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	sword_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.SWORD)
	sword_tab_icon.on_tab_view = true
	axe_tab_icon.set_icon(axe_icon_texture)
	axe_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	axe_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.AXE)
	lance_tab_icon.set_icon(lance_icon_texture)
	lance_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	lance_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.LANCE)
	bow_tab_icon.set_icon(bow_icon_texture)
	bow_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	bow_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.BOW)
	fist_tab_icon.set_icon(fist_icon_texture)
	fist_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	fist_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.FIST)
	staff_tab_icon.set_icon(staff_icon_texture)
	staff_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	staff_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.STAFF)
	dark_tab_icon.set_icon(dark_icon_texture)
	dark_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	dark_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.DARK)
	light_tab_icon.set_icon(light_icon_texture)
	light_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	light_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.LIGHT)
	nature_tab_icon.set_icon(nature_icon_texture)
	nature_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	nature_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.NATURE)
	animal_tab_icon.set_icon(animal_icon_texture)
	animal_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	animal_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.ANIMAL)
	monster_tab_icon.set_icon(monster_icon_texture)
	monster_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	monster_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.MONSTER)
	shield_tab_icon.set_icon(shield_icon_texture)
	shield_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	shield_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.SHIELD)
	dagger_tab_icon.set_icon(dagger_icon_texture)
	dagger_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	dagger_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.DAGGER)
	banner_tab_icon.set_icon(banner_icon_texture)
	banner_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.WEAPON)
	banner_tab_icon.set_item_subtheme(ItemConstants.WEAPON_TYPE.BANNER)
	item_tab_icon.set_icon(item_icon_texture)
	item_tab_icon.set_item_theme(ItemConstants.ITEM_TYPE.USEABLE_ITEM)
	fill_current_tab_view()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_bumper"):
		next_shop_screen()
	if event.is_action_pressed("left_bumper"):
		previous_shop_screen()

func fill_current_tab_view():
	var items_list
	if current_tab_theme == ItemConstants.ITEM_TYPE.WEAPON:
		items_list = filter_by_weapon_type(current_tab_subtheme)
	elif current_tab_theme == ItemConstants.ITEM_TYPE.USEABLE_ITEM:
		items_list = filter_by_useable_item()
	for item in items_list:
		var item_panel_container = item_panel_container_scene.instantiate()
		item_panel_container.item = item
		main_shop_inventory_container.add_child(item_panel_container)
		if !focused:
			item_panel_container.grab_focus.call_deferred()
			focused = true
		item_panel_container.focus_entered.connect(on_item_panel_focused.bind(item))
		item_panel_container.item_panel_pressed.connect(_on_item_bought)

func clear_shop_list():
	var children = main_shop_inventory_container.get_children()
	for child in children:
		child.queue_free()
		focused = false

func turn_off_all_tabs():
	var tab_container: HBoxContainer = $HBoxContainer/VBoxContainer/TabScrollContainer/HBoxContainer
	var children = tab_container.get_children()
	for child in children:
		if child.item_theme == current_tab_theme:
			if child.item_subtheme == current_tab_subtheme:
				pass
			else:
				child.on_tab_view = false
		else:
			child.on_tab_view = false

func filter_by_weapon_type(weapon_type : ItemConstants.WEAPON_TYPE):
	var all_items = ItemDatabase.items.keys()
	var accum = []
	for item_key in all_items:
		var item = ItemDatabase.items[item_key]
		if item is WeaponDefinition and item.weapon_type == weapon_type:
			if item.rarity == RarityDatabase.rarities.get("standard"):
				accum.append(item)
			elif item.rarity == RarityDatabase.rarities.get("common") or  item.rarity == RarityDatabase.rarities.get("uncommon"):
				accum.append(item)
			elif item.rarity == RarityDatabase.rarities.get("rare") and expanded_shop:
				accum.append(item)
	return accum

func filter_by_useable_item():
	var all_items = ItemDatabase.items.keys()
	var accum = []
	for item_key in all_items:
		var item : ItemDefinition = ItemDatabase.items[item_key]
		#if item.item_type != ItemConstants.ITEM_TYPE.WEAPON:
		if item is ConsumableItemDefinition:
			if item.use_effect == ItemConstants.CONSUMABLE_USE_EFFECT.HEAL:
				accum.append(item)
			elif item.rarity == RarityDatabase.rarities.get("common") and item.use_effect == ItemConstants.CONSUMABLE_USE_EFFECT.STAT_BOOST:
				accum.append(item)
			"""
			if item.rarity == RarityDatabase.rarities.get("standard"):
				accum.append(item)
			elif item.rarity == RarityDatabase.rarities.get("common") or  item.rarity == RarityDatabase.rarities.get("uncommon"):
				accum.append(item)
			elif item.rarity == RarityDatabase.rarities.get("rare") and expanded_shop:
				accum.append(item)
			"""
	return accum


func _on_tab_icon_switch(item_theme, item_subtheme):
	current_tab_theme = item_theme
	current_tab_subtheme = item_subtheme
	update_shop_items()

func update_shop_items():
	#if current_tab == ItemConstants.ITEM_TYPE.USEABLE_ITEM:
	#	pass
	#else:
	clear_shop_list()
	turn_off_all_tabs()
	fill_current_tab_view()

func clear_main_container():
	var children = main_container.get_children()
	for child_index in children.size():
		if child_index != 0:
			children[child_index].queue_free()

func on_item_panel_focused(item):
	clear_main_container()
	if item is WeaponDefinition:
		var weapon_detailed_info = weapon_detailed_info_scene.instantiate()
		weapon_detailed_info.item = item
		main_container.add_child(weapon_detailed_info)
		weapon_detailed_info.update_by_item()
		weapon_detailed_info.layout_direction = Control.LAYOUT_DIRECTION_LTR
	elif item is ConsumableItemDefinition:
		var consumable_item_detailed_info = preload("res://ui/battle_prep_new/item_detailed_info/consumable_item_detailed_info.tscn").instantiate()
		consumable_item_detailed_info.item = item
		main_container.add_child(consumable_item_detailed_info)
		consumable_item_detailed_info.layout_direction = Control.LAYOUT_DIRECTION_LTR

func _on_item_bought(item):
	item_bought.emit(item)

func next_shop_screen():
	AudioManager.play_sound_effect("menu_confirm")
	if current_tab_theme == ItemConstants.ITEM_TYPE.WEAPON:
		match current_tab_subtheme:
			ItemConstants.WEAPON_TYPE.SWORD:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.AXE
				update_shop_items()
				axe_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.AXE:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.LANCE
				update_shop_items()
				lance_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.LANCE:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.BOW
				update_shop_items()
				bow_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.BOW:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.FIST
				update_shop_items()
				fist_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.FIST:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.STAFF
				update_shop_items()
				staff_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.STAFF:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.DARK
				update_shop_items()
				dark_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.DARK:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.LIGHT
				update_shop_items()
				light_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.LIGHT:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.NATURE
				update_shop_items()
				nature_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.NATURE:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.ANIMAL
				update_shop_items()
				animal_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.ANIMAL:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.MONSTER
				update_shop_items()
				monster_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.MONSTER:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.SHIELD
				update_shop_items()
				shield_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.SHIELD:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.DAGGER
				update_shop_items()
				dagger_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.DAGGER:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.BANNER
				update_shop_items()
				banner_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.BANNER:
				current_tab_theme = ItemConstants.ITEM_TYPE.USEABLE_ITEM
				current_tab_subtheme = null
				update_shop_items()
				item_tab_icon.on_tab_view = true
				
	else:
		current_tab_theme = ItemConstants.ITEM_TYPE.WEAPON
		current_tab_subtheme = ItemConstants.WEAPON_TYPE.SWORD
		update_shop_items()
		sword_tab_icon.on_tab_view = true

func previous_shop_screen():
	AudioManager.play_sound_effect("menu_confirm")
	if current_tab_theme == ItemConstants.ITEM_TYPE.WEAPON:
		match current_tab_subtheme:
			ItemConstants.WEAPON_TYPE.SWORD:
				current_tab_theme = ItemConstants.ITEM_TYPE.USEABLE_ITEM
				current_tab_subtheme = null
				update_shop_items()
				item_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.AXE:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.SWORD
				update_shop_items()
				sword_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.LANCE:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.AXE
				update_shop_items()
				axe_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.BOW:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.LANCE
				update_shop_items()
				lance_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.FIST:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.BOW
				update_shop_items()
				bow_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.STAFF:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.FIST
				update_shop_items()
				fist_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.DARK:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.STAFF
				update_shop_items()
				staff_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.LIGHT:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.DARK
				update_shop_items()
				dark_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.NATURE:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.LIGHT
				update_shop_items()
				light_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.ANIMAL:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.NATURE
				update_shop_items()
				nature_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.MONSTER:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.ANIMAL
				update_shop_items()
				animal_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.SHIELD:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.MONSTER
				update_shop_items()
				monster_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.DAGGER:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.SHIELD
				update_shop_items()
				shield_tab_icon.on_tab_view = true
			ItemConstants.WEAPON_TYPE.BANNER:
				current_tab_subtheme = ItemConstants.WEAPON_TYPE.DAGGER
				update_shop_items()
				dagger_tab_icon.on_tab_view = true
				
	else:
		current_tab_theme = ItemConstants.ITEM_TYPE.WEAPON
		current_tab_subtheme = ItemConstants.WEAPON_TYPE.BANNER
		update_shop_items()
		banner_tab_icon.on_tab_view = true
