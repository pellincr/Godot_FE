extends Control

signal start_game()

@onready var press_any_button_label: RichTextLabel = $PressAnyButtonLabel
@onready var main_container: VBoxContainer = $MainContainer
@onready var start_button: GeneralMenuButton = $MainContainer/StartButton

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and press_any_button_label.visible:
		press_any_button_label.visible = false
		main_container.visible = true
		start_button.grab_focus()

func _on_start_button_pressed() -> void:
	start_game.emit()

func _on_options_button_pressed():
	#main_container.visible = false
	SignalBus.options_open.emit()
	#var options = OPTIONS_SCENE.instantiate()
	#add_child(options)
	#options.menu_closed.connect(_on_options_menu_closed)

#Quits the Game back to Desktop
func _on_quit_button_pressed():
	get_tree().quit()
