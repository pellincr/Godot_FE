extends Control

var playerOverworldData : PlayerOverworldData
var control_node : Node

@onready var archetype_container = $ArchetypeHContainer
@onready var recruit_container = $RecruitVContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	if playerOverworldData == null:
		playerOverworldData = PlayerOverworldData.new()
	archetype_container.set_po_data(playerOverworldData)
	recruit_container.set_po_data(playerOverworldData)
	archetype_container.set_control_node(control_node)
	recruit_container.set_control_node(control_node)




func archetype_selection_complete():
	archetype_container.visible = false
	recruit_container.visible = true
