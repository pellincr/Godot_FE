extends Node
class_name CombatMapEntityManager

##ART
const BARREL = preload("res://resources/sprites/entities/barrel.png")
const CRATE = preload("res://resources/sprites/entities/crate.png")
const DOOR_NEW = preload("res://resources/sprites/entities/door_new.png")
const CHEST_SPRITE_SHEET = preload("res://resources/sprites/entities/chest_sprite_sheet.png")

## Terrains
const CRACKED_STONE_WALL_TERRAIN = preload("res://resources/definitions/terrians/cracked_stone_wall_terrain.tres")

## Components
const COMBAT_MAP_ENTITY_DISPLAY = preload("res://ui/combat/combat_map_entity_display/combat_map_entity_display.tscn")

signal entity_added(cme:CombatEntity) #Use this to add the entity to the grid in CC
signal give_items(items : Array[ItemDefinition], source:String)
signal give_items_complete()
signal entity_process_complete()

@export var mapEntityData: MapEntityGroupData

var entity_groups : Dictionary 

func load_entities():
	#load the customn entities
	if mapEntityData != null:
		var entity_group_index = 0
		for entity: mapEntityDefinition in mapEntityData.entities:
			add_entity(entity, entity_group_index)
			entity_group_index += 1 # increment the inex after adding
	# Load the chest entities
		if not mapEntityData.chests.is_empty():
			for chest in mapEntityData.chests:
				add_chest_entity(chest, mapEntityData.default_chest_hp, mapEntityData.default_chest_defense, mapEntityData.default_breakable_terrain_resistance, entity_group_index)
				entity_group_index += 1 
	# Load the doors
		if not mapEntityData.doors.is_empty():
			for door: MapDoorEntityDefinition in mapEntityData.doors:
				for position in door.positions:
					add_door_entity(door, mapEntityData.default_door_hp, mapEntityData.default_door_defense, mapEntityData.default_door_resistance, position, entity_group_index)
				entity_group_index += 1 
	# Load the breakable terrain (walls)
		if not mapEntityData.breakable_terrains.is_empty():
			for bt in mapEntityData.breakable_terrains:
				add_breakable_terrain_entity(bt, mapEntityData.default_breakable_terrain_hp, mapEntityData.default_breakable_terrain_defense, mapEntityData.default_breakable_terrain_resistance, entity_group_index)
				entity_group_index += 1

func add_entity(cme:mapEntityDefinition, group_index: int):
	#create the combatEntity
	var combat_entity : CombatEntity = CombatEntity.new()
	combat_entity.populate(cme)
	combat_entity.set_entity_group(group_index)
	#create the display
	var cme_display : CombatEntityDisplay = COMBAT_MAP_ENTITY_DISPLAY.instantiate()
	cme_display.set_reference_entity_sprite(cme.map_view)
	cme_display.position = Vector2((cme.position.x * 32.0) + 16,(cme.position.y * 32.0) + 16)
	cme_display.z_index = 0
	$"../../Terrain/EntityLayer".add_child(cme_display)
	#Assign the display to the entity
	combat_entity.set_display(cme_display)
	# Add the entity to the Dictionary
	if entity_groups.has(group_index):
		entity_groups.get(group_index).append(combat_entity)
	else :
		var new_entity_group : Array[CombatEntity] = [combat_entity]
		entity_groups[group_index] = new_entity_group
	emit_signal("entity_added", combat_entity)

func add_chest_entity(mced : MapChestEntityDefinition, hp:int, def:int, res: int,  group_index:int ):
	#create the combatEntity
	var combat_entity : CombatEntity = CombatEntity.new()
	combat_entity.populate_chest(mced, hp, def, res)
	combat_entity.set_entity_group(group_index)
	#create the display
	var cme_display : CombatEntityDisplay = COMBAT_MAP_ENTITY_DISPLAY.instantiate()
	cme_display.set_reference_entity_sprite(mced.map_view)
	cme_display.position = Vector2((mced.position.x * 32.0) + 16,(mced.position.y * 32.0) + 16)
	cme_display.z_index = 0
	$"../../Terrain/EntityLayer".add_child(cme_display)
	#Assign the display to the entity
	combat_entity.set_display(cme_display)
	# Add the entity to the Dictionary
	if entity_groups.has(group_index):
		entity_groups.get(group_index).append(combat_entity)
	else :
		var new_entity_group : Array[CombatEntity] = [combat_entity]
		entity_groups[group_index] = new_entity_group
	emit_signal("entity_added", combat_entity)

func add_door_entity(mded : MapDoorEntityDefinition, hp:int, def:int, res: int, position:Vector2i, group_index:int ):
	#create the combatEntity
	var combat_entity : CombatEntity = CombatEntity.new()
	combat_entity.populate_door(mded, hp, def, res, position)
	combat_entity.set_entity_group(group_index)
	#create the display
	var cme_display : CombatEntityDisplay = COMBAT_MAP_ENTITY_DISPLAY.instantiate()
	if mded.orientation == mded.ORIENTATION.HORIZONTAL:
		cme_display.set_reference_entity_sprite(mded.map_view_horizontal)
	elif mded.orientation == mded.ORIENTATION.VERTICAL:
		cme_display.set_reference_entity_sprite(mded.map_view_vertical)
	cme_display.position = Vector2((position.x * 32.0) + 16,(position.y * 32.0) + 16)
	cme_display.z_index = 0
	$"../../Terrain/EntityLayer".add_child(cme_display)
	#Assign the display to the entity
	combat_entity.set_display(cme_display)
	# Add the entity to the Dictionary
	if entity_groups.has(group_index):
		entity_groups.get(group_index).append(combat_entity)
	else :
		var new_entity_group : Array[CombatEntity] = [combat_entity]
		entity_groups[group_index] = new_entity_group
	emit_signal("entity_added", combat_entity)

func add_breakable_terrain_entity(mbted : MapBreakableTerrainEntityDefinition, hp:int, def:int, res: int,  group_index:int ):
	#create the combatEntity
	var combat_entity : CombatEntity = CombatEntity.new()
	combat_entity.populate_breakable_terrain(mbted, hp, def, res)
	combat_entity.set_entity_group(group_index)
	#create the display
	var cme_display : CombatEntityDisplay = COMBAT_MAP_ENTITY_DISPLAY.instantiate()
	if mbted.orientation == mbted.ORIENTATION.HORIZONTAL:
		cme_display.set_reference_entity_sprite(mbted.map_view_h)
	elif mbted.orientation == mbted.ORIENTATION.VERTICAL:
		cme_display.set_reference_entity_sprite(mbted.map_view_v)
	cme_display.position = Vector2((mbted.position.x * 32.0) + 16,(mbted.position.y * 32.0) + 16)
	cme_display.z_index = 0
	$"../../Terrain/EntityLayer".add_child(cme_display)
	#Assign the display to the entity
	combat_entity.set_display(cme_display)
	# Add the entity to the Dictionary
	if entity_groups.has(group_index):
		entity_groups.get(group_index).append(combat_entity)
	else :
		var new_entity_group : Array[CombatEntity] = [combat_entity]
		entity_groups[group_index] = new_entity_group
	emit_signal("entity_added", combat_entity)



func disable_entity_group_by_entity(combat_entity : CombatEntity):
	await disable_entity_group_by_index(combat_entity.group)

func disable_entity_group_by_index(index: int):
	if entity_groups.has(index):
		for entity in entity_groups.get(index):
			await disable_entity(entity)

func disable_entity(combat_entity : CombatEntity):
	combat_entity.active = false
	combat_entity.display.queue_free()

func activate_entity(combat_entity: CombatEntity):
	pass

func get_contents(combat_entity: CombatEntity) -> Array[ItemDefinition]:
	return combat_entity.contents

func entity_destroyed_give_item(combat_entity: CombatEntity):
	disable_entity_group_by_entity(combat_entity)
	# give the item 
	give_items.emit(combat_entity.contents, CombatMapConstants.COMBAT_ENTITY)
	await give_items_complete

func entity_interacted_give_item(combat_entity: CombatEntity):
	disable_entity_group_by_entity(combat_entity)
	# give the item 
	give_items.emit(combat_entity.contents, CombatMapConstants.COMBAT_ENTITY)
	await give_items_complete

func entity_destroyed_remove(combat_entity: CombatEntity):
	await disable_entity_group_by_entity(combat_entity)

func entity_destroyed_chest(combat_entity: CombatEntity):
	disable_entity_group_by_entity(combat_entity)
	# give the item 
	var rubbish : Array[ItemDefinition] = [ItemDatabase.items.get("rubbish")]
	give_items.emit(rubbish, CombatMapConstants.COMBAT_ENTITY)
	await give_items_complete

func entity_interacted(combat_entity: CombatEntity):
	match combat_entity.interaction_type:
		CombatEntityConstants.ENTITY_TYPE.CRATE:
			pass
		CombatEntityConstants.ENTITY_TYPE.BREAKABLE_TERRAIN:
			pass
		CombatEntityConstants.ENTITY_TYPE.CHEST:
			await entity_interacted_give_item(combat_entity)
		CombatEntityConstants.ENTITY_TYPE.DOOR:
			await entity_interacted_remove(combat_entity)
	entity_process_complete.emit()

func entity_destroyed(combat_entity: CombatEntity):
	match combat_entity.interaction_type:
		CombatEntityConstants.ENTITY_TYPE.CRATE:
			await entity_destroyed_give_item(combat_entity)
		CombatEntityConstants.ENTITY_TYPE.BREAKABLE_TERRAIN:
			await entity_destroyed_remove(combat_entity)
		CombatEntityConstants.ENTITY_TYPE.DOOR:
			await entity_destroyed_remove(combat_entity)
		CombatEntityConstants.ENTITY_TYPE.CHEST:
			await entity_destroyed_chest(combat_entity)
	#entity_process_complete.emit()

func entity_interacted_remove(combat_entity: CombatEntity):
	disable_entity_group_by_entity(combat_entity)
	
func _on_give_item_complete():
	give_items_complete.emit()
