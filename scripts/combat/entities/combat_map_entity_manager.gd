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

@export var mapEntityData: Array[MapEntityGroupData]
@export var usable_chest_db_keys: Array[String]  = ["skeleton_key"]

var entity_groups : Dictionary #Dict<Group_index, Array[entities]>
var targetable_entity_types : Array[mapEntityDefinition.TYPE] = [mapEntityDefinition.TYPE.CHEST,mapEntityDefinition.TYPE.DOOR,mapEntityDefinition.TYPE.BREAKABLE_TERRAIN, mapEntityDefinition.TYPE.CRATE]
func load_entities():
	if mapEntityData != null:
		for entity_group : MapEntityGroupData  in mapEntityData:
			for entity_definition : mapEntityDefinition in entity_group.entities:
				add_entity(entity_definition, entity_group.group_index)

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

func disable_entity_group(index: int):
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

#func Chest(unit: CombatUnit, key: ItemDefinition, chest:CombatMapChestEntity):
	#print("Entered Chest in Combat.gd")
	#if key:
		#key.use()
	#for item in chest.contents:
		#await combat_unit_item_manager.give_combat_unit_item(unit, item)
	#entity_disable(chest)
	#major_action_complete()
	#
#func Door(unit: CombatUnit, key: ItemDefinition, door:CombatMapDoorEntity):
	#print("Entered Door in Combat.gd")
	#key.use()
	#for posn in door.entity_position_group:
		#entity_disable(controller.get_entity_at_position(posn))
	#controller.update_points_weight()
	#major_action_complete()
