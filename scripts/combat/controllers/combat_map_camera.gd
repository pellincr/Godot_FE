extends Camera2D
class_name CombatMapCamera

enum CAMERA_MODE {
	FOLLOW,
	FOCUS,
	FREE
}

@export var mode : CAMERA_MODE = CAMERA_MODE.FOLLOW
@export var zoomSpeed : float = 10;
@export var pan_threshold : float = .75
@export var camSpeed : float = 3.5
@export var game_map: TileMap 
@export var controller : CController
var zoomTarget :Vector2
var focus_target :Vector2

var dragStartMousePos = Vector2.ZERO
var dragStartCameraPos = Vector2.ZERO
var isDragging : bool = false
var zoomMin: Vector2 = Vector2(2, 2)
var zoomMax: Vector2 = Vector2(5.0, 5.0)

var initialized = false


# Called when the node enters the scene tree for the first time.
func _ready():
	zoomTarget = zoom
	#set_camera_limits()

func init():
	controller = get_node("../../Controller")
	game_map = controller.tile_map
	set_camera_limits()
	initialized = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if initialized :
		Zoom(delta)
		if mode == CAMERA_MODE.FOLLOW:
			SimpleFollow(delta)
		elif mode == CAMERA_MODE.FOCUS:
			center_target(delta)
		elif mode == CAMERA_MODE.FREE:
			ClickAndDrag()
	
func Zoom(delta):
	if Input.is_action_just_pressed("camera_zoom_in"):
		zoomTarget *= 1.1
		
	if Input.is_action_just_pressed("camera_zoom_out"):
		zoomTarget *= 0.9
	
	zoomTarget = clamp(zoomTarget, zoomMin, zoomMax)
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)

func SimpleFollow(delta): #this needs to be perfected
	var starting_position = position
	var tile_position
	if controller._camera_follow_move:
		tile_position = controller.controlled_node.position
	else:
		tile_position = controller.grid.map_to_position(controller.current_tile)		
	var viewport : Rect2 = get_viewport().get_visible_rect()
	#perform a simple follow when the camera is too close to its edge
	if tile_position.x > (viewport.position.x + viewport.size.x * pan_threshold/2) or tile_position.x < viewport.position.x - (viewport.size.x *pan_threshold/2) or tile_position.y > (viewport.position.y - viewport.size.y *pan_threshold/4) or tile_position.y < viewport.position.y - (viewport.size.y *pan_threshold/4) :
			var moveAmount = lerp(starting_position, tile_position, tile_position.length())
			moveAmount = moveAmount.normalized()
				#var moveAmount = (tile_offset - position).normalized()
			position = position.slerp(tile_position, camSpeed * delta)
		
func SimplePan(delta):
	var moveAmount = Vector2.ZERO
	if Input.is_action_pressed("camera_move_right"):
		moveAmount.x += 1
		
	if Input.is_action_pressed("camera_move_left"):
		moveAmount.x -= 1
		
	if Input.is_action_pressed("camera_move_up"):
		moveAmount.y -= 1
		
	if Input.is_action_pressed("camera_move_down"):
		moveAmount.y += 1
		
	moveAmount = moveAmount.normalized()
	position += moveAmount * delta * 1000 * (1/zoom.x)
	
func ClickAndDrag():
	if !isDragging and Input.is_action_just_pressed("camera_pan"):
		dragStartMousePos = get_viewport().get_mouse_position()
		dragStartCameraPos = position
		isDragging = true
		
	if isDragging and Input.is_action_just_released("camera_pan"):
		isDragging = false
		
	if isDragging:
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos
		position = dragStartCameraPos - moveVector * 1/zoom.x	

func centerCameraCenter(target_position: Vector2):
	position = target_position

func set_camera_limits(): ## needs to be updated
	var map_limits = game_map.get_used_rect()
	var map_cellsize = game_map.tile_set.tile_size
	self.limit_left = map_limits.position.x * map_cellsize.x
	self.limit_right = map_limits.end.x * map_cellsize.x
	self.limit_top = map_limits.position.y * map_cellsize.y
	self.limit_bottom = map_limits.end.y * map_cellsize.y

func set_mode(camera_mode : CAMERA_MODE):
	self.mode = camera_mode

func set_focus_target(target_position: Vector2):
	self.focus_target = target_position
	
#Forces the camera to pan to a target location on the game Grid
func center_target(delta):
	#var moveAmount = lerp(position, focus_target, .25)
	#moveAmount = moveAmount.normalized()
	position = position.slerp(focus_target, camSpeed * delta)
	pass
