extends Control



@onready var main_container = get_node("MainVContainer")
@onready var option_container = get_node("OptionVContainer")
@onready var save_container = get_node("SaveVContainer")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit()

func _on_return_button_pressed():
	main_container.visible = true
	option_container.visible = false
	save_container.visible = false


func _on_options_button_pressed():
	main_container.visible = false
	option_container.visible = true


func _on_start_button_pressed():
	main_container.visible = false
	save_container.visible = true


func _on_save_button_pressed():
	get_tree().change_scene_to_file("res://overworld/overworld.tscn")
