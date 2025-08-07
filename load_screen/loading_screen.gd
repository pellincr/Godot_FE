extends Control

@onready var loading_percent = $VBoxContainer/LoadingPercent

@onready var loading_bar = $VBoxContainer/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request(LoadScreenGlobals.next_screen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(LoadScreenGlobals.next_screen,progress)
	loading_bar.value = progress[0]*100
	loading_percent.text = str(ceil(progress[0]*100)) + "%"
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(LoadScreenGlobals.next_screen)
		get_tree().change_scene_to_packed(packed_scene)
