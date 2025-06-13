extends Control

var playerOverworldData : PlayerOverworldData
var control_node : Node = self

signal drafting_complete(po_data)

@onready var archetype_container = $ArchetypeHContainer
@onready var recruit_container_scene = preload("res://overworld/recruit_v_container.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	archetype_container.set_po_data(playerOverworldData)
	archetype_container.set_control_node(control_node)




func archetype_selection_complete():
	archetype_container.visible = false
	playerOverworldData = archetype_container.playerOverworldData
	var recruit_container = recruit_container_scene.instantiate()
	recruit_container.set_po_data(playerOverworldData)
	recruit_container.set_control_node(control_node)
	recruit_container.connect("recruiting_complete",recruiting_complete)
	$".".add_child(recruit_container)

func recruiting_complete():
	queue_free()
	drafting_complete.emit(playerOverworldData)
	
