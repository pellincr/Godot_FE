extends Control



@onready var animation_player: AnimationPlayer = $AnimationPlayer

const START_SCREEN_SCENE = preload("res://Main Game Scenes/Start Screen/start_screen.tscn")


func _ready() -> void:
	play_animation("fade_in")
	await  animation_player.animation_finished
	play_animation("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(START_SCREEN_SCENE)


func play_animation(animation):
	animation_player.play(animation)
