extends PanelContainer

@onready var enemy_unit_type_info_container: VBoxContainer = $MarginContainer/MainContainer/EnemyInfoMainContainer/EnemyUnitTypeScrollContainer/EnemyUnitTypeInfoContainer
@onready var enemy_unit_type_header_container: HBoxContainer = $MarginContainer/MainContainer/EnemyInfoMainContainer/EnemyUnitTypeScrollContainer/EnemyUnitTypeInfoContainer/EnemyUnitTypeHeaderContainer
@onready var enemy_usable_weapon_info_container: VBoxContainer = $MarginContainer/MainContainer/EnemyInfoMainContainer/EnemyUsableWeaponScrollContainer/EnemyUsableWeaponInfoContainer

@onready var reinforcement_unit_type_info_container: VBoxContainer = $MarginContainer/MainContainer/ReinforcementInfoMainContainer/ReinforcementUnitTypeScrollContainer/ReinforcementUnitTypeInfoContainer
@onready var reinforcement_unit_type_header_container: HBoxContainer = $MarginContainer/MainContainer/ReinforcementInfoMainContainer/ReinforcementUnitTypeScrollContainer/ReinforcementUnitTypeInfoContainer/ReinforcementUnitTypeHeaderContainer
@onready var reinforcement_usable_weapon_info_container: VBoxContainer = $MarginContainer/MainContainer/ReinforcementInfoMainContainer/ReinforcementUsableWeaponTypeScrollContainer/ReinforcementUsableWeaponInfoContainer


@onready var entity_info_container: VBoxContainer = $MarginContainer/MainContainer/EntityInfoContainer

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


var upcoming_enemies : EnemyGroup
var upcoming_entities : MapEntityGroupData
var upcoming_reinforcements : MapReinforcementData

func set_upcoming_enemies(enemy_group:EnemyGroup):
	upcoming_enemies = enemy_group

func set_upcoming_entities(entity_group : MapEntityGroupData):
	upcoming_entities = entity_group

func fill_all_containers():
	if upcoming_enemies:
		fill_enemy_unit_type_header_container()
		fill_enemy_unit_type_info_container()
		fill_enemy_usable_weapon_info_container()
	if upcoming_reinforcements:
		fill_reinforcement_unit_type_header_container()
		fill_reinforcement_unit_type_info_container()
		fill_reinforcement_usable_weapon_info_container()
	if upcoming_entities:
		fill_enitiy_info_container()



func fill_enemy_unit_type_header_container():
	var enemy_count = get_total_map_values(create_map(upcoming_enemies.group))
	var label := Label.new()
	label.text = " " + str(enemy_count)
	enemy_unit_type_header_container.add_child(label)
	label.add_theme_font_size_override("font_size",24)

func fill_enemy_unit_type_info_container():
	var enemy_map = create_map(upcoming_enemies.group)
	for enemy_type_key in enemy_map:
		var enemy_info_sub_container = HBoxContainer.new()
		var count_label := Label.new()
		var unit_type_label := Label.new()
		count_label.text = str(enemy_map.get(enemy_type_key)) + " X "
		unit_type_label.text = enemy_type_key
		enemy_info_sub_container.add_child(count_label)
		enemy_info_sub_container.add_child(unit_type_label)
		enemy_unit_type_info_container.add_child(enemy_info_sub_container)
		count_label.add_theme_font_size_override("font_size",24)
		unit_type_label.add_theme_font_size_override("font_size",24)

func fill_enemy_usable_weapon_info_container():
	var usable_weapon_map = create_enemy_weapon_type_map(upcoming_enemies.group) #TODO CHANGE THIS TO THE CURRENT ENEMIES ON THE MAP
	for usable_weapon_type_key in usable_weapon_map:
		var enemy_info_sub_container = HBoxContainer.new()
		var count_label := Label.new()
		var weapon_type_label := Label.new()
		var weapon_icon := TextureRect.new()
		count_label.text = str(usable_weapon_map.get(usable_weapon_type_key)) + " X "
		weapon_type_label.text = usable_weapon_type_to_string(usable_weapon_type_key)
		weapon_icon.texture = get_weapon_icon(usable_weapon_type_key)
		enemy_info_sub_container.add_child(count_label)
		enemy_info_sub_container.add_child(weapon_type_label)
		enemy_info_sub_container.add_child(weapon_icon)
		enemy_usable_weapon_info_container.add_child(enemy_info_sub_container)
		count_label.add_theme_font_size_override("font_size",24)
		weapon_type_label.add_theme_font_size_override("font_size",24)

func create_enemy_weapon_type_map(enemies) -> Dictionary:
	var usable_weapon_map := {}
	for enemy in enemies:
		var unit_type := UnitTypeDatabase.get_definition(enemy.unit_type_key)
		var usable_weapon_types = unit_type.usable_weapon_types
		if usable_weapon_types != null:
			for usable_weapon_type in usable_weapon_types:
				if usable_weapon_map.get(usable_weapon_type):
					usable_weapon_map[usable_weapon_type] += 1
				else:
					usable_weapon_map[usable_weapon_type] = 1
	return usable_weapon_map

func fill_reinforcement_unit_type_header_container():
	var reinforcement_count = get_total_map_values(create_map(upcoming_reinforcements.reinforcements))
	var label := Label.new()
	label.text = " " + str(reinforcement_count)
	reinforcement_unit_type_header_container.add_child(label)
	label.add_theme_font_size_override("font_size",24)

func fill_reinforcement_unit_type_info_container():
	var reinforcement_map = create_map(upcoming_reinforcements.reinforcements)
	for enemy_type_key in reinforcement_map:
		var enemy_info_sub_container = HBoxContainer.new()
		var count_label := Label.new()
		var unit_type_label := Label.new()
		count_label.text = str(reinforcement_map.get(enemy_type_key)) + " X "
		unit_type_label.text = enemy_type_key
		enemy_info_sub_container.add_child(count_label)
		enemy_info_sub_container.add_child(unit_type_label)
		reinforcement_unit_type_info_container.add_child(enemy_info_sub_container)
		count_label.add_theme_font_size_override("font_size",24)
		unit_type_label.add_theme_font_size_override("font_size",24)



func fill_reinforcement_usable_weapon_info_container():
	var usable_weapon_map = create_enemy_weapon_type_map(upcoming_reinforcements.reinforcements)
	for usable_weapon_type_key in usable_weapon_map:
		var enemy_info_sub_container = HBoxContainer.new()
		var count_label := Label.new()
		var weapon_type_label := Label.new()
		var weapon_icon := TextureRect.new()
		count_label.text = str(usable_weapon_map.get(usable_weapon_type_key)) + " X "
		weapon_type_label.text = usable_weapon_type_to_string(usable_weapon_type_key)
		weapon_icon.texture = get_weapon_icon(usable_weapon_type_key)
		enemy_info_sub_container.add_child(count_label)
		enemy_info_sub_container.add_child(weapon_type_label)
		enemy_info_sub_container.add_child(weapon_icon)
		reinforcement_usable_weapon_info_container.add_child(enemy_info_sub_container)
		count_label.add_theme_font_size_override("font_size",24)
		weapon_type_label.add_theme_font_size_override("font_size",24)


















func fill_enitiy_info_container():
	create_chest_info_label()
	create_door_info_label()
	create_search_entity_weapon_labels()


func create_map(enemies) -> Dictionary:
	var enemy_map := {}
	for enemy in enemies:
		if enemy_map.get(enemy.unit_type_key):
			enemy_map[enemy.unit_type_key] += 1
		else:
			enemy_map[enemy.unit_type_key] = 1
	return enemy_map


func get_total_map_values(map:Dictionary):
	var accum = 0
	for item in map:
		accum += map[item]
	return accum


func create_chest_info_label():
	var chest_count := 0
	if upcoming_entities:
		chest_count = upcoming_entities.chests.size()
	create_entity_info_label("Chests: ", chest_count)

func create_door_info_label():
	var door_count := 0
	if upcoming_entities:
		door_count = upcoming_entities.doors.size()
	create_entity_info_label("Doors: ", door_count)

func create_entity_info_label(entity_name,entity_count):
	var label := Label.new()
	label.text = entity_name + str(entity_count)
	entity_info_container.add_child(label)
	label.add_theme_font_size_override("font_size",24)

func create_search_entity_weapon_labels():
	if upcoming_entities:
		var search_entities := upcoming_entities.searchs
		var houses := 0
		var food_shelves := 0
		var book_shelves := 0
		var weapon_racks := 0
		for entity:MapSearchEntityDefinition in search_entities:
			match entity.type:
				MapSearchEntityDefinition.TYPE.HOUSE:
					houses += 1
				MapSearchEntityDefinition.TYPE.FOOD_SHELF:
					food_shelves += 1
				MapSearchEntityDefinition.TYPE.BOOK_SHELF:
					book_shelves += 1
				MapSearchEntityDefinition.TYPE.WEAPON_RACK:
					weapon_racks += 1
		create_entity_info_label("Houses: ", houses)
		create_entity_info_label("Food Shelves: ",food_shelves)
		create_entity_info_label("Book Shelves: ",book_shelves)
		create_entity_info_label("Weapon Racks: ",weapon_racks)

func usable_weapon_type_to_string(weapon_type : ItemConstants.WEAPON_TYPE):
	var str = ""
	match weapon_type:
			ItemConstants.WEAPON_TYPE.NONE:
				pass
			ItemConstants.WEAPON_TYPE.SWORD:
				str = "Sword User"
			ItemConstants.WEAPON_TYPE.AXE:
				str = "Axe User"
			ItemConstants.WEAPON_TYPE.LANCE:
				str = "Lance User"
			ItemConstants.WEAPON_TYPE.BOW:
				str = "Bow User"
			ItemConstants.WEAPON_TYPE.FIST:
				str = "Fist User"
			ItemConstants.WEAPON_TYPE.STAFF:
				str = "Staff User"
			ItemConstants.WEAPON_TYPE.DARK:
				str = "Dark User"
			ItemConstants.WEAPON_TYPE.LIGHT:
				str = "Light User"
			ItemConstants.WEAPON_TYPE.NATURE:
				str = "Nature User"
			ItemConstants.WEAPON_TYPE.ANIMAL:
				str = "Animal User"
			ItemConstants.WEAPON_TYPE.MONSTER:
				str = "Monster User"
			ItemConstants.WEAPON_TYPE.SHIELD:
				str = "Shield User"
			ItemConstants.WEAPON_TYPE.DAGGER:
				str = "Dagger User"
			ItemConstants.WEAPON_TYPE.BANNER:
				str = "banner User"
	return str

func get_weapon_icon(weapon_type : ItemConstants.WEAPON_TYPE):
	var texture
	match weapon_type:
		ItemConstants.WEAPON_TYPE.NONE:
			pass
		ItemConstants.WEAPON_TYPE.SWORD:
			texture = sword_icon_texture
		ItemConstants.WEAPON_TYPE.AXE:
			texture = axe_icon_texture
		ItemConstants.WEAPON_TYPE.LANCE:
			texture = lance_icon_texture
		ItemConstants.WEAPON_TYPE.BOW:
			texture = bow_icon_texture
		ItemConstants.WEAPON_TYPE.FIST:
			texture = fist_icon_texture
		ItemConstants.WEAPON_TYPE.STAFF:
			texture = staff_icon_texture
		ItemConstants.WEAPON_TYPE.DARK:
			texture = dark_icon_texture
		ItemConstants.WEAPON_TYPE.LIGHT:
			texture = light_icon_texture
		ItemConstants.WEAPON_TYPE.NATURE:
			texture = nature_icon_texture
		ItemConstants.WEAPON_TYPE.ANIMAL:
			texture = animal_icon_texture
		ItemConstants.WEAPON_TYPE.MONSTER:
			texture = monster_icon_texture
		ItemConstants.WEAPON_TYPE.SHIELD:
			texture = shield_icon_texture
		ItemConstants.WEAPON_TYPE.DAGGER:
			texture = dagger_icon_texture
		ItemConstants.WEAPON_TYPE.BANNER:
			texture = banner_icon_texture
	return texture
