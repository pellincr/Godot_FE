extends PanelContainer
signal menu_closed()
signal main_menu_selected()
signal quit_game_selected()

@onready var close_menu_button: Button = $MarginContainer/MainContainer/CloseMenuButton

@onready var main_container: VBoxContainer = $MarginContainer/MainContainer
@onready var confirm_sub_container: VBoxContainer = $MarginContainer/ConfirmSubContainer
@onready var yes_button: Button = $MarginContainer/ConfirmSubContainer/YesButton


const main_menu_scene = "res://Game Main Menu/main_menu.tscn"

const scene_transition_scene = preload("res://scene_transitions/SceneTransitionAnimation.tscn")

enum CONFIRM_STATE{
	MAIN_MENU,
	QUIT
}

var confirm_state = CONFIRM_STATE.MAIN_MENU

func _ready():
	AudioManager.play_sound_effect("menu_back")
	close_menu_button.grab_focus()

func transition_out_animation():
	var scene_transition = scene_transition_scene.instantiate()
	self.add_child(scene_transition)
	scene_transition.play_animation("fade_in")
	await get_tree().create_timer(0.5).timeout

func _on_close_menu_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	queue_free()
	menu_closed.emit()

func update_confirm_container(state : CONFIRM_STATE):
	main_container.visible = false
	confirm_sub_container.visible = true
	confirm_state = state
	yes_button.grab_focus()

func _on_main_menu_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	update_confirm_container(CONFIRM_STATE.MAIN_MENU)


func _on_quit_game_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	update_confirm_container(CONFIRM_STATE.QUIT)


func _on_yes_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	match confirm_state:
		CONFIRM_STATE.MAIN_MENU:
			main_menu_selected.emit()
			transition_out_animation()
			get_tree().change_scene_to_file(main_menu_scene)
		CONFIRM_STATE.QUIT:
			get_tree().quit()


func _on_no_button_pressed() -> void:
	AudioManager.play_sound_effect("menu_confirm")
	confirm_sub_container.visible = false
	main_container.visible = true
	close_menu_button.grab_focus()
