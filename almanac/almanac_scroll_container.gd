extends HBoxContainer

var playerOverworldData : PlayerOverworldData

@onready var main_scroll_container = $MainContainer/DetailedViewSubContainer/ScrollContainer/MainScrollContainer
@onready var almanac_scroll_header = $MainContainer/AlmanacScrollHeader

@onready var main_container = $MainContainer

@onready var detailed_view_sub_container = $MainContainer/DetailedViewSubContainer

const unit_type_panel_container_scene = preload("res://almanac/unit_type/unit_type_panel_container.tscn")
const unit_type_almanac_detailed_view_scene = preload("res://almanac/unit_type/unit_type_almanac_detailed_view.tscn")

const archetype_panel_container_scene = preload("res://almanac/archetype/archetype_panel_container.tscn")
const archetype_detailed_view_scene = preload("res://almanac/archetype/archetype_detailed_view.tscn")


const item_panel_container_scene = preload("res://ui/battle_prep_new/item_panel/item_panel_container.tscn")

const weapon_detailed_info_scene = preload("res://ui/battle_prep_new/item_detailed_info/weapon_detailed_info.tscn")
const equpiment_detailed_info_scene = preload("res://ui/battle_prep_new/item_detailed_info/equipment_detailed_info.tscn")
const consumable_item_detailed_info_scene = preload("res://ui/battle_prep_new/item_detailed_info/consumable_item_detailed_info.tscn")

var focused = false

func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	almanac_scroll_header.set_po_data(playerOverworldData)
	almanac_scroll_header.update_all_percents()
	fill_main_scroll_container_unit_type()
	

func set_po_data(po_data):
	playerOverworldData = po_data

func clear_main_scroll_container():
	var children = main_scroll_container.get_children()
	for child in children:
		child.queue_free()
		focused = false

func fill_main_scroll_container_unit_type():
	var unit_type_keys = UnitTypeDatabase.unit_types.keys()
	for unit_type_key in unit_type_keys:
		var unit_type = UnitTypeDatabase.unit_types[unit_type_key]
		var unit_type_panel_container = unit_type_panel_container_scene.instantiate()
		unit_type_panel_container.set_po_data(playerOverworldData)
		unit_type_panel_container.unit_type = unit_type
		if unit_type_panel_container.check_if_unlocked():
			unit_type_panel_container.focus_entered.connect(_on_unit_type_panel_focued.bind(unit_type,true))
		else:
			unit_type_panel_container.focus_entered.connect(_on_unit_type_panel_focued.bind(unit_type, false))
		main_scroll_container.add_child(unit_type_panel_container)
		if !focused:
			unit_type_panel_container.grab_focus.call_deferred()
			focused = true

func fill_main_scroll_container_commander_type():
	var commander_type_keys = UnitTypeDatabase.commander_types.keys()
	for commander_type_key in commander_type_keys:
		var commander_type = UnitTypeDatabase.commander_types[commander_type_key]
		var unit_type_panel_container = unit_type_panel_container_scene.instantiate()
		unit_type_panel_container.unit_type = commander_type
		unit_type_panel_container.set_po_data(playerOverworldData)
		if unit_type_panel_container.check_if_unlocked():
			unit_type_panel_container.focus_entered.connect(_on_unit_type_panel_focued.bind(commander_type, true))
		else:
			unit_type_panel_container.focus_entered.connect(_on_unit_type_panel_focued.bind(commander_type, false))
		main_scroll_container.add_child(unit_type_panel_container)
		if !focused:
			unit_type_panel_container.grab_focus.call_deferred()
			focused = true

func fill_main_scroll_container_archetypes():
	var archetype_keys := ArmyArchetypeDatabase.army_archetypes.keys()
	for archetype_key in archetype_keys:
		var archetype = ArmyArchetypeDatabase.army_archetypes[archetype_key]
		var archetype_panel_container = archetype_panel_container_scene.instantiate()
		archetype_panel_container.archetype = archetype
		archetype_panel_container.set_po_data(playerOverworldData)
		main_scroll_container.add_child(archetype_panel_container)
		if archetype_panel_container.check_if_unlocked():
			archetype_panel_container.focus_entered.connect(_on_archetype_panel_focused.bind(archetype,true))
		else:
			archetype_panel_container.focus_entered.connect(_on_archetype_panel_focused.bind(archetype,false))
		if !focused:
			archetype_panel_container.grab_focus.call_deferred()
			focused = true

func fill_main_scroll_container_weapons():
	var item_keys := ItemDatabase.items.keys()
	var commander_weapon_keys := ItemDatabase.commander_weapons.keys()
	for commander_weapon_key in commander_weapon_keys:
		var item = ItemDatabase.commander_weapons[commander_weapon_key]
		var item_panel_container = item_panel_container_scene.instantiate()
		item_panel_container.item = item
		main_scroll_container.add_child(item_panel_container)
		item_panel_container.focus_entered.connect(_on_item_panel_focused.bind(item))
		if !focused:
			item_panel_container.grab_focus.call_deferred()
			focused = true
	var items: Array[ItemDefinition] = []
	for key in item_keys:
		var item = ItemDatabase.items[key]
		if item is WeaponDefinition:
			items.append(item)
	items.sort_custom(CustomUtilityLibrary.sort_item)
	for item in items:
		var item_panel_container = item_panel_container_scene.instantiate()
		item_panel_container.item = item
		main_scroll_container.add_child(item_panel_container)
		item_panel_container.focus_entered.connect(_on_item_panel_focused.bind(item))

func fill_main_scroll_container_equpiment():
	var item_keys := ItemDatabase.items.keys()
	var items: Array[ItemDefinition] = []
	for key in item_keys:
		var item = ItemDatabase.items[key]
		if item is ItemDefinition:
			if item.item_type == ItemConstants.ITEM_TYPE.EQUIPMENT:
				items.append(item)
	items.sort_custom(CustomUtilityLibrary.sort_item)
	for item in items:
		var item_panel_container = item_panel_container_scene.instantiate()
		item_panel_container.item = item
		main_scroll_container.add_child(item_panel_container)
		item_panel_container.focus_entered.connect(_on_item_panel_focused.bind(item))
		if !focused:
			item_panel_container.grab_focus.call_deferred()
			focused = true

func fill_main_scroll_container_consumable():
	var item_keys := ItemDatabase.items.keys()
	var items: Array[ItemDefinition] = []
	for key in item_keys:
		var item = ItemDatabase.items[key]
		if item is ConsumableItemDefinition:
			items.append(item)
	items.sort_custom(CustomUtilityLibrary.sort_item)
	for item in items:
			var item_panel_container = item_panel_container_scene.instantiate()
			item_panel_container.item = item
			main_scroll_container.add_child(item_panel_container)
			item_panel_container.focus_entered.connect(_on_item_panel_focused.bind(item))
			if !focused:
				item_panel_container.grab_focus.call_deferred()
				focused = true


func clear_sub_children():
	var children = detailed_view_sub_container.get_children()
	for child_index in children.size():
		if child_index == 0:
			pass
		else:
			children[child_index].queue_free()

func _on_almanac_header_swapped(almanac_state : AlmanacScrollHeader.ALMANAC_STATES):
	clear_main_scroll_container()
	match almanac_state:
		AlmanacScrollHeader.ALMANAC_STATES.UNIT_TYPES:
			fill_main_scroll_container_unit_type()
		AlmanacScrollHeader.ALMANAC_STATES.COMMANDER_TYPES:
			fill_main_scroll_container_commander_type()
		AlmanacScrollHeader.ALMANAC_STATES.ARCHETYPES:
			fill_main_scroll_container_archetypes()
		AlmanacScrollHeader.ALMANAC_STATES.WEAPONS:
			fill_main_scroll_container_weapons()
		AlmanacScrollHeader.ALMANAC_STATES.EQUIPMENT:
			fill_main_scroll_container_equpiment()
		AlmanacScrollHeader.ALMANAC_STATES.CONSUMABLES:
			fill_main_scroll_container_consumable()

func _on_unit_type_panel_focued(unit_type, unlocked):
	clear_sub_children()
	var unit_type_almanac_detailed_view = unit_type_almanac_detailed_view_scene.instantiate()
	if unlocked:
		unit_type_almanac_detailed_view.unit_type = unit_type
	detailed_view_sub_container.add_child(unit_type_almanac_detailed_view)

func _on_archetype_panel_focused(archetype:ArmyArchetypeDefinition,unlocked):
	clear_sub_children()
	var archetype_detailed_view = archetype_detailed_view_scene.instantiate()
	if unlocked:
		archetype_detailed_view.archetype = archetype
	detailed_view_sub_container.add_child(archetype_detailed_view)

func _on_item_panel_focused(item:ItemDefinition):
	clear_sub_children()
	if item is WeaponDefinition:
		var weapon_detailed_info = weapon_detailed_info_scene.instantiate()
		weapon_detailed_info.item = item
		detailed_view_sub_container.add_child(weapon_detailed_info)
		weapon_detailed_info.update_by_item()
	elif item is ConsumableItemDefinition:
		var consumable_item_detailed_info = consumable_item_detailed_info_scene.instantiate()
		consumable_item_detailed_info.item = item
		detailed_view_sub_container.add_child(consumable_item_detailed_info)
	elif item.item_type == ItemConstants.ITEM_TYPE.EQUIPMENT:
		var equpiment_detailed_info = equpiment_detailed_info_scene.instantiate()
		equpiment_detailed_info.item = item
		detailed_view_sub_container.add_child(equpiment_detailed_info)
		
