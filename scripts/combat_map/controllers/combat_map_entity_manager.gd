extends Node
class_name CombatMapEntityManager
##
# This works with the CController to perform combat actions
# It stores unit data and information
##
#Imports
const COMBAT_MAP_ENTITY_DISPLAY = preload("res://ui/combat_map/combat_map_entity_display/combat_map_entity_display.tscn")

##Signals
signal turn_advanced()
signal entity_added(cme:CombatMapEntity)
signal entity_updated(cme: CombatMapEntity)
signal update_information(text: String)
signal target_selected(combat_exchange_info: CombatUnit)

#map entity data
@export var mapEntityData: MapEntityGroupData
@export var combatMapGrid : CombatMapGrid
@export var combat_unit_item_manager : CombatMapUnitItemManager

#entity variables
var combat_entities: Array[CombatMapEntity]
var disabled_combat_entities : Array[CombatMapEntity]

var combat_entities_groups = {}

@export var game_ui : Control
@export var controller : CController
@export var combat_map_audio_manager : AudioStreamPlayer ## TO BE CREATED

func _ready():
	load_entities()

func load_entities():
	if mapEntityData != null:
		for entity in mapEntityData.entities:
			add_entity(entity)

func add_entity(cme:CombatMapEntity):
	combat_entities.append(cme)
	var enity_display : CombatMapEntityDisplay = COMBAT_MAP_ENTITY_DISPLAY.instantiate()
	enity_display.set_reference_entity(cme)
	$"../Terrain/TileMap".add_child(enity_display)
	enity_display.position = Vector2((cme.position.x * 32.0) + 16,(cme.position.y * 32.0) + 16)
	enity_display.z_index = 0
	cme.display = enity_display
	emit_signal("entity_added", cme)

func entity_disable(e: CombatMapEntity):
	e.active = false
	disabled_combat_entities.append(e)
	e.display.queue_free()

##THIS COULD BE REDUNDANT
func play_audio(sound : AudioStream):
	combat_map_audio_manager.stream = sound
	combat_map_audio_manager.play()
	await combat_map_audio_manager.finished
	combat_map_audio_manager.audio_player_ready()
