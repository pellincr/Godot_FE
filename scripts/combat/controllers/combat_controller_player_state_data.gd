extends Resource
class_name CombatControllerPlayerStateData

@export var _player_state: CombatMapConstants.PLAYER_STATE
#@export var _control_node_active : bool #This may be re-dundant

@export var _current_tile : Vector2i # Where the cursor currently is
@export var _selected_tile : Vector2i # What we first selected (Most likely the tile containing the unit we have selected)
@export var _target_tile : Vector2i # Our First Target
@export var _move_tile : Vector2i # the tile we moved to

@export var _camera_state : CombatMapCamera.CAMERA_MODE

@export var _selector_mode : CombatMapSelector.MODE

func _init(player_state: CombatMapConstants.PLAYER_STATE, current_tile : Vector2i, seleceted_tile :Vector2i, target_tile: Vector2i, move_tile:Vector2i, selector_mode : CombatMapSelector.MODE ) -> void:
	_player_state = player_state
	#_control_node_active = control_node_active
	_current_tile = current_tile
	_selected_tile = seleceted_tile
	_target_tile = target_tile
	_move_tile = move_tile
	_selector_mode = selector_mode
