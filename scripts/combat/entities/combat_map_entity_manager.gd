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

@export var mapEntityData: Array[MapEntityGroupData]

var entity_groups : Dictionary 

func load_entities():
	if mapEntityData != null:
		for entity_group_index in range(mapEntityData.size()):
			for entity: mapEntityDefinition in mapEntityData[entity_group_index].entities:
				add_entity(entity, entity_group_index)

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

func disable_entity_group_by_entity(combat_entity : CombatEntity):
	disable_entity_group_by_index(combat_entity.group)

func disable_entity_group_by_index(index: int):
	if entity_groups.has(index):
		for entity in entity_groups.get(index):
			disable_entity(entity)

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
	disable_entity_group_by_entity(combat_entity)

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
			entity_destroyed_remove(combat_entity)
		CombatEntityConstants.ENTITY_TYPE.DOOR:
			entity_destroyed_remove(combat_entity)
		CombatEntityConstants.ENTITY_TYPE.CHEST:
			await entity_destroyed_chest(combat_entity)
	#entity_process_complete.emit()

func entity_interacted_remove(combat_entity: CombatEntity):
	disable_entity_group_by_entity(combat_entity)
	
func _on_give_item_complete():
	give_items_complete.emit()
