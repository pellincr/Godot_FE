extends Control

class_name OverworldButton

var contained_variable = null #this will be either a unit or an item depending on the button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_button() -> Button:
	return $HBoxContainer/Button

func set_button_text(text) -> void:
	$HBoxContainer/Button.text = text

func get_hbox_container():
	return $HBoxContainer

func get_contained_var():
	return contained_variable

func set_contained_var(data):
	contained_variable = data

func set_button_pressed(pressed_function, i = null) -> void:
	$HBoxContainer/Button.pressed.connect(pressed_function.bind(i))
