extends ScrollContainer

@onready var main_container = $MainScrollContainer

@onready var playerOverworldData:PlayerOverworldData

const hoh_party_scroll_container_scene = preload("res://hall_of_heroes/hall_of_heroes_party_scroll_container.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if !playerOverworldData:
		playerOverworldData = PlayerOverworldData.new()
	if playerOverworldData.hall_of_heroes_manager.latest_win_number > 0:
		fill_main_scroll_container()


func set_po_data(po_data):
	playerOverworldData = po_data


func fill_main_scroll_container():
	var i = playerOverworldData.hall_of_heroes_manager.latest_win_number
	while (i>0):
		var hoh_party_scroll_container = hoh_party_scroll_container_scene.instantiate()
		hoh_party_scroll_container.set_po_data(playerOverworldData)
		hoh_party_scroll_container.represented_win_number = i
		main_container.add_child(hoh_party_scroll_container)
		i -=1
