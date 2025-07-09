extends Node


var terrain_tile_map : TileMap 
var interactable_tile_map : TileMap

func perform_interactable_tile_action(tile: Vector2i):
	var interactable_tile_data = interactable_tile_map.get_cell_tile_data(0, tile)
	if interactable_tile_data:
		var interactable : InteractableTile = interactable_tile_data.get_custom_data("Interactable")
	#var tile_terrain :Terrain = tile_data.get_custom_data("Terrain")

func update_interactable_tile(tile,target_tile):
	interactable_tile_map.set_cell(tile, target_tile)

func _ready():
	terrain_tile_map = get_node("../Terrain/TileMap")
	interactable_tile_map = get_node("../Terrain/Interactables")
